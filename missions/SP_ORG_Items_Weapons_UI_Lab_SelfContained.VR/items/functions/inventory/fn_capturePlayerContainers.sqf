#include "..\..\script_version.hpp"

params [
    ["_unit", objNull, [objNull]],
    ["_target", "ANY", [""]]
];

if (isNull _unit) exitWith {
    [false, "ITEMS_CAPTURE_UNIT_NULL", "Unidade nula não pode ser capturada.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _t = toUpper _target;
if (_t isEqualTo "UNIFORM") then {_t = "U";};
if (_t isEqualTo "VEST") then {_t = "C";};
if (_t isEqualTo "BACKPACK") then {_t = "M";};
if !(_t in ["ANY", "U", "C", "M"]) exitWith {
    [false, "ITEMS_CONTAINER_TARGET_INVALID", "Capture target inválido; use ANY/U/C/M.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _overallBefore = [_unit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
if !(_overallBefore getOrDefault ["success", false]) exitWith {_overallBefore};
private _beforeData = _overallBefore getOrDefault ["data", createHashMap];

private _targets = if (_t isEqualTo "ANY") then {["U", "C", "M"]} else {[_t]};
private _allEntries = [];
private _allReserved = [];
private _containers = [];
private _absentTargets = [];
private _fatal = createHashMap;

{
    private _capture = [_unit, _x] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
    if (_capture getOrDefault ["success", false]) then {
        private _cd = _capture getOrDefault ["data", createHashMap];
        {_allEntries pushBack _x;} forEach (_cd getOrDefault ["entries", []]);
        {_allReserved pushBack _x;} forEach (_cd getOrDefault ["reservedCargo", []]);
        _containers pushBack createHashMapFromArray [
            ["target", _cd getOrDefault ["target", ""]],
            ["canonicalTarget", _cd getOrDefault ["canonicalTarget", ""]],
            ["containerClass", _cd getOrDefault ["containerClass", ""]],
            ["entryCount", count (_cd getOrDefault ["entries", []])],
            ["reservedCount", count (_cd getOrDefault ["reservedCargo", []])]
        ];
    } else {
        if ((_capture getOrDefault ["code", ""]) isEqualTo "ITEMS_CONTAINER_ABSENT" && {_t isEqualTo "ANY"}) then {
            _absentTargets pushBack _x;
        } else {
            _fatal = _capture;
        };
    };
    if ((count _fatal) > 0) exitWith {};
} forEach _targets;
if ((count _fatal) > 0) exitWith {_fatal};

private _normalizedResult = [_allEntries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedResult getOrDefault ["success", false]) exitWith {_normalizedResult};
private _normalized = (_normalizedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
private _draftName = if (_t isEqualTo "ANY") then {"Captura U/C/M"} else {format ["Captura %1", _t]};
private _draftResult = [_normalized, _t, _draftName] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
if !(_draftResult getOrDefault ["success", false]) exitWith {_draftResult};

private _overallAfter = [_unit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
if !(_overallAfter getOrDefault ["success", false]) exitWith {_overallAfter};
private _afterData = _overallAfter getOrDefault ["data", createHashMap];
private _unchanged = (_beforeData getOrDefault ["serialized", ""]) isEqualTo (_afterData getOrDefault ["serialized", "__DIFFERENT__"]);
if (!_unchanged) exitWith {
    [false, "ITEMS_CAPTURE_MUTATED_LOADOUT", "Captura agregada detectou alteração de loadout e foi recusada.", createHashMapFromArray [["before", _beforeData], ["after", _afterData]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_CAPTURE_COMPLETED",
    "Captura PLAYER_CONTAINERS concluída sem mutar inventário ou Repository.",
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER],
        ["target", _t],
        ["entries", _normalized],
        ["reservedCargo", _allReserved],
        ["containers", _containers],
        ["absentTargets", _absentTargets],
        ["draft", ((_draftResult getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap])],
        ["loadoutUnchanged", true],
        ["fingerprintBefore", _beforeData],
        ["fingerprintAfter", _afterData]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
