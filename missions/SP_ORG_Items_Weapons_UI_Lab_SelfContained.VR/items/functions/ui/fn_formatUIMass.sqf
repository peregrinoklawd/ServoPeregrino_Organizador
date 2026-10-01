#include "..\..\script_version.hpp"

/*
    Converts Arma inventory mass units to the player-facing convention used by
    the vanilla inventory: 10 mass units = 1 lb; kg derives from the exact
    lb->kg conversion. Internal application/capacity math remains in mass units.
*/
params [
    ["_mass",0,[0]],
    ["_includeImperial",false,[true]],
    ["_decimals",2,[0]]
];

private _safeMass=_mass max 0;
private _digits=(_decimals max 0) min 3;
private _kg=(_safeMass/22.0462262185);
private _lb=(_safeMass/10);
private _kgText=_kg toFixed _digits;
if (!_includeImperial) exitWith {format ["%1 kg",_kgText]};
format ["%1 kg (%2 lb)",_kgText,_lb toFixed _digits]
