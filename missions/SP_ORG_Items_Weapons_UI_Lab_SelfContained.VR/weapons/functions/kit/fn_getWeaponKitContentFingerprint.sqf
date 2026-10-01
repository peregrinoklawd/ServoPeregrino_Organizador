params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_normal get "success") exitWith {_normal};
private _kit = (_normal get "data") get "kit";

private _recipeFp = [_kit get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint;
if !(_recipeFp get "success") exitWith {_recipeFp};

private _fingerprint = str [
 "0.5-kit-content-candidate",
 toLowerANSI (_kit get "targetSlot"),
 (_recipeFp get "data") get "fingerprint"
];

[true,"WEAPONS_KIT_CONTENT_FINGERPRINT","WeaponKit content fingerprint excludes kitId and name; it is not WeaponInstance identity.",createHashMapFromArray [
 ["fingerprint",_fingerprint]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
