#include "..\..\script_version.hpp"

private _startedAt = diag_tickTime;
private _total = 0;
private _passed = 0;
private _failed = 0;
private _results = [];

private _assert = {
    params [
        ["_id", "", [""]],
        ["_condition", false, [false]],
        ["_detail", "", [""]]
    ];

    _total = _total + 1;
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed = _passed + 1;} else {_failed = _failed + 1;};
    _results pushBack [_id, _status, _detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.1] [%1] %2 — %3", _status, _id, _detail];
};

[] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;

private _build = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
[
    "ITEMS-0.1-001",
    (_build getOrDefault ["component", ""]) isEqualTo "Items",
    "getBuildInfo identifica o componente Items."
] call _assert;
[
    "ITEMS-0.1-002",
    (_build getOrDefault ["displayVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION,
    "displayVersion é 0.1."
] call _assert;
[
    "ITEMS-0.1-003",
    (_build getOrDefault ["semanticVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION,
    "semanticVersion corresponde à entrega 0.1."
] call _assert;

private _nexusValidation = [] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
[
    "ITEMS-0.1-004",
    _nexusValidation getOrDefault ["success", false],
    "Nexus 1.1 atual é aceito."
] call _assert;

private _incompatible = [999] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
[
    "ITEMS-0.1-005",
    !(_incompatible getOrDefault ["success", true]) && {(_incompatible getOrDefault ["code", ""]) isEqualTo "ITEMS_NEXUS_INCOMPATIBLE"},
    "Versão incompatível falha de forma controlada antes de inicializar Items."
] call _assert;

private _init = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
[
    "ITEMS-0.1-006",
    (_init getOrDefault ["success", false]) && {(_init getOrDefault ["code", ""]) isEqualTo "ITEMS_INITIALIZED"},
    "Primeira inicialização é bem-sucedida."
] call _assert;
[
    "ITEMS-0.1-007",
    missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false],
    "Flag de lifecycle foi gravada."
] call _assert;

private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
[
    "ITEMS-0.1-008",
    (_runtime getOrDefault ["status", ""]) isEqualTo "READY" && {_runtime getOrDefault ["ready", false]},
    "Runtime termina em READY."
] call _assert;

[
    "ITEMS-0.1-009",
    [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability,
    "Capability items.runtime v1 foi registrada."
] call _assert;
[
    "ITEMS-0.1-010",
    [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INTERFACE_VERSION] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability,
    "Capability items.ui v1 foi registrada."
] call _assert;

private _runtimeCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _runtimeCap = (_runtimeCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
[
    "ITEMS-0.1-011",
    (_runtimeCap getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER,
    "items.runtime pertence ao provedor Items."
] call _assert;

private _uiCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _uiCap = (_uiCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
private _uiMetadata = _uiCap getOrDefault ["metadata", createHashMap];
[
    "ITEMS-0.1-012",
    !(_uiMetadata getOrDefault ["ready", true]) && {(_uiMetadata getOrDefault ["status", ""]) isEqualTo "SKELETON"},
    "items.ui existe sem fingir que a UI final está pronta."
] call _assert;

private _uiStub = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
[
    "ITEMS-0.1-013",
    !(_uiStub getOrDefault ["success", true]) && {(_uiStub getOrDefault ["code", ""]) isEqualTo "ITEMS_UI_NOT_IMPLEMENTED"},
    "Abertura da UI é um stub controlado; nenhuma UI final foi antecipada."
] call _assert;

private _secondInit = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
[
    "ITEMS-0.1-014",
    (_secondInit getOrDefault ["success", false]) && {(_secondInit getOrDefault ["code", ""]) isEqualTo "ITEMS_ALREADY_INITIALIZED"},
    "initialize é idempotente."
] call _assert;

private _status = [] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus;
private _statusData = _status getOrDefault ["data", createHashMap];
[
    "ITEMS-0.1-015",
    (_status getOrDefault ["success", false]) && {(_statusData getOrDefault ["status", ""]) isEqualTo "READY"},
    "items.runtime expõe status READY."
] call _assert;
[
    "ITEMS-0.1-016",
    !(_statusData getOrDefault ["uiReady", true]),
    "Runtime declara explicitamente uiReady=false na entrega 0.1."
] call _assert;

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery", "0.1"],
    ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["total", _total],
    ["passed", _passed],
    ["failed", _failed],
    ["durationMs", _durationMs],
    ["results", _results],
    ["success", _failed isEqualTo 0]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, _summary];

diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] ENTREGA 0.1 — TOTAL=%1 PASS=%2 FAIL=%3 TEMPO=%4ms", _total, _passed, _failed, _durationMs];
diag_log "============================================================";

if (hasInterface) then {
    hint parseText format [
        "<t size='1.25'>SP_ORG_Items — Testes 0.1</t><br/><br/><t color='#7CFC00'>PASS: %1</t><br/><t color='%2'>FAIL: %3</t><br/>Total: %4<br/>Tempo: %5 ms<br/><br/>Consulte o RPT para os IDs individuais.",
        _passed,
        if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},
        _failed,
        _total,
        _durationMs
    ];
};

_summary
