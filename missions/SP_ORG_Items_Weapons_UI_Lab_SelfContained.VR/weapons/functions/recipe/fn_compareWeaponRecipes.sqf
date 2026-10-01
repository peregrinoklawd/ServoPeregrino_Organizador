params [["_left",false],["_right",false]];
private _a = [_left] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint;
if !(_a get "success") exitWith {_a};
private _b = [_right] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint;
if !(_b get "success") exitWith {_b};

[true,"WEAPONS_RECIPE_COMPARISON","Recipe equality compares desired build content; it is not physical weapon identity.",createHashMapFromArray [
 ["equal",((_a get "data") get "fingerprint") isEqualTo ((_b get "data") get "fingerprint")]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
