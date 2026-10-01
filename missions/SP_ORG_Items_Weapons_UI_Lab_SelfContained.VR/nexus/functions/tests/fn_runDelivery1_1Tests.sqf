#include "..\..\script_version.hpp"

params [["_silent", false, [false]]];

[] call ServoPeregrino_Organizador_Nexus_fnc_resetRuntimeForTests;

private _passed = 0;
private _total = 0;
private _failures = [];
private _assert = {
    params ["_name", "_condition", ["_details", ""]];
    _total = _total + 1;
    if (_condition) then {
        _passed = _passed + 1;
        diag_log format ["[SP_ORG] TESTE NEXUS 1.1 | PASSOU | %1 | %2", _name, _details];
    } else {
        _failures pushBack [_name, _details];
        diag_log format ["[SP_ORG] TESTE NEXUS 1.1 | FALHOU | %1 | %2", _name, _details];
    };
};

private _build = [] call ServoPeregrino_Organizador_Nexus_fnc_getBuildInfo;
["Build identificar Entrega 1.1", (_build getOrDefault ["displayVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_NEXUS_DISPLAY_VERSION, _build] call _assert;
["Namespace técnico permanecer estável", (_build getOrDefault ["namespace", ""]) isEqualTo "ServoPeregrino_Organizador", _build getOrDefault ["namespace", ""]] call _assert;
["Nexus estar inicializado", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_INITIALIZED_VAR, false], "initialized"] call _assert;

private _result = [true, "TEST_OK", "Resultado de teste."] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
["Resultado estruturado ser reconhecido", [_result] call ServoPeregrino_Organizador_Nexus_fnc_isResult, _result getOrDefault ["schema", ""]] call _assert;
["HashMap arbitrário não ser resultado", !([createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_isResult), "invalid"] call _assert;
["Resultado preservar sucesso", _result getOrDefault ["success", false], _result getOrDefault ["code", ""]] call _assert;

private _capabilityResult = ["armorer.station", 1, "ServoPeregrino_Organizador_Armorer"] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
["Registrar capacidade válida", _capabilityResult getOrDefault ["success", false], _capabilityResult getOrDefault ["code", ""]] call _assert;
["Detectar capacidade na versão mínima", ["armorer.station", 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability, "v1"] call _assert;
["Rejeitar versão mínima superior", !(["armorer.station", 2] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability), "v2"] call _assert;
private _duplicateCapability = ["armorer.station", 1, "ServoPeregrino_Organizador_Armorer"] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
["Registro idempotente não falhar", _duplicateCapability getOrDefault ["success", false], _duplicateCapability getOrDefault ["code", ""]] call _assert;
private _conflictingCapability = ["armorer.station", 1, "Outro_Provedor"] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
["Conflito de provedor ser rejeitado", !(_conflictingCapability getOrDefault ["success", true]), _conflictingCapability getOrDefault ["code", ""]] call _assert;
private _foundCapability = ["armorer.station"] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
["Consultar capacidade registrada", _foundCapability getOrDefault ["success", false], _foundCapability getOrDefault ["code", ""]] call _assert;
private _capabilities = [] call ServoPeregrino_Organizador_Nexus_fnc_listCapabilities;
["Listagem incluir Nexus e Armeiro", count ((_capabilities get "data") getOrDefault ["capabilities", []]) >= 2, count ((_capabilities get "data") getOrDefault ["capabilities", []])] call _assert;
["Capacidade ausente retornar false sem erro", !(["weapons.presets", 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability), "optional absence"] call _assert;
private _invalidCapability = ["", 1, "Provider"] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
["Identidade vazia ser rejeitada", !(_invalidCapability getOrDefault ["success", true]), _invalidCapability getOrDefault ["code", ""]] call _assert;

private _definition = [
    "armorer.weapon.configuration",
    1,
    "ServoPeregrino_Organizador_Armorer",
    ["weaponClass", "attachments"]
] call ServoPeregrino_Organizador_Nexus_fnc_registerContractDefinition;
["Registrar definição de contrato", _definition getOrDefault ["success", false], _definition getOrDefault ["code", ""]] call _assert;
private _contract = [
    "armorer.weapon.configuration",
    1,
    "ServoPeregrino_Organizador_Armorer",
    createHashMapFromArray [["weaponClass", "arifle_MX_F"], ["attachments", []]]
] call ServoPeregrino_Organizador_Nexus_fnc_createContract;
["Criar envelope canônico", (_contract getOrDefault ["schema", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_MAGIC, _contract getOrDefault ["contract", ""]] call _assert;
private _validContract = [_contract] call ServoPeregrino_Organizador_Nexus_fnc_validateContract;
["Validar contrato completo", _validContract getOrDefault ["success", false], _validContract getOrDefault ["code", ""]] call _assert;
private _incompleteContract = [
    "armorer.weapon.configuration",
    1,
    "ServoPeregrino_Organizador_Armorer",
    createHashMapFromArray [["weaponClass", "arifle_MX_F"]]
] call ServoPeregrino_Organizador_Nexus_fnc_createContract;
private _invalidContractResult = [_incompleteContract] call ServoPeregrino_Organizador_Nexus_fnc_validateContract;
["Detectar payload incompleto", !(_invalidContractResult getOrDefault ["success", true]), _invalidContractResult getOrDefault ["code", ""]] call _assert;
private _unsupportedContract = ["unknown.contract", 1, "Test", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createContract;
private _unsupportedResult = [_unsupportedContract] call ServoPeregrino_Organizador_Nexus_fnc_validateContract;
["Rejeitar contrato não registrado", !(_unsupportedResult getOrDefault ["success", true]), _unsupportedResult getOrDefault ["code", ""]] call _assert;

missionNamespace setVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0];
missionNamespace setVariable ["ServoPeregrino_Organizador_Nexus_testEventValue", ""];
private _subscriptionResult = [
    "armorer.session.started",
    {
        params ["_envelope"];
        missionNamespace setVariable [
            "ServoPeregrino_Organizador_Nexus_testEventCount",
            (missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0]) + 1
        ];
        private _payload = _envelope getOrDefault ["payload", createHashMap];
        missionNamespace setVariable ["ServoPeregrino_Organizador_Nexus_testEventValue", _payload getOrDefault ["sessionId", ""]];
    },
    "ServoPeregrino_Organizador_Armorer"
] call ServoPeregrino_Organizador_Nexus_fnc_subscribeEvent;
["Assinar evento", _subscriptionResult getOrDefault ["success", false], _subscriptionResult getOrDefault ["code", ""]] call _assert;
private _publishResult = [
    "armorer.session.started",
    createHashMapFromArray [["sessionId", "session-test-001"]],
    "ServoPeregrino_Organizador_Armorer"
] call ServoPeregrino_Organizador_Nexus_fnc_publishEvent;
["Publicar evento", _publishResult getOrDefault ["success", false], _publishResult getOrDefault ["code", ""]] call _assert;
["Invocar assinatura uma vez", (missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0]) isEqualTo 1, missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0]] call _assert;
["Entregar payload ao assinante", (missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventValue", ""]) isEqualTo "session-test-001", missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventValue", ""]] call _assert;
private _token = (_subscriptionResult get "data") getOrDefault ["token", ""];
private _unsubscribeResult = [_token] call ServoPeregrino_Organizador_Nexus_fnc_unsubscribeEvent;
["Remover assinatura", _unsubscribeResult getOrDefault ["success", false], _unsubscribeResult getOrDefault ["code", ""]] call _assert;
["Publicar sem assinantes continuar válido", (["armorer.session.started", createHashMap, "Test"] call ServoPeregrino_Organizador_Nexus_fnc_publishEvent) getOrDefault ["success", false], "zero subscribers"] call _assert;
["Assinatura removida não ser invocada", (missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0]) isEqualTo 1, missionNamespace getVariable ["ServoPeregrino_Organizador_Nexus_testEventCount", 0]] call _assert;

private _logLevel = ["DEBUG"] call ServoPeregrino_Organizador_Nexus_fnc_setLogLevel;
["Configurar nível de log", _logLevel getOrDefault ["success", false], _logLevel getOrDefault ["code", ""]] call _assert;
private _diagnostic = ["WARN", "TEST_WARNING", "Diagnóstico de teste."] call ServoPeregrino_Organizador_Nexus_fnc_createDiagnostic;
["Criar diagnóstico estruturado", (_diagnostic getOrDefault ["severity", ""]) isEqualTo "WARN", _diagnostic] call _assert;

private _removeCapability = ["armorer.station", "ServoPeregrino_Organizador_Armorer"] call ServoPeregrino_Organizador_Nexus_fnc_unregisterCapability;
["Remover capacidade pelo provedor", _removeCapability getOrDefault ["success", false], _removeCapability getOrDefault ["code", ""]] call _assert;
["Capacidade removida deixar de existir", !(["armorer.station", 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability), "removed"] call _assert;

private _failed = _total - _passed;
private _summary = format ["NEXUS 1.1: %1/%2 aprovados; %3 falha(s).", _passed, _total, _failed];
diag_log format ["[SP_ORG] %1", _summary];
if (!_silent && {hasInterface}) then {
    systemChat format ["[SP_ORG] %1", _summary];
    hint parseText format [
        "<t size='1.25'>SP_ORG — Nexus 1.1</t><br/><br/>%1/%2 testes aprovados.<br/>Falhas: %3<br/><br/>Build: %4",
        _passed,
        _total,
        _failed,
        SERVO_PEREGRINO_ORGANIZADOR_NEXUS_BUILD
    ];
};

[
    _failed isEqualTo 0,
    if (_failed isEqualTo 0) then {"TESTS_PASSED"} else {"TESTS_FAILED"},
    _summary,
    createHashMapFromArray [["passed", _passed], ["total", _total], ["failed", _failed], ["failures", _failures]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
