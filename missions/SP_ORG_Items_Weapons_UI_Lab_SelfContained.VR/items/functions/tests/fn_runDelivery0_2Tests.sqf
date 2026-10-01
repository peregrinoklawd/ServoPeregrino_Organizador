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
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.2] [%1] %2 — %3", _status, _id, _detail];
};

[] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;

// -------------------------------------------------------------------------
// Regressão da fundação 0.1
// -------------------------------------------------------------------------
private _build = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
["ITEMS-0.2-001", (_build getOrDefault ["component", ""]) isEqualTo "Items", "getBuildInfo identifica Items."] call _assert;
["ITEMS-0.2-002", (_build getOrDefault ["displayVersion", ""]) isEqualTo "0.2", "displayVersion é 0.2."] call _assert;
["ITEMS-0.2-003", (_build getOrDefault ["semanticVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION, "semanticVersion corresponde à candidata 0.2."] call _assert;

private _nexusValidation = [] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
["ITEMS-0.2-004", _nexusValidation getOrDefault ["success", false], "Nexus 1.1 atual é aceito."] call _assert;
private _incompatible = [999] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
["ITEMS-0.2-005", !(_incompatible getOrDefault ["success", true]) && {(_incompatible getOrDefault ["code", ""]) isEqualTo "ITEMS_NEXUS_INCOMPATIBLE"}, "Versão incompatível falha controladamente."] call _assert;

private _init = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
["ITEMS-0.2-006", (_init getOrDefault ["success", false]) && {(_init getOrDefault ["code", ""]) isEqualTo "ITEMS_INITIALIZED"}, "Primeira inicialização é bem-sucedida."] call _assert;
["ITEMS-0.2-007", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false], "Flag de lifecycle foi gravada."] call _assert;
private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
["ITEMS-0.2-008", (_runtime getOrDefault ["status", ""]) isEqualTo "READY" && {_runtime getOrDefault ["ready", false]}, "Runtime termina em READY."] call _assert;
["ITEMS-0.2-009", [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability, "items.runtime v1 registrada."] call _assert;
["ITEMS-0.2-010", [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INTERFACE_VERSION] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability, "items.ui v1 registrada."] call _assert;

private _runtimeCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _runtimeCap = (_runtimeCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
["ITEMS-0.2-011", (_runtimeCap getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER, "items.runtime pertence a Items."] call _assert;
private _runtimeMetadata = _runtimeCap getOrDefault ["metadata", createHashMap];
["ITEMS-0.2-012", (_runtimeMetadata getOrDefault ["dataModelReady", false]) && {(_runtimeMetadata getOrDefault ["itemKitVersion", 0]) isEqualTo 1} && {(_runtimeMetadata getOrDefault ["itemEntryVersion", 0]) isEqualTo 1}, "Runtime publica Data Model v1 como pronto."] call _assert;

private _uiCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _uiCap = (_uiCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
private _uiMetadata = _uiCap getOrDefault ["metadata", createHashMap];
["ITEMS-0.2-013", !(_uiMetadata getOrDefault ["ready", true]) && {(_uiMetadata getOrDefault ["status", ""]) isEqualTo "SKELETON"}, "UI continua stub; escopo não foi antecipado."] call _assert;
private _uiStub = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
["ITEMS-0.2-014", !(_uiStub getOrDefault ["success", true]) && {(_uiStub getOrDefault ["code", ""]) isEqualTo "ITEMS_UI_NOT_IMPLEMENTED"}, "openInterface continua falhando de forma controlada."] call _assert;
private _secondInit = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
["ITEMS-0.2-015", (_secondInit getOrDefault ["success", false]) && {(_secondInit getOrDefault ["code", ""]) isEqualTo "ITEMS_ALREADY_INITIALIZED"}, "initialize continua idempotente."] call _assert;
private _status = [] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus;
private _statusData = _status getOrDefault ["data", createHashMap];
["ITEMS-0.2-016", (_status getOrDefault ["success", false]) && {(_statusData getOrDefault ["status", ""]) isEqualTo "READY"} && {_statusData getOrDefault ["dataModelReady", false]}, "items.runtime expõe READY e dataModelReady."] call _assert;

// -------------------------------------------------------------------------
// IDs imutáveis e formato canônico
// -------------------------------------------------------------------------
private _id1 = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
private _id2 = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
["ITEMS-0.2-017", [_id1] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId, "ID gerado obedece sporg-itemkit-<UTC>-<8 dígitos>-<contador>."] call _assert;
["ITEMS-0.2-018", !(_id1 isEqualTo _id2) && {[_id2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "IDs consecutivos são distintos e válidos."] call _assert;
["ITEMS-0.2-019", !(["sporg-itemkit-20260826T170200-1e+007-0001"] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId), "Representação científica é rejeitada no ID."] call _assert;
["ITEMS-0.2-020", !(["sporg-itemkit-20260826T170200-12345678-00 1"] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId), "Espaço/caractere inválido é rejeitado no ID."] call _assert;

// -------------------------------------------------------------------------
// ItemEntry v1
// -------------------------------------------------------------------------
private _itemResult = ["ITEM", "FirstAidKit", 2, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _itemEntry = (_itemResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.2-021", _itemResult getOrDefault ["success", false], "ITEM/NONE pode ser criado."] call _assert;
["ITEMS-0.2-022", _itemEntry isEqualTo [1, "ITEM", "FirstAidKit", 2, "NONE", []], "ITEM v1 possui formato canônico."] call _assert;
private _itemWrongMode = ["ITEM", "FirstAidKit", 1, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.2-023", !(_itemWrongMode getOrDefault ["success", true]), "ITEM não aceita stateMode de magazine."] call _assert;

private _fullResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fullEntry = (_fullResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.2-024", (_fullResult getOrDefault ["success", false]) && {(_fullEntry # 3) isEqualTo 3} && {(_fullEntry # 4) isEqualTo "DEFAULT_FULL"}, "MAGAZINE DEFAULT_FULL é válido."] call _assert;

private _exactResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactEntry = (_exactResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.2-025", _exactResult getOrDefault ["success", false], "MAGAZINE EXACT válido é aceito."] call _assert;
["ITEMS-0.2-026", (_exactResult getOrDefault ["success", false]) && {(count _exactEntry) isEqualTo 6} && {(_exactEntry # 5) isEqualTo [30,17,6]}, "EXACT preserva exatamente [30,17,6]."] call _assert;
private _exactMismatch = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.2-027", !(_exactMismatch getOrDefault ["success", true]) && {(_exactMismatch getOrDefault ["code", ""]) isEqualTo "ITEMS_MAG_EXACT_COUNT_MISMATCH"}, "quantity != count(stateData) é rejeitado com código específico."] call _assert;
private _exactNegative = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [-1]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.2-028", !(_exactNegative getOrDefault ["success", true]), "Munição negativa em EXACT é rejeitada."] call _assert;
private _exactZero = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [0]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.2-029", _exactZero getOrDefault ["success", false], "Magazine vazio EXACT [0] permanece representável."] call _assert;

// -------------------------------------------------------------------------
// Normalização: nunca misturar DEFAULT_FULL e EXACT
// -------------------------------------------------------------------------
private _itemA = ((_itemResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _itemBResult = ["ITEM", "FirstAidKit", 3, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _itemB = (_itemBResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normItemsResult = [[_itemA, _itemB]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normItems = (_normItemsResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.2-030", (_normItemsResult getOrDefault ["success", false]) && {(count _normItems) isEqualTo 1} && {((_normItems # 0) # 3) isEqualTo 5}, "ITEM repetido agrupa quantidade."] call _assert;

private _full2Result = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _full2 = (_full2Result getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normFullResult = [[_fullEntry, _full2]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normFull = (_normFullResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.2-031", (count _normFull) isEqualTo 1 && {((_normFull # 0) # 3) isEqualTo 5}, "DEFAULT_FULL da mesma classe agrupa quantidade."] call _assert;

private _exactAResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30,17]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactBResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactA = (_exactAResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _exactB = (_exactBResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normExactResult = [[_exactA, _exactB]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normExact = (_normExactResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.2-032", (count _normExact) isEqualTo 1 && {((_normExact # 0) # 3) isEqualTo 3} && {((_normExact # 0) # 5) isEqualTo [30,17,6]}, "EXACT concatena stateData preservando ordem e quantity=count."] call _assert;

private _mixedResult = [[_fullEntry, _exactEntry]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _mixed = (_mixedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.2-033", (count _mixed) isEqualTo 2 && {((_mixed # 0) # 4) isEqualTo "DEFAULT_FULL"} && {((_mixed # 1) # 4) isEqualTo "EXACT"}, "DEFAULT_FULL e EXACT nunca são agrupados entre si."] call _assert;

private _badNormalize = [[[1, "MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30]]]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
["ITEMS-0.2-034", !(_badNormalize getOrDefault ["success", true]) && {(_badNormalize getOrDefault ["code", ""]) isEqualTo "ITEMS_MAG_EXACT_COUNT_MISMATCH"}, "Normalização recusa entrada inválida em vez de corrigir silenciosamente."] call _assert;

// -------------------------------------------------------------------------
// ItemKit v1 em memória
// -------------------------------------------------------------------------
private _kitResult = ["Kit Médico 0.2", [_itemA, _itemB, _exactA, _exactB, _fullEntry], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit = (_kitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.2-035", _kitResult getOrDefault ["success", false], "ItemKit v1 é criado em memória."] call _assert;
["ITEMS-0.2-036", (_kitResult getOrDefault ["success", false]) && {(count _kit) isEqualTo 10} && {(_kit # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC} && {(_kit # 1) isEqualTo 1}, "ItemKit possui magic e version exclusivos de Items."] call _assert;
["ITEMS-0.2-037", ((count _kit) isEqualTo 10) && {[_kit # 2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "ItemKit recebe ID canônico imutável."] call _assert;
private _kitEntries = _kit # 8;
["ITEMS-0.2-038", (count _kitEntries) isEqualTo 3, "createItemKit normaliza ITEM, EXACT e DEFAULT_FULL em três entradas separadas."] call _assert;
private _kitExactIndex = _kitEntries findIf {((_x # 1) isEqualTo "MAGAZINE") && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.2-039", _kitExactIndex >= 0 && {((_kitEntries # _kitExactIndex) # 5) isEqualTo [30,17,6]}, "ItemKit preserva [30,17,6] após normalização."] call _assert;
["ITEMS-0.2-040", ((count _kit) isEqualTo 10) && {(_kit # 4) isEqualTo "ANY"}, "preferredTarget ANY é preservado."] call _assert;
private _kitSemantic = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
["ITEMS-0.2-041", _kitSemantic getOrDefault ["success", false], "ItemKit criado passa validação semântica."] call _assert;

private _renameResult = [_kit, "Kit Médico Renomeado"] call ServoPeregrino_Organizador_Items_fnc_renameItemKit;
private _renamedKit = (_renameResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.2-042", (_renameResult getOrDefault ["success", false]) && {(_renamedKit # 2) isEqualTo (_kit # 2)} && {(_renamedKit # 3) isEqualTo "Kit Médico Renomeado"}, "Renomear preserva o ID imutável."] call _assert;

private _cloneResult = [_kit, "Kit Médico Clone"] call ServoPeregrino_Organizador_Items_fnc_cloneItemKit;
private _cloneKit = (_cloneResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.2-043", (_cloneResult getOrDefault ["success", false]) && {!((_cloneKit # 2) isEqualTo (_kit # 2))} && {[_cloneKit # 2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "Clone recebe novo ID válido."] call _assert;
["ITEMS-0.2-044", (_cloneResult getOrDefault ["success", false]) && {(count _cloneKit) isEqualTo 10} && {(count _kit) isEqualTo 10} && {(_cloneKit # 8) isEqualTo (_kit # 8)}, "Clone preserva conteúdo e estados EXACT."] call _assert;

private _badMagicResult = createHashMap;
if ((count _kit) isEqualTo 10) then {
    private _badMagic = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badMagic set [0, "APM_KIT"];
    _badMagicResult = [_badMagic] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
};
["ITEMS-0.2-045", ((count _kit) isEqualTo 10) && {!(_badMagicResult getOrDefault ["success", true])}, "ItemKit rejeita magic de outro domínio/projeto."] call _assert;

private _badTargetResult = createHashMap;
if ((count _kit) isEqualTo 10) then {
    private _badTarget = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badTarget set [4, "WEAPON"];
    _badTargetResult = [_badTarget] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
};
["ITEMS-0.2-046", ((count _kit) isEqualTo 10) && {!(_badTargetResult getOrDefault ["success", true])}, "preferredTarget fora de ANY/U/C/M é rejeitado."] call _assert;

private _badStructure = [_kit select [0, 9]] call ServoPeregrino_Organizador_Items_fnc_validateItemKitStructural;
["ITEMS-0.2-047", !(_badStructure getOrDefault ["success", true]), "Payload estrutural com campo ausente é rejeitado."] call _assert;

private _emptyKitResult = ["Kit Vazio", [], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
["ITEMS-0.2-048", !(_emptyKitResult getOrDefault ["success", true]) && {(_emptyKitResult getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_PAYLOAD_EMPTY"}, "ItemKit persistível vazio é rejeitado; draft vazio fica para 0.6."] call _assert;

// -------------------------------------------------------------------------
// Validação ambiental separada: indisponível não invalida schema persistível
// -------------------------------------------------------------------------
private _availableEntryResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _availableEntry = (_availableEntryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _availableEnv = [_availableEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
["ITEMS-0.2-049", _availableEnv getOrDefault ["success", false], "Classe vanilla existente é ambientalmente disponível."] call _assert;

private _missingEntryResult = ["ITEM", "SP_ORG_ITEMS_CLASS_DOES_NOT_EXIST_0_2", 1, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _missingEntry = (_missingEntryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _missingSemantic = [_missingEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
private _missingEnv = [_missingEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
["ITEMS-0.2-050", (_missingSemantic getOrDefault ["success", false]) && {!(_missingEnv getOrDefault ["success", true])} && {(_missingEnv getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE"}, "Classe ausente continua semanticamente persistível e falha somente no nível ambiental."] call _assert;

private _missingKitResult = ["Kit Mod Ausente", [_missingEntry], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _missingKit = (_missingKitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _missingKitBefore = [_missingKit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _missingKitEnv = [_missingKit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitEnvironmental;
["ITEMS-0.2-051", (_missingKitResult getOrDefault ["success", false]) && {!(_missingKitEnv getOrDefault ["success", true])} && {(_missingKitEnv getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE"}, "ItemKit com mod ausente permanece criável/persistível, mas é marcado ambientalmente indisponível."] call _assert;
["ITEMS-0.2-052", _missingKit isEqualTo _missingKitBefore, "Validação ambiental não apaga nem altera ItemKit indisponível."] call _assert;

// -------------------------------------------------------------------------
// Storage v1 em memória — schema que a entrega 0.3 persistirá
// -------------------------------------------------------------------------
private _emptyStorageResult = [[], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
private _emptyStorage = (_emptyStorageResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []];
["ITEMS-0.2-053", (_emptyStorageResult getOrDefault ["success", false]) && {(count (_emptyStorage # 2)) isEqualTo 0}, "Storage v1 vazio é válido como estado inicial em memória."] call _assert;
["ITEMS-0.2-054", (_emptyStorageResult getOrDefault ["success", false]) && {(count _emptyStorage) isEqualTo 4} && {(_emptyStorage # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC} && {(_emptyStorage # 1) isEqualTo 1}, "Storage possui magic/version exclusivos de Items."] call _assert;

private _storageWithKitResult = [[_kit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
private _storageWithKit = (_storageWithKitResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []];
["ITEMS-0.2-055", (_storageWithKitResult getOrDefault ["success", false]) && {(count (_storageWithKit # 2)) isEqualTo 1}, "Storage aceita ItemKit semanticamente válido."] call _assert;

private _duplicateStorageResult = [[_kit, _kit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
["ITEMS-0.2-056", !(_duplicateStorageResult getOrDefault ["success", true]) && {(_duplicateStorageResult getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_DUPLICATE_KIT_ID"}, "Storage rejeita IDs de ItemKit duplicados."] call _assert;

private _storageMissingResult = [[_missingKit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
["ITEMS-0.2-057", _storageMissingResult getOrDefault ["success", false], "Storage semântico preserva kit de mod ausente; disponibilidade continua ambiental."] call _assert;

private _badStorageResult = createHashMap;
if ((count _emptyStorage) isEqualTo 4) then {
    private _badStorage = [_emptyStorage] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badStorage set [0, "APM_STORAGE"];
    _badStorageResult = [_badStorage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
};
["ITEMS-0.2-058", ((count _emptyStorage) isEqualTo 4) && {!(_badStorageResult getOrDefault ["success", true])} && {(_badStorageResult getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_INVALID_MAGIC"}, "Storage rejeita magic pertencente a outro domínio/projeto."] call _assert;

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery", "0.2"],
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
diag_log format ["[SP_ORG] [ITEMS] ENTREGA 0.2 — TOTAL=%1 PASS=%2 FAIL=%3 TEMPO=%4ms", _total, _passed, _failed, _durationMs];
diag_log "============================================================";

if (hasInterface) then {
    hint parseText format [
        "<t size='1.25'>SP_ORG_Items — Testes 0.2</t><br/><br/><t color='#7CFC00'>PASS: %1</t><br/><t color='%2'>FAIL: %3</t><br/>Total: %4<br/>Tempo: %5 ms<br/><br/>Gate esperado: <t color='#7CFC00'>58 / 58</t><br/>Consulte o RPT para os IDs individuais.",
        _passed,
        if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},
        _failed,
        _total,
        _durationMs
    ];
};

_summary
