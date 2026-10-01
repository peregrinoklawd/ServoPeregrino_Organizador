#include "..\..\script_version.hpp"
params [["_logToRPT",true,[true]]];
private _needles=["inventory","gear","backpack","vest","uniform","item","cargo","container","equip"];
private _candidates=[];
private _cfg=configFile >> "CfgSounds";
for "_i" from 0 to ((count _cfg)-1) do {
    private _c=_cfg select _i;
    if (isClass _c) then {
        private _name=configName _c;
        private _arr=getArray (_c >> "sound");
        private _path=if ((count _arr)>0) then {_arr#0} else {""};
        private _hay=toLower format ["%1 %2",_name,_path];
        if ((_needles findIf {_hay find _x >= 0})>=0) then {_candidates pushBack ["CfgSounds",_name,_path];};
    };
};
private _inventoryProps=[];
private _root=configFile >> "RscDisplayInventory";
if (isClass _root) then {
    private _props=configProperties [_root,"isArray _x",true];
    {
        private _n=configName _x;
        private _ln=toLower _n;
        if (_ln find "sound" >= 0) then {
            private _a=getArray _x;
            if ((count _a)>0) then {_inventoryProps pushBack ["RscDisplayInventory",_n,_a#0];};
        };
    } forEach _props;
};
if (_logToRPT) then {
    diag_log "============================================================";
    diag_log format ["[SP_ORG] [ITEMS] [VANILLA_SOUND_SCAN] CfgSounds candidates=%1 inventoryProps=%2",count _candidates,count _inventoryProps];
    {diag_log format ["[SP_ORG] [ITEMS] [VANILLA_SOUND_SCAN] source=%1 name=%2 path=%3",_x#0,_x#1,_x#2];} forEach _inventoryProps;
    {diag_log format ["[SP_ORG] [ITEMS] [VANILLA_SOUND_SCAN] source=%1 name=%2 path=%3",_x#0,_x#1,_x#2];} forEach (_candidates select [0,(count _candidates) min 120]);
    diag_log "============================================================";
};
[true,"ITEMS_VANILLA_SOUND_SCAN_COMPLETE",format ["Scanner encontrou %1 candidato(s) em CfgSounds e %2 propriedade(s) sound em RscDisplayInventory.",count _candidates,count _inventoryProps],createHashMapFromArray [["cfgSoundCandidates",_candidates],["inventorySoundProperties",_inventoryProps]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
