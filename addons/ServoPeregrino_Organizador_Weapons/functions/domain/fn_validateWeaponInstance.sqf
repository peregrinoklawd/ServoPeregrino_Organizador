params [["_value",false]];
if !(_value isEqualType createHashMap) exitWith {[false,"WEAPONS_INSTANCE_PAYLOAD_INVALID","Expected HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _keys = ["schemaVersion","instanceId","serial","weaponClass","configuration","metadata","createdAt","updatedAt"];
if !(count _value isEqualTo count _keys && {{_x in _value} count _keys isEqualTo count _keys}) exitWith {[false,"WEAPONS_INSTANCE_FIELDS_INVALID","Closed schema; no other domain state."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !((_value get "schemaVersion") isEqualTo "0.1-A-candidate") exitWith {[false,"WEAPONS_SCHEMA_INCOMPATIBLE","Candidate schema mismatch."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !([_value get "instanceId","WID-"] call ServoPeregrino_Organizador_Weapons_fnc_isValidIdentityToken) exitWith {[false,"WEAPONS_INSTANCE_ID_INVALID","Invalid instanceId."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !([_value get "serial","SPW-"] call ServoPeregrino_Organizador_Weapons_fnc_isValidIdentityToken) exitWith {[false,"WEAPONS_SERIAL_INVALID","Invalid serial."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _valid = [_value get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_valid get "success") exitWith {_valid};
if !((toLowerANSI (_value get "weaponClass")) isEqualTo (toLowerANSI (((_value get "configuration") get "weaponClass")))) exitWith {[false,"WEAPONS_CLASS_MISMATCH","Instance and configuration classes differ."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _meta = _value get "metadata";
if !(_meta isEqualType createHashMap) exitWith {[false,"WEAPONS_METADATA_INVALID","Expected closed metadata."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(count _meta isEqualTo 2 && {(_meta getOrDefault ["scope",""]) isEqualTo "SESSION"} && {(_meta getOrDefault ["authority",""]) isEqualTo "SERVER"}) exitWith {[false,"WEAPONS_METADATA_INVALID","Only scope/authority allowed in candidate metadata."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _badTime = ["createdAt","updatedAt"] findIf {
 private _t = _value get _x;
 !(_t isEqualType [] && {count _t isEqualTo 7} && {{_x isEqualType 0} count _t isEqualTo 7})
};
if (_badTime >= 0) exitWith {[false,"WEAPONS_TIMESTAMP_INVALID","Expected systemTimeUTC arrays."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"WEAPONS_INSTANCE_VALID","Candidate instance valid; physical binding not implied."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
