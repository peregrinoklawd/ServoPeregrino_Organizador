#include "..\..\script_version.hpp"
private _initResult=[] call ServoPeregrino_Organizador_Items_fnc_initialize; if !(_initResult getOrDefault ["success",false]) exitWith {_initResult};
if (!hasInterface) exitWith {[false,"ITEMS_UI_NO_INTERFACE","A interface de Items exige cliente com interface.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
disableSerialization;
private _readinessR = [player] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _readiness = _readinessR getOrDefault ["data",createHashMap];
private _physicalEnabled = _readiness getOrDefault ["physicalMutationEnabled",false];
private _meta = createHashMapFromArray [
    ["idd",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD],
    ["panels",["KITS","DRAFT","CATALOG","EQUIPMENT"]],
    ["readOnlyShell",false],
    ["draftInteractionReady",true],
    ["applicationEngineReady",_readiness getOrDefault ["engineReady",false]],
    ["physicalMutationAvailable",true],
    ["physicalMutationEnabled",false],
    ["mutatesInventory",false],
    ["physicalCommandEnabled",_physicalEnabled],
    ["physicalCommandsMutateInventory",true],
    ["resolvedPhysicalTarget",_readiness getOrDefault ["resolvedTarget",""]]
];
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) exitWith {[true,"ITEMS_UI_ALREADY_OPEN","A interface de Items já está aberta.",[_meta] call ServoPeregrino_Organizador_Items_fnc_deepCopy] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _ok=createDialog "SP_ORG_Items_Dialog";
if (!_ok) exitWith {[false,"ITEMS_UI_CREATE_DIALOG_FAILED","O Arma não conseguiu criar SP_ORG_Items_Dialog.",createHashMapFromArray [["dialog","SP_ORG_Items_Dialog"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"ITEMS_UI_OPENED","Interface 0.12-D.6 aberta com navegação simplificada, peso em kg/lb, header compacto e DnD preservado. Arraste itens entre os painéis ou use os botões de ação.",_meta] call ServoPeregrino_Organizador_Nexus_fnc_createResult
