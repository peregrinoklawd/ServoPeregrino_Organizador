#include "..\..\script_version.hpp"
params [
    ["_query", "", [""]],
    ["_categoryId", "ALL", [""]],
    ["_offset", 0, [0]],
    ["_window", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE, [0]]
];

private _startedAt = diag_tickTime;
private _categories = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogCategories;
private _category = toUpper _categoryId;
if !(_category in _categories) exitWith {
    [false,"ITEMS_UI_CATALOG_CATEGORY_INVALID","Categoria de catálogo inválida para a projeção focal da UI.",createHashMapFromArray [["categoryId",_categoryId],["allowed",_categories]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cache = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap];
private _items = _cache getOrDefault ["items",[]];
private _cacheBuilt = (_cache getOrDefault ["provider",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER
    && {(_cache getOrDefault ["buildKey",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD};
if (!_cacheBuilt) exitWith {
    [false,"ITEMS_UI_CATALOG_CACHE_NOT_READY","Cache CONFIG_ALL ainda não está pronto para a projeção focal da UI.",createHashMapFromArray [["itemCount",count _items]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _sourceKey = format ["%1|%2|%3",_cache getOrDefault ["buildKey",""],count _items,str (_cache getOrDefault ["builtAtUTC",[]])];
private _projection = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap];
private _indexBuildMs = 0;
private _indexBuiltNow = false;
if ((_projection getOrDefault ["sourceKey",""]) isNotEqualTo _sourceKey) then {
    private _indexStartedAt = diag_tickTime;
    private _byCategory = createHashMap;
    { _byCategory set [_x,[]]; } forEach _categories;
    {
        private _idx = _forEachIndex;
        private _all = _byCategory getOrDefault ["ALL",[]];
        _all pushBack _idx;
        _byCategory set ["ALL",_all];
        private _cat = _x getOrDefault ["categoryId","OTHER"];
        if !(_cat in _categories) then {_cat = "OTHER";};
        if (_cat isNotEqualTo "ALL") then {
            private _arr = _byCategory getOrDefault [_cat,[]];
            _arr pushBack _idx;
            _byCategory set [_cat,_arr];
        };
    } forEach _items;
    _indexBuildMs = round ((diag_tickTime-_indexStartedAt)*1000);
    _projection = createHashMapFromArray [
        ["sourceKey",_sourceKey],
        ["byCategory",_byCategory],
        ["itemCount",count _items],
        ["builtAtTick",diag_tickTime],
        ["buildDurationMs",_indexBuildMs],
        ["buildCount",(((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap]) getOrDefault ["buildCount",0]) + 1)]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,_projection];
    _indexBuiltNow = true;
};

private _byCategory = _projection getOrDefault ["byCategory",createHashMap];
private _indices = _byCategory getOrDefault [_category,[]];
private _needle = toLower _query;
private _safeWindow = (_window max 1) min 500;
private _safeOffset = _offset max 0;
private _filterStartedAt = diag_tickTime;
private _total = 0;
private _windowIndices = [];

if (_needle isEqualTo "") then {
    _total = count _indices;
    if (_safeOffset >= _total && {_total > 0}) then {_safeOffset = ((_total-_safeWindow) max 0);};
    private _take = (_total-_safeOffset) min _safeWindow;
    if (_take > 0) then {_windowIndices = _indices select [_safeOffset,_take];};
} else {
    private _scan = {
        params ["_startAt"];
        private _matchCount = 0;
        private _picked = [];
        {
            private _item = _items # _x;
            private _haystack = toLower format ["%1 %2 %3 %4",
                _item getOrDefault ["className",""],
                _item getOrDefault ["displayName",""],
                _item getOrDefault ["addon",""],
                _item getOrDefault ["categoryId",""]
            ];
            if ((_haystack find _needle) >= 0) then {
                if (_matchCount >= _startAt && {(count _picked) < _safeWindow}) then {_picked pushBack _x;};
                _matchCount = _matchCount + 1;
            };
        } forEach _indices;
        [_matchCount,_picked]
    };
    private _first = [_safeOffset] call _scan;
    _total = _first # 0;
    _windowIndices = _first # 1;
    if (_safeOffset >= _total && {_total > 0}) then {
        _safeOffset = ((_total-_safeWindow) max 0);
        private _second = [_safeOffset] call _scan;
        _total = _second # 0;
        _windowIndices = _second # 1;
    };
};
private _filterMs = round ((diag_tickTime-_filterStartedAt)*1000);

private _rows = [];
{
    _rows pushBack ([(_items # _x)] call ServoPeregrino_Organizador_Items_fnc_copyCatalogItem);
} forEach _windowIndices;
private _totalMs = round ((diag_tickTime-_startedAt)*1000);

[true,"ITEMS_UI_CATALOG_WINDOW_READY","Janela focal do Catálogo construída diretamente sobre o cache runtime, sem copiar o catálogo inteiro.",createHashMapFromArray [
    ["query",_query],["categoryId",_category],["offset",_safeOffset],["windowSize",_safeWindow],
    ["rows",_rows],["totalFiltered",_total],["baseCount",count _items],["categoryBaseCount",count _indices],
    ["projectionBuiltNow",_indexBuiltNow],["projectionBuildMs",_indexBuildMs],["projectionBuildCount",_projection getOrDefault ["buildCount",0]],
    ["filterMs",_filterMs],["totalMs",_totalMs],["defensiveCopies",count _rows]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
