"""P0 Policy reference oracle: NOT an SQF engine test.

Run from repo root:
    python -m unittest discover -s tools/policy -p 'test_*.py' -v
"""
from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

FIXTURES = (
    Path(__file__).resolve().parents[2]
    / "machine"
    / "policy"
    / "p0_contract_fixtures_v1.json"
)
CLASSNAME = re.compile(r"[A-Za-z0-9_]{1,128}\Z", re.ASCII)
FIELDS = frozenset(("schema", "schemaVersion", "whitelist", "blacklist"))
MAX_LIST = 4096
MAX_BYTES = 512 * 1024


def validate_export(payload: object) -> bool:
    if type(payload) is not dict or set(payload) != FIELDS:
        return False
    if payload["schema"] != "SPORG_POLICY_EXPORT":
        return False
    if type(payload["schemaVersion"]) is not int or payload["schemaVersion"] != 1:
        return False
    for field in ("whitelist", "blacklist"):
        items = payload[field]
        if type(items) is not list or len(items) > MAX_LIST:
            return False
        seen: set[str] = set()
        for raw in items:
            if type(raw) is not str:
                return False
            name = raw.strip()
            if not CLASSNAME.fullmatch(name):
                return False
            key = name.lower()
            if key in seen:
                return False
            seen.add(key)
    encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    return len(encoded.encode("utf-8")) <= MAX_BYTES


def decide(whitelist: list[str], blacklist: list[str], class_name: str) -> tuple[bool, str]:
    query = class_name.lower()
    white = {name.strip().lower() for name in whitelist}
    black = {name.strip().lower() for name in blacklist}
    if query in black:
        return False, "POLICY_DENY_BLACKLIST"
    if white and query not in white:
        return False, "POLICY_DENY_NOT_WHITELIST"
    if white:
        return True, "POLICY_ALLOW_WHITELIST"
    return True, "POLICY_ALLOW_OPEN"


def normalize_export(payload: dict) -> dict:
    """Preserve class spelling; stable ordering for semantically stable snapshots."""
    return {
        "schema": "SPORG_POLICY_EXPORT",
        "schemaVersion": 1,
        "whitelist": sorted((s.strip() for s in payload["whitelist"]), key=str.lower),
        "blacklist": sorted((s.strip() for s in payload["blacklist"]), key=str.lower),
    }


def readiness(state: str, required: bool) -> tuple[bool, str]:
    if state == "ABSENT" and not required:
        return True, "POLICY_ALLOW_OPEN"
    if state == "INVALID":
        return False, "POLICY_INVALID"
    if state in ("PENDING", "ABSENT"):
        return False, "POLICY_NOT_READY"
    raise ValueError("Readiness reference only models inactive states")


class PolicyP0Contracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.fixture = json.loads(FIXTURES.read_text(encoding="utf-8"))
        assert cls.fixture["schema"] == "SPORG_POLICY_P0_FIXTURES"

    def test_decision_matrix(self) -> None:
        for case in self.fixture["decisionCases"]:
            with self.subTest(case=case["id"]):
                self.assertEqual(
                    decide(case["whitelist"], case["blacklist"], case["className"]),
                    (case["allowed"], case["code"]),
                )

    def test_portable_payload_validation(self) -> None:
        for case in self.fixture["validationCases"]:
            with self.subTest(case=case["id"]):
                self.assertEqual(validate_export(case["data"]), case["valid"])

    def test_fail_closed_readiness(self) -> None:
        for case in self.fixture["readinessCases"]:
            with self.subTest(case=case["id"]):
                self.assertEqual(
                    readiness(case["state"], case["required"]),
                    (case["allowed"], case["code"]),
                )

    def test_environment_is_independent(self) -> None:
        for case in self.fixture["environmentCases"]:
            with self.subTest(case=case["id"]):
                self.assertEqual(
                    case["policyAllowed"] and case["environmentPresent"],
                    case["mayAdd"],
                )
                self.assertTrue(case["preservePersistedEntry"])

    def test_json_semantic_roundtrip(self) -> None:
        source = {
            "schema": "SPORG_POLICY_EXPORT",
            "schemaVersion": 1,
            "whitelist": ["itemGPS", "FirstAidKit"],
            "blacklist": ["ItemGPS"],
        }
        self.assertTrue(validate_export(source))
        canonical = normalize_export(source)
        payload = json.dumps(canonical, ensure_ascii=False)
        imported = json.loads(payload)
        self.assertTrue(validate_export(imported))
        self.assertEqual(normalize_export(imported), canonical)
        self.assertEqual(decide(imported["whitelist"], imported["blacklist"], "ItemGPS")[0], False)

    def test_no_extra_authority_fields(self) -> None:
        base = {"schema": "SPORG_POLICY_EXPORT", "schemaVersion": 1, "whitelist": [], "blacklist": []}
        for injection in ("revision", "fingerprint", "source", "isAdmin", "admin"):
            with self.subTest(key=injection):
                self.assertFalse(validate_export({**base, injection: 1}))

    def test_bad_boundaries(self) -> None:
        template = {"schema": "SPORG_POLICY_EXPORT", "schemaVersion": 1, "whitelist": [], "blacklist": []}
        for invalid in ([None], [1], ["a.b"], ["Bad Class"], ["a;exec"], ["-StartsWithPunctuation"], [""]):
            with self.subTest(classname=invalid):
                self.assertFalse(validate_export({**template, "blacklist": invalid}))
        self.assertFalse(validate_export({**template, "whitelist": ["A"] * (MAX_LIST + 1)}))

    def test_numeric_prefix_real_classnames(self) -> None:
        """G2 RPT: actual config classes whose first character is a digit."""
        template = {"schema": "SPORG_POLICY_EXPORT", "schemaVersion": 1, "whitelist": [], "blacklist": []}
        for classname in ("30Rnd_556x45_Stanag", "121_SP10M_18_FDE", "1st_pack_1", "1StartsWithDigit"):
            with self.subTest(classname=classname):
                self.assertTrue(validate_export({**template, "whitelist": [classname]}))
        self.assertFalse(validate_export({**template, "whitelist": ["30Rnd_556x45_Stanag;call compile evil"]}))


if __name__ == "__main__":
    unittest.main()
