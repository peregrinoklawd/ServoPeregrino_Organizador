#include "..\..\script_version.hpp"
params [["_movement","ADD",[""]]];

private _m=toUpper _movement;
if !(_m in ["ADD","REMOVE","CLEAR","REPLACE"]) then {_m="ADD";};
private _label=switch _m do {
    case "REMOVE": {"Remover / deletar item"};
    case "CLEAR": {"Limpar / remover conteúdo"};
    case "REPLACE": {"Substituir / mover conteúdo"};
    default {"Adicionar / mover item"};
};

// O modset não muda durante a missão. Resolver CfgSounds em todo clique é desperdício,
// portanto a CP-B.5 faz o lookup uma única vez por sessão e reutiliza o provider resolvido.
private _cacheKey="ServoPeregrino_Organizador_Items_uiMovementSoundProviderCache";
private _providerCache=missionNamespace getVariable [_cacheKey,createHashMap];
if ((count _providerCache) isEqualTo 0) then {
    private _soundClass="";
    private _provider="";
    private _classScope="MAIN";
    private _configReference="";
    private _fallback=false;

    if (isClass (configFile >> "CfgSounds" >> "real_bagclose")) then {
        _soundClass="real_bagclose";
        _provider="BGD_REAL_SFX_INVENTORY_BAGCLOSE";
        _configReference="CfgSounds.real_bagclose";
    } else {
        if (isClass (configFile >> "CfgSounds" >> "addItemOK")) then {
            _soundClass="addItemOK";
            _provider="ARMA3_CFGSOUNDS_ADDITEMOK_FALLBACK";
            _configReference="CfgSounds.addItemOK";
            _fallback=true;
        } else {
            _soundClass="SP_ORG_Items_UI_Success";
            _provider="SPORG_LOCAL_SAFE_FALLBACK";
            _classScope="MISSION";
            _configReference="Mission.CfgSounds.SP_ORG_Items_UI_Success";
            _fallback=true;
        };
    };

    private _cfg=if (_classScope isEqualTo "MAIN") then {configFile >> "CfgSounds" >> _soundClass} else {missionConfigFile >> "CfgSounds" >> _soundClass};
    private _classAvailable=(_soundClass isNotEqualTo "") && {isClass _cfg};
    private _soundArray=if (_classAvailable) then {getArray (_cfg >> "sound")} else {[]};
    private _resolvedPath=_soundArray param [0,"",[""]];
    _providerCache=createHashMapFromArray [
        ["soundClass",_soundClass],["classScope",_classScope],["resolvedPath",_resolvedPath],
        ["provider",_provider],["configReference",_configReference],["fallback",_fallback],
        ["classAvailable",_classAvailable],["resolvedAtTick",diag_tickTime],
        ["realInventoryAvailable",isClass (configFile >> "CfgSounds" >> "real_bagclose")],
        ["realPickupAvailable",isClass (configFile >> "CfgSounds" >> "real_pickup")],
        ["realDropAvailable",isClass (configFile >> "CfgSounds" >> "real_drop")],
        ["realBagOpenAvailable",isClass (configFile >> "CfgSounds" >> "real_bagopen")]
    ];
    missionNamespace setVariable [_cacheKey,_providerCache];
    diag_log format ["[SP_ORG] [ITEMS] [UX_MOVE_SOUND] PROVIDER_CACHE provider=%1 class=%2 scope=%3 available=%4 resolvedPath=%5",_provider,_soundClass,_classScope,_classAvailable,_resolvedPath];
};

createHashMapFromArray [
    ["movement",_m],
    ["soundClass",_providerCache getOrDefault ["soundClass",""]],
    ["classScope",_providerCache getOrDefault ["classScope","MAIN"]],
    ["resolvedPath",_providerCache getOrDefault ["resolvedPath",""]],
    ["classAvailable",_providerCache getOrDefault ["classAvailable",false]],
    ["volume",1],
    ["pitch",1],
    ["label",_label],
    ["provider",_providerCache getOrDefault ["provider",""]],
    ["configReference",_providerCache getOrDefault ["configReference",""]],
    ["unifiedCue",true],
    ["fallback",_providerCache getOrDefault ["fallback",false]],
    ["providerCached",true],
    ["realInventoryAvailable",_providerCache getOrDefault ["realInventoryAvailable",false]],
    ["realPickupAvailable",_providerCache getOrDefault ["realPickupAvailable",false]],
    ["realDropAvailable",_providerCache getOrDefault ["realDropAvailable",false]],
    ["realBagOpenAvailable",_providerCache getOrDefault ["realBagOpenAvailable",false]],
    ["note","CP-B.5 resolve o provider uma única vez por missão. Prefere real_bagclose; fallback addItemOK; último fallback cue local autocontido."]
]
