waitUntil {!isNull player};
waitUntil {!isNull findDisplay 46};

[] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
[] call ServoPeregrino_Organizador_UICommon_fnc_initialize;
[] call ServoPeregrino_Organizador_Items_fnc_initialize;

missionNamespace setVariable ["SP_ORG_SC_Lab_fnc_openItems", {
    hintSilent "";
    private _r = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
    if (_r isEqualType createHashMap && {!(_r getOrDefault ["success",false])}) then {
        hint format ["Items: %1 - %2",_r getOrDefault ["code","UNKNOWN"],_r getOrDefault ["message",""]];
    };
    diag_log format ["[SP_ORG] [SELF_CONTAINED_UI_LAB] ITEMS_OPEN result=%1",_r];
}];

missionNamespace setVariable ["SP_ORG_SC_Lab_fnc_testUICommon", {
    private _r = [] call ServoPeregrino_Organizador_UICommon_fnc_runFoundationTests;
    private _d = _r getOrDefault ["data",createHashMap];
    hint format ["UICommon 0.1 Foundation: %1 PASS / %2 FAIL",_d getOrDefault ["passed",0],_d getOrDefault ["failed",0]];
    diag_log format ["[SP_ORG] [SELF_CONTAINED_UI_LAB] UICOMMON_TEST result=%1",_r];
}];

missionNamespace setVariable ["SP_ORG_SC_Lab_fnc_openWeapons", {
    hint "Weapons 0.6-E ainda nao foi incorporada: os fontes da ultima missao testada nao estao no monorepo. Nao sera usada a antiga 0.1-A como substituta.";
    diag_log "[SP_ORG] [SELF_CONTAINED_UI_LAB] WEAPONS_0_6_SOURCE_PENDING";
}];

missionNamespace setVariable ["SP_ORG_SC_Lab_fnc_install", {
    params [["_unit",objNull,[objNull]]];
    if (isNull _unit || {!local _unit}) exitWith {};

    _unit addAction ["<t color='#7FD9D0'>SP_ORG LAB - ABRIR ITEMS</t>",{[] call (missionNamespace getVariable ["SP_ORG_SC_Lab_fnc_openItems",{}]);},nil,14,true,true,"","alive _this",50];
    _unit addAction ["<t color='#9ED9A6'>SP_ORG LAB - TESTAR UICOMMON</t>",{[] call (missionNamespace getVariable ["SP_ORG_SC_Lab_fnc_testUICommon",{}]);},nil,13.5,true,true,"","alive _this",50];
    _unit addAction ["<t color='#D7C27D'>SP_ORG LAB - ABRIR WEAPONS</t>",{[] call (missionNamespace getVariable ["SP_ORG_SC_Lab_fnc_openWeapons",{}]);},nil,13,true,true,"","alive _this",50];
}];

[player] call (missionNamespace getVariable ["SP_ORG_SC_Lab_fnc_install",{}]);

if !(isNil "ServoPeregrino_Organizador_Items_fnc_installTestActions") then {
    [player] call ServoPeregrino_Organizador_Items_fnc_installTestActions;
};

player addEventHandler ["Respawn", {
    params ["_newUnit"];
    [_newUnit] call (missionNamespace getVariable ["SP_ORG_SC_Lab_fnc_install",{}]);
}];

diag_log format [
    "[SP_ORG] [SELF_CONTAINED_UI_LAB] CLIENT_READY player=%1 uid=%2",
    name player,getPlayerUID player
];

hint parseText "<t size='1.2'>SP_ORG Self-Contained UI Lab</t><br/><br/>Nexus, UICommon e Items estao dentro da propria missao.<br/><br/>Nenhum PBO do Servo Peregrino deve estar carregado neste teste.";
