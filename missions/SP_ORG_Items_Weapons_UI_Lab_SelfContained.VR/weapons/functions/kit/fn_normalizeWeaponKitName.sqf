params [["_name","",[""]]];

private _chars = toArray _name;
private _ws = [9,10,13,32];

while {count _chars > 0 && {(_chars select 0) in _ws}} do {
 _chars deleteAt 0;
};
while {count _chars > 0 && {(_chars select ((count _chars) - 1)) in _ws}} do {
 _chars deleteAt ((count _chars) - 1);
};

private _normalized = toString _chars;
if (_normalized isEqualTo "") exitWith {
 [false,"WEAPONS_KIT_NAME_EMPTY","WeaponKit name must contain at least one non-whitespace character."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (count _normalized > 64) exitWith {
 [false,"WEAPONS_KIT_NAME_TOO_LONG","WeaponKit name is limited to 64 characters."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_KIT_NAME_NORMALIZED","WeaponKit name normalized.",createHashMapFromArray [
 ["name",_normalized]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
