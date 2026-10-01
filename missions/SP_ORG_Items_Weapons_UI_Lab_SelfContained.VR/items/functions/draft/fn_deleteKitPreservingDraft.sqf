#include "..\..\script_version.hpp"
params [["_kitId", "", [""]]];
if !([_kitId] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId) exitWith {
    [false, "ITEMS_KIT_ID_INVALID", "ID informado para exclusão é inválido.", createHashMapFromArray [["kitId", _kitId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftData = _draftR getOrDefault ["data", createHashMap];
private _current = _draftData getOrDefault ["current", createHashMap];
private _isBacking = (_draftData getOrDefault ["hasDraft", false]) && {(_current getOrDefault ["mode", ""]) isEqualTo "EDIT"} && {(_current getOrDefault ["kitId", ""]) isEqualTo _kitId};
private _delete = [_kitId] call ServoPeregrino_Organizador_Items_fnc_deleteKit;
if !(_delete getOrDefault ["success", false]) exitWith {_delete};
private _detach = if (_isBacking) then {[_kitId] call ServoPeregrino_Organizador_Items_fnc_detachDraftFromPersistedKit} else {[true, "ITEMS_DRAFT_DETACH_NOOP", "Draft atual não dependia do kit excluído.", createHashMapFromArray [["kitId", _kitId], ["detached", false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(_detach getOrDefault ["success", false]) exitWith {
    [false, "ITEMS_KIT_DELETED_DRAFT_DETACH_FAILED", "O ItemKit foi excluído, mas o Draft não pôde ser desacoplado; estado de UI/Draft requer atenção.", createHashMapFromArray [["repositoryDeleted", true], ["kitId", _kitId], ["deleteResult", _delete], ["detachResult", _detach]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _detached = ((_detach getOrDefault ["data", createHashMap]) getOrDefault ["detached", false]);
[
    true,
    if (_detached) then {"ITEMS_KIT_DELETED_DRAFT_PRESERVED"} else {"ITEMS_KIT_PERSISTED_DELETED"},
    if (_detached) then {"Kit salvo excluído; conteúdo aberto preservado como novo Draft não salvo."} else {"Kit salvo excluído permanentemente."},
    createHashMapFromArray [["kitId", _kitId], ["draftDetached", _detached], ["deleteResult", _delete], ["detachResult", _detach]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
