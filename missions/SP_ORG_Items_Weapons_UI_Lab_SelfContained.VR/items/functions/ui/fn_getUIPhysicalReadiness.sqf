#include "..\..\script_version.hpp"
params [
    ["_unit", objNull, [objNull]],
    ["_requestedTarget", "", [""]],
    ["_preferredTarget", "", [""]],
    ["_options", createHashMap, [createHashMap]]
];

private _ui = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
private _requested = toUpper _requestedTarget;
if (_requested isEqualTo "") then {_requested = toUpper (_ui getOrDefault ["applicationTarget", "ANY"]);};
private _requestedRaw = _requested;
if !(_requested in ["ANY","U","C","M","UNIFORM","VEST","BACKPACK"]) then {_requested = "ANY";};

private _preferred = toUpper _preferredTarget;
if (_preferred isEqualTo "") then {
    private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
    private _draftD = _draftR getOrDefault ["data", createHashMap];
    private _draft = _draftD getOrDefault ["current", createHashMap];
    _preferred = toUpper (_draft getOrDefault ["preferredTarget", "ANY"]);
};
if !(_preferred in ["ANY","U","C","M","UNIFORM","VEST","BACKPACK"]) then {_preferred = "ANY";};

private _appR = [] call ServoPeregrino_Organizador_Items_fnc_getApplicationStatus;
private _app = _appR getOrDefault ["data", createHashMap];
private _engineReady = (_appR getOrDefault ["success", false]) && {_app getOrDefault ["ready", false]};
private _executing = _app getOrDefault ["executing", false];
if (!_engineReady || {_executing}) exitWith {
    [true, "ITEMS_UI_PHYSICAL_NOT_READY", if (_executing) then {"Application Engine está ocupado; UI física fica bloqueada até a transação terminar."} else {"Application Engine não está pronto; UI física permanece segura e desligada."}, createHashMapFromArray [
        ["physicalMutationEnabled", false], ["engineReady", _engineReady], ["executing", _executing],
        ["requestedTarget", _requested], ["preferredTarget", _preferred], ["resolvedTarget", ""], ["container", objNull],
        ["applicationStatus", _app]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capacityTargetCanonical = {
    params ["_target"];
    private _t=toUpper _target;
    if (_t isEqualTo "U") exitWith {"UNIFORM"};
    if (_t isEqualTo "C") exitWith {"VEST"};
    if (_t isEqualTo "M") exitWith {"BACKPACK"};
    _t
};

// Fixture físico isolado para os testes automáticos da 0.10.
// Só é aceito enquanto o orquestrador de testes está ativo e o target é TEST_*.
// O runtime normal nunca envia esta opção e continua obrigatoriamente resolvendo U/C/M do jogador.
private _testTarget = _options getOrDefault ["testResolvedTarget", createHashMap];
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
private _testTargetName = toUpper (_testTarget getOrDefault ["target", ""]);
private _testContainer = _testTarget getOrDefault ["container", objNull];
private _testClass = _testTarget getOrDefault ["containerClass", ""];
private _testAllowed = (_orchestrator getOrDefault ["running", false])
    && {(count _testTarget) > 0}
    && {(_testTargetName find "TEST_") isEqualTo 0}
    && {!isNull _testContainer}
    && {_testClass isNotEqualTo ""};
if (_testAllowed) exitWith {
    private _capCtx=_testTarget getOrDefault ["capacityContext",createHashMap];
    if !(_capCtx isEqualType createHashMap) then {_capCtx=createHashMap;};
    if ((_capCtx getOrDefault ["gearClass",""]) isEqualTo "") then {_capCtx set ["gearClass",_testClass];};
    private _capacityR=[_testContainer,[_testTargetName] call _capacityTargetCanonical,_capCtx] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics;
    private _capacity=if (_capacityR getOrDefault ["success",false]) then {_capacityR getOrDefault ["data",createHashMap]} else {createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",loadAbs _testContainer],["availableLoad",-1]]};
    [true, "ITEMS_UI_PHYSICAL_TEST_TARGET_READY", "Fixture físico isolado resolvido para a suíte automática; nenhum CAManBase/player é mutado.", createHashMapFromArray [
        ["physicalMutationEnabled", true], ["engineReady", true], ["executing", false],
        ["requestedTarget", if (_requestedRaw isEqualTo "") then {_testTargetName} else {_requestedRaw}], ["preferredTarget", _preferred],
        ["resolvedTarget", _testTargetName], ["targetReason", "TEST_FIXTURE"],
        ["container", _testContainer], ["containerClass", _testClass], ["availableTargets", [_testTargetName]], ["capacity",_capacity], ["testFixture", true]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if (isNull _unit) exitWith {
    [true, "ITEMS_UI_PHYSICAL_UNIT_UNAVAILABLE", "Unidade local indisponível; UI física permanece desligada sem mutação.", createHashMapFromArray [
        ["physicalMutationEnabled", false], ["engineReady", true], ["executing", false],
        ["requestedTarget", _requested], ["preferredTarget", _preferred], ["resolvedTarget", ""], ["container", objNull]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _resolvedR = [_unit, _requested, _preferred] call ServoPeregrino_Organizador_Items_fnc_resolveApplicationTarget;
if !(_resolvedR getOrDefault ["success", false]) exitWith {
    [true, "ITEMS_UI_PHYSICAL_TARGET_UNAVAILABLE", "Nenhum target físico elegível pôde ser resolvido; comandos físicos permanecem bloqueados.", createHashMapFromArray [
        ["physicalMutationEnabled", false], ["engineReady", true], ["executing", false],
        ["requestedTarget", _requested], ["preferredTarget", _preferred], ["resolvedTarget", ""], ["container", objNull],
        ["targetResult", _resolvedR]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _rd = _resolvedR getOrDefault ["data", createHashMap];
private _resolvedTarget=_rd getOrDefault ["target", ""];
private _resolvedContainer=_rd getOrDefault ["container", objNull];
private _resolvedClass=_rd getOrDefault ["className", ""];
private _capacity=createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]];
if (!isNull _resolvedContainer) then {
    private _capacityR=[_resolvedContainer,[_resolvedTarget] call _capacityTargetCanonical,createHashMapFromArray [["gearClass",_resolvedClass]]] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics;
    if (_capacityR getOrDefault ["success",false]) then {_capacity=_capacityR getOrDefault ["data",_capacity];};
};
[true, "ITEMS_UI_PHYSICAL_READY", "Application Engine e target físico estão prontos para um comando explícito.", createHashMapFromArray [
    ["physicalMutationEnabled", true], ["engineReady", true], ["executing", false],
    ["requestedTarget", _requested], ["preferredTarget", _preferred],
    ["resolvedTarget", _resolvedTarget], ["targetReason", _rd getOrDefault ["reason", ""]],
    ["container", _resolvedContainer], ["containerClass", _resolvedClass],
    ["availableTargets", +(_rd getOrDefault ["availableTargets", []])], ["capacity",_capacity], ["testFixture", false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
