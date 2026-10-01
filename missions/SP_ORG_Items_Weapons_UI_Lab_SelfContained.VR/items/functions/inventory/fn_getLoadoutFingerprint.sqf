params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {
    [false, "ITEMS_CAPTURE_UNIT_NULL", "Não é possível obter fingerprint de unidade nula.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _loadout = getUnitLoadout _unit;
private _copy = [_loadout] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
[
    true,
    "ITEMS_LOADOUT_FINGERPRINT_CREATED",
    "Fingerprint estrutural do loadout criado em modo somente leitura.",
    createHashMapFromArray [
        ["loadout", _copy],
        ["serialized", str _copy]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
