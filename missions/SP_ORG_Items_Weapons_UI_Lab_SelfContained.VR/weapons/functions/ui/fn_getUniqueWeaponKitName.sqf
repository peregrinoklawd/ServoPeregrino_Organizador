#include "..\..\script_version.hpp"
params [["_baseName","",[""]]];

private _raw = _baseName;
if ((count _raw) > 64) then {_raw = toString ((toArray _raw) select [0,64])};
private _normalizedR = [_raw] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
if !(_normalizedR get "success") exitWith {_normalizedR};
private _base = (_normalizedR get "data") get "name";

private _listR = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
if !(_listR get "success") exitWith {_listR};
private _used = ((_listR get "data") getOrDefault ["kits",[]]) apply {toLowerANSI (_x getOrDefault ["name",""])};

private _candidate = _base;
private _counter = 2;
while {(toLowerANSI _candidate) in _used && {_counter <= 9999}} do {
 private _suffix = format [" (%1)",_counter];
 private _maxBase = (64 - count _suffix) max 1;
 private _shortBase = toString ((toArray _base) select [0,_maxBase]);
 _candidate = _shortBase + _suffix;
 _counter = _counter + 1;
};
if ((toLowerANSI _candidate) in _used) exitWith {
 [false,"WEAPONS_UI_UNIQUE_NAME_EXHAUSTED","Could not derive a unique WeaponKit name."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_UI_UNIQUE_NAME","Unique WeaponKit name resolved without repository mutation.",createHashMapFromArray [["name",_candidate]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
