params [["_kitId","",[""]],["_newName","",[""]]];
private _sourceResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_sourceResult get "success") exitWith {_sourceResult};
private _source = (_sourceResult get "data") get "kit";

[_newName,_source get "targetSlot",_source get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit
