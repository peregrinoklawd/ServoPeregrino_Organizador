#include "..\..\script_version.hpp"
params [
    ["_sourceType", "", [""]],
    ["_sourceIDC", -1, [0]],
    ["_sourceId", "", [""]]
];
// Payload is deliberately optional for backward-compatible START callers.
// Never persist nil inside UI state: nil cannot be safely traversed by the
// recursive defensive deepCopy used by getUIState/view-model construction.
private _hasPayload = (count _this) > 3;
private _payload = if (_hasPayload) then {_this # 3} else {[]};
private _sourceText = if ((count _this) > 4) then {_this # 4} else {""};
if !(_sourceText isEqualType "") then {_sourceText = str _sourceText;};
private _sourcePicture = if ((count _this) > 5) then {_this # 5} else {""};
if !(_sourcePicture isEqualType "") then {_sourcePicture = str _sourcePicture;};

private _type = toUpper _sourceType;
private _frozenPayload = if (_hasPayload) then {[_payload] call ServoPeregrino_Organizador_Items_fnc_deepCopy} else {[]};
if !(_type in ["KIT","CATALOG","EQUIPMENT","ENTRY"]) exitWith {
    [false, "ITEMS_UI_DRAG_SOURCE_INVALID", "Origem não pode iniciar DnD.", createHashMapFromArray [["sourceType", _sourceType], ["sourceIDC", _sourceIDC]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _drag = createHashMapFromArray [
    ["active", true], ["sourceType", _type], ["sourceIDC", _sourceIDC], ["sourceId", _sourceId],
    ["sourcePayload", _frozenPayload], ["hasSourcePayload", _hasPayload],
    ["sourceText", _sourceText], ["sourcePicture", _sourcePicture], ["startedAtTick", diag_tickTime], ["frozenAtRevision", (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap]) getOrDefault ["revision",0]]
];
[true, "ITEMS_UI_DRAG_SNAPSHOT_FROZEN", "Identidade e payload do drag foram congelados no START.", createHashMapFromArray [["drag", _drag]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
