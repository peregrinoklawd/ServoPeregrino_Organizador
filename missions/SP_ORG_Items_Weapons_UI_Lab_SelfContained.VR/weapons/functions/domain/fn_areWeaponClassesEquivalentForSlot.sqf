params [
 ["_left","",[""]],
 ["_right","",[""]],
 ["_slot","PRIMARY",[""]]
];

private _slotName = toUpperANSI _slot;
if !(_slotName in ["PRIMARY","SECONDARY","HANDGUN"]) exitWith {
 [false,"WEAPONS_CLASS_EQUIVALENCE_SLOT_INVALID","Expected PRIMARY, SECONDARY or HANDGUN."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if (_left isEqualTo "" || {_right isEqualTo ""}) exitWith {
 [true,"WEAPONS_CLASS_EQUIVALENCE","Empty class is never equivalent.",createHashMapFromArray [
  ["equivalent",false],["mode","EMPTY"],["slot",_slotName]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if ((toLowerANSI _left) isEqualTo (toLowerANSI _right)) exitWith {
 [true,"WEAPONS_CLASS_EQUIVALENCE","Exact class match.",createHashMapFromArray [
  ["equivalent",true],["mode","EXACT"],["slot",_slotName],["left",_left],["right",_right]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !(_slotName isEqualTo "SECONDARY") exitWith {
 [true,"WEAPONS_CLASS_EQUIVALENCE","Non-secondary slots require exact class match.",createHashMapFromArray [
  ["equivalent",false],["mode","STRICT_SLOT"],["slot",_slotName],["left",_left],["right",_right]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _leftCfg = configFile >> "CfgWeapons" >> _left;
private _rightCfg = configFile >> "CfgWeapons" >> _right;
if !(isClass _leftCfg && {isClass _rightCfg}) exitWith {
 [true,"WEAPONS_CLASS_EQUIVALENCE","Unknown weapon class cannot be family-equivalent.",createHashMapFromArray [
  ["equivalent",false],["mode","UNKNOWN_CLASS"],["slot",_slotName],["left",_left],["right",_right]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !(getNumber (_leftCfg >> "type") isEqualTo 4 && {getNumber (_rightCfg >> "type") isEqualTo 4}) exitWith {
 [true,"WEAPONS_CLASS_EQUIVALENCE","Only SECONDARY type=4 classes may use family equivalence.",createHashMapFromArray [
  ["equivalent",false],["mode","TYPE_MISMATCH"],["slot",_slotName],["left",_left],["right",_right]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _familyOf = {
 params ["_cfg"];
 private _class = configName _cfg;
 private _base = getText (_cfg >> "baseWeapon");
 if (_base isEqualTo "") then {_base = _class};
 toLowerANSI _base
};

private _leftFamily = [_leftCfg] call _familyOf;
private _rightFamily = [_rightCfg] call _familyOf;
private _equivalent = _leftFamily isEqualTo _rightFamily;

[true,"WEAPONS_CLASS_EQUIVALENCE","SECONDARY class family comparison completed.",createHashMapFromArray [
 ["equivalent",_equivalent],
 ["mode",if (_equivalent) then {"SECONDARY_BASEWEAPON_FAMILY"} else {"DIFFERENT_FAMILY"}],
 ["slot",_slotName],
 ["left",configName _leftCfg],
 ["right",configName _rightCfg],
 ["leftFamily",_leftFamily],
 ["rightFamily",_rightFamily]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
