#include "..\..\script_version.hpp"

params [
    ["_contractId", "", [""]],
    ["_version", 1, [0]],
    ["_provider", "", [""]],
    ["_requiredPayloadKeys", [], [[]]],
    ["_metadata", createHashMap, [createHashMap]]
];

private _normalizedId = toLowerANSI _contractId;
if (_normalizedId isEqualTo "") exitWith {
    [false, "CONTRACT_ID_REQUIRED", "O identificador do contrato é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_version < 1) exitWith {
    [false, "CONTRACT_VERSION_INVALID", "A versão do contrato deve ser maior ou igual a 1."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_provider isEqualTo "") exitWith {
    [false, "CONTRACT_PROVIDER_REQUIRED", "O provedor do contrato é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if ((_requiredPayloadKeys findIf {!(_x isEqualType "") || {_x isEqualTo ""}}) >= 0) exitWith {
    [false, "CONTRACT_REQUIRED_KEYS_INVALID", "Todas as chaves obrigatórias devem ser textos não vazios."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_REGISTRY_VAR, createHashMap];
private _registryKey = format ["%1@%2", _normalizedId, _version];
private _existing = _registry getOrDefault [_registryKey, createHashMap];

if ((count _existing) > 0) exitWith {
    private _existingKeys = +(_existing getOrDefault ["requiredPayloadKeys", []]);
    private _newKeys = +_requiredPayloadKeys;
    _existingKeys sort true;
    _newKeys sort true;

    if (
        (_existing getOrDefault ["provider", ""]) isEqualTo _provider
        && {_existingKeys isEqualTo _newKeys}
    ) then {
        [true, "CONTRACT_ALREADY_REGISTERED", "O contrato já estava registrado com a mesma definição.", createHashMapFromArray [["definition", _existing]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    } else {
        [false, "CONTRACT_CONFLICT", format ["O contrato %1 já possui outra definição ou provedor.", _registryKey], createHashMapFromArray [["definition", _existing]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    }
};

private _definition = createHashMapFromArray [
    ["id", _normalizedId],
    ["version", _version],
    ["provider", _provider],
    ["requiredPayloadKeys", +_requiredPayloadKeys],
    ["metadata", _metadata],
    ["registeredAtUTC", systemTimeUTC]
];
_registry set [_registryKey, _definition];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_REGISTRY_VAR, _registry];

[true, "CONTRACT_REGISTERED", format ["Contrato registrado: %1.", _registryKey], createHashMapFromArray [["definition", _definition]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
