params [
    ["_query", "", [""]],
    ["_categoryId", "ALL", [""]]
];

private _categories = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogCategories;
private _category = toUpper _categoryId;
if !(_category in _categories) exitWith {
    [false, "ITEMS_CATALOG_CATEGORY_INVALID", "Categoria de catálogo inválida.", createHashMapFromArray [["categoryId", _categoryId], ["allowed", _categories]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _catalogResult = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
if !(_catalogResult getOrDefault ["success", false]) exitWith {_catalogResult};
private _catalogData = _catalogResult getOrDefault ["data", createHashMap];
private _items = _catalogData getOrDefault ["items", []];
private _needle = toLower _query;

private _filtered = _items select {
    private _item = _x;
    private _categoryMatch = (_category isEqualTo "ALL") || {(_item getOrDefault ["categoryId", "OTHER"]) isEqualTo _category};
    private _queryMatch = true;
    if (_needle isNotEqualTo "") then {
        private _haystack = toLower format [
            "%1 %2 %3 %4",
            _item getOrDefault ["className", ""],
            _item getOrDefault ["displayName", ""],
            _item getOrDefault ["addon", ""],
            _item getOrDefault ["categoryId", ""]
        ];
        _queryMatch = (_haystack find _needle) >= 0;
    };
    _categoryMatch && {_queryMatch}
};

[
    true,
    "ITEMS_CATALOG_FILTERED",
    "Busca/filtro executados somente sobre o cache runtime; configs não foram revarridos.",
    createHashMapFromArray [
        ["query", _query],
        ["categoryId", _category],
        ["items", _filtered],
        ["count", count _filtered],
        ["baseCount", count _items]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
