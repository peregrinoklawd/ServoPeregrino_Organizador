params [
    ["_className", "", [""]],
    ["_sourceConfig", "", [""]]
];

if (_className isEqualTo "") exitWith {
    [false, "ITEMS_CONTENT_CLASS_EMPTY", "Classe vazia não pode ser classificada.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _resolvedSource = _sourceConfig;
private _cfg = configNull;

if (_resolvedSource isEqualTo "") then {
    private _magCfg = configFile >> "CfgMagazines" >> _className;
    private _weaponCfg = configFile >> "CfgWeapons" >> _className;
    if (isClass _magCfg) then {
        _resolvedSource = "CfgMagazines";
        _cfg = _magCfg;
    } else {
        if (isClass _weaponCfg) then {
            _resolvedSource = "CfgWeapons";
            _cfg = _weaponCfg;
        };
    };
} else {
    if (_resolvedSource in ["CfgWeapons", "CfgMagazines"]) then {
        _cfg = configFile >> _resolvedSource >> _className;
    };
};

if !(isClass _cfg) exitWith {
    [
        true,
        "ITEMS_CONTENT_CLASS_UNAVAILABLE",
        "Classe não existe na sessão atual; identidade foi preservada como indisponível.",
        createHashMapFromArray [
            ["className", _className],
            ["sourceConfig", _resolvedSource],
            ["itemType", ["Unknown", "Unknown"]],
            ["category", "Unknown"],
            ["detail", "Unknown"],
            ["ownership", "RESERVED"],
            ["contentType", "UNKNOWN"],
            ["categoryId", "OTHER"],
            ["eligible", false],
            ["available", false],
            ["reason", "CLASS_NOT_FOUND"],
            ["classificationPath", "UNAVAILABLE"]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// CfgMagazines já é uma fonte tipada. Chamar BIS_fnc_itemType para cada magazine
// durante CONFIG_ALL custa caro e não acrescenta informação de ownership.
// Para CfgWeapons mantemos BIS_fnc_itemType como autoridade de compatibilidade.
private _classificationPath = if (_resolvedSource isEqualTo "CfgMagazines") then {"MAGAZINE_FAST"} else {"BIS_ITEMTYPE"};
private _itemType = if (_resolvedSource isEqualTo "CfgMagazines") then {
    ["Magazine", "Magazine"]
} else {
    [_className] call BIS_fnc_itemType
};

private _category = _itemType param [0, "Unknown", [""]];
private _detail = _itemType param [1, "Unknown", [""]];
private _ownership = "RESERVED";
private _contentType = "RESERVED";
private _reason = "UNSUPPORTED_OR_FOREIGN_DOMAIN";
private _eligible = false;

if (_resolvedSource isEqualTo "CfgMagazines") then {
    _ownership = "CONTENT_MAGAZINE";
    _contentType = "MAGAZINE";
    _reason = "MAGAZINE_CARGO";
    _eligible = true;
} else {
    if (_category isEqualTo "Item") then {
        _ownership = "CONTENT";
        _contentType = "ITEM";
        _reason = "ITEM_CARGO";
        _eligible = true;
    };
    if (_category isEqualTo "Magazine") then {
        _ownership = "CONTENT_MAGAZINE";
        _contentType = "MAGAZINE";
        _reason = "MAGAZINE_CARGO";
        _eligible = true;
    };
    if (_category isEqualTo "Weapon") then {
        _ownership = "RESERVED";
        _contentType = "RESERVED";
        _reason = "WEAPON_DOMAIN";
        _eligible = false;
    };
    if (_category isEqualTo "Equipment") then {
        _ownership = "RESERVED";
        _contentType = "RESERVED";
        _reason = "EQUIPMENT_DOMAIN";
        _eligible = false;
    };
};

private _categoryId = [_className, _resolvedSource, _itemType, _cfg] call ServoPeregrino_Organizador_Items_fnc_deriveCatalogCategory;

[
    true,
    "ITEMS_CONTENT_CLASS_CLASSIFIED",
    "Classe classificada pela política CONTENT central do SP_ORG_Items.",
    createHashMapFromArray [
        ["className", _className],
        ["sourceConfig", _resolvedSource],
        ["itemType", +_itemType],
        ["category", _category],
        ["detail", _detail],
        ["ownership", _ownership],
        ["contentType", _contentType],
        ["categoryId", _categoryId],
        ["eligible", _eligible],
        ["available", true],
        ["reason", _reason],
        ["classificationPath", _classificationPath]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
