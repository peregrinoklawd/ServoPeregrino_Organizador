params [["_value",false]];
private _error = "";
if !(_value isEqualType createHashMap) exitWith {[false,"WEAPONS_CONFIGURATION_PAYLOAD_INVALID","Expected HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _keys = ["schemaVersion","weaponClass","muzzle","pointer","optic","bipod"];
if !((count _value) isEqualTo count _keys && {{_x in _value} count _keys isEqualTo count _keys}) exitWith {
 [false,"WEAPONS_CONFIGURATION_FIELDS_INVALID","Closed candidate schema; missing/unknown fields. Loaded magazine/ammo state is not WeaponConfiguration."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_value get "schemaVersion") isEqualTo "0.2-candidate") exitWith {[false,"WEAPONS_SCHEMA_INCOMPATIBLE","Candidate schema mismatch."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
{
 if !((_value get _x) isEqualType "") then {_error = "WEAPONS_CONFIGURATION_TYPE_INVALID"};
} forEach ["weaponClass","muzzle","pointer","optic","bipod"];
if !(_error isEqualTo "") exitWith {[false,_error,"Class fields must be strings."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if ((_value get "weaponClass") isEqualTo "") exitWith {[false,"WEAPONS_CLASS_INVALID","Empty weapon class."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"WEAPONS_CONFIGURATION_VALID","Structural validation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
