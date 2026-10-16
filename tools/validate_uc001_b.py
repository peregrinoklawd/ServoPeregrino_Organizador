#!/usr/bin/env python3
"""Static safety gates for Weapons UC-001-B R2. Not a SQF engine/runtime validation."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
M = ROOT / "missions" / "SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR"
F = M / "weapons" / "functions"
def contents(path):
    return path.read_text(encoding="utf-8")
resolver = contents(F / "catalog" / "fn_resolveAttachmentCompatibility.sqf")
compat = contents(F / "catalog" / "fn_getWeaponCompatibility.sqf")
legacy = contents(F / "catalog" / "fn_getUnderbarrelCompatibility.sqf")
semantic = contents(F / "domain" / "fn_validateWeaponConfigurationSemantic.sqf")
runner = contents(F / "tests" / "fn_runUC001BTests.sqf")
r5 = contents(F / "tests" / "fn_runDelivery0_7_ETests.sqf")
desc = contents(M / "description.ext")
init = contents(M / "initPlayerLocal.sqf")
version = contents(M / "weapons" / "script_version.hpp")
workflow = contents(ROOT / ".github" / "workflows" / "package-selfcontained-ui-lab.yml")
identity = contents(ROOT / "missions" / "PACKAGE_MISSION_NAME.txt").strip()
checks = []
def check(label, okay):
    checks.append((label, bool(okay)))
    print(("PASS" if okay else "FAIL") + " | " + label)

check("Build 0.7-F R1", '0.7.5.2-uc001-b-r2-legacy-source-contract-mission-first' in version)
check("Canonical resolver exists", len(resolver)>1000)
check("Canonical function registered", 'class resolveAttachmentCompatibility {};' in desc)
check("B runner registered", "class runUC001BTests {};" in desc)
check("B test action installed", "SP_ORG LAB - TESTAR UC-001-B R2" in init)
check("B test action invokes new runner", "fnc_runUC001BTests" in init)
check("B runner keeps R5 cumulative", "fnc_runDelivery0_7_ETests" in runner)
check("B R5 still expects 1446", "1446" in r5)
check("B runner explicitly expects 1516", "private _expected=1518;" in runner)
check("B runner covers all four slots", all('"'+x+'"' in runner for x in ["muzzle","pointer","optic","bipod"]))
check("B runner contains no physical mutation", not any(re.search(r"\b"+re.escape(cmd)+r"\b",re.sub(r"//[^\n]*","",runner),re.I) for cmd in ["setUnitLoadout","addPrimaryWeaponItem","addWeapon","createUnit"]))
check("Resolver covers all four fields", all('"'+x+'"' in resolver for x in ["muzzle","pointer","optic","bipod"]))
check("Resolver uses scoped engine source", "compatibleItems [_weapon,_engineSlot]" in resolver)
check("Resolver uses documented slot-filtered CBA source", '[_weapon,_cbaType] call CBA_fnc_compatibleItems' in resolver)
check("Optional CBA correctly detected", 'isNil "CBA_fnc_compatibleItems"' in resolver)
check("Scope/public CBA filter", 'getNumber (_cfg >> "scope")<2' in resolver)
check("Hashmap canonical case-insensitive dedup", 'toLowerANSI _canonical' in resolver)
check("Mission cache and per-class key", "AttachmentCompatibilityCache_UC001B_R1" in resolver and "toLowerANSI _weapon" in resolver)
check("Resolver logs only disagreement or initial resolve", "[COMPAT_SOURCE_DIFF]" in resolver and "[COMPAT_RESOLVE]" in resolver)
check("Catalog delegates to resolver", "fnc_resolveAttachmentCompatibility" in compat)
check("Legacy 0.3 catalog source marker restored", '["source","ENGINE_COMPATIBLE_COMMANDS"]' in compat)
check("New CBA provenance retained in dedicated source field", '["attachmentSources",_attachmentSources]' in compat)
check("R2 runner asserts legacy + modern metadata", "B R2 legacy compatibility source marker preserved" in runner and "B R2 four-field source metadata available" in runner)
check("Semantic delegates to resolver", "fnc_resolveAttachmentCompatibility" in semantic)
check("R4 underbarrel facade delegates to resolver", "fnc_resolveAttachmentCompatibility" in legacy)
check("Semantic logs incompatible item", "[COMPAT_REJECT]" in semantic)
check("Legacy R4 schema preserved", all('"'+x+'"' in legacy for x in ["items","engineCount","cbaAvailable","cbaCount","cbaAdded","cbaAddedCount","source"]))
check("Magazine rules intentionally unchanged", 'compatibleMagazines _weaponClass' in compat and 'compatibleMagazines [_weaponClass,_muzzle]' in compat)
check("No physical application code in resolver", not any(re.search(r"\b"+re.escape(cmd)+r"\b",re.sub(r"//[^\n]*","",resolver),re.I) for cmd in ["setUnitLoadout","addPrimaryWeaponItem","removeWeapon","addWeapon","createUnit","deleteVehicle","remoteExec"]))
check("Mission package name correct", identity == "SP_ORG_Weapons_UC_001_B_Unified_Attachments_R2.VR")
check("CI branch included", "feature/weapons-uc-001-b-unified-attachments" in workflow)
check("CI validation included", "tools/validate_uc001_b.py" in workflow)
check("Documentation exists", (ROOT / "docs" / "80_WEAPONS_UC001B_R1_UNIFIED_ATTACHMENTS.md").exists())
passed=sum(ok for _,ok in checks)
print(f"UC001B R2 STATIC SUMMARY passed={passed} failed={len(checks)-passed} total={len(checks)}")
sys.exit(0 if passed==len(checks) else 1)
