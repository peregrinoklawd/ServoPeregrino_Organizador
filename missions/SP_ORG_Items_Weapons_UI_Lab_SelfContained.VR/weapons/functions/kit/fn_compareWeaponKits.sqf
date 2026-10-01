params [["_left",false],["_right",false]];
private _a = [_left] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_a get "success") exitWith {_a};
private _b = [_right] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_b get "success") exitWith {_b};
private _leftKit = (_a get "data") get "kit";
private _rightKit = (_b get "data") get "kit";

private _afp = [_leftKit] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKitContentFingerprint;
if !(_afp get "success") exitWith {_afp};
private _bfp = [_rightKit] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKitContentFingerprint;
if !(_bfp get "success") exitWith {_bfp};

[true,"WEAPONS_KIT_COMPARISON","WeaponKit identity, name and content compared separately.",createHashMapFromArray [
 ["sameIdentity",(_leftKit get "kitId") isEqualTo (_rightKit get "kitId")],
 ["sameName",(toLowerANSI (_leftKit get "name")) isEqualTo (toLowerANSI (_rightKit get "name"))],
 ["sameContent",((_afp get "data") get "fingerprint") isEqualTo ((_bfp get "data") get "fingerprint")]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
