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
        hint format ["UICommon 0.2-F F1 Foundation: %1 PASS / %2 FAIL",_d getOrDefault ["passed",0],_d getOrDefault ["failed",0]];
        diag_log format ["[SP_ORG] [FULL_UI_LAB] UICOMMON_TEST result=%1",_r];
    }];


    missionNamespace setVariable ["SP_ORG_FullLab_fnc_testItemsUICommon", {
        private _r=[] call ServoPeregrino_Organizador_Items_fnc_runUICommonEquivalenceTests;
        private _d=_r getOrDefault ["data",createHashMap];
        hint format ["Items + UICommon Equivalence: %1 PASS / %2 FAIL",_d getOrDefault ["passed",0],_d getOrDefault ["failed",0]];
        diag_log format ["[SP_ORG] [FULL_UI_LAB] ITEMS_UICOMMON_EQUIVALENCE result=%1",_r];
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_testWeapons07B", {
        [] spawn {
            private _r=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_BTests;
            diag_log format ["[SP_ORG] [FULL_UI_LAB] WEAPONS_0_7_B_TEST result=%1",_r];
        };
    }];

    missionNamespace setVariable ["SP_ORG_FullLab_fnc_installCoreActions", {
        params [["_unit",objNull,[objNull]]];
        if (isNull _unit || {!local _unit}) exitWith {};
        {
            private _id = _unit getVariable [_x,-1];
            if (_id >= 0) then {_unit removeAction _id;};
        } forEach ["SPORG_FL_Items","SPORG_FL_Weapons","SPORG_FL_UICommon","SPORG_FL_ItemsUICommon","SPORG_FL_WeaponsR6","SPORG_FL_Weapons07B"];

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
        _unit setVariable ["SPORG_FL_Weapons07B", _unit addAction [
            "<t color='#F0D98C'>SP_ORG LAB - TESTAR WEAPONS 0.7-B</t>",
            {[] call (missionNamespace getVariable ["SP_ORG_FullLab_fnc_testWeapons07B",{}]);},nil,14,true,true,"","alive _this && isServer",50
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
    hint parseText "<t size='1.2'>SP_ORG - WEAPONS 0.7-B + UICOMMON 0.2</t><br/><br/>Weapons 0.7-B habilita a primeira aplicacao fisica slot-safe no core, sobre Plan/Snapshot homologados na 0.7-A.<br/><br/><t color='#F0D98C'>IMPORTANTE:</t> o AUTO TEST executa as mutacoes em uma unidade isolada criada pelo harness. O loadout do jogador nao deve ser alterado. Integracao fisica com a UI fica para 0.7-D.<br/><br/>Nao carregue PBOs do Servo Peregrino neste teste.";
};
