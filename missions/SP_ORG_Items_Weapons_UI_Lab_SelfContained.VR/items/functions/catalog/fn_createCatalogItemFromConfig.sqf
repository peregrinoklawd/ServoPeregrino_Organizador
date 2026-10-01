params [
    ["_className", "", [""]],
    ["_sourceConfig", "", [""]]
];

private _classification = [_className, _sourceConfig] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
if !(_classification getOrDefault ["success", false]) exitWith {_classification};
private _cd = _classification getOrDefault ["data", createHashMap];

if !(_cd getOrDefault ["available", false]) exitWith {
    [
        true,
        "ITEMS_CATALOG_ITEM_RESOLVED_UNAVAILABLE",
        "Classe preservada como referência indisponível.",
        createHashMapFromArray [["item", createHashMapFromArray [
            ["className", _className],
            ["displayName", _className],
            ["picture", ""],
            ["addon", ""],
            ["contentType", "UNKNOWN"],
            ["categoryId", "OTHER"],
            ["massEstimate", 0],
            ["magazineCapacity", 0],
            ["available", false],
            ["unavailableReason", "CLASS_NOT_FOUND"],
            ["sourceConfig", _sourceConfig],
            ["eligible", false],
            ["itemType", ["Unknown", "Unknown"]]
        ]]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _resolvedSource = _cd getOrDefault ["sourceConfig", _sourceConfig];
private _cfg = configFile >> _resolvedSource >> _className;
private _displayName = getText (_cfg >> "displayName");
private _picture = getText (_cfg >> "picture");
private _addons = configSourceAddonList _cfg;
private _addon = _addons param [0, "", [""]];
private _mass = getNumber (_cfg >> "mass");
if (_resolvedSource isEqualTo "CfgWeapons") then {
    private _itemInfoMass = getNumber (_cfg >> "ItemInfo" >> "mass");
    if (_itemInfoMass > 0) then {_mass = _itemInfoMass;};
};
private _magazineCapacity = if (_resolvedSource isEqualTo "CfgMagazines") then {getNumber (_cfg >> "count")} else {0};

private _item = createHashMapFromArray [
    ["className", _className],
    ["displayName", if (_displayName isEqualTo "") then {_className} else {_displayName}],
    ["picture", _picture],
    ["addon", _addon],
    ["contentType", _cd getOrDefault ["contentType", "UNKNOWN"]],
    ["categoryId", _cd getOrDefault ["categoryId", "OTHER"]],
    ["massEstimate", _mass],
    ["magazineCapacity", _magazineCapacity],
    ["available", true],
    ["unavailableReason", if (_cd getOrDefault ["eligible", false]) then {""} else {_cd getOrDefault ["reason", "NOT_CONTENT_DOMAIN"]}],
    ["sourceConfig", _resolvedSource],
    ["eligible", _cd getOrDefault ["eligible", false]],
    ["itemType", +(_cd getOrDefault ["itemType", ["Unknown", "Unknown"]])]
];

[
    true,
    if (_item getOrDefault ["eligible", false]) then {"ITEMS_CATALOG_ITEM_CREATED"} else {"ITEMS_CATALOG_ITEM_FOREIGN_DOMAIN"},
    "Metadados runtime do item foram resolvidos a partir dos configs atuais.",
    createHashMapFromArray [["item", _item]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
