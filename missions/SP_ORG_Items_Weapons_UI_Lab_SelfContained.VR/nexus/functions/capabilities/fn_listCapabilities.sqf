#include "..\..\script_version.hpp"

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
private _ids = keys _registry;
_ids sort true;

private _entries = [];
{
    _entries pushBack (_registry get _x);
} forEach _ids;

[true, "CAPABILITIES_LISTED", format ["%1 capacidade(s) registrada(s).", count _entries], createHashMapFromArray [["capabilities", _entries]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
