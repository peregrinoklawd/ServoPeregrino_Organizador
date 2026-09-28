params [["_value",false]];
private _error = "";
if !(_value isEqualType createHashMap) exitWith {[false,"WEAPONS_CONFIGURATION_PAYLOAD_INVALID","Expected HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _keys = ["schemaVersion","weaponClass","muzzle","pointer","optic","bipod","primaryMagazine","secondaryMagazine"];
if !((count _value) isEqualTo count _keys && {{_x in _value} count _keys isEqualTo count _keys}) exitWith {
 [false,"WEAPONS_CONFIGURATION_FIELDS_INVALID","Closed candidate schema; missing/unknown fields."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_value get "schemaVersion") isEqualTo "0.1-A-candidate") exitWith {[false,"WEAPONS_SCHEMA_INCOMPATIBLE","Candidate schema mismatch."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
{
 if !((_value get _x) isEqualType "") then {_error = "WEAPONS_CONFIGURATION_TYPE_INVALID"};
} forEach ["weaponClass","muzzle","pointer","optic","bipod"];
if !(_error isEqualTo "") exitWith {[false,_error,"Class fields must be strings."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if ((_value get "weaponClass") isEqualTo "") exitWith {[false,"WEAPONS_CLASS_INVALID","Empty weapon class."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
{
 private _mag = _value get _x;
 if !(_mag isEqualType []) then {_error = "WEAPONS_MAGAZINE_INVALID"} else {
  if !(_mag isEqualTo []) then {
   if !(count _mag isEqualTo 2) then {_error = "WEAPONS_MAGAZINE_INVALID"} else {
    if !((_mag select 0) isEqualType "" && {(_mag select 0) != ""} && {(_mag select 1) isEqualType 0}) then {_error = "WEAPONS_MAGAZINE_INVALID"} else {
     private _ammo = _mag select 1;
     if !(finite _ammo && {_ammo >= 0} && {_ammo isEqualTo floor _ammo}) then {_error = "WEAPONS_AMMO_INVALID"};
    };
   };
  };
 };
} forEach ["primaryMagazine","secondaryMagazine"];
[_error isEqualTo "",if (_error isEqualTo "") then {"WEAPONS_CONFIGURATION_VALID"} else {_error},"Structural validation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
