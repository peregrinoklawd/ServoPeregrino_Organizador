#include "..\..\script_version.hpp"
// Items UX: CAPTURAR substitui apenas entradas do rascunho, sem tocar no equipamento ou Repository.
// Preparar e validar a captura ANTES de qualquer escrita garante rollback por ausência de mutação.
params [["_unit",objNull,[objNull]],["_target","U",[""]]];
private _capture = [_unit,_target] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
if !(_capture getOrDefault ["success",false]) exitWith {_capture};
private _d = _capture getOrDefault ["data",createHashMap];
private _prepared = [
    _d getOrDefault ["entries",[]],
    _d getOrDefault ["canonicalTarget","ANY"],
    format ["Captura %1",_d getOrDefault ["canonicalTarget",_target]]
] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
if !(_prepared getOrDefault ["success",false]) exitWith {_prepared};
private _capturedDraft = ((_prepared getOrDefault ["data",createHashMap]) getOrDefault ["draft",createHashMap]);
private _newEntries = [_capturedDraft getOrDefault ["entries",[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
if !(_state getOrDefault ["hasDraft",false]) exitWith {
    // Sem rascunho: mantém a semântica já existente de criar um Draft NEW.
    [_capturedDraft] call ServoPeregrino_Organizador_Items_fnc_openCaptureDraft
};

// Com rascunho EDIT/NEW: preservar identidade, nome, destino preferido, baseline e origem.
// Substituir somente entries. O usuário decide depois se deseja SALVAR.
private _oldDraft = _state getOrDefault ["current",createHashMap];
if ((count _oldDraft) isEqualTo 0) exitWith {
    [false,"ITEMS_DRAFT_CAPTURE_STATE_INVALID","Estado de rascunho inválido; captura não aplicada.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _nextState = [_state] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _nextDraft = [_oldDraft] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_nextDraft set ["entries",_newEntries];
_nextDraft set ["dirty",true];
_nextDraft set ["lastModifiedAtUTC",systemTimeUTC];
_nextState set ["current",_nextDraft];
_nextState set ["revision",(_state getOrDefault ["revision",0])+1];
_nextState set ["lastAction","REPLACE_ENTRIES_FROM_CAPTURE"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_nextState];

[true,"ITEMS_DRAFT_CAPTURE_REPLACED","Conteúdo de ITENS DO KIT substituído pelo equipamento visualizado. Salve o kit para persistir a alteração.",createHashMapFromArray [
    ["capturedTarget",_d getOrDefault ["canonicalTarget",_target]],
    ["entryCount",count _newEntries],
    ["draft",[_nextDraft] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["repositoryWritten",false],["inventoryMutated",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
