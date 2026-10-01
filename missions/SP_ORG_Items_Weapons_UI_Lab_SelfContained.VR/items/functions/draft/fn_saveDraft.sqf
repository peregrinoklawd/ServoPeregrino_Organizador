#include "..\..\script_version.hpp"
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap]; if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy; private _mode = _draft getOrDefault ["mode", "NEW"];
if (_mode isEqualTo "EDIT" && {!(_draft getOrDefault ["dirty", false])}) exitWith {[true, "ITEMS_DRAFT_SAVE_NO_CHANGES", "Draft EDIT não possui alterações; nenhuma escrita foi feita.", createHashMapFromArray [["draft", _draft]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _saveResult = createHashMap;
if (_mode isEqualTo "NEW") then {
    private _created = [_draft getOrDefault ["name", ""], _draft getOrDefault ["entries", []], _draft getOrDefault ["preferredTarget", "ANY"], _draft getOrDefault ["origin", ["MANUAL", "LOCAL"]]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
    if !(_created getOrDefault ["success", false]) exitWith {_saveResult = _created;};
    _saveResult = [((_created getOrDefault ["data", createHashMap]) getOrDefault ["kit", []])] call ServoPeregrino_Organizador_Items_fnc_saveKit;
} else {
    if !(_mode isEqualTo "EDIT") exitWith {_saveResult = [false, "ITEMS_DRAFT_MODE_INVALID", "Modo de Draft inválido para save.", createHashMapFromArray [["mode", _mode]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
    private _kitId = _draft getOrDefault ["kitId", ""]; private _get = [_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
    if !(_get getOrDefault ["success", false]) exitWith {_saveResult = _get;};
    private _repoKit = ((_get getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
    if !((_repoKit # 7) isEqualTo (_draft getOrDefault ["baseUpdatedAtUTC", []])) exitWith {
        _saveResult = [false, "ITEMS_DRAFT_STALE", "ItemKit persistido mudou depois que o Draft EDIT foi aberto. Recarregue/descarte antes de salvar.", createHashMapFromArray [["kitId", _kitId], ["draftBaseUpdatedAtUTC", _draft getOrDefault ["baseUpdatedAtUTC", []]], ["repositoryUpdatedAtUTC", +(_repoKit # 7)]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    };
    if ((count _saveResult) isEqualTo 0) then {
        private _normalized = [_draft getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
        if !(_normalized getOrDefault ["success", false]) exitWith {_saveResult = _normalized;};
        private _candidate = [_repoKit] call ServoPeregrino_Organizador_Items_fnc_deepCopy; _candidate set [3, _draft getOrDefault ["name", ""]]; _candidate set [4, _draft getOrDefault ["preferredTarget", "ANY"]]; _candidate set [5, [_draft getOrDefault ["origin", ["MANUAL", "LOCAL"]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy]; _candidate set [8, [((_normalized getOrDefault ["data", createHashMap]) getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
        _saveResult = [_candidate] call ServoPeregrino_Organizador_Items_fnc_saveKit;
    };
};
if !(_saveResult getOrDefault ["success", false]) exitWith {_saveResult};
private _savedKit = ((_saveResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]); private _now = systemTimeUTC; private _cleanDraft = createHashMapFromArray [["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION], ["mode", "EDIT"], ["kitId", _savedKit # 2], ["baseUpdatedAtUTC", +(_savedKit # 7)], ["name", _savedKit # 3], ["preferredTarget", _savedKit # 4], ["origin", [(_savedKit # 5)] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["entries", [(_savedKit # 8)] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["dirty", false], ["createdFrom", _draft getOrDefault ["createdFrom", "MANUAL"]], ["openedAtUTC", _draft getOrDefault ["openedAtUTC", +_now]], ["lastModifiedAtUTC", +_now]];
_state set ["current", _cleanDraft]; _state set ["baseline", [_cleanDraft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]; _state set ["revision", (_state getOrDefault ["revision", 0]) + 1]; _state set ["lastAction", "SAVE"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[true, if (_mode isEqualTo "NEW") then {"ITEMS_DRAFT_SAVED_NEW"} else {"ITEMS_DRAFT_SAVED_EDIT"}, "Draft persistido explicitamente e convertido/atualizado para estado EDIT limpo.", createHashMapFromArray [["kit", _savedKit], ["draft", [_cleanDraft] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["storageResult", _saveResult]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
