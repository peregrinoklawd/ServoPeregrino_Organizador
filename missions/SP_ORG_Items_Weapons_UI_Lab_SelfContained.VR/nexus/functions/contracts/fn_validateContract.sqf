#include "..\..\script_version.hpp"

params [["_contract", createHashMap]];

if !(_contract isEqualType createHashMap) exitWith {
    [false, "CONTRACT_TYPE_INVALID", "O contrato deve ser um HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_contract getOrDefault ["schema", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_MAGIC) exitWith {
    [false, "CONTRACT_SCHEMA_INVALID", "O schema do contrato é inválido."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _contractId = _contract getOrDefault ["contract", ""];
private _version = _contract getOrDefault ["version", 0];
private _source = _contract getOrDefault ["source", ""];
private _correlationId = _contract getOrDefault ["correlationId", ""];
private _payload = _contract getOrDefault ["payload", createHashMap];

if (
    _contractId isEqualTo ""
    || {_version < 1}
    || {_source isEqualTo ""}
    || {_correlationId isEqualTo ""}
    || {!(_payload isEqualType createHashMap)}
) exitWith {
    [false, "CONTRACT_STRUCTURE_INVALID", "O contrato não possui identidade, versão, origem, correlação ou payload válidos."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_REGISTRY_VAR, createHashMap];
private _registryKey = format ["%1@%2", toLowerANSI _contractId, _version];
private _definition = _registry getOrDefault [_registryKey, createHashMap];

if ((count _definition) isEqualTo 0) exitWith {
    [false, "CONTRACT_UNSUPPORTED", format ["Contrato não registrado: %1.", _registryKey]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _payloadKeys = keys _payload;
private _missing = (_definition getOrDefault ["requiredPayloadKeys", []]) select {!(_x in _payloadKeys)};
if ((count _missing) > 0) exitWith {
    [false, "CONTRACT_PAYLOAD_INCOMPLETE", "O payload não contém todas as chaves obrigatórias.", createHashMapFromArray [["missingKeys", _missing]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true, "CONTRACT_VALID", "Contrato válido.", createHashMapFromArray [["contract", _contract], ["definition", _definition]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
