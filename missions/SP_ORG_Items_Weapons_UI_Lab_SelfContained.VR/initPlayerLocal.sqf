[] spawn {
    waitUntil {!isNull player};
    waitUntil {!isNull findDisplay 46};

    [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
    [] call ServoPeregrino_Organizador_UICommon_fnc_initialize;
    [] call ServoPeregrino_Organizador_Items_fnc_initialize;
    [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_openItems", {
        hintSilent "";
        private _r = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
        diag_log format ["[SP_ORG] [FULL_UI_LAB] OPEN_ITEMS result=%1",_r];
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_openWeapons", {
        hintSilent "";
        private _r = [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
        diag_log format ["[SP_ORG] [FULL_UI_LAB] OPEN_WEAPONS result=%1",_r];
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_testUICommon", {
        private _r = [] call ServoPeregrino_Organizador_UICommon_fnc_runFoundationTests;
        private _d = _r getOrDefault ["data",createHashMap];
        hint format ["UICommon 0.2-C C1 Foundation: %1 PASS / %2 FAIL",_d getOrDefault ["passed",0],_d getOrDefault ["failed",0]];
        diag_log format ["[SP_ORG] [FULL_UI_LAB] UICOMMON_TEST result=%1",_r];
    }];


    missionNamespace setVariable ["SP_ORG_FullLab_fnc_testItemsUICommon", {
        private _r=[] call ServoPeregrino_Organizador_Items_fnc_runUICommonEquivalenceTests;
        private _d=_r getOrDefault ["data",createHashMap];
        hint format ["Items + UICommon Equivalence: %1 PASS / %2 FAIL",_d getOrDefault ["passed",0],_d getOrDefault ["failed",0]];
        diag_log format ["[SP_ORG] [FULL_UI_LAB] ITEMS_UICOMMON_EQUIVALENCE result=%1",_r];
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_testWeaponsR2", {
        [] spawn {
            private _r=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_6_FR6Tests;
            diag_log format ["[SP_ORG] [FULL_UI_LAB] WEAPONS_0_6_F_R1_TEST result=%1",_r];
        };
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_installCoreActions", {
        params [["_unit",objNull,[objNull]]];
        if (isNull _unit || {!local _unit}) exitWith {};
        {
            private _id = _unit getVariable [_x,-1];
            if (_id >= 0) then {_unit removeAction _id;};
        } forEach ["SPORG_FL_Items","SPORG_FL_Weapons","SPORG_FL_UICommon","SPORG_FL_ItemsUICommon","SPORG_FL_WeaponsR2"];

        _unit setVariable ["SPORG_FL_Items", _unit addAction [
            "<t color='#7FD9D0' size='1.12'>SP_ORG LAB - ABRIR ITEMS</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_openItems",{}]);},nil,16,true,true,"","alive _this",50
        ]];
        _unit setVariable ["SPORG_FL_Weapons", _unit addAction [
            "<t color='#D7C27D' size='1.12'>SP_ORG LAB - ABRIR WEAPONS</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_openWeapons",{}]);},nil,15.5,true,true,"","alive _this",50
        ]];
        _unit setVariable ["SPORG_FL_UICommon", _unit addAction [
            "<t color='#9ED9A6'>SP_ORG LAB - TESTAR UICOMMON</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_testUICommon",{}]);},nil,15,true,true,"","alive _this",50
        ]];
        _unit setVariable ["SPORG_FL_ItemsUICommon", _unit addAction [
            "<t color='#A8D7FF'>SP_ORG LAB - TESTAR ITEMS + UICOMMON</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_testItemsUICommon",{}]);},nil,14.5,true,true,"","alive _this",50
        ]];
        _unit setVariable ["SPORG_FL_WeaponsR2", _unit addAction [
            "<t color='#F0D98C'>SP_ORG LAB - TESTAR WEAPONS 0.6-F R6</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_testWeaponsR2",{}]);},nil,14,true,true,"","alive _this && isServer",50
        ]];
    }];

    [player] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_installCoreActions",{}]);

    // Preserve both modules' own diagnostic/test action sets.
    if !(isNil "ServoPeregrino_Organizador_Items_fnc_installTestActions") then {
        [player] call ServoPeregrino_Organizador_Items_fnc_installTestActions;
    };
    if !(isNil "ServoPeregrino_Organizador_Weapons_fnc_installLabActions") then {
        [player] call ServoPeregrino_Organizador_Weapons_fnc_installLabActions;
    };

    if (isNil {missionNamespace getVariable "SP_ORG_Weapons_DrawLabelsEH"}) then {
        private _eh = addMissionEventHandler ["Draw3D",{
            {
                _x params ["_var","_text"];
                private _obj = missionNamespace getVariable [_var,objNull];
                if (!isNull _obj && {player distance _obj < 40}) then {
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\dot_CA.paa",
                        [1,1,1,1], ASLToAGL (getPosASL _obj vectorAdd [0,0,1.7]),
                        0.75,0.75,0,_text,2,0.045,"RobotoCondensed","center",true
                    ];
                };
            } forEach [
                ["SP_ORG_Weapons_Box_ACCESSORIES","WEAPONS 0.6-F R6 - COMPACT FILTER REGRESSION"],
                ["SP_ORG_Weapons_Box_TRANSFER","REGRESSION - LIFECYCLE TRANSFER"],
                ["SP_ORG_Weapons_Box_DUPLICATES","REGRESSION - IDENTICAL WEAPONS"]
            ];
        }];
        missionNamespace setVariable ["SP_ORG_Weapons_DrawLabelsEH",_eh];
    };

    player addEventHandler ["Respawn", {
        params ["_newUnit"];
        [_newUnit] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_installCoreActions",{}]);
        if !(isNil "ServoPeregrino_Organizador_Items_fnc_installTestActions") then {[_newUnit] call ServoPeregrino_Organizador_Items_fnc_installTestActions;};
        if !(isNil "ServoPeregrino_Organizador_Weapons_fnc_installLabActions") then {[_newUnit] call ServoPeregrino_Organizador_Weapons_fnc_installLabActions;};
    }];

    diag_log format ["[SP_ORG] [FULL_UI_LAB] CLIENT_READY player=%1 owner=%2",name player,clientOwner];
    hint parseText "<t size='1.2'>SP_ORG - WEAPONS 0.6-F R6 + UICOMMON</t><br/><br/>Nexus + UICommon 0.2-C C1 + Items Equivalence + Weapons 0.6-F R6 estao dentro desta missao.<br/><br/><t color='#7FD9D0'>ITEMS</t> permanece baseline funcional. <t color='#D7C27D'>WEAPONS</t> preserva a R5 e compacta o espaçamento dos filtros Tipo/Acessório, mantendo preview sem distorção, linhas alteradas em âmbar, authoring dinâmico e focused refresh.<br/><br/>Aplicacao fisica de Weapons continua reservada para 0.7. Nao carregue PBOs do Servo Peregrino neste teste.";
};
