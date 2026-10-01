#include "..\..\script_version.hpp"
params [["_plan", createHashMap, [createHashMap]]];
if ((count _plan) isEqualTo 0) exitWith {[false, "ITEMS_PLAN_FAILED", "ApplicationPlan vazio.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if ((_plan getOrDefault ["version", 0]) isNotEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION) exitWith {[false, "ITEMS_PLAN_FAILED", "Versão de ApplicationPlan não suportada.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if ((_plan getOrDefault ["status", ""]) isNotEqualTo "READY") exitWith {[false, "ITEMS_PLAN_FAILED", "ApplicationPlan não está READY.", createHashMapFromArray [["status", _plan getOrDefault ["status", ""]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _container = _plan getOrDefault ["container", objNull];
if (isNull _container) exitWith {[false, "ITEMS_CONTAINER_NULL", "ApplicationPlan perdeu o container físico.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _op = _plan getOrDefault ["operation", ""];
if !(_op in ["ADD", "REMOVE", "REPLACE", "CLEAR"]) exitWith {[false, "ITEMS_PLAN_FAILED", "Operação do ApplicationPlan não é suportada.", createHashMapFromArray [["operation", _op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (_op isEqualTo "REPLACE" && {(_plan getOrDefault ["policy", ""]) isNotEqualTo "STRICT"}) exitWith {[false, "ITEMS_PLAN_FAILED", "REPLACE é obrigatoriamente STRICT.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if ((count (_plan getOrDefault ["actions", []])) isEqualTo 0 && {!(_plan getOrDefault ["noOp", false])}) exitWith {[false, "ITEMS_PLAN_FAILED", "ApplicationPlan não possui ações e não está marcado como no-op.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true, "ITEMS_APPLICATION_PLAN_VALID", "ApplicationPlan v1 está estruturalmente executável.", createHashMapFromArray [["planId", _plan getOrDefault ["planId", ""]], ["operation", _op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
