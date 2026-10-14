#!/usr/bin/env python3
"""Static safety/packaging checks for mission-first UC-001-A (not an SQF compiler)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
MISSION = ROOT / "missions" / "SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR"
AUDIT = MISSION / "weapons" / "functions" / "tests" / "fn_auditUC001ASources.sqf"
CODE = AUDIT.read_text(encoding="utf-8")
DESCRIPTION = (MISSION / "description.ext").read_text(encoding="utf-8")
INIT = (MISSION / "initPlayerLocal.sqf").read_text(encoding="utf-8")
R5 = (MISSION / "weapons" / "functions" / "tests" / "fn_runDelivery0_7_ETests.sqf").read_text(encoding="utf-8")
VERSION = (MISSION / "weapons" / "script_version.hpp").read_text(encoding="utf-8")
WORKFLOW = (ROOT / ".github" / "workflows" / "package-selfcontained-ui-lab.yml").read_text(encoding="utf-8")
PACKAGE = (ROOT / "missions" / "PACKAGE_MISSION_NAME.txt").read_text(encoding="utf-8").strip()
checks = []

def check(label: str, condition: bool) -> None:
    checks.append((label, bool(condition)))
    print(("PASS" if condition else "FAIL") + " | " + label)

check("Baseline R5 build kept", '0.7.4.5-pending-save-as-new-e1-r5-mission-first' in VERSION)
check("R5 cumulative runner kept", "MISSION_FIRST_0_7_E_R5" in R5)
check("R5 runner still expects 1446", "1446" in R5)
check("UC001A function registered", "class auditUC001ASources {};" in DESCRIPTION)
check("UC001A diagnostic source present", AUDIT.is_file())
check("UC001A action exposed", "SP_ORG LAB - AUDITAR FONTES UC-001-A" in INIT)
check("UC001A action resolves function", "ServoPeregrino_Organizador_Weapons_fnc_auditUC001ASources" in INIT)
check("UC001A checks every weapon slot", '["PRIMARY","HANDGUN","SECONDARY"]' in INIT)
check("Audit source snapshots equipment", "fnc_getEquipmentSlotSnapshot" in CODE)
check("Audits all 4 attachment types", all(f'"{i}"' in CODE for i in ("muzzle", "pointer", "optic", "bipod")))
check("Probes per-slot engine source", "compatibleItems [_weapon,_engineSlot]" in CODE)
check("CBA attachment source guarded", 'isNil "CBA_fnc_compatibleItems"' in CODE)
check("CBA magazine source guarded", 'isNil "CBA_fnc_compatibleMagazines"' in CODE)
check("Muzzle-scoped magazine audit", "compatibleMagazines [_weapon,_muzzle]" in CODE)
check("Reports magazine wells", '"magazineWell"' in CODE)
check("Reports physical loadout invariant", '"loadoutUnchanged"' in CODE)
check("Has source diff logs", "[UC001A_SOURCE]" in CODE)
check("Has magazine logs", "[UC001A_MAGAZINE]" in CODE)
check("Has explicit summary logs", "[UC001A_SUMMARY]" in CODE)
check("Has robust missing CBA result", "cbaItemsAvailable" in CODE and "cbaMagazinesAvailable" in CODE)
EXECUTABLE = re.sub(r"//[^\n]*", "", CODE)
for cmd in ("setUnitLoadout", "addMagazine", "addItemToVest", "removeMagazine",
            "setVariable", "createUnit", "createVehicle", "remoteExec", "setPos", "deleteVehicle"):
    # This file may read mission state through other read-only functions.
    check("No mutation command: " + cmd, not re.search(r"\b" + re.escape(cmd) + r"\b", EXECUTABLE, re.I))
check("Mission package identity set", PACKAGE == "SP_ORG_Weapons_UC_001_A_Source_Audit_R1.VR")
check("Workflow includes UC-001-A branch", "feature/weapons-uc-001-a-compatibility-audit" in WORKFLOW)
check("Workflow validates UC001A", "tools/validate_uc001_a.py" in WORKFLOW)
check("Backlog documented", (ROOT / "docs" / "77_WEAPONS_BACKLOG_AMMO_VEST_ICON_FILTERS.md").is_file())
check("Audit documentation present", (ROOT / "docs" / "78_WEAPONS_UC_001_A_SOURCE_AUDIT.md").is_file())

passed = sum(ok for _, ok in checks)
failed = len(checks) - passed
print(f"UC001A STATIC SUMMARY passed={passed} failed={failed} total={len(checks)}")
sys.exit(0 if failed == 0 else 1)
