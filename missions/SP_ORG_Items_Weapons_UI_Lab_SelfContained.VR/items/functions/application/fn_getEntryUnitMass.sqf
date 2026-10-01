params [["_entry", [], [[]]]];
if !(_entry isEqualType [] && {(count _entry) >= 6}) exitWith {createHashMapFromArray [["known", false], ["mass", 0]]};
private _type = _entry # 1;
private _className = _entry # 2;
private _mass = 0;
if (_type isEqualTo "MAGAZINE") then {
    private _cfg = configFile >> "CfgMagazines" >> _className;
    if (isClass _cfg) then {_mass = getNumber (_cfg >> "mass");};
} else {
    private _cfg = configFile >> "CfgWeapons" >> _className;
    if (isClass _cfg) then {
        _mass = getNumber (_cfg >> "ItemInfo" >> "mass");
        if (_mass <= 0) then {_mass = getNumber (_cfg >> "mass");};
    };
};
createHashMapFromArray [["known", _mass > 0], ["mass", _mass max 0], ["className", _className]]
