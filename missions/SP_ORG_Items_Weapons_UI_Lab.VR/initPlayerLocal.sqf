waitUntil {!isNull player};
waitUntil {!isNull findDisplay 46};

private _safeInit = {
    params ["_fnName"];
    if (isNil _fnName) exitWith {false};
    call compile format ["[] call %1", _fnName];
    true
};

["ServoPeregrino_Organizador_Nexus_fnc_initialize"] call _safeInit;
["ServoPeregrino_Organizador_UICommon_fnc_initialize"] call _safeInit;
["ServoPeregrino_Organizador_Items_fnc_initialize"] call _safeInit;
["ServoPeregrino_Organizador_Weapons_fnc_initialize"] call _safeInit;

missionNamespace setVariable ["SP_ORG_UI_Lab_fnc_openItems", {
    hintSilent "";
    if (isNil "ServoPeregrino_Organizador_Items_fnc_openInterface") exitWith {
        hint "Items nao esta disponivel nesta execucao.";
        diag_log "[SP_ORG] [UI_LAB] ITEMS_OPEN_UNAVAILABLE";
    };
    private _r = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
    if (_r isEqualType createHashMap && {!(_r getOrDefault ["success",false])}) then {
        hint format ["Items: %1 - %2",_r getOrDefault ["code","UNKNOWN"],_r getOrDefault ["message",""]];
    };
    diag_log format ["[SP_ORG] [UI_LAB] ITEMS_OPEN result=%1",_r];
}];

missionNamespace setVariable ["SP_ORG_UI_Lab_fnc_openWeapons", {
    hintSilent "";
    if (isNil "ServoPeregrino_Organizador_Weapons_fnc_openInterface") exitWith {
        hint "Weapons UI mission-first ainda nao esta materializada neste Lab. A fundacao 0.1-A pode estar carregada, mas nao e a UI 0.6.";
        diag_log "[SP_ORG] [UI_LAB] WEAPONS_UI_OPEN_UNAVAILABLE";
    };
    private _r = [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
    if (_r isEqualType createHashMap && {!(_r getOrDefault ["success",false])}) then {
        hint format ["Weapons: %1 - %2",_r getOrDefault ["code","UNKNOWN"],_r getOrDefault ["message",""]];
    };
    diag_log format ["[SP_ORG] [UI_LAB] WEAPONS_OPEN result=%1",_r];
}];

missionNamespace setVariable ["SP_ORG_UI_Lab_fnc_testUICommon", {
    hintSilent "";
    if (isNil "ServoPeregrino_Organizador_UICommon_fnc_runFoundationTests") exitWith {
        hint "UICommon nao esta carregado.";
        diag_log "[SP_ORG] [UI_LAB] UICOMMON_TEST_UNAVAILABLE";
    };
    private _r = [] call ServoPeregrino_Organizador_UICommon_fnc_runFoundationTests;
    private _d = _r getOrDefault ["data",createHashMap];
    private _msg = format [
        "UICommon 0.1 Foundation: %1 PASS / %2 FAIL",
        _d getOrDefault ["passed",0],
        _d getOrDefault ["failed",0]
    ];
    hint _msg;
    diag_log format ["[SP_ORG] [UI_LAB] UICOMMON_TEST result=%1",_r];
}];

missionNamespace setVariable ["SP_ORG_UI_Lab_fnc_reportModules", {
    private _items = !(isNil "ServoPeregrino_Organizador_Items_fnc_openInterface");
    private _weaponsUI = !(isNil "ServoPeregrino_Organizador_Weapons_fnc_openInterface");
    private _weaponsCore = !(isNil "ServoPeregrino_Organizador_Weapons_fnc_initialize");
    private _uiCommon = !(isNil "ServoPeregrino_Organizador_UICommon_fnc_initialize");
    private _text = format [
        "UI Lab | UICommon=%1 | Items UI=%2 | Weapons Core=%3 | Weapons UI=%4",
        _uiCommon,_items,_weaponsCore,_weaponsUI
    ];
    hint _text;
    diag_log format ["[SP_ORG] [UI_LAB] MODULE_REPORT %1",_text];
}];

missionNamespace setVariable ["SP_ORG_UI_Lab_fnc_installActions", {
    params [["_unit",objNull,[objNull]]];
    if (isNull _unit || {!local _unit}) exitWith {};

    {
        private _old = _unit getVariable [_x,-1];
        if (_old >= 0) then {_unit removeAction _old;};
    } forEach [
        "SP_ORG_UI_Lab_ActionItems",
        "SP_ORG_UI_Lab_ActionWeapons",
        "SP_ORG_UI_Lab_ActionUICommon",
        "SP_ORG_UI_Lab_ActionStatus"
    ];

    private _itemsId = _unit addAction [
        "<t color='#7FD9D0'>SP_ORG UI LAB - ABRIR ITEMS</t>",
        {[] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_openItems",{}]);},
        nil,14,true,true,"","alive _this",50
    ];
    private _weaponsId = _unit addAction [
        "<t color='#D7C27D'>SP_ORG UI LAB - ABRIR WEAPONS</t>",
        {[] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_openWeapons",{}]);},
        nil,13.5,true,true,"","alive _this",50
    ];
    private _uiCommonId = _unit addAction [
        "<t color='#9ED9A6'>SP_ORG UI LAB - TESTAR UICOMMON</t>",
        {[] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_testUICommon",{}]);},
        nil,13,true,true,"","alive _this",50
    ];
    private _statusId = _unit addAction [
        "<t color='#B8B8B8'>SP_ORG UI LAB - STATUS MODULOS</t>",
        {[] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_reportModules",{}]);},
        nil,12.5,true,true,"","alive _this",50
    ];

    _unit setVariable ["SP_ORG_UI_Lab_ActionItems",_itemsId];
    _unit setVariable ["SP_ORG_UI_Lab_ActionWeapons",_weaponsId];
    _unit setVariable ["SP_ORG_UI_Lab_ActionUICommon",_uiCommonId];
    _unit setVariable ["SP_ORG_UI_Lab_ActionStatus",_statusId];
}];

[player] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_installActions",{}]);

if !(isNil "ServoPeregrino_Organizador_Items_fnc_installTestActions") then {
    [player] call ServoPeregrino_Organizador_Items_fnc_installTestActions;
};

player addEventHandler ["Respawn", {
    params ["_newUnit"];
    [_newUnit] call (missionNamespace getVariable ["SP_ORG_UI_Lab_fnc_installActions",{}]);
}];

diag_log format [
    "[SP_ORG] [UI_LAB] CLIENT_READY player=%1 uid=%2 UICommon=%3 ItemsUI=%4 WeaponsCore=%5 WeaponsUI=%6",
    name player,
    getPlayerUID player,
    !(isNil "ServoPeregrino_Organizador_UICommon_fnc_initialize"),
    !(isNil "ServoPeregrino_Organizador_Items_fnc_openInterface"),
    !(isNil "ServoPeregrino_Organizador_Weapons_fnc_initialize"),
    !(isNil "ServoPeregrino_Organizador_Weapons_fnc_openInterface")
];

hint parseText "<t size='1.2'>SP_ORG Items + Weapons UI Lab</t><br/><br/>Use o menu de acoes para testar UICommon, abrir Items e, quando materializada, abrir a UI mission-first de Weapons.<br/><br/><t color='#FFD966'>Weapons Core carregado nao significa Weapons UI 0.6 carregada.</t>";
