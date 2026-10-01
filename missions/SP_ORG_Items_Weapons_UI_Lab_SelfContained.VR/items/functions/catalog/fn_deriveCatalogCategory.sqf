params [
    ["_className", "", [""]],
    ["_sourceConfig", "", [""]],
    ["_itemType", ["Unknown", "Unknown"], [[]]],
    ["_cfg", configNull]
];

private _classLower = toLower _className;
private _displayLower = "";
if (isClass _cfg) then {
    _displayLower = toLower (getText (_cfg >> "displayName"));
};
private _detailLower = toLower (_itemType param [1, "Unknown", [""]]);
private _searchText = format ["%1 %2 %3", _classLower, _displayLower, _detailLower];

if (_sourceConfig isEqualTo "CfgMagazines") exitWith {
    private _explosiveTokens = ["mine", "charge", "satchel", "ied", "explosive", "claymore", "slam", "tripwire"];
    private _isExplosive = (_explosiveTokens findIf {(_searchText find _x) >= 0}) >= 0;
    if (_isExplosive) exitWith {"EXPLOSIVES"};

    private _grenadeTokens = ["grenade", "smoke", "flare", "chemlight", "chem", "handgrenade"];
    private _isGrenade = (_grenadeTokens findIf {(_searchText find _x) >= 0}) >= 0;
    if (_isGrenade) exitWith {"GRENADES"};

    "MAGAZINES"
};

private _medicalTokens = [
    "firstaid", "medikit", "medical", "bandage", "morphine", "epinephrine",
    "tourniquet", "splint", "plasma", "blood", "saline", "guedel", "surgical",
    "aed", "iv_", "ivbag", "painkiller"
];
if ((_medicalTokens findIf {(_searchText find _x) >= 0}) >= 0) exitWith {"MEDICAL"};

private _foodTokens = ["food", "ration", "mre", "meal", "water", "drink", "canteen", "bottle", "snack"];
if ((_foodTokens findIf {(_searchText find _x) >= 0}) >= 0) exitWith {"FOOD"};

private _toolTokens = ["toolkit", "tool", "wirecutter", "entrench", "clacker", "detonator", "multitool"];
if ((_toolTokens findIf {(_searchText find _x) >= 0}) >= 0) exitWith {"TOOLS"};

"OTHER"
