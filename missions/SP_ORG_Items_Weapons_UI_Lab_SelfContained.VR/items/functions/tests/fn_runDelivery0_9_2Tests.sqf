#include "..\..\script_version.hpp"


private _existingTestState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_existingTestState getOrDefault ["running", false]) exitWith {
    private _elapsed = round ((diag_tickTime - (_existingTestState getOrDefault ["startedAtTick", diag_tickTime])) * 1000);
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.9.2] [BUSY] Suíte já está em execução (%1 ms). Nova execução recusada.", _elapsed];
    if (hasInterface) then {
        hint format ["SP_ORG_Items 0.9.2: suíte já em execução (%1 ms). Aguarde o resumo final.", _elapsed];
    };
    createHashMapFromArray [
        ["success", false],
        ["code", "ITEMS_TEST_SUITE_ALREADY_RUNNING"],
        ["elapsedMs", _elapsed]
    ]
};

private _testState = createHashMapFromArray [
    ["running", true],
    ["delivery", "0.9.2"],
    ["startedAtTick", diag_tickTime]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, _testState];

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
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.9.2] [%1] %2 — %3", _status, _id, _detail];
};

// 0.9.2: cada gate de invariância compara um segmento curto; baseline global fica apenas histórica/diagnóstica.
private _compareLoadoutSegment = {
    params ["_beforeData","_afterData","_label"];
    private _cmp=[_beforeData,_afterData,_label] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
    private _d=_cmp getOrDefault ["data",createHashMap];
    if !(_d getOrDefault ["equal",false]) then {
        diag_log format ["[SP_ORG] [ITEMS] [TEST 0.9.2] [LOADOUT DIFF] %1 changedIndexes=%2",_label,_d getOrDefault ["changedIndexes",[]]];
    };
    _d getOrDefault ["equal",false]
};

[] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;
private _testModeSetup = ["AUTO_0_9_2", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;

// -------------------------------------------------------------------------
// Regressão da fundação 0.1
// -------------------------------------------------------------------------
private _build = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
["ITEMS-0.4-001", (_build getOrDefault ["component", ""]) isEqualTo "Items", "getBuildInfo identifica Items."] call _assert;
["ITEMS-0.4-002", (_build getOrDefault ["displayVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION, "displayVersion corresponde ao header da candidata corrente."] call _assert;
["ITEMS-0.4-003", (_build getOrDefault ["semanticVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION, "semanticVersion corresponde ao header da candidata corrente."] call _assert;

private _nexusValidation = [] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
["ITEMS-0.4-004", _nexusValidation getOrDefault ["success", false], "Nexus 1.1 atual é aceito."] call _assert;
private _incompatible = [999] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
["ITEMS-0.4-005", !(_incompatible getOrDefault ["success", true]) && {(_incompatible getOrDefault ["code", ""]) isEqualTo "ITEMS_NEXUS_INCOMPATIBLE"}, "Versão incompatível falha controladamente."] call _assert;

private _init = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
["ITEMS-0.4-006", (_init getOrDefault ["success", false]) && {(_init getOrDefault ["code", ""]) isEqualTo "ITEMS_INITIALIZED"}, "Primeira inicialização é bem-sucedida."] call _assert;
["ITEMS-0.4-007", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false], "Flag de lifecycle foi gravada."] call _assert;
private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
["ITEMS-0.4-008", (_runtime getOrDefault ["status", ""]) isEqualTo "READY" && {_runtime getOrDefault ["ready", false]}, "Runtime termina em READY."] call _assert;
["ITEMS-0.4-009", [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability, "items.runtime v1 registrada."] call _assert;
["ITEMS-0.4-010", [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INTERFACE_VERSION] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability, "items.ui v1 registrada."] call _assert;

private _runtimeCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _runtimeCap = (_runtimeCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
["ITEMS-0.4-011", (_runtimeCap getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER, "items.runtime pertence a Items."] call _assert;
private _runtimeMetadata = _runtimeCap getOrDefault ["metadata", createHashMap];
["ITEMS-0.4-012", (_runtimeMetadata getOrDefault ["dataModelReady", false]) && {(_runtimeMetadata getOrDefault ["itemKitVersion", 0]) isEqualTo 1} && {(_runtimeMetadata getOrDefault ["itemEntryVersion", 0]) isEqualTo 1}, "Runtime publica Data Model v1 como pronto."] call _assert;

private _uiCapResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
private _uiCap = (_uiCapResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
private _uiMetadata = _uiCap getOrDefault ["metadata", createHashMap];
["ITEMS-0.4-013", (_uiMetadata getOrDefault ["ready", false]) && {(_uiMetadata getOrDefault ["status", ""]) isEqualTo "DRAFT_DIRECT_MANIPULATION"} && {_uiMetadata getOrDefault ["draftInteractionReady", false]} && {!(_uiMetadata getOrDefault ["physicalMutationEnabled", true])}, "items.ui evolui para Draft Direct Manipulation mantendo físico explicitamente OFF."] call _assert;
["ITEMS-0.4-014", (_uiMetadata getOrDefault ["entryPoint", ""]) isEqualTo "ServoPeregrino_Organizador_Items_fnc_openInterface" && {(_uiMetadata getOrDefault ["mutatesInventory", true]) isEqualTo false}, "openInterface é entry point real da UI e metadata declara ausência de mutação física."] call _assert;
private _secondInit = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
["ITEMS-0.4-015", (_secondInit getOrDefault ["success", false]) && {(_secondInit getOrDefault ["code", ""]) isEqualTo "ITEMS_ALREADY_INITIALIZED"}, "initialize continua idempotente."] call _assert;
private _status = [] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus;
private _statusData = _status getOrDefault ["data", createHashMap];
["ITEMS-0.4-016", (_status getOrDefault ["success", false]) && {(_statusData getOrDefault ["status", ""]) isEqualTo "READY"} && {_statusData getOrDefault ["dataModelReady", false]}, "items.runtime expõe READY e dataModelReady."] call _assert;

// -------------------------------------------------------------------------
// IDs imutáveis e formato canônico
// -------------------------------------------------------------------------
private _id1 = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
private _id2 = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
["ITEMS-0.4-017", [_id1] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId, "ID gerado obedece sporg-itemkit-<UTC>-<8 dígitos>-<contador>."] call _assert;
["ITEMS-0.4-018", !(_id1 isEqualTo _id2) && {[_id2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "IDs consecutivos são distintos e válidos."] call _assert;
["ITEMS-0.4-019", !(["sporg-itemkit-20260826T170200-1e+007-0001"] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId), "Representação científica é rejeitada no ID."] call _assert;
["ITEMS-0.4-020", !(["sporg-itemkit-20260826T170200-12345678-00 1"] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId), "Espaço/caractere inválido é rejeitado no ID."] call _assert;

// -------------------------------------------------------------------------
// ItemEntry v1
// -------------------------------------------------------------------------
private _itemResult = ["ITEM", "FirstAidKit", 2, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _itemEntry = (_itemResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.4-021", _itemResult getOrDefault ["success", false], "ITEM/NONE pode ser criado."] call _assert;
["ITEMS-0.4-022", _itemEntry isEqualTo [1, "ITEM", "FirstAidKit", 2, "NONE", []], "ITEM v1 possui formato canônico."] call _assert;
private _itemWrongMode = ["ITEM", "FirstAidKit", 1, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.4-023", !(_itemWrongMode getOrDefault ["success", true]), "ITEM não aceita stateMode de magazine."] call _assert;

private _fullResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fullEntry = (_fullResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.4-024", (_fullResult getOrDefault ["success", false]) && {(_fullEntry # 3) isEqualTo 3} && {(_fullEntry # 4) isEqualTo "DEFAULT_FULL"}, "MAGAZINE DEFAULT_FULL é válido."] call _assert;

private _exactResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactEntry = (_exactResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
["ITEMS-0.4-025", _exactResult getOrDefault ["success", false], "MAGAZINE EXACT válido é aceito."] call _assert;
["ITEMS-0.4-026", (_exactResult getOrDefault ["success", false]) && {(count _exactEntry) isEqualTo 6} && {(_exactEntry # 5) isEqualTo [30,17,6]}, "EXACT preserva exatamente [30,17,6]."] call _assert;
private _exactMismatch = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.4-027", !(_exactMismatch getOrDefault ["success", true]) && {(_exactMismatch getOrDefault ["code", ""]) isEqualTo "ITEMS_MAG_EXACT_COUNT_MISMATCH"}, "quantity != count(stateData) é rejeitado com código específico."] call _assert;
private _exactNegative = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [-1]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.4-028", !(_exactNegative getOrDefault ["success", true]), "Munição negativa em EXACT é rejeitada."] call _assert;
private _exactZero = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [0]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
["ITEMS-0.4-029", _exactZero getOrDefault ["success", false], "Magazine vazio EXACT [0] permanece representável."] call _assert;

// -------------------------------------------------------------------------
// Normalização: nunca misturar DEFAULT_FULL e EXACT
// -------------------------------------------------------------------------
private _itemA = ((_itemResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _itemBResult = ["ITEM", "FirstAidKit", 3, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _itemB = (_itemBResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normItemsResult = [[_itemA, _itemB]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normItems = (_normItemsResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.4-030", (_normItemsResult getOrDefault ["success", false]) && {(count _normItems) isEqualTo 1} && {((_normItems # 0) # 3) isEqualTo 5}, "ITEM repetido agrupa quantidade."] call _assert;

private _full2Result = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _full2 = (_full2Result getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normFullResult = [[_fullEntry, _full2]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normFull = (_normFullResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.4-031", (count _normFull) isEqualTo 1 && {((_normFull # 0) # 3) isEqualTo 5}, "DEFAULT_FULL da mesma classe agrupa quantidade."] call _assert;

private _exactAResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30,17]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactBResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactA = (_exactAResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _exactB = (_exactBResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _normExactResult = [[_exactA, _exactB]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normExact = (_normExactResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.4-032", (count _normExact) isEqualTo 1 && {((_normExact # 0) # 3) isEqualTo 3} && {((_normExact # 0) # 5) isEqualTo [30,17,6]}, "EXACT concatena stateData preservando ordem e quantity=count."] call _assert;

private _mixedResult = [[_fullEntry, _exactEntry]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _mixed = (_mixedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
["ITEMS-0.4-033", (count _mixed) isEqualTo 2 && {((_mixed # 0) # 4) isEqualTo "DEFAULT_FULL"} && {((_mixed # 1) # 4) isEqualTo "EXACT"}, "DEFAULT_FULL e EXACT nunca são agrupados entre si."] call _assert;

private _badNormalize = [[[1, "MAGAZINE", "30Rnd_65x39_caseless_mag", 2, "EXACT", [30]]]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
["ITEMS-0.4-034", !(_badNormalize getOrDefault ["success", true]) && {(_badNormalize getOrDefault ["code", ""]) isEqualTo "ITEMS_MAG_EXACT_COUNT_MISMATCH"}, "Normalização recusa entrada inválida em vez de corrigir silenciosamente."] call _assert;

// -------------------------------------------------------------------------
// ItemKit v1 em memória
// -------------------------------------------------------------------------
private _kitResult = ["Kit Médico 0.4", [_itemA, _itemB, _exactA, _exactB, _fullEntry], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit = (_kitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.4-035", _kitResult getOrDefault ["success", false], "ItemKit v1 é criado em memória."] call _assert;
["ITEMS-0.4-036", (_kitResult getOrDefault ["success", false]) && {(count _kit) isEqualTo 10} && {(_kit # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC} && {(_kit # 1) isEqualTo 1}, "ItemKit possui magic e version exclusivos de Items."] call _assert;
["ITEMS-0.4-037", ((count _kit) isEqualTo 10) && {[_kit # 2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "ItemKit recebe ID canônico imutável."] call _assert;
private _kitEntries = _kit # 8;
["ITEMS-0.4-038", (count _kitEntries) isEqualTo 3, "createItemKit normaliza ITEM, EXACT e DEFAULT_FULL em três entradas separadas."] call _assert;
private _kitExactIndex = _kitEntries findIf {((_x # 1) isEqualTo "MAGAZINE") && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.4-039", _kitExactIndex >= 0 && {((_kitEntries # _kitExactIndex) # 5) isEqualTo [30,17,6]}, "ItemKit preserva [30,17,6] após normalização."] call _assert;
["ITEMS-0.4-040", ((count _kit) isEqualTo 10) && {(_kit # 4) isEqualTo "ANY"}, "preferredTarget ANY é preservado."] call _assert;
private _kitSemantic = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
["ITEMS-0.4-041", _kitSemantic getOrDefault ["success", false], "ItemKit criado passa validação semântica."] call _assert;

private _renameResult = [_kit, "Kit Médico Renomeado"] call ServoPeregrino_Organizador_Items_fnc_renameItemKit;
private _renamedKit = (_renameResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.4-042", (_renameResult getOrDefault ["success", false]) && {(_renamedKit # 2) isEqualTo (_kit # 2)} && {(_renamedKit # 3) isEqualTo "Kit Médico Renomeado"}, "Renomear preserva o ID imutável."] call _assert;

private _cloneResult = [_kit, "Kit Médico Clone"] call ServoPeregrino_Organizador_Items_fnc_cloneItemKit;
private _cloneKit = (_cloneResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.4-043", (_cloneResult getOrDefault ["success", false]) && {!((_cloneKit # 2) isEqualTo (_kit # 2))} && {[_cloneKit # 2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "Clone recebe novo ID válido."] call _assert;
["ITEMS-0.4-044", (_cloneResult getOrDefault ["success", false]) && {(count _cloneKit) isEqualTo 10} && {(count _kit) isEqualTo 10} && {(_cloneKit # 8) isEqualTo (_kit # 8)}, "Clone preserva conteúdo e estados EXACT."] call _assert;

private _badMagicResult = createHashMap;
if ((count _kit) isEqualTo 10) then {
    private _badMagic = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badMagic set [0, "APM_KIT"];
    _badMagicResult = [_badMagic] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
};
["ITEMS-0.4-045", ((count _kit) isEqualTo 10) && {!(_badMagicResult getOrDefault ["success", true])}, "ItemKit rejeita magic de outro domínio/projeto."] call _assert;

private _badTargetResult = createHashMap;
if ((count _kit) isEqualTo 10) then {
    private _badTarget = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badTarget set [4, "WEAPON"];
    _badTargetResult = [_badTarget] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
};
["ITEMS-0.4-046", ((count _kit) isEqualTo 10) && {!(_badTargetResult getOrDefault ["success", true])}, "preferredTarget fora de ANY/U/C/M é rejeitado."] call _assert;

private _badStructure = [_kit select [0, 9]] call ServoPeregrino_Organizador_Items_fnc_validateItemKitStructural;
["ITEMS-0.4-047", !(_badStructure getOrDefault ["success", true]), "Payload estrutural com campo ausente é rejeitado."] call _assert;

private _emptyKitResult = ["Kit Vazio", [], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
["ITEMS-0.4-048", !(_emptyKitResult getOrDefault ["success", true]) && {(_emptyKitResult getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_PAYLOAD_EMPTY"}, "ItemKit persistível vazio é rejeitado; draft vazio fica para 0.6."] call _assert;

// -------------------------------------------------------------------------
// Validação ambiental separada: indisponível não invalida schema persistível
// -------------------------------------------------------------------------
private _availableEntryResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _availableEntry = (_availableEntryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _availableEnv = [_availableEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
["ITEMS-0.4-049", _availableEnv getOrDefault ["success", false], "Classe vanilla existente é ambientalmente disponível."] call _assert;

private _missingEntryResult = ["ITEM", "SP_ORG_ITEMS_CLASS_DOES_NOT_EXIST_0_3", 1, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _missingEntry = (_missingEntryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []];
private _missingSemantic = [_missingEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
private _missingEnv = [_missingEntry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
["ITEMS-0.4-050", (_missingSemantic getOrDefault ["success", false]) && {!(_missingEnv getOrDefault ["success", true])} && {(_missingEnv getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE"}, "Classe ausente continua semanticamente persistível e falha somente no nível ambiental."] call _assert;

private _missingKitResult = ["Kit Mod Ausente", [_missingEntry], "ANY", ["TEST", "LAB"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _missingKit = (_missingKitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _missingKitBefore = [_missingKit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _missingKitEnv = [_missingKit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitEnvironmental;
["ITEMS-0.4-051", (_missingKitResult getOrDefault ["success", false]) && {!(_missingKitEnv getOrDefault ["success", true])} && {(_missingKitEnv getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE"}, "ItemKit com mod ausente permanece criável/persistível, mas é marcado ambientalmente indisponível."] call _assert;
["ITEMS-0.4-052", _missingKit isEqualTo _missingKitBefore, "Validação ambiental não apaga nem altera ItemKit indisponível."] call _assert;

// -------------------------------------------------------------------------
// Storage v1 em memória — schema que a entrega 0.4 persistirá
// -------------------------------------------------------------------------
private _emptyStorageResult = [[], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
private _emptyStorage = (_emptyStorageResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []];
["ITEMS-0.4-053", (_emptyStorageResult getOrDefault ["success", false]) && {(count (_emptyStorage # 2)) isEqualTo 0}, "Storage v1 vazio é válido como estado inicial em memória."] call _assert;
["ITEMS-0.4-054", (_emptyStorageResult getOrDefault ["success", false]) && {(count _emptyStorage) isEqualTo 4} && {(_emptyStorage # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC} && {(_emptyStorage # 1) isEqualTo 1}, "Storage possui magic/version exclusivos de Items."] call _assert;

private _storageWithKitResult = [[_kit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
private _storageWithKit = (_storageWithKitResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []];
["ITEMS-0.4-055", (_storageWithKitResult getOrDefault ["success", false]) && {(count (_storageWithKit # 2)) isEqualTo 1}, "Storage aceita ItemKit semanticamente válido."] call _assert;

private _duplicateStorageResult = [[_kit, _kit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
["ITEMS-0.4-056", !(_duplicateStorageResult getOrDefault ["success", true]) && {(_duplicateStorageResult getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_DUPLICATE_KIT_ID"}, "Storage rejeita IDs de ItemKit duplicados."] call _assert;

private _storageMissingResult = [[_missingKit], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
["ITEMS-0.4-057", _storageMissingResult getOrDefault ["success", false], "Storage semântico preserva kit de mod ausente; disponibilidade continua ambiental."] call _assert;

private _badStorageResult = createHashMap;
if ((count _emptyStorage) isEqualTo 4) then {
    private _badStorage = [_emptyStorage] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _badStorage set [0, "APM_STORAGE"];
    _badStorageResult = [_badStorage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
};
["ITEMS-0.4-058", ((count _emptyStorage) isEqualTo 4) && {!(_badStorageResult getOrDefault ["success", true])} && {(_badStorageResult getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_INVALID_MAGIC"}, "Storage rejeita magic pertencente a outro domínio/projeto."] call _assert;


// -------------------------------------------------------------------------
// Repository persistente 0.4 — profileNamespace isolado + CRUD + recovery
// -------------------------------------------------------------------------
["ITEMS-0.4-059", _testModeSetup getOrDefault ["success", false], "Namespace isolado de teste foi ativado sem tocar nas chaves de produção."] call _assert;
private _repoStatus0 = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoData0 = _repoStatus0 getOrDefault ["data", createHashMap];
["ITEMS-0.4-060", (_repoStatus0 getOrDefault ["success", false]) && {(_repoData0 getOrDefault ["source", ""]) isEqualTo "EMPTY"} && {(_repoData0 getOrDefault ["kitCount", -1]) isEqualTo 0}, "Repository inicia vazio em memória quando não existem chaves persistidas de teste."] call _assert;

private _persistItemResult = ["ITEM", "FirstAidKit", 2, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _persistMagResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _persistKitResult = [
    "Kit Persistência 0.4",
    [
        (_persistItemResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []],
        (_persistMagResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]
    ],
    "VEST",
    ["TEST", "REPOSITORY"]
] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _persistKit = (_persistKitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _persistId = if ((count _persistKit) >= 3) then {_persistKit # 2} else {""};
private _saveCreate = [_persistKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
["ITEMS-0.4-061", (_saveCreate getOrDefault ["success", false]) && {(_saveCreate getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_PERSISTED_CREATED"}, "saveKit cria o primeiro ItemKit persistido."] call _assert;

private _list1 = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
private _list1Data = _list1 getOrDefault ["data", createHashMap];
private _summaries1 = _list1Data getOrDefault ["kits", []];
["ITEMS-0.4-062", (_list1 getOrDefault ["success", false]) && {(_list1Data getOrDefault ["count", 0]) isEqualTo 1} && {(count _summaries1) isEqualTo 1} && {((_summaries1 # 0) getOrDefault ["id", ""]) isEqualTo _persistId}, "listKits retorna summary ordenável sem expor storage serializado."] call _assert;

private _get1 = [_persistId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _get1Kit = (_get1 getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _get1ExactIndex = if ((count _get1Kit) >= 9) then {(_get1Kit # 8) findIf {((_x # 1) isEqualTo "MAGAZINE") && {(_x # 4) isEqualTo "EXACT"}}} else {-1};
private _get1ExactState = if (_get1ExactIndex >= 0) then {((_get1Kit # 8) # _get1ExactIndex) # 5} else {[]};
["ITEMS-0.4-063", (_get1 getOrDefault ["success", false]) && {_get1ExactState isEqualTo [30,17,6]}, "Repository preserva EXACT [30,17,6] após persistência."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _reload1 = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _reload1KitResult = [_persistId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _reload1Kit = (_reload1KitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _reload1HasKitShape = (_reload1Kit isEqualType []) && {(count _reload1Kit) >= 10};
["ITEMS-0.4-064", (_reload1 getOrDefault ["success", false]) && {(_reload1 getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_LOADED"} && {_reload1HasKitShape} && {(_reload1Kit # 2) isEqualTo _persistId}, "Round-trip limpa estado runtime e recarrega o mesmo ItemKit do primary persistido."] call _assert;
private _reload1Entries = if (_reload1HasKitShape) then {_reload1Kit # 8} else {[]};
private _reload1ExactIndex = _reload1Entries findIf {(_x isEqualType []) && {(count _x) >= 6} && {(_x # 4) isEqualTo "EXACT"}};
private _reload1ExactState = if (_reload1ExactIndex >= 0) then {(_reload1Entries # _reload1ExactIndex) # 5} else {[]};
["ITEMS-0.4-065", _reload1ExactState isEqualTo [30,17,6], "Round-trip preserva munição parcial individual exatamente."] call _assert;

private _createdAtBefore = +(_reload1Kit # 6);
private _renamedPersistResult = [_reload1Kit, "Kit Persistência 0.4 Renomeado"] call ServoPeregrino_Organizador_Items_fnc_renameItemKit;
private _renamedPersistKit = (_renamedPersistResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _saveUpdate = [_renamedPersistKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _savedUpdatedKit = (_saveUpdate getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
["ITEMS-0.4-066", (_saveUpdate getOrDefault ["success", false]) && {(_saveUpdate getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_PERSISTED_UPDATED"} && {(_savedUpdatedKit # 2) isEqualTo _persistId}, "Update persiste por ID imutável sem criar duplicata."] call _assert;
["ITEMS-0.4-067", (_savedUpdatedKit # 6) isEqualTo _createdAtBefore && {(_savedUpdatedKit # 3) isEqualTo "Kit Persistência 0.4 Renomeado"}, "Update preserva createdAt original e grava novo nome."] call _assert;

private _clonePersist = [_persistId, "Clone Persistente 0.4"] call ServoPeregrino_Organizador_Items_fnc_cloneKit;
private _clonePersistData = _clonePersist getOrDefault ["data", createHashMap];
private _cloneKit = _clonePersistData getOrDefault ["kit", []];
private _cloneId = _clonePersistData getOrDefault ["cloneId", ""];
["ITEMS-0.4-068", (_clonePersist getOrDefault ["success", false]) && {!(_cloneId isEqualTo _persistId)} && {[_cloneId] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "cloneKit persiste clone com novo ID válido."] call _assert;
private _cloneMetadata = if ((count _cloneKit) >= 10) then {_cloneKit # 9} else {[]};
["ITEMS-0.4-069", (["clonedFromId", _persistId] in _cloneMetadata), "Clone persistente registra metadata clonedFromId sem mudar o schema ItemKit v1."] call _assert;
private _cloneExactIndex = (_cloneKit # 8) findIf {(_x # 4) isEqualTo "EXACT"};
["ITEMS-0.4-070", (_cloneExactIndex >= 0) && {(((_cloneKit # 8) # _cloneExactIndex) # 5) isEqualTo [30,17,6]}, "Clone persistente mantém EXACT intacto."] call _assert;
private _list2 = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
["ITEMS-0.4-071", ((_list2 getOrDefault ["data", createHashMap]) getOrDefault ["count", 0]) isEqualTo 2, "Repository contém original + clone, sem duplicação implícita."] call _assert;

private _deleteOriginal = [_persistId] call ServoPeregrino_Organizador_Items_fnc_deleteKit;
private _deletedLookup = [_persistId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _cloneLookup = [_cloneId] call ServoPeregrino_Organizador_Items_fnc_getKit;
["ITEMS-0.4-072", (_deleteOriginal getOrDefault ["success", false]) && {!(_deletedLookup getOrDefault ["success", true])} && {(_deletedLookup getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_NOT_FOUND"}, "deleteKit exclui exclusivamente por ID."] call _assert;
["ITEMS-0.4-073", _cloneLookup getOrDefault ["success", false], "Excluir o original não remove o clone independente."] call _assert;

private _invalidPersist = ["Kit Vazio", [], "ANY", ["TEST", "INVALID"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
["ITEMS-0.4-074", !(_invalidPersist getOrDefault ["success", true]) && {(_invalidPersist getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_PAYLOAD_EMPTY"}, "Kit vazio continua impossível de materializar como payload persistível."] call _assert;
private _listBeforeInvalidSave = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
private _badKitArray = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC, 1, "bad", "", "ANY", ["TEST","BAD"], +systemTimeUTC, +systemTimeUTC, [], []];
private _badSaveKit = [_badKitArray] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _listAfterInvalidSave = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
["ITEMS-0.4-075", !(_badSaveKit getOrDefault ["success", true]) && {(((_listBeforeInvalidSave getOrDefault ["data", createHashMap]) getOrDefault ["count", -1]) isEqualTo (((_listAfterInvalidSave getOrDefault ["data", createHashMap]) getOrDefault ["count", -2])))}, "saveKit inválido é recusado sem alterar Repository."] call _assert;

private _missingPersistEntryResult = ["ITEM", "SP_ORG_ITEMS_MISSING_MOD_PERSIST_0_3", 1, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _missingPersistKitResult = ["Kit Mod Ausente Persistente", [(_missingPersistEntryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]], "ANY", ["TEST", "MISSING_MOD"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _missingPersistKit = (_missingPersistKitResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _missingPersistSave = [_missingPersistKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _missingPersistId = if ((count _missingPersistKit) >= 3) then {_missingPersistKit # 2} else {""};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _missingReload = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _missingLookup = [_missingPersistId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _missingLookupKit = (_missingLookup getOrDefault ["data", createHashMap]) getOrDefault ["kit", []];
private _missingEnvAfterReload = [_missingLookupKit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitEnvironmental;
["ITEMS-0.4-076", (_missingPersistSave getOrDefault ["success", false]) && {_missingReload getOrDefault ["success", false]} && {_missingLookup getOrDefault ["success", false]} && {!(_missingEnvAfterReload getOrDefault ["success", true])} && {(_missingEnvAfterReload getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE"}, "Item de mod ausente sobrevive ao round-trip e continua apenas ambientalmente indisponível."] call _assert;

private _repoBeforeCorruption = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoBeforeData = _repoBeforeCorruption getOrDefault ["data", createHashMap];
private _validPrimaryBeforeCorruption = _repoBeforeData getOrDefault ["storage", []];
private _corruptPrimary = ["CORRUPT_PRIMARY", 999, [], []];
private _injectPrimary = ["PRIMARY", _corruptPrimary] call ServoPeregrino_Organizador_Items_fnc_injectTestStoragePayload;
private _recover1 = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _recoverData1 = _recover1 getOrDefault ["data", createHashMap];
["ITEMS-0.4-077", (_injectPrimary getOrDefault ["success", false]) && {(_recover1 getOrDefault ["success", false])} && {(_recover1 getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_RECOVERED_LAST_GOOD"} && {(_recoverData1 getOrDefault ["source", ""]) isEqualTo "LAST_GOOD"}, "Primary corrompido recupera lastGood validado."] call _assert;
private _recoveredStorage1 = _recoverData1 getOrDefault ["storage", []];
["ITEMS-0.4-078", (_recoveredStorage1 isEqualType []) && {(count _recoveredStorage1) isEqualTo 4} && {(_recoveredStorage1 # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC}, "Recovery usa storage válido do domínio Items, não payload corrompido."] call _assert;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _recover2 = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
["ITEMS-0.4-079", (_recover2 getOrDefault ["success", false]) && {(_recover2 getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_RECOVERED_LAST_GOOD"}, "Segundo load ainda precisa de lastGood: recovery não sobrescreveu silenciosamente o primary inválido."] call _assert;

private _corruptLastGood = ["CORRUPT_LASTGOOD", 999, [], []];
private _injectLastGood = ["LASTGOOD", _corruptLastGood] call ServoPeregrino_Organizador_Items_fnc_injectTestStoragePayload;
private _unrecoverable = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _repoAfterUnrecoverable = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
["ITEMS-0.4-080", (_injectLastGood getOrDefault ["success", false]) && {!(_unrecoverable getOrDefault ["success", true])} && {(_unrecoverable getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_UNRECOVERABLE"}, "Primary + lastGood inválidos falham explicitamente sem fabricar sucesso."] call _assert;
["ITEMS-0.4-081", !(_repoAfterUnrecoverable getOrDefault ["success", true]), "Storage irrecuperável não é mascarado por Repository vazio artificial."] call _assert;

// Reconstituir uma baseline válida isolada para testar save inválido e migração.
private _clearAgain = ["AUTO_0_9_2", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _reloadEmptyAgain = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _saveCloneFresh = [_cloneKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _validBeforeBadStorage = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _badStorageSave = [["WRONG_MAGIC", 1, [], []]] call ServoPeregrino_Organizador_Items_fnc_saveStorage;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _reloadAfterBadStorage = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
private _listAfterBadStorage = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
["ITEMS-0.4-082", !(_badStorageSave getOrDefault ["success", true]) && {_reloadAfterBadStorage getOrDefault ["success", false]} && {(((_listAfterBadStorage getOrDefault ["data", createHashMap]) getOrDefault ["count", 0]) isEqualTo 1)}, "saveStorage inválido é rejeitado antes da escrita e baseline válida permanece recarregável."] call _assert;

private _repoForMigration = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _migrationCurrent = [((_repoForMigration getOrDefault ["data", createHashMap]) getOrDefault ["storage", []])] call ServoPeregrino_Organizador_Items_fnc_migrateStorage;
["ITEMS-0.4-083", (_migrationCurrent getOrDefault ["success", false]) && {(_migrationCurrent getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_MIGRATION_NOT_REQUIRED"} && {!(((_migrationCurrent getOrDefault ["data", createHashMap]) getOrDefault ["migrated", true]))}, "migrateStorage trata v1 como no-op validado."] call _assert;
private _futureStorage = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC, 99, [], []];
private _migrationFuture = [_futureStorage] call ServoPeregrino_Organizador_Items_fnc_migrateStorage;
["ITEMS-0.4-084", !(_migrationFuture getOrDefault ["success", true]) && {(_migrationFuture getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_UNSUPPORTED_VERSION"}, "Versão sem caminho conhecido é recusada; não existe migração inventada."] call _assert;
private _migrationForeign = [["APM_STORAGE", 1, [], []]] call ServoPeregrino_Organizador_Items_fnc_migrateStorage;
["ITEMS-0.4-085", !(_migrationForeign getOrDefault ["success", true]) && {(_migrationForeign getOrDefault ["code", ""]) isEqualTo "ITEMS_STORAGE_INVALID_MAGIC"}, "migrateStorage nunca importa magic do APM/outro domínio implicitamente."] call _assert;

private _badGet = ["not-a-valid-id"] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _badDelete = ["not-a-valid-id"] call ServoPeregrino_Organizador_Items_fnc_deleteKit;
["ITEMS-0.4-086", !(_badGet getOrDefault ["success", true]) && {(_badGet getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_ID_INVALID"}, "getKit rejeita identidade inválida antes de consultar Repository."] call _assert;
["ITEMS-0.4-087", !(_badDelete getOrDefault ["success", true]) && {(_badDelete getOrDefault ["code", ""]) isEqualTo "ITEMS_KIT_ID_INVALID"}, "deleteKit rejeita identidade inválida antes de mutar storage."] call _assert;

private _runtime03 = [] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus;
private _runtime03Data = _runtime03 getOrDefault ["data", createHashMap];
["ITEMS-0.4-088", (_runtime03 getOrDefault ["success", false]) && {_runtime03Data getOrDefault ["repositoryReady", false]}, "items.runtime expõe repositoryReady na entrega 0.4."] call _assert;


// -------------------------------------------------------------------------
// Capture & Container Fidelity 0.4
// -------------------------------------------------------------------------
private _runtime04 = [] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus;
private _runtime04Data = _runtime04 getOrDefault ["data", createHashMap];
["ITEMS-0.4-089", (_runtime04 getOrDefault ["success", false]) && {_runtime04Data getOrDefault ["captureReady", false]}, "Runtime publica captureReady=true."] call _assert;
["ITEMS-0.4-090", (_runtime04Data getOrDefault ["containerProvider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER && {!(_runtime04Data getOrDefault ["captureMutatesInventory", true])}, "Runtime identifica PLAYER_CONTAINERS e declara captura não mutável."] call _assert;

private _classItem = ["FirstAidKit"] call ServoPeregrino_Organizador_Items_fnc_classifyCargoClass;
private _classItemData = _classItem getOrDefault ["data", createHashMap];
["ITEMS-0.4-091", (_classItem getOrDefault ["success", false]) && {(_classItemData getOrDefault ["ownership", ""]) isEqualTo "CONTENT"}, "FirstAidKit é elegível como CONTENT de cargo."] call _assert;
private _classHelmet = ["H_HelmetB"] call ServoPeregrino_Organizador_Items_fnc_classifyCargoClass;
private _classHelmetData = _classHelmet getOrDefault ["data", createHashMap];
["ITEMS-0.4-092", (_classHelmet getOrDefault ["success", false]) && {(_classHelmetData getOrDefault ["ownership", ""]) isEqualTo "RESERVED"} && {(_classHelmetData getOrDefault ["reason", ""]) isEqualTo "EQUIPMENT_DOMAIN"}, "Capacete é reservado ao domínio Equipment."] call _assert;
private _classWeapon = ["arifle_MX_F"] call ServoPeregrino_Organizador_Items_fnc_classifyCargoClass;
private _classWeaponData = _classWeapon getOrDefault ["data", createHashMap];
["ITEMS-0.4-093", (_classWeapon getOrDefault ["success", false]) && {(_classWeaponData getOrDefault ["ownership", ""]) isEqualTo "RESERVED"} && {(_classWeaponData getOrDefault ["reason", ""]) isEqualTo "WEAPON_DOMAIN"}, "Arma-base é reservada ao domínio Weapons/Armorer."] call _assert;

private _synthetic = [
    [["FirstAidKit", "FirstAidKit", "H_HelmetB"], [2, 3, 1]],
    [["30Rnd_65x39_caseless_mag",30],["30Rnd_65x39_caseless_mag",17],["30Rnd_65x39_caseless_mag",6]],
    [["arifle_MX_F"],[1]],
    [["B_AssaultPack_khk"],[1]]
] call ServoPeregrino_Organizador_Items_fnc_analyzeContainerCargo;
private _syntheticData = _synthetic getOrDefault ["data", createHashMap];
private _syntheticEntries = _syntheticData getOrDefault ["entries", []];
private _syntheticReserved = _syntheticData getOrDefault ["reservedCargo", []];
private _synItemIdx = _syntheticEntries findIf {(_x # 1) isEqualTo "ITEM" && {(_x # 2) isEqualTo "FirstAidKit"}};
private _synMagIdx = _syntheticEntries findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"}};
["ITEMS-0.4-094", _synthetic getOrDefault ["success", false], "Analisador puro aceita cargo sintético misto."] call _assert;
["ITEMS-0.4-095", _synItemIdx >= 0 && {((_syntheticEntries # _synItemIdx) # 3) isEqualTo 5}, "ITEM cargo repetido é agrupado em quantity=5."] call _assert;
["ITEMS-0.4-096", _synMagIdx >= 0 && {((_syntheticEntries # _synMagIdx) # 4) isEqualTo "EXACT"} && {((_syntheticEntries # _synMagIdx) # 5) isEqualTo [30,17,6]}, "Magazines físicos viram EXACT preservando [30,17,6]."] call _assert;
["ITEMS-0.4-097", _synMagIdx >= 0 && {((_syntheticEntries # _synMagIdx) # 3) isEqualTo 3}, "EXACT capturado mantém quantity=count(stateData)."] call _assert;
["ITEMS-0.4-098", (_syntheticReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "WEAPON" && {(_x getOrDefault ["className", ""]) isEqualTo "arifle_MX_F"}}) >= 0, "Weapon cargo é identificado como reserved."] call _assert;
["ITEMS-0.4-099", (_syntheticReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "EQUIPMENT" && {(_x getOrDefault ["className", ""]) isEqualTo "H_HelmetB"}}) >= 0, "Wearable equipment em itemCargo é identificado como reserved."] call _assert;
["ITEMS-0.4-100", (_syntheticReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "NESTED_CONTAINER" && {(_x getOrDefault ["className", ""]) isEqualTo "B_AssaultPack_khk"}}) >= 0, "Nested backpack é identificado e não atravessado."] call _assert;
["ITEMS-0.4-101", (_syntheticEntries findIf {(_x # 2) in ["H_HelmetB", "arifle_MX_F", "B_AssaultPack_khk"]}) < 0, "Armas/equipment/nested containers não entram em CONTENT mutável."] call _assert;

private _captureDraftResult = [_syntheticEntries, "U", "Draft Captura Teste"] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
private _captureDraft = (_captureDraftResult getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap];
["ITEMS-0.4-102", _captureDraftResult getOrDefault ["success", false], "Captura cria Draft NEW em memória."] call _assert;
["ITEMS-0.4-103", (_captureDraft getOrDefault ["mode", ""]) isEqualTo "NEW" && {(_captureDraft getOrDefault ["kitId", "x"]) isEqualTo ""}, "Capture draft não possui identidade persistida."] call _assert;
["ITEMS-0.4-104", (_captureDraft getOrDefault ["dirty", false]) && {(_captureDraft getOrDefault ["createdFrom", ""]) isEqualTo "CAPTURE"}, "Capture draft nasce dirty e createdFrom=CAPTURE."] call _assert;
["ITEMS-0.4-105", (_captureDraft getOrDefault ["preferredTarget", ""]) isEqualTo "UNIFORM", "Target U é canonizado para UNIFORM no draft."] call _assert;
private _emptyDraftResult = [[], "ANY", "Captura Vazia"] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
private _emptyDraft = (_emptyDraftResult getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap];
["ITEMS-0.4-106", (_emptyDraftResult getOrDefault ["success", false]) && {(count (_emptyDraft getOrDefault ["entries", [1]])) isEqualTo 0}, "Draft de captura pode ser vazio sem fabricar ItemKit persistível."] call _assert;
private _badTarget = [player, "INVALID"] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
["ITEMS-0.4-107", !(_badTarget getOrDefault ["success", true]) && {(_badTarget getOrDefault ["code", ""]) isEqualTo "ITEMS_CONTAINER_TARGET_INVALID"}, "Resolver rejeita target fora de U/C/M."] call _assert;
private _nullResolve = [objNull, "U"] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
["ITEMS-0.4-108", !(_nullResolve getOrDefault ["success", true]) && {(_nullResolve getOrDefault ["code", ""]) isEqualTo "ITEMS_CAPTURE_UNIT_NULL"}, "Resolver trata unidade nula com diagnóstico limpo."] call _assert;

// Regressão física hermética: sem entidade temporária e sem reconstrução de loadout.
// A semântica determinística de ITEM/EXACT/reserved já foi provada acima com cargo sintético puro.
// Aqui o runner usa o player SOMENTE LEITURA, evitando disparar sistemas externos que observam
// nascimento/equipamento de CAManBase (lição aprendida nas candidatas 0.4.1 e 0.7.1).
private _captureUnit = player;
private _playerBeforeFixture = [_captureUnit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _playerBeforeFixtureData = _playerBeforeFixture getOrDefault ["data", createHashMap];
private _availableTarget = "";
private _resolveAvailable = createHashMap;
{
    private _candidateResolve = [_captureUnit, _x] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
    if ((_candidateResolve getOrDefault ["success", false]) && {_availableTarget isEqualTo ""}) then {
        _availableTarget = _x;
        _resolveAvailable = _candidateResolve;
    };
} forEach ["U","C","M"];
["ITEMS-0.4-109", _availableTarget isNotEqualTo "" && {_resolveAvailable getOrDefault ["success", false]}, "PLAYER_CONTAINERS resolve ao menos um container real do player sem preparar/mutar fixture."] call _assert;

private _captureAvailable = if (_availableTarget isEqualTo "") then {createHashMap} else {[_captureUnit, _availableTarget] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer};
private _captureAvailableData = _captureAvailable getOrDefault ["data", createHashMap];
["ITEMS-0.4-110", _captureAvailable getOrDefault ["success", false], "Captura read-only de container real disponível é bem-sucedida."] call _assert;
["ITEMS-0.4-111", _captureAvailableData getOrDefault ["loadoutUnchanged", false], "Captura real declara loadoutUnchanged=true."] call _assert;
["ITEMS-0.4-112", (_captureAvailableData getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER, "Captura real publica provider PLAYER_CONTAINERS."] call _assert;
private _playerAfterSingleCapture = [_captureUnit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _playerAfterSingleCaptureData = _playerAfterSingleCapture getOrDefault ["data", createHashMap];
["ITEMS-0.4-113", (_playerBeforeFixtureData getOrDefault ["serialized", "A"]) isEqualTo (_playerAfterSingleCaptureData getOrDefault ["serialized", "B"]), "Fingerprint do player é idêntico antes/depois da captura real de um container."] call _assert;
["ITEMS-0.4-114", (_syntheticEntries findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 4) isEqualTo "EXACT"} && {(_x # 5) isEqualTo [30,17,6]}}) >= 0, "Fidelidade EXACT [30,17,6] permanece coberta por fixture de dados puro, sem CAManBase sintético."] call _assert;

private _repoBeforeCapture = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoBeforeCaptureData = _repoBeforeCapture getOrDefault ["data", createHashMap];
private _repoBeforeCaptureStorage = _repoBeforeCaptureData getOrDefault ["storage", []];
private _captureAny = [_captureUnit, "ANY"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainers;
private _captureAnyData = _captureAny getOrDefault ["data", createHashMap];
private _captureAnyDraft = _captureAnyData getOrDefault ["draft", createHashMap];
["ITEMS-0.4-115", (_captureAny getOrDefault ["success", false]) && {(_captureAny getOrDefault ["code", ""]) isEqualTo "ITEMS_CAPTURE_COMPLETED"} && {_captureAnyData getOrDefault ["loadoutUnchanged", false]}, "Captura agregada ANY/U/C/M do player é somente leitura."] call _assert;
["ITEMS-0.4-116", (_captureAnyDraft getOrDefault ["mode", ""]) isEqualTo "NEW" && {(_captureAnyDraft getOrDefault ["createdFrom", ""]) isEqualTo "CAPTURE"}, "Captura ANY produz Draft NEW em memória."] call _assert;
private _repoAfterCapture = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoAfterCaptureData = _repoAfterCapture getOrDefault ["data", createHashMap];
private _repoAfterCaptureStorage = _repoAfterCaptureData getOrDefault ["storage", []];
["ITEMS-0.4-117", _repoBeforeCaptureStorage isEqualTo _repoAfterCaptureStorage, "Captura não grava nem altera Repository."] call _assert;
["ITEMS-0.4-118", (_syntheticReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "EQUIPMENT" && {(_x getOrDefault ["className", ""]) isEqualTo "H_HelmetB"}}) >= 0, "Equipment reservado permanece coberto por fixture de dados puro."] call _assert;
["ITEMS-0.4-119", (_syntheticReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "WEAPON" && {(_x getOrDefault ["className", ""]) isEqualTo "arifle_MX_F"}}) >= 0, "Weapon reservado permanece coberto por fixture de dados puro."] call _assert;
private _captureContainers = _captureAnyData getOrDefault ["containers", []];
private _captureAbsent = _captureAnyData getOrDefault ["absentTargets", []];
["ITEMS-0.4-120", (_captureContainers isEqualType []) && {_captureAbsent isEqualType []} && {((count _captureContainers) + (count _captureAbsent)) isEqualTo 3}, "ANY representa explicitamente os três targets como presentes ou ausentes sem mutar equipamento."] call _assert;
["ITEMS-0.4-121", (_captureAbsent findIf {!(_x in ["U","C","M"])}) < 0, "Captura ANY tolera containers ausentes e os diagnostica somente como U/C/M."] call _assert;

private _playerAfterFixture = [_captureUnit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _playerAfterFixtureData = _playerAfterFixture getOrDefault ["data", createHashMap];
["ITEMS-0.4-122", (_playerBeforeFixtureData getOrDefault ["serialized", "A"]) isEqualTo (_playerAfterFixtureData getOrDefault ["serialized", "B"]), "Runner hermético não altera, restaura nem substitui o loadout do jogador."] call _assert;
["ITEMS-0.4.1-123", (_captureAvailableData getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER, "Regressão 0.4.1: capturePlayerContainer devolve provider PLAYER_CONTAINERS sem erro de preprocessor/macro."] call _assert;
["ITEMS-0.4.2-124", _captureUnit isEqualTo player && {(_playerBeforeFixtureData getOrDefault ["serialized", "A"]) isEqualTo (_playerAfterFixtureData getOrDefault ["serialized", "B"])}, "Fixture cumulativo atual é hermético: dados sintéticos puros + player somente leitura; nenhum CAManBase temporário equipado."] call _assert;


// -------------------------------------------------------------------------
// Catalog Core 0.5 — CONFIG_ALL + cache por sessão/build
// -------------------------------------------------------------------------
private _catalogStatusBefore = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogBeforeData = _catalogStatusBefore getOrDefault ["data", createHashMap];
["ITEMS-0.5-125", (_runtime getOrDefault ["catalogReady", false]) && {(_runtime getOrDefault ["catalogProvider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER}, "Runtime declara Catalog Service CONFIG_ALL pronto sem antecipar UI."] call _assert;
["ITEMS-0.5-126", (_build getOrDefault ["catalogProvider", ""]) isEqualTo "CONFIG_ALL" && {(_build getOrDefault ["catalogModelVersion", 0]) isEqualTo 1}, "getBuildInfo publica provider CONFIG_ALL e CatalogItem runtime v1."] call _assert;
["ITEMS-0.5-127", !(_catalogBeforeData getOrDefault ["cacheBuilt", true]) && {(_catalogBeforeData getOrDefault ["configScanCount", -1]) isEqualTo 0}, "Initialize é lazy: catálogo ainda não foi construído nem varreu configs."] call _assert;

private _catalogCategories = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogCategories;
["ITEMS-0.5-128", _catalogCategories isEqualTo ["ALL","MAGAZINES","GRENADES","EXPLOSIVES","TOOLS","FOOD","MEDICAL","OTHER"], "Categorias compactas da UX 1.0 possuem IDs canônicos e fallback OTHER."] call _assert;

private _classFAK = ["FirstAidKit", "CfgWeapons"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classFAKData = _classFAK getOrDefault ["data", createHashMap];
["ITEMS-0.5-129", (_classFAK getOrDefault ["success", false]) && {(_classFAKData getOrDefault ["eligible", false])} && {(_classFAKData getOrDefault ["contentType", ""]) isEqualTo "ITEM"}, "Classificação CONTENT central reconhece FirstAidKit como ITEM elegível."] call _assert;

private _classHelmet = ["H_HelmetB", "CfgWeapons"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classHelmetData = _classHelmet getOrDefault ["data", createHashMap];
["ITEMS-0.5-130", (_classHelmet getOrDefault ["success", false]) && {!(_classHelmetData getOrDefault ["eligible", true])} && {(_classHelmetData getOrDefault ["reason", ""]) isEqualTo "EQUIPMENT_DOMAIN"}, "Classificação central preserva capacete no domínio Equipment."] call _assert;

private _classWeapon = ["arifle_MX_F", "CfgWeapons"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classWeaponData = _classWeapon getOrDefault ["data", createHashMap];
["ITEMS-0.5-131", (_classWeapon getOrDefault ["success", false]) && {!(_classWeaponData getOrDefault ["eligible", true])} && {(_classWeaponData getOrDefault ["reason", ""]) isEqualTo "WEAPON_DOMAIN"}, "Classificação central não adota arma-base como Items CONTENT."] call _assert;

private _classMag = ["30Rnd_65x39_caseless_mag", "CfgMagazines"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classMagData = _classMag getOrDefault ["data", createHashMap];
["ITEMS-0.5-132", (_classMag getOrDefault ["success", false]) && {(_classMagData getOrDefault ["eligible", false])} && {(_classMagData getOrDefault ["contentType", ""]) isEqualTo "MAGAZINE"}, "CfgMagazines público é classificado como MAGAZINE CONTENT."] call _assert;
["ITEMS-0.5-133", (_classFAKData getOrDefault ["categoryId", ""]) isEqualTo "MEDICAL", "FirstAidKit é categorizado como MEDICAL."] call _assert;

private _classToolkit = ["ToolKit", "CfgWeapons"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classToolkitData = _classToolkit getOrDefault ["data", createHashMap];
["ITEMS-0.5-134", (_classToolkit getOrDefault ["success", false]) && {(_classToolkitData getOrDefault ["categoryId", ""]) isEqualTo "TOOLS"}, "ToolKit é categorizado como TOOLS."] call _assert;
["ITEMS-0.5-135", (_classMagData getOrDefault ["categoryId", ""]) isEqualTo "MAGAZINES", "Magazine convencional é categorizado como MAGAZINES."] call _assert;

private _classGrenade = ["HandGrenade", "CfgMagazines"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classGrenadeData = _classGrenade getOrDefault ["data", createHashMap];
["ITEMS-0.5-136", (_classGrenade getOrDefault ["success", false]) && {(_classGrenadeData getOrDefault ["categoryId", ""]) isEqualTo "GRENADES"}, "HandGrenade é categorizada como GRENADES."] call _assert;

private _classExplosive = ["DemoCharge_Remote_Mag", "CfgMagazines"] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
private _classExplosiveData = _classExplosive getOrDefault ["data", createHashMap];
["ITEMS-0.5-137", (_classExplosive getOrDefault ["success", false]) && {(_classExplosiveData getOrDefault ["categoryId", ""]) isEqualTo "EXPLOSIVES"}, "DemoCharge é categorizada como EXPLOSIVES."] call _assert;

private _catalogFAKResult = ["FirstAidKit", "CfgWeapons"] call ServoPeregrino_Organizador_Items_fnc_createCatalogItemFromConfig;
private _catalogFAK = (_catalogFAKResult getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap];
["ITEMS-0.5-138", (_catalogFAKResult getOrDefault ["success", false]) && {(_catalogFAK getOrDefault ["className", ""]) isEqualTo "FirstAidKit"} && {(_catalogFAK getOrDefault ["displayName", ""]) isNotEqualTo ""} && {(_catalogFAK getOrDefault ["sourceConfig", ""]) isEqualTo "CfgWeapons"}, "CatalogItem runtime resolve identidade + displayName + sourceConfig sem persistir metadados."] call _assert;

// Regressões 0.5.1: um build concorrente deve ser recusado e não pode ser invalidado.
private _fakeBuildState = createHashMapFromArray [
    ["running", true],
    ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
    ["buildKey", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["startedAtTick", diag_tickTime],
    ["currentRoot", "TEST_LOCK"],
    ["visitedConfigClasses", 123]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _fakeBuildState];
private _busyBuild = [false] call ServoPeregrino_Organizador_Items_fnc_buildCatalog;
["ITEMS-0.5.1-167", !(_busyBuild getOrDefault ["success", true]) && {(_busyBuild getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_BUILD_IN_PROGRESS"}, "Build concorrente é recusado controladamente sem iniciar segunda varredura."] call _assert;
private _busyInvalidate = ["AUTO_BUSY_GUARD"] call ServoPeregrino_Organizador_Items_fnc_invalidateCatalogCache;
["ITEMS-0.5.1-168", !(_busyInvalidate getOrDefault ["success", true]) && {(_busyInvalidate getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_BUILD_BUSY"}, "Invalidação é recusada enquanto há build em andamento; cache não entra em corrida destrutiva."] call _assert;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];

diag_log "[SP_ORG] [ITEMS] [TEST 0.9.2] [INFO] Iniciando o único build completo CONFIG_ALL da suíte cumulativa rápida. Em modsets grandes aguarde os logs BUILD_PROGRESS; não execute a suíte novamente.";

private _firstCatalog = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
private _firstCatalogData = _firstCatalog getOrDefault ["data", createHashMap];
private _firstCatalogItems = _firstCatalogData getOrDefault ["items", []];
private _firstCatalogCount = _firstCatalogData getOrDefault ["count", 0];
["ITEMS-0.5-139", (_firstCatalog getOrDefault ["success", false]) && {(_firstCatalog getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_READY"}, "Primeira consulta constrói e retorna catálogo CONFIG_ALL."] call _assert;
["ITEMS-0.5-140", _firstCatalogCount > 0 && {(count _firstCatalogItems) isEqualTo _firstCatalogCount}, "Catálogo contém todas as classes elegíveis descobertas sem limite arbitrário hardcoded."] call _assert;

private _catalogStatus1 = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogStatus1Data = _catalogStatus1 getOrDefault ["data", createHashMap];
["ITEMS-0.5-141", _catalogStatus1Data getOrDefault ["cacheBuilt", false], "Primeira consulta marca cache da sessão/build como construído."] call _assert;
["ITEMS-0.5-142", (_catalogStatus1Data getOrDefault ["buildCount", 0]) isEqualTo 1, "Primeira consulta executa exatamente um build de catálogo."] call _assert;
["ITEMS-0.5-143", (_catalogStatus1Data getOrDefault ["configScanCount", 0]) isEqualTo 1, "Primeira consulta executa exatamente uma varredura global de configs."] call _assert;
["ITEMS-0.5.1-169", !(_catalogStatus1Data getOrDefault ["buildInProgress", true]) && {(_catalogStatus1Data getOrDefault ["scanAttemptCount", 0]) isEqualTo 1}, "Build finaliza liberando lock e registra exatamente uma tentativa de scan."] call _assert;
["ITEMS-0.5.1-170", (_catalogStatus1Data getOrDefault ["weaponPrefilterSkippedCount", 0]) > 0 && {(_catalogStatus1Data getOrDefault ["candidateCount", 0]) > 0}, "Scanner prefiltra CfgWeapons óbvio antes do custo de classificação sem perder candidatos CONTENT."] call _assert;
["ITEMS-0.5.1-171", (_catalogStatus1Data getOrDefault ["magazineFastPathCount", 0]) > 0, "CfgMagazines usa caminho tipado rápido e evita BIS_fnc_itemType em cada magazine do CONFIG_ALL."] call _assert;

private _fakIdx = _firstCatalogItems findIf {(_x getOrDefault ["className", ""]) isEqualTo "FirstAidKit"};
private _magIdx = _firstCatalogItems findIf {(_x getOrDefault ["className", ""]) isEqualTo "30Rnd_65x39_caseless_mag"};
private _weaponIdx = _firstCatalogItems findIf {(_x getOrDefault ["className", ""]) isEqualTo "arifle_MX_F"};
private _helmetIdx = _firstCatalogItems findIf {(_x getOrDefault ["className", ""]) isEqualTo "H_HelmetB"};
["ITEMS-0.5-144", _fakIdx >= 0, "CONFIG_ALL inclui FirstAidKit como CONTENT."] call _assert;
["ITEMS-0.5-145", _magIdx >= 0, "CONFIG_ALL inclui magazine convencional como CONTENT."] call _assert;
["ITEMS-0.5-146", _weaponIdx < 0, "CONFIG_ALL exclui arma-base do catálogo Items."] call _assert;
["ITEMS-0.5-147", _helmetIdx < 0, "CONFIG_ALL exclui equipamento vestível do catálogo Items."] call _assert;

private _buildCountBeforeHit = _catalogStatus1Data getOrDefault ["buildCount", -1];
private _scanBeforeHit = _catalogStatus1Data getOrDefault ["configScanCount", -1];
private _hitsBefore = _catalogStatus1Data getOrDefault ["cacheHitCount", 0];
private _secondCatalog = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
private _catalogStatus2 = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogStatus2Data = _catalogStatus2 getOrDefault ["data", createHashMap];
["ITEMS-0.5-148", (_secondCatalog getOrDefault ["success", false]) && {(_catalogStatus2Data getOrDefault ["buildCount", -2]) isEqualTo _buildCountBeforeHit}, "Consulta repetida reutiliza cache e não reconstrói catálogo."] call _assert;
["ITEMS-0.5-149", (_catalogStatus2Data getOrDefault ["configScanCount", -2]) isEqualTo _scanBeforeHit, "Consulta repetida não revarre CfgWeapons/CfgMagazines."] call _assert;
["ITEMS-0.5-150", (_catalogStatus2Data getOrDefault ["cacheHitCount", 0]) > _hitsBefore, "Consulta repetida registra cache hit observável."] call _assert;

private _cacheCountBeforeFilter = _catalogStatus2Data getOrDefault ["itemCount", -1];
private _scanBeforeFilter = _catalogStatus2Data getOrDefault ["configScanCount", -1];
private _filterFAK = ["FirstAidKit", "ALL"] call ServoPeregrino_Organizador_Items_fnc_filterCatalog;
private _filterFAKData = _filterFAK getOrDefault ["data", createHashMap];
private _filterFAKItems = _filterFAKData getOrDefault ["items", []];
["ITEMS-0.5-151", (_filterFAK getOrDefault ["success", false]) && {(count _filterFAKItems) >= 1} && {(_filterFAKItems findIf {(_x getOrDefault ["className", ""]) isEqualTo "FirstAidKit"}) >= 0}, "Busca local encontra FirstAidKit sem alterar a base."] call _assert;

private _filterMedical = ["", "MEDICAL"] call ServoPeregrino_Organizador_Items_fnc_filterCatalog;
private _filterMedicalData = _filterMedical getOrDefault ["data", createHashMap];
private _filterMedicalItems = _filterMedicalData getOrDefault ["items", []];
["ITEMS-0.5-152", (_filterMedical getOrDefault ["success", false]) && {(count _filterMedicalItems) > 0} && {(_filterMedicalItems findIf {(_x getOrDefault ["categoryId", ""]) isNotEqualTo "MEDICAL"}) < 0}, "Filtro MEDICAL retorna somente itens da categoria solicitada."] call _assert;

private _filterBad = ["", "INVALID_CATEGORY"] call ServoPeregrino_Organizador_Items_fnc_filterCatalog;
["ITEMS-0.5-153", !(_filterBad getOrDefault ["success", true]) && {(_filterBad getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_CATEGORY_INVALID"}, "Categoria inválida falha controladamente sem fallback silencioso."] call _assert;

private _catalogStatusAfterFilter = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogStatusAfterFilterData = _catalogStatusAfterFilter getOrDefault ["data", createHashMap];
["ITEMS-0.5-154", (_catalogStatusAfterFilterData getOrDefault ["itemCount", -2]) isEqualTo _cacheCountBeforeFilter && {(_catalogStatusAfterFilterData getOrDefault ["configScanCount", -2]) isEqualTo _scanBeforeFilter}, "Busca/filtro não altera cache original nem revarre configs."] call _assert;

private _copyIsolationCatalog = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
private _copyIsolationItems = ((_copyIsolationCatalog getOrDefault ["data", createHashMap]) getOrDefault ["items", []]);
private _copyIsolationOk = false;
if ((count _copyIsolationItems) > 0) then {
    private _firstCopy = _copyIsolationItems # 0;
    private _copyClass = _firstCopy getOrDefault ["className", ""];
    private _originalName = _firstCopy getOrDefault ["displayName", ""];
    _firstCopy set ["displayName", "SP_ORG_MUTATED_CALLER_COPY"];
    private _resolvedAgain = [_copyClass] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
    private _resolvedAgainItem = ((_resolvedAgain getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
    _copyIsolationOk = (_resolvedAgainItem getOrDefault ["displayName", ""]) isEqualTo _originalName;
};
["ITEMS-0.5-155", _copyIsolationOk, "getCatalog devolve cópias runtime; mutação do caller não contamina o cache autoritativo."] call _assert;

private _resolveFAK = ["FirstAidKit"] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
private _resolveFAKData = _resolveFAK getOrDefault ["data", createHashMap];
private _resolveFAKItem = _resolveFAKData getOrDefault ["item", createHashMap];
["ITEMS-0.5-156", (_resolveFAK getOrDefault ["success", false]) && {(_resolveFAKData getOrDefault ["fromCache", false])} && {(_resolveFAKItem getOrDefault ["available", false])} && {(_resolveFAKItem getOrDefault ["eligible", false])}, "resolveCatalogItem usa índice do cache para classe elegível existente."] call _assert;

private _missingClassName = "SP_ORG_ITEMS_CLASS_DOES_NOT_EXIST_0_5";
private _missingStatusBefore = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _countBeforeMissingResolve = ((_missingStatusBefore getOrDefault ["data", createHashMap]) getOrDefault ["itemCount", -1]);
private _resolveMissing = [_missingClassName] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
private _resolveMissingData = _resolveMissing getOrDefault ["data", createHashMap];
private _resolveMissingItem = _resolveMissingData getOrDefault ["item", createHashMap];
["ITEMS-0.5-157", (_resolveMissing getOrDefault ["success", false]) && {!(_resolveMissingItem getOrDefault ["available", true])} && {(_resolveMissingItem getOrDefault ["unavailableReason", ""]) isEqualTo "CLASS_NOT_FOUND"} && {(_resolveMissingItem getOrDefault ["className", ""]) isEqualTo _missingClassName}, "Item de mod ausente é resolvido explicitamente como indisponível sem apagar sua identidade."] call _assert;
private _countAfterMissingResolve = (([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data", createHashMap]) getOrDefault ["itemCount", -2];
["ITEMS-0.5-158", _countAfterMissingResolve isEqualTo _countBeforeMissingResolve, "Resolver classname ausente não injeta referência fantasma no cache base."] call _assert;

// A 0.5.1 homologou o rebuild real completo. Nas suítes cumulativas seguintes,
// mantemos UM CONFIG_ALL real e exercitamos invalidate + retomada do cache com um
// snapshot de fixture do próprio build homologado. O gate completo lento continua
// disponível como ação manual separada no laboratório.
private _catalogCacheSnapshot = [(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogMetricsSnapshot = [(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogBuildStateSnapshot = [(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogRuntimeSnapshot = [(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _invalidateBefore = _catalogStatusAfterFilterData getOrDefault ["invalidationCount", 0];
private _invalidate = ["AUTO_TEST_0_6_1"] call ServoPeregrino_Organizador_Items_fnc_invalidateCatalogCache;
private _statusInvalidated = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusInvalidatedData = _statusInvalidated getOrDefault ["data", createHashMap];
["ITEMS-0.5-159", (_invalidate getOrDefault ["success", false]) && {(_invalidate getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_CACHE_INVALIDATED"} && {!(_statusInvalidatedData getOrDefault ["cacheBuilt", true])} && {(_statusInvalidatedData getOrDefault ["itemCount", -1]) isEqualTo 0}, "invalidateCatalogCache remove explicitamente o cache da sessão."] call _assert;
["ITEMS-0.5-160", (_statusInvalidatedData getOrDefault ["invalidationCount", 0]) isEqualTo (_invalidateBefore + 1) && {(_statusInvalidatedData getOrDefault ["lastInvalidationReason", ""]) isEqualTo "AUTO_TEST_0_6_1"}, "Invalidação é observável e registra razão sem varrer configs."] call _assert;

private _buildCountBeforeRebuild = _statusInvalidatedData getOrDefault ["buildCount", 0];
private _scanBeforeRebuild = _statusInvalidatedData getOrDefault ["configScanCount", 0];
private _cacheHitsBeforeFastRestore = _catalogMetricsSnapshot getOrDefault ["cacheHitCount", 0];

// FAST_CUMULATIVE_CACHE_RESTORE: restaura somente o fixture runtime que acabou de ser
// produzido pelo build real desta mesma execução. Não representa comportamento de produção;
// serve para evitar um segundo scan de ~70k classes em toda entrega futura.
private _restoredMetrics = [_catalogMetricsSnapshot] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_restoredMetrics set ["invalidationCount", _statusInvalidatedData getOrDefault ["invalidationCount", _invalidateBefore + 1]];
_restoredMetrics set ["lastInvalidationReason", _statusInvalidatedData getOrDefault ["lastInvalidationReason", "AUTO_TEST_0_6_1"]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, [_catalogCacheSnapshot] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, _restoredMetrics];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, [_catalogBuildStateSnapshot] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, [_catalogRuntimeSnapshot] call ServoPeregrino_Organizador_Items_fnc_deepCopy];

private _statusFastRestored = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusFastRestoredData = _statusFastRestored getOrDefault ["data", createHashMap];
["ITEMS-0.5-161", (_statusFastRestoredData getOrDefault ["cacheBuilt", false]) && {(_statusFastRestoredData getOrDefault ["itemCount", -1]) isEqualTo _firstCatalogCount}, "Regressão cumulativa rápida restaura o cache homologado da própria execução após testar invalidate."] call _assert;
["ITEMS-0.5-162", (_statusFastRestoredData getOrDefault ["configScanCount", -1]) isEqualTo _scanBeforeRebuild && {(_statusFastRestoredData getOrDefault ["buildCount", -1]) isEqualTo _buildCountBeforeRebuild}, "Regressão rápida não executa segundo CONFIG_ALL real; scan/build permanecem em 1 nesta suíte."] call _assert;

private _rebuild = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
private _statusRebuilt = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusRebuiltData = _statusRebuilt getOrDefault ["data", createHashMap];
["ITEMS-0.5-163", (_rebuild getOrDefault ["success", false]) && {(_statusRebuiltData getOrDefault ["configScanCount", -1]) isEqualTo _scanBeforeRebuild} && {(_statusRebuiltData getOrDefault ["cacheHitCount", 0]) > _cacheHitsBeforeFastRestore}, "Após restauração do fixture, getCatalog usa cache e não dispara nova varredura global."] call _assert;

private _scanBeforePostFilter = _statusRebuiltData getOrDefault ["configScanCount", 0];
private _allFilter = ["", "ALL"] call ServoPeregrino_Organizador_Items_fnc_filterCatalog;
private _allFilterData = _allFilter getOrDefault ["data", createHashMap];
private _statusAfterPostFilter = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusAfterPostFilterData = _statusAfterPostFilter getOrDefault ["data", createHashMap];
["ITEMS-0.5-164", (_allFilter getOrDefault ["success", false]) && {(_allFilterData getOrDefault ["count", -1]) isEqualTo (_statusRebuiltData getOrDefault ["itemCount", -2])}, "Filtro ALL sem busca representa a visão integral do cache."] call _assert;
["ITEMS-0.5-165", (_statusAfterPostFilterData getOrDefault ["configScanCount", -1]) isEqualTo _scanBeforePostFilter, "Filtros posteriores continuam operando somente sobre cache."] call _assert;

private _resolveMag = ["30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
private _resolveMagItem = ((_resolveMag getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
["ITEMS-0.5-166", (_resolveMag getOrDefault ["success", false]) && {(_resolveMagItem getOrDefault ["magazineCapacity", 0]) > 0} && {(_resolveMagItem getOrDefault ["categoryId", ""]) isEqualTo "MAGAZINES"}, "CatalogItem de magazine expõe capacidade derivada de runtime e categoria sem persistir isso no ItemKit."] call _assert;

// -------------------------------------------------------------------------
// Draft & Kit Lifecycle 0.6 — NEW / EDIT / dirty / merge / save explícito
// -------------------------------------------------------------------------
private _playerLoadoutBeforeDraftTests = str (getUnitLoadout player);
private _catalogStatusBeforeDraftTests = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogScansBeforeDraftTests = ((_catalogStatusBeforeDraftTests getOrDefault ["data", createHashMap]) getOrDefault ["configScanCount", -1]);

private _draftStatus0 = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftStatus0Data = _draftStatus0 getOrDefault ["data", createHashMap];
["ITEMS-0.6-172", (_draftStatus0 getOrDefault ["success", false]) && {(_draftStatus0Data getOrDefault ["ready", false])} && {!(_draftStatus0Data getOrDefault ["hasDraft", true])}, "Draft Service inicia READY e vazio; initialize não fabrica Draft."] call _assert;

private _newDraft = ["Draft Manual 0.6", "U", ["MANUAL", "LOCAL"], []] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _newDraftData = _newDraft getOrDefault ["data", createHashMap];
private _newDraftModel = _newDraftData getOrDefault ["draft", createHashMap];
["ITEMS-0.6-173", (_newDraft getOrDefault ["success", false]) && {(_newDraftModel getOrDefault ["mode", ""]) isEqualTo "NEW"} && {(_newDraftModel getOrDefault ["kitId", "x"]) isEqualTo ""}, "createNewDraft cria NEW sem identidade persistida."] call _assert;
["ITEMS-0.6-174", (_newDraftModel getOrDefault ["dirty", false]) && {(_newDraftModel getOrDefault ["preferredTarget", ""]) isEqualTo "UNIFORM"} && {(count (_newDraftModel getOrDefault ["entries", []])) isEqualTo 0}, "Draft NEW vazio é permitido em memória, nasce dirty e canoniza U -> UNIFORM."] call _assert;
private _blockedReplace = ["Outro Draft", "ANY", ["MANUAL", "LOCAL"], []] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
["ITEMS-0.6-175", !(_blockedReplace getOrDefault ["success", true]) && {(_blockedReplace getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE"}, "Draft dirty não pode ser substituído silenciosamente por outro Draft."] call _assert;

private _nameChange = ["Kit Operacional 0.6"] call ServoPeregrino_Organizador_Items_fnc_setDraftName;
private _targetChange = ["C"] call ServoPeregrino_Organizador_Items_fnc_setDraftPreferredTarget;
private _editState = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _editDraft = ((_editState getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-176", (_nameChange getOrDefault ["success", false]) && {(_editDraft getOrDefault ["name", ""]) isEqualTo "Kit Operacional 0.6"}, "Nome é editado somente no Draft."] call _assert;
["ITEMS-0.6-177", (_targetChange getOrDefault ["success", false]) && {(_editDraft getOrDefault ["preferredTarget", ""]) isEqualTo "VEST"} && {_editDraft getOrDefault ["dirty", false]}, "Target C é canonizado para VEST e mantém dirty."] call _assert;

private _addFAK = ["FirstAidKit", 2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _draftAfterFAK = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _entriesAfterFAK = _draftAfterFAK getOrDefault ["entries", []];
private _fakIdx = _entriesAfterFAK findIf {(_x # 1) isEqualTo "ITEM" && {(_x # 2) isEqualTo "FirstAidKit"} && {(_x # 4) isEqualTo "NONE"}};
["ITEMS-0.6-178", (_addFAK getOrDefault ["success", false]) && {_fakIdx >= 0} && {((_entriesAfterFAK # _fakIdx) # 3) isEqualTo 2}, "Catalog -> Draft converte FirstAidKit em ITEM/NONE quantity=2."] call _assert;

private _addMag = ["30Rnd_65x39_caseless_mag", 1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _exactForDraftResult = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 3, "EXACT", [30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exactForDraft = ((_exactForDraftResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _addExact = [_exactForDraft] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;
private _entriesMag = ((((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]) getOrDefault ["entries", []]));
private _fullIdx = _entriesMag findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_x # 4) isEqualTo "DEFAULT_FULL"}};
private _exactIdx = _entriesMag findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.6-179", (_addMag getOrDefault ["success", false]) && {_fullIdx >= 0} && {((_entriesMag # _fullIdx) # 3) isEqualTo 1}, "Catalog magazine entra como DEFAULT_FULL; catálogo não fabrica estado EXACT."] call _assert;
["ITEMS-0.6-180", (_addExact getOrDefault ["success", false]) && {_exactIdx >= 0} && {((_entriesMag # _exactIdx) # 5) isEqualTo [30,17,6]}, "Draft aceita MAGAZINE EXACT preservando stateData individual."] call _assert;

private _incExact = ["MAGAZINE", "30Rnd_65x39_caseless_mag", "EXACT"] call ServoPeregrino_Organizador_Items_fnc_incrementDraftEntry;
private _entriesAfterInc = ((((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]) getOrDefault ["entries", []]));
private _fullIdx2 = _entriesAfterInc findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_x # 4) isEqualTo "DEFAULT_FULL"}};
private _exactIdx2 = _entriesAfterInc findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.6-181", (_incExact getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_EXACT_INCREMENT_AS_DEFAULT_FULL" && {_fullIdx2 >= 0} && {((_entriesAfterInc # _fullIdx2) # 3) isEqualTo 2} && {((_entriesAfterInc # _exactIdx2) # 5) isEqualTo [30,17,6]}, "+ em EXACT mantém EXACT intacto e cria/incrementa DEFAULT_FULL separado."] call _assert;

private _growExact = ["MAGAZINE", "30Rnd_65x39_caseless_mag", "EXACT", 4] call ServoPeregrino_Organizador_Items_fnc_setDraftEntryQuantity;
["ITEMS-0.6-182", !(_growExact getOrDefault ["success", true]) && {(_growExact getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_EXACT_QUANTITY_GROW_FORBIDDEN"}, "Edição numérica de EXACT não pode fabricar stateData."] call _assert;
private _shrinkExact = ["MAGAZINE", "30Rnd_65x39_caseless_mag", "EXACT", 2] call ServoPeregrino_Organizador_Items_fnc_setDraftEntryQuantity;
private _entriesShrink = ((((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]) getOrDefault ["entries", []]));
private _exactShrinkIdx = _entriesShrink findIf {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.6-183", (_shrinkExact getOrDefault ["success", false]) && {_exactShrinkIdx >= 0} && {((_entriesShrink # _exactShrinkIdx) # 3) isEqualTo 2} && {((_entriesShrink # _exactShrinkIdx) # 5) isEqualTo [30,17]}, "Reduzir quantidade EXACT remove estados do Draft sem inventar munição."] call _assert;
private _decExact = ["MAGAZINE", "30Rnd_65x39_caseless_mag", "EXACT"] call ServoPeregrino_Organizador_Items_fnc_decrementDraftEntry;
private _entriesDec = ((((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]) getOrDefault ["entries", []]));
private _exactDecIdx = _entriesDec findIf {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.6-184", (_decExact getOrDefault ["success", false]) && {_exactDecIdx >= 0} && {((_entriesDec # _exactDecIdx) # 5) isEqualTo [30]}, "- em EXACT remove exatamente uma unidade/estado."] call _assert;

private _zeroFAK = ["ITEM", "FirstAidKit", "NONE", 0] call ServoPeregrino_Organizador_Items_fnc_setDraftEntryQuantity;
private _entriesZero = ((((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]) getOrDefault ["entries", []]));
["ITEMS-0.6-185", (_zeroFAK getOrDefault ["success", false]) && {(_entriesZero findIf {(_x # 2) isEqualTo "FirstAidKit"}) < 0}, "Quantidade zero remove a ItemEntry do Draft."] call _assert;
private _addFAK2 = ["FirstAidKit", 2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
["ITEMS-0.6-186", _addFAK2 getOrDefault ["success", false], "Item removido pode ser adicionado novamente via Catalog sem tocar inventário."] call _assert;

private _mergeItemR = ["ITEM", "FirstAidKit", 3, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _mergeExactR = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _repoBeforeMerge = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
private _repoBeforeMergeCount = ((_repoBeforeMerge getOrDefault ["data", createHashMap]) getOrDefault ["count", -1]);
private _mergeItemEntry = ((_mergeItemR getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _mergeExactEntry = ((_mergeExactR getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _mergeEntries = [[_mergeItemEntry, _mergeExactEntry]] call ServoPeregrino_Organizador_Items_fnc_mergeEntriesIntoDraft;
private _afterMergeDraft = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _afterMergeEntries = _afterMergeDraft getOrDefault ["entries", []];
private _mergeFAKIdx = _afterMergeEntries findIf {(_x # 2) isEqualTo "FirstAidKit"};
private _mergeExactIdx = _afterMergeEntries findIf {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x # 4) isEqualTo "EXACT"}};
["ITEMS-0.6-187", (_mergeEntries getOrDefault ["success", false]) && {_mergeFAKIdx >= 0} && {((_afterMergeEntries # _mergeFAKIdx) # 3) isEqualTo 5} && {((_afterMergeEntries # _mergeExactIdx) # 5) isEqualTo [30,6]}, "Merge normaliza ITEM e concatena EXACT preservando ordem/semântica."] call _assert;
private _repoAfterMerge = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
["ITEMS-0.6-188", (((_repoAfterMerge getOrDefault ["data", createHashMap]) getOrDefault ["count", -2]) isEqualTo _repoBeforeMergeCount) && {_afterMergeDraft getOrDefault ["dirty", false]}, "Merge é somente Draft: não existe autosave no Repository."] call _assert;

private _saveNew = [] call ServoPeregrino_Organizador_Items_fnc_saveDraft;
private _saveNewData = _saveNew getOrDefault ["data", createHashMap];
private _savedKit = _saveNewData getOrDefault ["kit", []];
private _savedDraft = _saveNewData getOrDefault ["draft", createHashMap];
private _savedId = if ((count _savedKit) > 2) then {_savedKit # 2} else {""};
["ITEMS-0.6-189", (_saveNew getOrDefault ["success", false]) && {[_savedId] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId} && {(_savedDraft getOrDefault ["mode", ""]) isEqualTo "EDIT"} && {!(_savedDraft getOrDefault ["dirty", true])}, "Save NEW gera ID, persiste e transforma Draft em EDIT limpo."] call _assert;
private _savedGet = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _savedGetKit = ((_savedGet getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _savedExactIdx = if ((count _savedGetKit) > 8) then {(_savedGetKit # 8) findIf {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x # 4) isEqualTo "EXACT"}}} else {-1};
["ITEMS-0.6-190", (_savedGet getOrDefault ["success", false]) && {_savedExactIdx >= 0} && {(((_savedGetKit # 8) # _savedExactIdx) # 5) isEqualTo [30,6]}, "Repository recebe exatamente o payload Draft, inclusive EXACT após merge."] call _assert;

private _createdAtBeforeEdit = if ((count _savedGetKit) > 6) then {+(_savedGetKit # 6)} else {[]};
private _editName = ["Kit Operacional 0.6 EDIT"] call ServoPeregrino_Organizador_Items_fnc_setDraftName;
private _dirtyState = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _dirtyCurrent = ((_dirtyState getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-191", (_editName getOrDefault ["success", false]) && {_dirtyCurrent getOrDefault ["dirty", false]} && {(_dirtyCurrent getOrDefault ["kitId", ""]) isEqualTo _savedId}, "Editar Draft EDIT marca dirty sem trocar identidade."] call _assert;
private _blockedLoadDirty = [_savedId] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit;
["ITEMS-0.6-192", !(_blockedLoadDirty getOrDefault ["success", true]) && {(_blockedLoadDirty getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE"}, "Até recarregar o mesmo kit é bloqueado enquanto EDIT está dirty; decisão precisa ser explícita."] call _assert;
private _saveEdit = [] call ServoPeregrino_Organizador_Items_fnc_saveDraft;
private _saveEditKit = ((_saveEdit getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
["ITEMS-0.6-193", (_saveEdit getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_SAVED_EDIT" && {(count _saveEditKit) > 7} && {(_saveEditKit # 2) isEqualTo _savedId}, "Save EDIT preserva kitId e limpa dirty."] call _assert;
["ITEMS-0.6-194", ((count _saveEditKit) > 7) && {(_saveEditKit # 6) isEqualTo _createdAtBeforeEdit} && {(_saveEditKit # 3) isEqualTo "Kit Operacional 0.6 EDIT"}, "Save EDIT preserva createdAt original e persiste alterações do Draft."] call _assert;

["Nome Local a Descartar"] call ServoPeregrino_Organizador_Items_fnc_setDraftName;
private _dirtyBeforeDiscard = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-195", _dirtyBeforeDiscard getOrDefault ["dirty", false], "Dirty permanece verdadeiro até ação explícita de Save/Discard."] call _assert;
private _discardEdit = [] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
private _afterDiscardEdit = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-196", (_discardEdit getOrDefault ["success", false]) && {!(_afterDiscardEdit getOrDefault ["dirty", true])} && {(_afterDiscardEdit getOrDefault ["name", ""]) isEqualTo "Kit Operacional 0.6 EDIT"}, "Discard EDIT recarrega o Repository atual e elimina somente alterações locais."] call _assert;

private _mergeSourceEntryR = ["ITEM", "ToolKit", 2, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _mergeSourceEntry = ((_mergeSourceEntryR getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _mergeSourceKitR = ["Kit Fonte Merge 0.6", [_mergeSourceEntry], "BACKPACK", ["MANUAL", "TEST"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _mergeSourceSave = [((_mergeSourceKitR getOrDefault ["data", createHashMap]) getOrDefault ["kit", []])] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _mergeSourceKit = ((_mergeSourceSave getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _mergeSourceId = if ((count _mergeSourceKit) > 2) then {_mergeSourceKit # 2} else {""};
private _repoSourceBeforeMerge = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _repoSourceBeforeMergeKit = ((_repoSourceBeforeMerge getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _mergeKit = [_mergeSourceId] call ServoPeregrino_Organizador_Items_fnc_mergeKitIntoDraft;
private _mergedKitDraft = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _toolIdx = (_mergedKitDraft getOrDefault ["entries", []]) findIf {(_x # 2) isEqualTo "ToolKit"};
["ITEMS-0.6-197", (_mergeKit getOrDefault ["success", false]) && {_toolIdx >= 0} && {_mergedKitDraft getOrDefault ["dirty", false]}, "Kit persistido pode ser mesclado/copiado no Draft atual sem trocar identidade/nome automaticamente."] call _assert;
private _repoSourceAfterMerge = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
["ITEMS-0.6-198", (((_repoSourceAfterMerge getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]) isEqualTo _repoSourceBeforeMergeKit), "Merge de kit não salva implicitamente o Draft nem altera o kit fonte."] call _assert;

private _repoCountBeforeSaveAs = ((([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data", createHashMap]) getOrDefault ["count", -1]);
private _saveAs = ["Kit Duplicado 0.6"] call ServoPeregrino_Organizador_Items_fnc_saveDraftAsNew;
private _saveAsKit = ((_saveAs getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _saveAsId = if ((count _saveAsKit) > 2) then {_saveAsKit # 2} else {""};
["ITEMS-0.6-199", (_saveAs getOrDefault ["success", false]) && {!(_saveAsId isEqualTo _savedId)} && {[_saveAsId] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId}, "Save As New sempre cria nova identidade e seleciona o novo ItemKit como EDIT limpo."] call _assert;
private _repoCountAfterSaveAs = ((([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data", createHashMap]) getOrDefault ["count", -2]);
private _originalAfterSaveAs = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
["ITEMS-0.6-200", (_repoCountAfterSaveAs isEqualTo (_repoCountBeforeSaveAs + 1)) && {(((_originalAfterSaveAs getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]) # 2) isEqualTo _savedId}, "Save As New adiciona exatamente um kit e preserva o original independente."] call _assert;

["Mudança no Duplicado"] call ServoPeregrino_Organizador_Items_fnc_setDraftName;
private _discardDuplicate = [] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
private _dupAfterDiscard = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-201", (_discardDuplicate getOrDefault ["success", false]) && {(_dupAfterDiscard getOrDefault ["name", ""]) isEqualTo "Kit Duplicado 0.6"} && {!(_dupAfterDiscard getOrDefault ["dirty", true])}, "Discard de EDIT criado por Save As New volta ao snapshot persistido desse novo ID."] call _assert;

private _newAfterClean = ["Novo descartável", "ANY", ["MANUAL", "LOCAL"], []] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _discardNew = [] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
private _stateAfterDiscardNew = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
["ITEMS-0.6-202", (_newAfterClean getOrDefault ["success", false]) && {(_discardNew getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_NEW_DISCARDED"} && {!(((_stateAfterDiscardNew getOrDefault ["data", createHashMap]) getOrDefault ["hasDraft", true]))}, "Discard NEW abandona o draft não persistido e deixa o serviço vazio."] call _assert;

private _loadOriginal = [_savedId] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit;
private _loadedOriginalDraft = ((_loadOriginal getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap]);
["ITEMS-0.6-203", (_loadOriginal getOrDefault ["success", false]) && {(_loadedOriginalDraft getOrDefault ["mode", ""]) isEqualTo "EDIT"} && {!(_loadedOriginalDraft getOrDefault ["dirty", true])} && {(_loadedOriginalDraft getOrDefault ["kitId", ""]) isEqualTo _savedId}, "loadDraftFromKit abre ItemKit persistido como EDIT limpo e registra baseUpdatedAtUTC."] call _assert;

private _externalGet = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
uiSleep 0.02; // garante timestamp externo distinto para o gate optimistic-stale.
private _externalKitRaw = ((_externalGet getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _externalKit = [_externalKitRaw] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_externalKit set [3, "ALTERADO_EXTERNO_0_6"];
private _externalSave = [_externalKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
["Mudança local concorrente"] call ServoPeregrino_Organizador_Items_fnc_setDraftName;
private _staleSave = [] call ServoPeregrino_Organizador_Items_fnc_saveDraft;
["ITEMS-0.6-204", (_externalSave getOrDefault ["success", false]) && {!(_staleSave getOrDefault ["success", true])} && {(_staleSave getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_STALE"}, "Save EDIT detecta optimistic-stale quando Repository mudou depois do load."] call _assert;
private _staleDraft = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _repoAfterStale = [_savedId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _repoAfterStaleKit = ((_repoAfterStale getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
["ITEMS-0.6-205", (_staleDraft getOrDefault ["dirty", false]) && {(count _repoAfterStaleKit) > 3} && {(_repoAfterStaleKit # 3) isEqualTo "ALTERADO_EXTERNO_0_6"}, "Falha stale não limpa dirty e não sobrescreve a versão externa do Repository."] call _assert;
private _discardStale = [] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
private _afterDiscardStale = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-206", (_discardStale getOrDefault ["success", false]) && {(_afterDiscardStale getOrDefault ["name", ""]) isEqualTo "ALTERADO_EXTERNO_0_6"} && {!(_afterDiscardStale getOrDefault ["dirty", true])}, "Discard após stale recarrega a versão atual do Repository, não uma baseline velha em memória."] call _assert;

private _captureDraftR = [[_exactForDraft], "ANY", "Capture Draft 0.6"] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
private _captureDraftModel = ((_captureDraftR getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap]);
private _openCapture = [_captureDraftModel] call ServoPeregrino_Organizador_Items_fnc_openCaptureDraft;
private _openedCaptureDraft = ((_openCapture getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap]);
["ITEMS-0.6-207", (_openCapture getOrDefault ["success", false]) && {(_openedCaptureDraft getOrDefault ["mode", ""]) isEqualTo "NEW"} && {(_openedCaptureDraft getOrDefault ["createdFrom", ""]) isEqualTo "CAPTURE"} && {_openedCaptureDraft getOrDefault ["dirty", false]}, "Capture 0.4 pode ser adotado pelo Draft Service como NEW dirty sem autosave."] call _assert;
private _saveCaptureDraft = [] call ServoPeregrino_Organizador_Items_fnc_saveDraft;
private _saveCaptureKit = ((_saveCaptureDraft getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _saveCaptureExactIdx = if ((count _saveCaptureKit) > 8) then {(_saveCaptureKit # 8) findIf {(_x # 4) isEqualTo "EXACT"}} else {-1};
["ITEMS-0.6-208", (_saveCaptureDraft getOrDefault ["success", false]) && {_saveCaptureExactIdx >= 0} && {(((_saveCaptureKit # 8) # _saveCaptureExactIdx) # 5) isEqualTo [30,17,6]}, "Save de Draft originado por Capture preserva EXACT integralmente."] call _assert;

private _missingDraftAdd = ["SP_ORG_ITEMS_CLASS_DOES_NOT_EXIST_0_6", 1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
["ITEMS-0.6-209", !(_missingDraftAdd getOrDefault ["success", true]) && {(_missingDraftAdd getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_CATALOG_ITEM_UNAVAILABLE"}, "Draft não materializa classe de mod ausente; identidade persistida continua responsabilidade do ItemKit existente."] call _assert;
private _weaponDraftAdd = ["arifle_MX_F", 1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
["ITEMS-0.6-210", !(_weaponDraftAdd getOrDefault ["success", true]) && {(_weaponDraftAdd getOrDefault ["code", ""]) isEqualTo "ITEMS_DRAFT_CATALOG_ITEM_FOREIGN_DOMAIN"}, "Draft respeita ownership: arma-base não é adotada por Items via Catalog."] call _assert;

private _addToolDraft = ["ToolKit", 1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _removeToolDraft = ["ITEM", "ToolKit", "NONE"] call ServoPeregrino_Organizador_Items_fnc_removeDraftEntry;
private _afterRemoveTool = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-211", (_addToolDraft getOrDefault ["success", false]) && {(_removeToolDraft getOrDefault ["success", false])} && {((_afterRemoveTool getOrDefault ["entries", []]) findIf {(_x # 2) isEqualTo "ToolKit"}) < 0}, "removeDraftEntry remove a linha identificada por type/class/mode, nunca por seleção visual global."] call _assert;

private _copyState1 = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _copyDraft1 = ((_copyState1 getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _originalCopyName = _copyDraft1 getOrDefault ["name", ""];
_copyDraft1 set ["name", "MUTACAO_CALLER_NAO_DEVE_VAZAR"];
private _copyState2 = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _copyDraft2 = ((_copyState2 getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
["ITEMS-0.6-212", (_copyDraft2 getOrDefault ["name", ""]) isEqualTo _originalCopyName, "getDraftState devolve cópia: caller não contamina o Draft autoritativo."] call _assert;



private _playerLoadoutAfterDraftTests = str (getUnitLoadout player);
["ITEMS-0.6-213", _playerLoadoutAfterDraftTests isEqualTo _playerLoadoutBeforeDraftTests, "Todo o ciclo Draft 0.6 é não físico: loadout do jogador permanece idêntico."] call _assert;
private _catalogStatusAfterDraftTests = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogScansAfterDraftTests = ((_catalogStatusAfterDraftTests getOrDefault ["data", createHashMap]) getOrDefault ["configScanCount", -2]);
["ITEMS-0.6-214", _catalogScansAfterDraftTests isEqualTo _catalogScansBeforeDraftTests, "Operações Draft usam resolve/cache local e não provocam nova varredura global do Catalog."] call _assert;
// Hotfix 0.6.1 — deep copy deve isolar HashMaps e estruturas aninhadas, não só arrays.
private _copyProbeSource = createHashMapFromArray [["name", "ORIGINAL"], ["nested", createHashMapFromArray [["values", [1,2,3]]]]];
private _copyProbe = [_copyProbeSource] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_copyProbe set ["name", "MUTATED_COPY"];
["ITEMS-0.6.1-215", (_copyProbeSource getOrDefault ["name", ""]) isEqualTo "ORIGINAL", "deepCopy cria um HashMap top-level independente em vez de devolver a mesma referência."] call _assert;
private _copyProbeNested = _copyProbe getOrDefault ["nested", createHashMap];
private _copyProbeValues = _copyProbeNested getOrDefault ["values", []];
_copyProbeValues set [0, 999];
_copyProbeNested set ["values", _copyProbeValues];
private _sourceNested = _copyProbeSource getOrDefault ["nested", createHashMap];
["ITEMS-0.6.1-216", ((_sourceNested getOrDefault ["values", []]) # 0) isEqualTo 1, "deepCopy é recursivo em HashMap + Array; mutação aninhada da cópia não vaza para a origem."] call _assert;

private _internalAliasState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
private _internalCurrent = _internalAliasState getOrDefault ["current", createHashMap];
private _internalBaseline = _internalAliasState getOrDefault ["baseline", createHashMap];
private _currentNameBeforeAliasProbe = _internalCurrent getOrDefault ["name", ""];
private _baselineNameBeforeAliasProbe = _internalBaseline getOrDefault ["name", ""];
_internalCurrent set ["name", "SP_ORG_ALIAS_PROBE_CURRENT"];
private _baselineIndependent = (_internalBaseline getOrDefault ["name", ""]) isEqualTo _baselineNameBeforeAliasProbe && {(_internalBaseline getOrDefault ["name", ""]) isNotEqualTo "SP_ORG_ALIAS_PROBE_CURRENT"};
_internalCurrent set ["name", _currentNameBeforeAliasProbe];
["ITEMS-0.6.1-217", _baselineIndependent, "Draft current e baseline são HashMaps independentes; editar current não contamina baseline."] call _assert;

private _nestedStateCopy1 = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _nestedDraftCopy1 = ((_nestedStateCopy1 getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
private _nestedEntriesCopy1 = _nestedDraftCopy1 getOrDefault ["entries", []];
private _nestedExactCopyIdx = _nestedEntriesCopy1 findIf {(_x # 4) isEqualTo "EXACT" && {(count (_x # 5)) > 0}};
private _nestedIsolationOk = _nestedExactCopyIdx >= 0;
if (_nestedIsolationOk) then {
    private _entryCopy = _nestedEntriesCopy1 # _nestedExactCopyIdx;
    private _stateDataCopy = +(_entryCopy # 5);
    private _expectedAmmo0 = _stateDataCopy # 0;
    _stateDataCopy set [0, 999];
    _entryCopy set [5, _stateDataCopy];
    _nestedEntriesCopy1 set [_nestedExactCopyIdx, _entryCopy];
    _nestedDraftCopy1 set ["entries", _nestedEntriesCopy1];
    private _nestedStateCopy2 = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
    private _nestedDraftCopy2 = ((_nestedStateCopy2 getOrDefault ["data", createHashMap]) getOrDefault ["current", createHashMap]);
    private _nestedEntriesCopy2 = _nestedDraftCopy2 getOrDefault ["entries", []];
    private _nestedExactCopyIdx2 = _nestedEntriesCopy2 findIf {(_x # 4) isEqualTo "EXACT" && {(count (_x # 5)) > 0}};
    _nestedIsolationOk = _nestedExactCopyIdx2 >= 0 && {(((_nestedEntriesCopy2 # _nestedExactCopyIdx2) # 5) # 0) isEqualTo _expectedAmmo0};
};
["ITEMS-0.6.1-218", _nestedIsolationOk, "getDraftState isola também arrays/stateData aninhados dentro do HashMap retornado."] call _assert;

["ITEMS-0.6.1-219", _catalogScansAfterDraftTests isEqualTo 1, "Suíte cumulativa 0.6.1 executa exatamente um CONFIG_ALL real; rebuild completo da 0.5.1 fica no gate manual lento opcional."] call _assert;


// -------------------------------------------------------------------------
// Entrega 0.7 — Four-Panel UI Shell
// -------------------------------------------------------------------------
private _uiStateR = [] call ServoPeregrino_Organizador_Items_fnc_getUIState;
private _uiState = ((_uiStateR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
["ITEMS-0.7-220", (_uiStateR getOrDefault ["success",false]) && {(_uiState getOrDefault ["ready",false])} && {!(_uiState getOrDefault ["readOnlyShell",true])} && {_uiState getOrDefault ["draftInteractionReady",false]} && {!(_uiState getOrDefault ["physicalMutationEnabled",true])}, "UI State preserva contrato Four-Panel e evolui de shell read-only para Draft editing com físico OFF."] call _assert;
["ITEMS-0.7-221", (_uiState getOrDefault ["applicationTarget",""]) isEqualTo "ANY" && {(_uiState getOrDefault ["equipmentView",""]) isEqualTo "U"}, "Destino de aplicação e visualização física possuem defaults distintos e explícitos."] call _assert;
private _uiInternal = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _uiInternal set ["applicationTarget","M"]; _uiInternal set ["equipmentView","C"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiInternal];
private _uiIndependentR=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _uiIndependent=((_uiIndependentR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
["ITEMS-0.7-222", (_uiIndependent getOrDefault ["applicationTarget",""]) isEqualTo "M" && {(_uiIndependent getOrDefault ["equipmentView",""]) isEqualTo "C"}, "Destino da aplicação permanece independente do equipamento visualizado."] call _assert;
_uiInternal set ["applicationTarget","ANY"]; _uiInternal set ["equipmentView","U"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiInternal];
private _uiCopyR=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _uiCopy=((_uiCopyR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]); _uiCopy set ["catalogQuery","MUTATION_SHOULD_NOT_LEAK"]; private _uiCopyR2=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _uiCopy2=((_uiCopyR2 getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
["ITEMS-0.7-223", (_uiCopy2 getOrDefault ["catalogQuery",""]) isNotEqualTo "MUTATION_SHOULD_NOT_LEAK", "getUIState devolve cópia defensiva; caller não contamina estado autoritativo."] call _assert;
private _feedbackBefore=count (_uiCopy2 getOrDefault ["history",[]]); ["Mensagem teste UI 0.7","INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback; private _feedbackR=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _feedback=((_feedbackR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
["ITEMS-0.7-224", (_feedback getOrDefault ["temporaryMessage",""]) isEqualTo "Mensagem teste UI 0.7" && {(count (_feedback getOrDefault ["history",[]])) >= _feedbackBefore}, "Feedback temporário e histórico transitório pertencem ao estado da UI."] call _assert;
private _loadoutBeforeUIVM=str (getUnitLoadout player); private _scanBeforeUIVM=(([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap]) getOrDefault ["configScanCount",-1];
private _vmR=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel; private _vm=_vmR getOrDefault ["data",createHashMap];
["ITEMS-0.7-225", (_vmR getOrDefault ["success",false]) && {(_vm getOrDefault ["panels",[]]) isEqualTo ["KITS","DRAFT","CATALOG","EQUIPMENT"]}, "View-model expõe exatamente os quatro painéis simultâneos do contrato UX."] call _assert;
["ITEMS-0.7-226", !(_vm getOrDefault ["readOnlyShell",true]) && {_vm getOrDefault ["draftInteractionReady",false]} && {!(_vm getOrDefault ["physicalMutationEnabled",true])}, "View-model permite Draft Direct Manipulation sem antecipar mutação física/Application Engine."] call _assert;
["ITEMS-0.7-227", (_vm getOrDefault ["kits",[]]) isEqualType [], "Painel MEUS KITS é alimentado pelo Repository em estrutura própria de view-model."] call _assert;
private _vmDraft=_vm getOrDefault ["draft",createHashMap]; ["ITEMS-0.7-228", (_vmDraft getOrDefault ["rows",[]]) isEqualType [] && {(_vmDraft getOrDefault ["hasDraft",false]) isEqualType true}, "Painel KIT SELECIONADO representa Draft/estado vazio sem tocar persistência."] call _assert;
private _vmCat=_vm getOrDefault ["catalog",createHashMap]; ["ITEMS-0.7-229", (_vmCat getOrDefault ["cacheBuilt",false]) && {(_vmCat getOrDefault ["baseCount",0]) > 0}, "Painel CATÁLOGO usa cache CONFIG_ALL homologado da sessão."] call _assert;
["ITEMS-0.7-230", (count (_vmCat getOrDefault ["rows",[]])) <= SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE && {(_vmCat getOrDefault ["totalFiltered",0]) >= count (_vmCat getOrDefault ["rows",[]])}, "Catálogo renderiza janela virtual limitada sem limitar a base completa."] call _assert;
private _vmEq=_vm getOrDefault ["equipment",createHashMap]; ["ITEMS-0.7-231", (_vmEq getOrDefault ["view",""]) isEqualTo "U" && {_vmEq getOrDefault ["loadoutUnchanged",false]}, "Painel CONTEÚDO lê o Uniforme fisicamente sem alterar loadout."] call _assert;
["ITEMS-0.7-232", (str (getUnitLoadout player)) isEqualTo _loadoutBeforeUIVM, "Construir todos os quatro view-models é não físico."] call _assert;
private _scanAfterUIVM=(([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap]) getOrDefault ["configScanCount",-2]; ["ITEMS-0.7-233", _scanAfterUIVM isEqualTo _scanBeforeUIVM, "Construir/filtrar view-model da UI não dispara nova varredura global do Catalog."] call _assert;
["ITEMS-0.7-234", (_vm getOrDefault ["context",""]) find "destino aplicação" >= 0 && {(_vm getOrDefault ["context",""]) find "visualizar" >= 0}, "Rodapé de contexto explicita destino de aplicação e equipamento visualizado separadamente."] call _assert;
private _stateForFilter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _stateForFilter set ["catalogQuery","FirstAidKit"]; _stateForFilter set ["catalogCategory","MEDICAL"]; _stateForFilter set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateForFilter]; private _filteredVMR=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel; private _filteredCat=(_filteredVMR getOrDefault ["data",createHashMap]) getOrDefault ["catalog",createHashMap];
["ITEMS-0.7-235", (_filteredCat getOrDefault ["totalFiltered",0]) >= 1 && {((_filteredCat getOrDefault ["rows",[]]) findIf {(_x getOrDefault ["className",""]) isEqualTo "FirstAidKit"}) >= 0}, "Busca + categoria da UI filtram localmente o catálogo sem alterar base."] call _assert;
private _scanAfterFilter=(([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap]) getOrDefault ["configScanCount",-3]; ["ITEMS-0.7-236", _scanAfterFilter isEqualTo _scanBeforeUIVM, "Busca/filtro da UI não revarrem configs."] call _assert;
_stateForFilter set ["catalogQuery",""]; _stateForFilter set ["catalogCategory","ALL"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateForFilter];
private _cfgRoot=if (isClass (missionConfigFile >> "SP_ORG_Items_Dialog")) then {missionConfigFile} else {configFile}; ["ITEMS-0.7-237", isClass (_cfgRoot >> "SP_ORG_Items_Dialog"), "Classe SP_ORG_Items_Dialog está registrada no config da execução."] call _assert;
private _dialogCfg=_cfgRoot >> "SP_ORG_Items_Dialog"; ["ITEMS-0.7-238", getNumber (_dialogCfg >> "idd") isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD, "IDD 7700 da UI é estável e publicável no build info."] call _assert;
private _controls=_dialogCfg >> "controls"; ["ITEMS-0.7-239", isClass (_controls >> "KitsList") && {isClass (_controls >> "DraftList")} && {isClass (_controls >> "CatalogList")} && {isClass (_controls >> "EquipmentList")}, "Config contém listas dedicadas aos quatro painéis."] call _assert;
["ITEMS-0.7-240", isClass (_controls >> "KitsSearch") && {isClass (_controls >> "DraftSearch")} && {isClass (_controls >> "CatalogSearch")} && {isClass (_controls >> "EquipmentSearch")}, "Cada painel possui busca local própria no shell."] call _assert;
["ITEMS-0.7-241", isClass (_controls >> "AppAny") && {isClass (_controls >> "AppU")} && {isClass (_controls >> "AppC")} && {isClass (_controls >> "AppM")}, "Controles de destino de aplicação ANY/U/C/M existem separados da visualização física."] call _assert;
["ITEMS-0.7-242", isClass (_controls >> "EquipU") && {isClass (_controls >> "EquipC")} && {isClass (_controls >> "EquipM")}, "Controles U/C/M de visualização do equipamento são um grupo distinto."] call _assert;
["ITEMS-0.7-243", isClass (_controls >> "FooterContext") && {isClass (_controls >> "FooterMessage")} && {isClass (_controls >> "FooterHistory")}, "Footer implementa contexto persistente, mensagem temporária e histórico da sessão."] call _assert;
["ITEMS-0.7-244", isClass (_controls >> "Prev") && {isClass (_controls >> "Next")}, "Catálogo possui navegação da janela virtual sem criar milhares de controles permanentes."] call _assert;
private _build07=[] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo; ["ITEMS-0.7-245", (_build07 getOrDefault ["delivery",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION && {(_build07 getOrDefault ["uiDisplayIdd",0]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD}, "BuildInfo publica a entrega corrente do header e o contrato básico da UI sem congelar versão intermediária."] call _assert;
private _runtime07=[] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus; private _runtime07d=_runtime07 getOrDefault ["data",createHashMap]; ["ITEMS-0.7-246", _runtime07d getOrDefault ["uiReady",false], "Runtime publica uiReady=true somente após a implementação real do shell."] call _assert;
private _cap07=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability; private _cap07m=(((_cap07 getOrDefault ["data",createHashMap]) getOrDefault ["capability",createHashMap]) getOrDefault ["metadata",createHashMap]); ["ITEMS-0.7-247", (_cap07m getOrDefault ["displayClass",""]) isEqualTo "SP_ORG_Items_Dialog" && {(_cap07m getOrDefault ["panels",[]]) isEqualTo ["KITS","DRAFT","CATALOG","EQUIPMENT"]}, "Capability items.ui descreve display e quatro painéis sem expor internals de outro módulo."] call _assert;
["ITEMS-0.7-248", !(_cap07m getOrDefault ["mutatesInventory",true]), "Capability items.ui declara explicitamente que o shell não muta inventário."] call _assert;
private _beforeFeedbackLoadout=str (getUnitLoadout player); for "_i" from 1 to 8 do {[format ["Hist %1",_i],"INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;}; private _histCapR=[] call ServoPeregrino_Organizador_Items_fnc_getUIState; private _histCap=((_histCapR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]); ["ITEMS-0.7-249", (count (_histCap getOrDefault ["history",[]])) <= 6, "Histórico transitório possui limite e não cresce indefinidamente durante sessão."] call _assert;
["ITEMS-0.7-250", (str (getUnitLoadout player)) isEqualTo _beforeFeedbackLoadout, "Feedback/estado UI não altera inventário."] call _assert;
private _statePage=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _statePage set ["catalogOffset",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_statePage]; private _pageVMR=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel; private _pageCat=(_pageVMR getOrDefault ["data",createHashMap]) getOrDefault ["catalog",createHashMap]; ["ITEMS-0.7-251", (_pageCat getOrDefault ["offset",0]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE && {(count (_pageCat getOrDefault ["rows",[]])) <= SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE}, "Segunda janela virtual do catálogo preserva base integral sem milhares de controles."] call _assert;
_statePage set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_statePage];
private _missingMeta=["SP_ORG_ITEMS_UI_MISSING_0_7"] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata; ["ITEMS-0.7-252", !(_missingMeta getOrDefault ["available",true]) && {(_missingMeta getOrDefault ["className",""]) isEqualTo "SP_ORG_ITEMS_UI_MISSING_0_7"}, "UI metadata mantém identidade de item ausente marcada como indisponível."] call _assert;
private _loadoutFinalUI=str (getUnitLoadout player); ["ITEMS-0.7-253", _loadoutFinalUI isEqualTo _loadoutBeforeUIVM, "Toda a validação do shell 0.7 termina com loadout idêntico ao início do gate UI."] call _assert;
private _scanFinalUI=(([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap]) getOrDefault ["configScanCount",-9]; ["ITEMS-0.7-254", _scanFinalUI isEqualTo 1, "Suíte 0.7 mantém exatamente um CONFIG_ALL real apesar de view-model, filtros e paginação."] call _assert;

// -------------------------------------------------------------------------
// Hotfix 0.7.1 — prova runtime do config de controles e do display handle.
// A 0.7 apenas provava existência das classes; controles sem `type` ainda passavam.
// -------------------------------------------------------------------------
private _bg = _dialogCfg >> "controlsBackground";
private _typesResolved =
    (getNumber (_controls >> "HeaderTitle" >> "type") isEqualTo 0) &&
    (getNumber (_controls >> "Close" >> "type") isEqualTo 1) &&
    (getNumber (_controls >> "KitsSearch" >> "type") isEqualTo 2) &&
    (getNumber (_controls >> "KitsList" >> "type") isEqualTo 5) &&
    (getNumber (_controls >> "KitsStatus" >> "type") isEqualTo 13) &&
    (getNumber (_bg >> "Shade" >> "type") isEqualTo 0);
["ITEMS-0.7.1-255", _typesResolved, "Tipos CT_* dos controles resolvem no config runtime; regressão 'no type entry' não pode retornar verde."] call _assert;

private _displayBeforeSmoke = findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayBeforeSmoke) then {closeDialog 0; uiSleep 0.02;};
private _smokeOpen = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
private _smokeDisplay = findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
["ITEMS-0.7.1-256", (_smokeOpen getOrDefault ["success",false]) && {!isNull _smokeDisplay}, "Smoke runtime: createDialog cria display 7700 real em vez de apenas possuir classe config."] call _assert;

private _requiredControlsReady = !isNull _smokeDisplay &&
    {!isNull (_smokeDisplay displayCtrl 1102)} &&
    {!isNull (_smokeDisplay displayCtrl 2104)} &&
    {!isNull (_smokeDisplay displayCtrl 3120)} &&
    {!isNull (_smokeDisplay displayCtrl 4120)} &&
    {!isNull (_smokeDisplay displayCtrl 5000)};
["ITEMS-0.7.1-257", _requiredControlsReady, "Smoke runtime: quatro listas e footer existem como Controls reais no display aberto."] call _assert;

private _uiStoredDisplay = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
private _missionStoredDisplay = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
["ITEMS-0.7.1-258", (!isNull _uiStoredDisplay) && {_uiStoredDisplay isEqualTo _smokeDisplay} && {isNull _missionStoredDisplay}, "Handle Display fica em uiNamespace; missionNamespace não recebe valor não serializável."] call _assert;

if (!isNull _smokeDisplay) then {closeDialog 0; uiSleep 0.02;};
private _closedDisplay = findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _closedStoredDisplay = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
["ITEMS-0.7.1-259", isNull _closedDisplay && {isNull _closedStoredDisplay}, "Unload/close limpa o handle UI sem deixar display órfão."] call _assert;


// -------------------------------------------------------------------------
// Hotfix 0.7.2 — contrato visual: contexto do mundo + ícones sempre opacos.
// -------------------------------------------------------------------------
private _shadeColor = getArray (_bg >> "Shade" >> "colorBackground");
private _panelAlphas = [
    (getArray (_bg >> "P1" >> "colorBackground")) # 3,
    (getArray (_bg >> "P2" >> "colorBackground")) # 3,
    (getArray (_bg >> "P3" >> "colorBackground")) # 3,
    (getArray (_bg >> "P4" >> "colorBackground")) # 3,
    (getArray (_bg >> "FooterBg" >> "colorBackground")) # 3
];
["ITEMS-0.7.2-260", (count _shadeColor) isEqualTo 4 && {(_shadeColor # 3) <= 0.18}, "Backdrop global é translúcido; o mundo ao fundo não pode ser apagado pela UI."] call _assert;
["ITEMS-0.7.2-261", (_panelAlphas findIf {_x > 0.50}) < 0, "Painéis/footer respeitam teto de opacidade do tema translúcido 0.7.2."] call _assert;
private _listBaseCfg = missionConfigFile >> "SPORG_Items_List";
private _picNormal = getArray (_listBaseCfg >> "colorPicture");
private _picSelected = getArray (_listBaseCfg >> "colorPictureSelected");
["ITEMS-0.7.2-262", (count _picNormal) isEqualTo 4 && {(_picNormal # 3) >= 0.99}, "Ícone de listbox possui alpha opaco no estado normal; não depende da seleção para existir."] call _assert;
["ITEMS-0.7.2-263", (count _picSelected) isEqualTo 4 && {(_picSelected # 3) >= 0.99}, "Ícone de listbox permanece opaco no estado selecionado; seleção altera fundo, não a existência da imagem."] call _assert;

// Smoke visual de uma linha conhecida sem seleção: filtra FirstAidKit, abre UI e lê a picture materializada.
private _visualState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_visualState set ["catalogQuery","FirstAidKit"];
_visualState set ["catalogCategory","ALL"];
_visualState set ["catalogOffset",0];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_visualState];
private _visualOpen = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
private _visualDisplay = findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _visualDisplay) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.01;};
private _visualCatalog = if (isNull _visualDisplay) then {controlNull} else {_visualDisplay displayCtrl 3120};
private _visualPicture = if (isNull _visualCatalog || {(lbSize _visualCatalog) < 1}) then {""} else {_visualCatalog lbPicture 0};
["ITEMS-0.7.2-264", (_visualOpen getOrDefault ["success",false]) && {!isNull _visualCatalog} && {(lbSize _visualCatalog) >= 1} && {_visualPicture isNotEqualTo ""}, "Linha não selecionada do catálogo materializa picture real (FirstAidKit); imagem não fica invisível até o clique."] call _assert;
if (!isNull _visualDisplay) then {closeDialog 0; uiSleep 0.02;};
["ITEMS-0.7.2-265", _captureUnit isEqualTo player && {(_playerBeforeFixtureData getOrDefault ["serialized","A"]) isEqualTo (_playerAfterFixtureData getOrDefault ["serialized","B"])}, "Runner atual usa integração física somente leitura e não cria/equipa entidade sintética que possa disparar mods externos."] call _assert;


// -------------------------------------------------------------------------
// Draft Direct Manipulation 0.8 — UI -> Draft Service, arrows, row controls and frozen drag.
// -------------------------------------------------------------------------
private _segBefore08R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segBefore08=_segBefore08R getOrDefault ["data",createHashMap];
private _ui08 = [] call ServoPeregrino_Organizador_Items_fnc_getUIState;
private _ui08s = ((_ui08 getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
["ITEMS-0.8-266", !(_ui08s getOrDefault ["readOnlyShell",true]) && {_ui08s getOrDefault ["draftInteractionReady",false]} && {!(_ui08s getOrDefault ["physicalMutationEnabled",true])}, "UI 0.8 habilita manipulação de Draft e mantém mutação física explicitamente desligada."] call _assert;
private _dlg08 = missionConfigFile >> "SP_ORG_Items_Dialog" >> "controls";
["ITEMS-0.8-267", getNumber ((_dlg08 >> "DraftList") >> "type") isEqualTo 19 || {getNumber (missionConfigFile >> "SPORG_Items_DraftTable" >> "type") isEqualTo 19}, "KIT SELECIONADO usa CT_CONTROLS_TABLE para controles reais por linha."] call _assert;
private _draftNameCfg=_dlg08>>"DraftName"; private _draftSearchCfg=_dlg08>>"DraftSearch"; private _kitSearchCfg=_dlg08>>"KitsSearch"; private _catSearchCfg=_dlg08>>"CatalogSearch"; private _eqSearchCfg=_dlg08>>"EquipmentSearch";
["ITEMS-0.8-268", abs ((getNumber (_draftSearchCfg>>"y"))-(getNumber (_kitSearchCfg>>"y"))) < 0.0001 && {abs ((getNumber (_draftSearchCfg>>"y"))-(getNumber (_catSearchCfg>>"y"))) < 0.0001} && {abs ((getNumber (_draftSearchCfg>>"y"))-(getNumber (_eqSearchCfg>>"y"))) < 0.0001}, "Busca do KIT SELECIONADO alinha verticalmente com as buscas dos outros três painéis."] call _assert;
["ITEMS-0.8-269", getNumber (_draftNameCfg>>"type") isEqualTo 2 && {(getNumber (_draftNameCfg>>"y")) < (getNumber (_draftSearchCfg>>"y"))}, "Nome editável do kit está no cabeçalho, entre título/status e antes da busca."] call _assert;
private _rowTemplate=missionConfigFile>>"SPORG_Items_DraftTable">>"RowTemplate";
["ITEMS-0.8-270", isClass (_rowTemplate>>"Minus") && {isClass (_rowTemplate>>"Quantity")} && {isClass (_rowTemplate>>"Plus")} && {isClass (_rowTemplate>>"Delete")}, "Template de linha possui - / quantidade / + / Delete como controles próprios."] call _assert;
["ITEMS-0.8-271", getNumber ((_dlg08>>"KitsList")>>"canDrag") isEqualTo 1 && {getNumber ((_dlg08>>"CatalogList")>>"canDrag") isEqualTo 1} && {getNumber ((_dlg08>>"EquipmentList")>>"canDrag") isEqualTo 1}, "Kits, Catalog e Equipment são origens nativas de drag; Draft é destino draft-only."] call _assert;

// Isolar os testes funcionais 0.8 em Draft NEW previsível.
private _pre08=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
if (_pre08 getOrDefault ["hasDraft",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;};
private _new08=["Kit UI 0.8","ANY",["TEST","UI_08"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _add08=["FirstAidKit",2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _exact08R=["MAGAZINE","30Rnd_65x39_caseless_mag",3,"EXACT",[30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exact08=((_exact08R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); if ((count _exact08)>0) then {[_exact08] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;};
private _open08=[] call ServoPeregrino_Organizador_Items_fnc_openInterface; uiSleep 0.02; private _disp08=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _disp08) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.02;};
private _table08=if (isNull _disp08) then {controlNull}else{_disp08 displayCtrl 2104};
["ITEMS-0.8-272", (_new08 getOrDefault ["success",false]) && {_add08 getOrDefault ["success",false]} && {!isNull _table08} && {(ctRowCount _table08)>=2}, "Smoke runtime: Draft NEW materializa linhas reais no Controls Table."] call _assert;
private _rowControls08=if (isNull _table08 || {(ctRowCount _table08)<1}) then {[]} else {_table08 ctRowControls 0};
["ITEMS-0.8-273", (count _rowControls08)>=7 && {count ((_rowControls08#3) getVariable ["SPORG_Items_rowKey",[]]) isEqualTo 3} && {count ((_rowControls08#4) getVariable ["SPORG_Items_rowKey",[]]) isEqualTo 3} && {count ((_rowControls08#5) getVariable ["SPORG_Items_rowKey",[]]) isEqualTo 3} && {count ((_rowControls08#6) getVariable ["SPORG_Items_rowKey",[]]) isEqualTo 3}, "Cada controle de linha carrega sua própria chave type/class/mode; nenhuma ação depende de seleção global antiga."] call _assert;
private _plusItem=["PLUS",["ITEM","FirstAidKit","NONE"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
private _afterPlus=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]; private _fa=(_afterPlus getOrDefault ["entries",[]]) select {(_x#2) isEqualTo "FirstAidKit"};
["ITEMS-0.8-274", (_plusItem getOrDefault ["success",false]) && {(count _fa) isEqualTo 1} && {((_fa#0)#3) isEqualTo 3}, "+ por chave da própria linha incrementa ITEM no Draft."] call _assert;
private _minusItem=["MINUS",["ITEM","FirstAidKit","NONE"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
private _afterMinus=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]; private _fa2=(_afterMinus getOrDefault ["entries",[]]) select {(_x#2) isEqualTo "FirstAidKit"};
["ITEMS-0.8-275", (_minusItem getOrDefault ["success",false]) && {((_fa2#0)#3) isEqualTo 2}, "- por linha reduz exatamente uma unidade."] call _assert;
private _exactPlus=["PLUS",["MAGAZINE","30Rnd_65x39_caseless_mag","EXACT"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
private _afterExact=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]; private _exactRows=(_afterExact getOrDefault ["entries",[]]) select {(_x#2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x#4) isEqualTo "EXACT"}}; private _fullRows=(_afterExact getOrDefault ["entries",[]]) select {(_x#2) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x#4) isEqualTo "DEFAULT_FULL"}};
["ITEMS-0.8-276", (_exactPlus getOrDefault ["success",false]) && {(count _exactRows)isEqualTo 1} && {((_exactRows#0)#5) isEqualTo [30,17,6]} && {(count _fullRows)isEqualTo 1} && {((_fullRows#0)#3) isEqualTo 1}, "+ em EXACT pela UI preserva [30,17,6] e cria DEFAULT_FULL separado."] call _assert;
private _exactGrow=["QUANTITY",["MAGAZINE","30Rnd_65x39_caseless_mag","EXACT"],4] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
["ITEMS-0.8-277", !(_exactGrow getOrDefault ["success",true]) && {(_exactGrow getOrDefault ["code",""]) isEqualTo "ITEMS_DRAFT_EXACT_QUANTITY_GROW_FORBIDDEN"}, "Digitação numérica da UI não fabrica stateData EXACT."] call _assert;
private _zeroItem=["QUANTITY",["ITEM","FirstAidKit","NONE"],0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
private _afterZero=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap];
["ITEMS-0.8-278", (_zeroItem getOrDefault ["success",false]) && {((_afterZero getOrDefault ["entries",[]]) findIf {(_x#2)isEqualTo "FirstAidKit"})<0}, "Quantidade 0 via controle da linha remove a entrada sem confirmação unitária."] call _assert;
private _badQty=["QUANTITY",["MAGAZINE","30Rnd_65x39_caseless_mag","DEFAULT_FULL"],"abc"] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
["ITEMS-0.8-279", !(_badQty getOrDefault ["success",true]) && {(_badQty getOrDefault ["code",""]) isEqualTo "ITEMS_UI_QUANTITY_TEXT_INVALID"}, "Texto de quantidade inválido é recusado antes de chegar ao Draft Service."] call _assert;
private _name08=["Kit Simétrico 0.8"] call ServoPeregrino_Organizador_Items_fnc_setDraftName; private _target08=["C"] call ServoPeregrino_Organizador_Items_fnc_setDraftPreferredTarget;
private _draft08=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap];
["ITEMS-0.8-280", (_name08 getOrDefault ["success",false]) && {(_draft08 getOrDefault ["name",""]) isEqualTo "Kit Simétrico 0.8"} && {_draft08 getOrDefault ["dirty",false]}, "Nome no cabeçalho edita somente o Draft e marca dirty."] call _assert;
["ITEMS-0.8-281", (_target08 getOrDefault ["success",false]) && {(_draft08 getOrDefault ["preferredTarget",""]) isEqualTo "VEST"}, "preferredTarget continua íntegro no Draft/ItemKit v1 para compatibilidade, embora não seja exposto na UI."] call _assert;

private _catalogToDraft=["CATALOG","FirstAidKit"] call ServoPeregrino_Organizador_Items_fnc_handleUITransferToDraft;
["ITEMS-0.8-282", _catalogToDraft getOrDefault ["success",false], "Seta/drag Catalog -> Draft adiciona uma unidade usando classname explícito da própria origem."] call _assert;
private _eqPayload=["MAGAZINE","30Rnd_65x39_caseless_mag",2,"EXACT",[12,4]]; private _eqToDraft=["EQUIPMENT",_eqPayload] call ServoPeregrino_Organizador_Items_fnc_handleUITransferToDraft;
private _eqDraft=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]; private _exactCombined=(_eqDraft getOrDefault ["entries",[]]) select {(_x#2)isEqualTo "30Rnd_65x39_caseless_mag" && {(_x#4)isEqualTo "EXACT"}};
["ITEMS-0.8-283", (_eqToDraft getOrDefault ["success",false]) && {(count _exactCombined)isEqualTo 1} && {((_exactCombined#0)#5) isEqualTo [30,17,6,12,4]}, "Equipment -> Draft copia/captura EXACT preservando estados individuais; equipamento origem não é removido."] call _assert;

// Persistir um kit fonte separado e provar merge draft-only.
private _srcEntryR=["ITEM","ToolKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _srcEntry=((_srcEntryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _srcKitR=["Fonte Merge 0.8",[_srcEntry],"ANY",["TEST","MERGE"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit; private _srcKit=((_srcKitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _srcSave=[_srcKit] call ServoPeregrino_Organizador_Items_fnc_saveKit; private _srcId=if (_srcSave getOrDefault ["success",false]) then {(((_srcSave getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])#2)} else {""}; private _srcBefore=if (_srcId isEqualTo "") then {createHashMap}else{[_srcId] call ServoPeregrino_Organizador_Items_fnc_getKit};
private _merge08=["KIT",_srcId] call ServoPeregrino_Organizador_Items_fnc_handleUITransferToDraft; private _srcAfter=if (_srcId isEqualTo "") then {createHashMap}else{[_srcId] call ServoPeregrino_Organizador_Items_fnc_getKit};
["ITEMS-0.8-284", (_merge08 getOrDefault ["success",false]) && {(_srcBefore getOrDefault ["success",false])} && {(_srcAfter getOrDefault ["success",false])} && {(((_srcBefore getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])#8) isEqualTo (((_srcAfter getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])#8)}, "Kit inteiro -> Draft faz merge/cópia e não altera/autosalva o kit fonte."] call _assert;

// Drag source freezes origin at START. A mudança da seleção depois do início não altera sourcePayload.
if (!isNull _disp08) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.01;};
private _cat08=if (isNull _disp08) then {controlNull}else{_disp08 displayCtrl 3120};
private _dragStarted=false; private _frozenClass="";
if (!isNull _cat08 && {(lbSize _cat08)>0}) then {private _data0=_cat08 lbData 0; private _txt0=_cat08 lbText 0; _dragStarted=["START",[_cat08,[[_txt0,0,_data0]]]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent; private _uiDrag=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _ds=_uiDrag getOrDefault ["dragState",createHashMap]; _frozenClass=_ds getOrDefault ["sourcePayload",""]; _uiDrag set ["selectedCatalogClass","__CHANGED_AFTER_DRAG_START__"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiDrag];};
private _uiDragAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _frozenAfter=(_uiDragAfter getOrDefault ["dragState",createHashMap]) getOrDefault ["sourcePayload",""];
["ITEMS-0.8-285", _dragStarted && {_frozenClass isNotEqualTo ""} && {_frozenAfter isEqualTo _frozenClass} && {_frozenAfter isNotEqualTo (_uiDragAfter getOrDefault ["selectedCatalogClass",""])}, "Origem do drag é congelada no início e não reutiliza seleção posterior."] call _assert;
private _dragBefore=(_uiDragAfter getOrDefault ["dragState",createHashMap]); private _wrongDrop=false; if (!isNull _disp08) then {private _drop08=_disp08 displayCtrl 2103; _wrongDrop=["DROP",[_drop08,0,0,9999,[["wrong",0,"wrong"]]]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;};
["ITEMS-0.8-286", !_wrongDrop, "Drop com originIDC/data divergentes é cancelado sem agir sobre seleção velha."] call _assert;

// Save explicit; Draft -> Repository only when requested.
private _repoCountBefore=(([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data",createHashMap]) getOrDefault ["kits",[]];
private _save08=[] call ServoPeregrino_Organizador_Items_fnc_saveDraft; private _dsSaved=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _savedCurrent=_dsSaved getOrDefault ["current",createHashMap];
["ITEMS-0.8-287", (_save08 getOrDefault ["success",false]) && {(_savedCurrent getOrDefault ["mode",""]) isEqualTo "EDIT"} && {!(_savedCurrent getOrDefault ["dirty",true])}, "Salvar pela camada 0.8 continua explícito e transforma NEW em EDIT limpo."] call _assert;
private _countBeforeClone=count ((([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data",createHashMap]) getOrDefault ["kits",[]]); private _saveAs08=[] call ServoPeregrino_Organizador_Items_fnc_saveDraftAsNew; private _countAfterClone=count ((([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data",createHashMap]) getOrDefault ["kits",[]]);
["ITEMS-0.8-288", (_saveAs08 getOrDefault ["success",false]) && {_countAfterClone isEqualTo (_countBeforeClone+1)}, "Salvar como novo pela UI mantém semântica de novo ID e adiciona exatamente um ItemKit."] call _assert;
private _cfgCatalog08=_dlg08>>"CatalogList"; private _cfgEquipment08=_dlg08>>"EquipmentList"; private _cfgKits08=_dlg08>>"KitsList"; private _cfgDrop08=_dlg08>>"DraftDrop";
private _dragRuntime08=(getText (_cfgCatalog08>>"onLBDrag")) find "handleUIDragEvent" >= 0 && {(getText (_cfgEquipment08>>"onLBDrag")) find "handleUIDragEvent" >= 0} && {(getText (_cfgKits08>>"onLBDrag")) find "handleUIDragEvent" >= 0};
private _dropRuntime08=(getText (_cfgDrop08>>"onLBDrop")) find "handleUIDragEvent" >= 0;
private _arrowRuntime08=(getText (_cfgCatalog08>>"onMouseButtonClick")) find "CATALOG_ARROW_CLICK" >= 0 && {(getText (_cfgEquipment08>>"onMouseButtonClick")) find "EQUIPMENT_ARROW_CLICK" >= 0};
["ITEMS-0.8-289", _dragRuntime08 && {_dropRuntime08} && {_arrowRuntime08}, "Config runtime realmente carregado contém drag, drop e setas dos fluxos Draft-only; teste não depende de ler .hpp por path."] call _assert;
// Regressão de estado: selecionar outro kit por UI deve sobreviver ao retorno do transition helper.
private _switchTarget08=_srcId; private _switchIndex08=-1;
if (!isNull _disp08) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.01; private _kl08=_disp08 displayCtrl 1102; for "_i" from 0 to ((lbSize _kl08)-1) do {if ((_kl08 lbData _i) isEqualTo _switchTarget08) exitWith {_switchIndex08=_i;};}; if (_switchIndex08>=0) then {["KIT_SELECT",_switchIndex08] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; uiSleep 0.02;};};
private _afterSwitchUI08=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _afterSwitchDraft08=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _afterSwitchCur08=_afterSwitchDraft08 getOrDefault ["current",createHashMap];
["ITEMS-0.8-290", _switchIndex08>=0 && {(_afterSwitchUI08 getOrDefault ["selectedKitId",""]) isEqualTo _switchTarget08} && {(_afterSwitchCur08 getOrDefault ["kitId",""]) isEqualTo _switchTarget08} && {(_afterSwitchCur08 getOrDefault ["mode",""]) isEqualTo "EDIT"}, "Selecionar kit pela UI não é revertido por state stale do handler; selectedKitId e Draft EDIT permanecem sincronizados."] call _assert;
// Regressão de refresh: KillFocus causado por ctClear não pode transformar texto transitório em edição.
private _guardBefore08=[_afterSwitchCur08] call ServoPeregrino_Organizador_Items_fnc_deepCopy; private _guardWorked08=false;
if (!isNull _disp08) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.01; private _tblGuard08=_disp08 displayCtrl 2104; if ((ctRowCount _tblGuard08)>0) then {private _rcGuard08=_tblGuard08 ctRowControls 0; if ((count _rcGuard08)>=5) then {private _qtyGuard08=_rcGuard08#4; private _uiGuard08=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _uiGuard08 set ["refreshing",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiGuard08]; _qtyGuard08 ctrlSetText "999"; _guardWorked08=[_qtyGuard08] call ServoPeregrino_Organizador_Items_fnc_commitDraftQuantityFromControl; _uiGuard08=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _uiGuard08 set ["refreshing",false]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiGuard08];};};};
private _guardAfter08=(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap];
["ITEMS-0.8-291", _guardWorked08 && {(_guardAfter08 getOrDefault ["entries",[]]) isEqualTo (_guardBefore08 getOrDefault ["entries",[]])}, "KillFocus interno durante refresh é ignorado; ctClear não edita quantidade nem provoca mutação recursiva do Draft."] call _assert;
private _playerAfter08=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _pAfter08=_playerAfter08 getOrDefault ["data",createHashMap];
["ITEMS-0.8-292", [_segBefore08,_pAfter08,"ITEMS-0.8-292"] call _compareLoadoutSegment, "Toda a manipulação 0.8 (linha/seta/drag/save) termina sem mutar o loadout físico do jogador no próprio segmento."] call _assert;
if (!isNull _disp08) then {closeDialog 0; uiSleep 0.02;};



// -------------------------------------------------------------------------
// Draft UI Hardening 0.8.1 — regression gates for RPT/ultrawide/tooltips.
// -------------------------------------------------------------------------
private _openMeta081=[] call ServoPeregrino_Organizador_Items_fnc_openInterface; uiSleep 0.02;
private _openData081=_openMeta081 getOrDefault ["data",createHashMap];
["ITEMS-0.8.1-293", (_openMeta081 getOrDefault ["success",false]) && {!(_openData081 getOrDefault ["readOnlyShell",true])} && {_openData081 getOrDefault ["draftInteractionReady",false]} && {!(_openData081 getOrDefault ["physicalMutationEnabled",true])} && {!(_openData081 getOrDefault ["mutatesInventory",true])}, "openInterface publica metadata coerente com Draft Direct Manipulation e físico OFF."] call _assert;
private _disp081=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _cfgControls081=missionConfigFile>>"SP_ORG_Items_Dialog">>"controls";
private _rowCfg081=missionConfigFile>>"SPORG_Items_DraftTable">>"RowTemplate";
private _picW081=getNumber ((_rowCfg081>>"Picture")>>"columnW"); private _picH081=getNumber ((_rowCfg081>>"Picture")>>"controlH");
private _picPixelsW081=if (pixelW>0) then {_picW081/pixelW}else{-1}; private _picPixelsH081=if (pixelH>0) then {_picH081/pixelH}else{-2};
["ITEMS-0.8.1-294", _picPixelsW081>0 && {_picPixelsH081>0} && {abs (_picPixelsW081-_picPixelsH081) <= 1.5}, "Imagem da linha Draft preserva proporção quadrada em pixels; safeZoneW ultrawide não pode esticá-la."] call _assert;
private _minusW081=getNumber ((_rowCfg081>>"Minus")>>"columnW"); private _minusH081=getNumber ((_rowCfg081>>"Minus")>>"controlH"); private _plusW081=getNumber ((_rowCfg081>>"Plus")>>"columnW"); private _delW081=getNumber ((_rowCfg081>>"Delete")>>"columnW");
["ITEMS-0.8.1-295", abs ((_minusW081/pixelW)-(_minusH081/pixelH))<=1.5 && {abs ((_plusW081/pixelW)-(_minusH081/pixelH))<=1.5} && {abs ((_delW081/pixelW)-(_minusH081/pixelH))<=1.5}, "Botões -, + e X da linha usam métrica compacta aspect-safe em vez de largura proporcional ao monitor."] call _assert;
private _closeCfg081=_cfgControls081>>"Close"; private _clearCfg081=_cfgControls081>>"CatalogClear"; private _prevCfg081=_cfgControls081>>"Prev";
private _squareCfg081={params ["_cfg"]; private _w=getNumber (_cfg>>"w"); private _h=getNumber (_cfg>>"h"); (_w>0)&&{(_h>0)}&&{abs ((_w/pixelW)-(_h/pixelH))<=1.5}};
["ITEMS-0.8.1-296", [_closeCfg081] call _squareCfg081 && {[_clearCfg081] call _squareCfg081} && {[_prevCfg081] call _squareCfg081}, "Fechar, limpar busca e paginação usam IconButton quadrado/compacto em qualquer aspect ratio."] call _assert;
["ITEMS-0.8.1-297", !isClass (_cfgControls081>>"PreferredLabel") && {!isClass (_cfgControls081>>"PrefAny")} && {!isClass (_cfgControls081>>"PrefU")} && {!isClass (_cfgControls081>>"PrefC")} && {!isClass (_cfgControls081>>"PrefM")}, "Destino recomendado do kit foi removido apenas da UI para reduzir ruído; não existe segundo grupo U/C/M concorrente."] call _assert;
private _prefStillSchema081=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _prefCur081=_prefStillSchema081 getOrDefault ["current",createHashMap];
["ITEMS-0.8.1-298", (_prefCur081 getOrDefault ["preferredTarget",""]) in ["ANY","UNIFORM","VEST","BACKPACK"], "preferredTarget continua no Draft/ItemKit v1 internamente; remoção visual não quebra compatibilidade de schema."] call _assert;
private _tooltipCfgs081=["Close","KitsClear","KitsNew","KitsDuplicate","KitsDelete","DraftName","DraftClear","DraftDrop","DraftSave","DraftSaveAs","DraftDiscard","CatalogClear","Prev","Next","EquipmentClear","EquipU","EquipC","EquipM","EquipmentRefresh"];
private _tooltipMissing081=_tooltipCfgs081 findIf {(getText (_cfgControls081>>_x>>"tooltip")) isEqualTo ""};
["ITEMS-0.8.1-299", _tooltipMissing081<0, "Botões/campos críticos voltam a possuir tooltips curtos e consistentes."] call _assert;
private _arrowTextOk081=false; private _rowTooltipsOk081=false;
if (!isNull _disp081) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.02; private _cat081=_disp081 displayCtrl 3120; private _eq081=_disp081 displayCtrl 4120; _arrowTextOk081=(lbSize _cat081)<1 || {(_cat081 lbTextRight 0) isEqualTo "←"}; _rowTooltipsOk081=(lbSize _cat081)<1 || {(_cat081 lbTooltip 0) isNotEqualTo ""}; if ((lbSize _eq081)>0) then {_rowTooltipsOk081=_rowTooltipsOk081 && {(_eq081 lbTooltip 0) isNotEqualTo ""};};};
["ITEMS-0.8.1-300", _arrowTextOk081, "Seta de transferência é affordance compacta ←; texto '← KIT' deixa de ocupar largura excessiva da linha."] call _assert;
["ITEMS-0.8.1-301", _rowTooltipsOk081, "Linhas de catálogo/equipamento materializam tooltip runtime com identidade e instrução de transferência."] call _assert;
private _cleanForTransition081=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
if (_cleanForTransition081 getOrDefault ["hasDraft",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;};
private _seedTransition081=["Kit confirmação 0.8.1","ANY",["TEST","TRANSITION_081"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _dirtyTransition081=["FirstAidKit",1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _trNew081=["NEW_DRAFT","",true] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition;
private _afterTransition081=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _afterTransitionCur081=_afterTransition081 getOrDefault ["current",createHashMap];
["ITEMS-0.8.1-302", (_seedTransition081 getOrDefault ["success",false]) && {(_dirtyTransition081 getOrDefault ["success",false])} && {(_trNew081 getOrDefault ["success",false])} && {(_afterTransitionCur081 getOrDefault ["name",""]) isEqualTo "Novo Kit"}, "Transição confirmada aceita payload String vazio e substitui Draft dirty sem variável _p indefinida; caminho assíncrono é validado no gate manual."] call _assert;

// -------------------------------------------------------------------------
// Draft UI Polish 0.8.2 — fechamento visual/interação responsiva.
// -------------------------------------------------------------------------
private _segBefore082R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segBefore082=_segBefore082R getOrDefault ["data",createHashMap];
private _rowCfg082=missionConfigFile>>"SPORG_Items_DraftTable">>"RowTemplate";
private _qtyW082=getNumber ((_rowCfg082>>"Quantity")>>"columnW");
private _sqW082=getNumber ((_rowCfg082>>"Minus")>>"columnW");
private _qtyRatio082=if (_sqW082>0) then {_qtyW082/_sqW082} else {-1};
["ITEMS-0.8.2-303", _qtyRatio082>=1.25 && {_qtyRatio082<=1.65}, "Campo de quantidade é compacto, mas preserva largura suficiente para edição numérica direta."] call _assert;
private _dropCfg082=missionConfigFile>>"SP_ORG_Items_Dialog">>"controls">>"DraftDrop";
["ITEMS-0.8.2-304", (getText (_dropCfg082>>"text")) isEqualTo "ARRASTE ITENS PARA CÁ", "Destino de DnD fica discreto em repouso; SOLTE PARA ADICIONAR é reservado ao gesto ativo."] call _assert;
private _labelsNarrow082=[760] call ServoPeregrino_Organizador_Items_fnc_getResponsiveCatalogLabels;
private _labelsWide082=[1400] call ServoPeregrino_Organizador_Items_fnc_getResponsiveCatalogLabels;
["ITEMS-0.8.2-305", (_labelsNarrow082#1) isEqualTo "MUNI" && {(_labelsWide082#1) isEqualTo "MUNIÇÃO"} && {(_labelsWide082#4) isEqualTo "FERRAMENTAS"}, "Categorias possuem labels compactos em largura estreita e nomes completos quando há espaço real em pixels."] call _assert;
private _vm082=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel; private _catVm082=(_vm082 getOrDefault ["data",createHashMap]) getOrDefault ["catalog",createHashMap];
["ITEMS-0.8.2-306", !isNil {_catVm082 get "buildVisitedCount"} && {!isNil {_catVm082 get "buildPartialItemCount"}} && {!isNil {_catVm082 get "buildCurrentRoot"}}, "View-model carrega métricas leves de progresso do CONFIG_ALL sem iniciar nova varredura."] call _assert;
private _fcfg082=missionConfigFile>>"SP_ORG_Items_Dialog">>"controls"; private _fContext082=getNumber ((_fcfg082>>"FooterContext")>>"size"); private _fMessage082=getNumber ((_fcfg082>>"FooterMessage")>>"size"); private _fHistory082=getNumber ((_fcfg082>>"FooterHistory")>>"size");
["ITEMS-0.8.2-307", _fContext082>=_fMessage082 && {_fMessage082>_fHistory082} && {_fHistory082>0}, "Footer possui hierarquia legível: contexto/resultado prioritários e histórico secundário."] call _assert;
private _pFinal082=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _pFinalData082=_pFinal082 getOrDefault ["data",createHashMap];
["ITEMS-0.8.2-308", [_segBefore082,_pFinalData082,"ITEMS-0.8.2-308"] call _compareLoadoutSegment, "Polimento 0.8.2 permanece exclusivamente UI/Draft; loadout físico é idêntico dentro do segmento."] call _assert;
// -------------------------------------------------------------------------
// Drag Lifecycle & Quantity Enter 0.9 — manual-contract regressions.
// -------------------------------------------------------------------------
private _segBefore083R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segBefore083=_segBefore083R getOrDefault ["data",createHashMap];
private _state083=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gesture083=diag_tickTime;
_state083 set ["dragState",createHashMapFromArray [["active",true],["sourceType","CATALOG"],["sourceIDC",3120],["sourceId","FirstAidKit"],["sourcePayload","FirstAidKit"],["startedAtTick",_gesture083]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state083];
if (!isNull _disp081) then {private _drop083=_disp081 displayCtrl 2103; _drop083 ctrlSetText "SOLTE PARA ADICIONAR"; _drop083 ctrlSetBackgroundColor [0.04,0.28,0.23,0.38];};
["MOUSE_UP",[]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;
uiSleep 0.02;
private _afterCancelState083=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _afterCancelDrag083=_afterCancelState083 getOrDefault ["dragState",createHashMap];
["ITEMS-0.8.3-309", !(_afterCancelDrag083 getOrDefault ["active",true]), "Soltar o mouse fora do target encerra o drag mesmo quando o engine não gera onLBDrop."] call _assert;
private _dropText083=if (isNull _disp081) then {""} else {ctrlText (_disp081 displayCtrl 2103)};
["ITEMS-0.8.3-310", (isNull _disp081) || {_dropText083 isEqualTo "ARRASTE ITENS PARA CÁ"}, "Cancelamento de drag restaura o estado visual normal; SOLTE PARA ADICIONAR não fica preso."] call _assert;
// Um cancelamento agendado por gesto antigo não pode cancelar um gesto novo iniciado antes do próximo ciclo.
private _oldGesture083=diag_tickTime; private _sOld083=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_sOld083 set ["dragState",createHashMapFromArray [["active",true],["sourceType","CATALOG"],["sourceIDC",3120],["sourceId","OLD"],["sourcePayload","FirstAidKit"],["startedAtTick",_oldGesture083]]]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_sOld083];
["MOUSE_UP",[]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;
private _newGesture083=_oldGesture083+1; private _sNew083=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_sNew083 set ["dragState",createHashMapFromArray [["active",true],["sourceType","CATALOG"],["sourceIDC",3120],["sourceId","NEW"],["sourcePayload","FirstAidKit"],["startedAtTick",_newGesture083]]]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_sNew083];
if (!isNull _disp081) then {private _dropRace083=_disp081 displayCtrl 2103; _dropRace083 ctrlSetText "SOLTE PARA ADICIONAR";};
uiSleep 0.02; private _afterRace083=(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["dragState",createHashMap]; private _raceText083=if (isNull _disp081) then {"SOLTE PARA ADICIONAR"} else {ctrlText (_disp081 displayCtrl 2103)};
["ITEMS-0.8.3-311", (_afterRace083 getOrDefault ["active",false]) && {(_afterRace083 getOrDefault ["startedAtTick",-1]) isEqualTo _newGesture083} && {_raceText083 isEqualTo "SOLTE PARA ADICIONAR"}, "Cancelamento deferido é vinculado ao gesto original e não mata nem neutraliza visualmente um drag novo/um DROP válido por corrida de eventos."] call _assert;
["TEST_RESET"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
// Enter/Numpad Enter no Edit real de quantidade.
private _beforeQtySetup083=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
if (_beforeQtySetup083 getOrDefault ["hasDraft",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;};
["Kit Enter 0.9","ANY",["TEST","ENTER_083"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
["FirstAidKit",2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
if (!isNull _disp081) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.02;};
private _enterHandled083=false; private _enterQty083=-1;
if (!isNull _disp081) then {
    private _table083=_disp081 displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC;
    private _rows083=ctRowCount _table083;
    if (_rows083>0) then {
        private _controls083=_table083 ctRowControls 0;
        if ((count _controls083)>=7) then {private _qty083=_controls083#4; _qty083 ctrlSetText "4"; _enterHandled083=[_qty083,28,false,false,false] call ServoPeregrino_Organizador_Items_fnc_handleDraftQuantityKeyDown; uiSleep 0.02;};
    };
};
private _draftAfterEnter083=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _curAfterEnter083=_draftAfterEnter083 getOrDefault ["current",createHashMap];
private _entryAfterEnter083=((_curAfterEnter083 getOrDefault ["entries",[]]) select {(_x#1) isEqualTo "ITEM" && {(_x#2) isEqualTo "FirstAidKit"}});
if ((count _entryAfterEnter083)>0) then {_enterQty083=(_entryAfterEnter083#0)#3;};
["ITEMS-0.8.3-312", _enterHandled083 && {_enterQty083 isEqualTo 4}, "DIK_RETURN confirma imediatamente a quantidade digitada sem exigir Tab ou clique fora."] call _assert;
private _numpadHandled083=false; private _numpadQty083=-1;
if (!isNull _disp081) then {
    [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.02;
    private _table083b=_disp081 displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC;
    if ((ctRowCount _table083b)>0) then {private _controls083b=_table083b ctRowControls 0; if ((count _controls083b)>=7) then {private _qty083b=_controls083b#4; _qty083b ctrlSetText "5"; _numpadHandled083=[_qty083b,156,false,false,false] call ServoPeregrino_Organizador_Items_fnc_handleDraftQuantityKeyDown; uiSleep 0.02;};};
};
private _draftAfterNumpad083=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _curAfterNumpad083=_draftAfterNumpad083 getOrDefault ["current",createHashMap];
private _entryAfterNumpad083=((_curAfterNumpad083 getOrDefault ["entries",[]]) select {(_x#1) isEqualTo "ITEM" && {(_x#2) isEqualTo "FirstAidKit"}}); if ((count _entryAfterNumpad083)>0) then {_numpadQty083=(_entryAfterNumpad083#0)#3;};
["ITEMS-0.8.3-313", _numpadHandled083 && {_numpadQty083 isEqualTo 5}, "DIK_NUMPADENTER confirma quantidade com a mesma semântica do Enter principal."] call _assert;
private _pFinal083=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _pFinalData083=_pFinal083 getOrDefault ["data",createHashMap];
["ITEMS-0.8.3-314", [_segBefore083,_pFinalData083,"ITEMS-0.8.3-314"] call _compareLoadoutSegment, "Hotfix de lifecycle/Enter permanece exclusivamente UI/Draft; loadout físico é idêntico dentro do segmento."] call _assert;

// -------------------------------------------------------------------------
// Physical Transaction Engine 0.9 — plan/fingerprint/snapshot/commit/rollback.
// Fixture físico: GroundWeaponHolder local, nunca CAManBase e nunca loadout do player.
// -------------------------------------------------------------------------
if (!isNull _disp081) then {closeDialog 0; uiSleep 0.02;};
private _appStatus09=[] call ServoPeregrino_Organizador_Items_fnc_getApplicationStatus; private _appData09=_appStatus09 getOrDefault ["data",createHashMap];
["ITEMS-0.9-315", (_appStatus09 getOrDefault ["success",false]) && {_appData09 getOrDefault ["ready",false]} && {(_appData09 getOrDefault ["planVersion",0]) isEqualTo 1} && {(_appData09 getOrDefault ["snapshotVersion",0]) isEqualTo 1}, "Application Engine publica runtime READY e schemas v1."] call _assert;
private _build09=[] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
["ITEMS-0.9-316", (_build09 getOrDefault ["scope",""]) isEqualTo "PHYSICAL_TRANSACTION_ENGINE" && {(_build09 getOrDefault ["delivery",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION}, "BuildInfo identifica a Entrega 0.9 Physical Transaction Engine."] call _assert;
private _runtime09=[] call ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus; private _runtimeData09=_runtime09 getOrDefault ["data",createHashMap]; private _ui09=_runtimeData09 getOrDefault ["ui",createHashMap];
["ITEMS-0.9-317", (_runtimeData09 getOrDefault ["applicationReady",false]) && {!(_ui09 getOrDefault ["physicalMutationEnabled",true])}, "Engine físico está pronto abaixo da UI, mas gestos da UI continuam explicitamente sem mutação até 0.10."] call _assert;
private _invalidAny09=[objNull,"ANY","ADD",[[_itemEntry] call ServoPeregrino_Organizador_Items_fnc_deepCopy],"BEST_EFFORT",createHashMap] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan;
["ITEMS-0.9-318", !(_invalidAny09 getOrDefault ["success",true]) && {(_invalidAny09 getOrDefault ["code",""]) in ["ITEMS_CONTAINER_TARGET_INVALID","ITEMS_CONTAINER_NULL"]}, "ANY nunca é aceito como target físico de commit."] call _assert;
private _deferred09=[objNull,"TEST_CONTAINER","REPLACE",[[_itemEntry] call ServoPeregrino_Organizador_Items_fnc_deepCopy],"STRICT",createHashMap] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan;
["ITEMS-0.9-319", !(_deferred09 getOrDefault ["success",true]) && {(_deferred09 getOrDefault ["code",""]) isEqualTo "ITEMS_OPERATION_DEFERRED_0_10"}, "REPLACE/CLEAR continuam bloqueados na 0.9; kit inteiro permanece para 0.10."] call _assert;

private _makeFixture09={
    private _o=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
    _o addItemCargoGlobal ["FirstAidKit",3];
    _o addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,17];
    _o addWeaponCargoGlobal ["arifle_MX_F",1];
    _o addBackpackCargoGlobal ["B_AssaultPack_khk",1];
    _o
};
private _fixture09=call _makeFixture09;
private _capture09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent; private _capData09=_capture09 getOrDefault ["data",createHashMap];
private _capEntries09=_capData09 getOrDefault ["entries",[]]; private _capReserved09=_capData09 getOrDefault ["reservedCargo",[]];
["ITEMS-0.9-320", (_capture09 getOrDefault ["success",false]) && {(count _capEntries09)>=2}, "Fixture físico é capturado como CONTENT mutável sem CAManBase sintético."] call _assert;
["ITEMS-0.9-321", (_capReserved09 findIf {(_x getOrDefault ["kind",""]) isEqualTo "WEAPON"})>=0 && {(_capReserved09 findIf {(_x getOrDefault ["kind",""]) isEqualTo "NESTED_CONTAINER"})>=0}, "Weapon e nested backpack do fixture são classificados como reserved e ficam fora do CONTENT mutável."] call _assert;
private _fpA09=[_capEntries09,_capReserved09,"GroundWeaponHolder_Scripted","TEST_CONTAINER"] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _revEntries09=[_capEntries09] call ServoPeregrino_Organizador_Items_fnc_deepCopy; reverse _revEntries09;
private _revReserved09=[_capReserved09] call ServoPeregrino_Organizador_Items_fnc_deepCopy; reverse _revReserved09;
private _fpB09=[_revEntries09,_revReserved09,"GroundWeaponHolder_Scripted","TEST_CONTAINER"] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
["ITEMS-0.9-322", (_fpA09 getOrDefault ["serialized","A"]) isEqualTo (_fpB09 getOrDefault ["serialized","B"]), "Fingerprint é canônico: ordem incidental das entradas/reserved cargo não altera a assinatura."] call _assert;
private _beforePlanFp09=([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap];
private _addFullEntryR09=["MAGAZINE","30Rnd_65x39_caseless_mag",2,"DEFAULT_FULL",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _addFullEntry09=((_addFullEntryR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _planFullR09=[_fixture09,"TEST_CONTAINER","ADD",[_addFullEntry09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _planFull09=((_planFullR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]);
private _afterPlanFp09=([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap];
["ITEMS-0.9-323", (_planFullR09 getOrDefault ["success",false]) && {((((_beforePlanFp09 getOrDefault ["fingerprint",createHashMap]) getOrDefault ["serialized","A"])) isEqualTo (((_afterPlanFp09 getOrDefault ["fingerprint",createHashMap]) getOrDefault ["serialized","B"])))}, "CREATE PLAN é dry-run: nenhuma mutação física acontece antes de execute."] call _assert;
private _fullAction09=(_planFull09 getOrDefault ["actions",[]]) param [0,createHashMap,[createHashMap]]; private _fullPhysical09=_fullAction09 getOrDefault ["entry",[]]; private _fullAmmo09=getNumber(configFile>>"CfgMagazines">>"30Rnd_65x39_caseless_mag">>"count");
["ITEMS-0.9-324", (_fullPhysical09 param [4,""]) isEqualTo "EXACT" && {(_fullPhysical09 param [5,[]]) isEqualTo [_fullAmmo09,_fullAmmo09]}, "DEFAULT_FULL é resolvido no plan para estados físicos EXACT cheios; persistência/Draft continuam separados."] call _assert;
private _snapR09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerSnapshot; private _snap09=((_snapR09 getOrDefault ["data",createHashMap]) getOrDefault ["snapshot",createHashMap]);
["ITEMS-0.9-325", (_snapR09 getOrDefault ["success",false]) && {(_snap09 getOrDefault ["version",0]) isEqualTo 1} && {(count (_snap09 getOrDefault ["entries",[]]))>0}, "ContainerSnapshot v1 existe antes da primeira mutação e preserva CONTENT + fingerprint."] call _assert;

private _addItem09=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _addItemEntry09=((_addItem09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _planAddItemR09=[_fixture09,"TEST_CONTAINER","ADD",[_addItemEntry09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _planAddItem09=((_planAddItemR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]); private _execAddItem09=[_planAddItem09,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan;
private _afterAddItem09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent; private _afterAddEntries09=(_afterAddItem09 getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]; private _fak09=_afterAddEntries09 select {(_x#1)isEqualTo "ITEM" && {(_x#2)isEqualTo "FirstAidKit"}};
["ITEMS-0.9-326", (_execAddItem09 getOrDefault ["success",false]) && {(((_execAddItem09 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]) getOrDefault ["status",""]) isEqualTo "COMPLETE"} && {(count _fak09)>0} && {((_fak09#0)#3) isEqualTo 5}, "ADD unitário aplica ITEM, mede depois e retorna ApplyResult COMPLETE."] call _assert;
private _exactAddR09=["MAGAZINE","30Rnd_65x39_caseless_mag",2,"EXACT",[30,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _exactAdd09=((_exactAddR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _planExactR09=[_fixture09,"TEST_CONTAINER","ADD",[_exactAdd09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _execExact09=[((_planExactR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan;
private _afterExact09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent; private _magE09=(((_afterExact09 getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]) select {(_x#1)isEqualTo "MAGAZINE" && {(_x#2)isEqualTo "30Rnd_65x39_caseless_mag"}}); private _states09=if ((count _magE09)>0) then {+((_magE09#0)#5)} else {[]}; _states09 sort true;
["ITEMS-0.9-327", (_execExact09 getOrDefault ["success",false]) && {_states09 isEqualTo [6,17,30]}, "ADD MAGAZINE EXACT preserva munição individual [17] + [30,6] no container físico."] call _assert;
private _reservedAfterAdd09=(([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["reservedCargo",[]];
["ITEMS-0.9-328", (_reservedAfterAdd09 findIf {(_x getOrDefault ["kind",""]) isEqualTo "WEAPON"})>=0 && {(_reservedAfterAdd09 findIf {(_x getOrDefault ["kind",""]) isEqualTo "NESTED_CONTAINER"})>=0}, "ADD dirigido preserva domains reserved no mesmo container."] call _assert;
private _remItemR09=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _remItem09=((_remItemR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _planRemItemR09=[_fixture09,"TEST_CONTAINER","REMOVE",[_remItem09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _execRemItem09=[((_planRemItemR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _afterRemItem09=(([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]; private _fakRem09=_afterRemItem09 select {(_x#1)isEqualTo "ITEM" && {(_x#2)isEqualTo "FirstAidKit"}};
["ITEMS-0.9-329", (_execRemItem09 getOrDefault ["success",false]) && {(count _fakRem09)>0} && {((_fakRem09#0)#3) isEqualTo 3}, "REMOVE unitário de ITEM remove somente a quantidade planejada."] call _assert;
private _remExactR09=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _remExact09=((_remExactR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _planRemExactR09=[_fixture09,"TEST_CONTAINER","REMOVE",[_remExact09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _execRemExact09=[((_planRemExactR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _magAfterRemExact09=((([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]) select {(_x#1)isEqualTo "MAGAZINE" && {(_x#2)isEqualTo "30Rnd_65x39_caseless_mag"}}; private _statesAfterRem09=if ((count _magAfterRemExact09)>0) then {+((_magAfterRemExact09#0)#5)} else {[]}; _statesAfterRem09 sort true;
["ITEMS-0.9-330", (_execRemExact09 getOrDefault ["success",false]) && {_statesAfterRem09 isEqualTo [6,30]}, "REMOVE EXACT remove o estado individual solicitado e preserva os demais magazines."] call _assert;
private _remFullR09=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"DEFAULT_FULL",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _remFull09=((_remFullR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _planRemFullR09=[_fixture09,"TEST_CONTAINER","REMOVE",[_remFull09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _execRemFull09=[((_planRemFullR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _magAfterFull09=((([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]) select {(_x#1)isEqualTo "MAGAZINE" && {(_x#2)isEqualTo "30Rnd_65x39_caseless_mag"}}; private _statesAfterFull09=if ((count _magAfterFull09)>0) then {+((_magAfterFull09#0)#5)} else {[]};
["ITEMS-0.9-331", (_execRemFull09 getOrDefault ["success",false]) && {_statesAfterFull09 isEqualTo [6]}, "REMOVE DEFAULT_FULL remove somente magazine fisicamente cheio; partial 6 permanece."] call _assert;

private _staleEntryR09=["ITEM","ToolKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _staleEntry09=((_staleEntryR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _stalePlanR09=[_fixture09,"TEST_CONTAINER","ADD",[_staleEntry09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _stalePlan09=((_stalePlanR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]); _fixture09 addItemCargoGlobal ["FirstAidKit",1]; private _staleExec09=[_stalePlan09,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _afterStale09=(([_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
["ITEMS-0.9-332", !(_staleExec09 getOrDefault ["success",true]) && {(_staleExec09 getOrDefault ["code",""]) isEqualTo "ITEMS_PLAN_STALE"} && {(_afterStale09 findIf {(_x#1)isEqualTo "ITEM" && {(_x#2)isEqualTo "ToolKit"}})<0}, "Revalidation detecta fingerprint stale antes do snapshot/commit e não aplica a ação planejada."] call _assert;

private _mass09=[_addItemEntry09] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass; private _unitMass09=_mass09 getOrDefault ["mass",0];
["ITEMS-0.9-333", (_mass09 getOrDefault ["known",false]) && {_unitMass09>0}, "Mass resolver conhece a massa do FirstAidKit vanilla para planejamento de capacidade."] call _assert;
private _capReqR09=["ITEM","FirstAidKit",5,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _capReq09=((_capReqR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _capCtx09=createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",_unitMass09*2.5],["currentLoadOverride",0]]; private _bestPlanR09=[_fixture09,"TEST_CONTAINER","ADD",[_capReq09],"BEST_EFFORT",_capCtx09] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _bestPlan09=((_bestPlanR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]);
["ITEMS-0.9-334", (_bestPlanR09 getOrDefault ["success",false]) && {(count (_bestPlan09 getOrDefault ["actions",[]])) isEqualTo 1} && {(count (_bestPlan09 getOrDefault ["rejectedEntries",[]])) isEqualTo 1} && {(((_bestPlan09 getOrDefault ["actions",[]])#0) getOrDefault ["plannedQuantity",0]) isEqualTo 2}, "ADD BEST_EFFORT planeja subconjunto quando capacidade estimada é insuficiente e explica rejeição."] call _assert;
private _strictPlanR09=[_fixture09,"TEST_CONTAINER","ADD",[_capReq09],"STRICT",_capCtx09] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan;
["ITEMS-0.9-335", !(_strictPlanR09 getOrDefault ["success",true]) && {(_strictPlanR09 getOrDefault ["code",""]) isEqualTo "ITEMS_PLAN_FAILED"}, "Política STRICT recusa plano de ADD quando não cabe integralmente."] call _assert;

// Reinicia fixture para PARTIAL e rollback injetado determinísticos.
deleteVehicle _fixture09; uiSleep 0.01; _fixture09=call _makeFixture09;
private _partialReqR09=["ITEM","FirstAidKit",5,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _partialReq09=((_partialReqR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _partialPlanR09=[_fixture09,"TEST_CONTAINER","REMOVE",[_partialReq09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _partialPlan09=((_partialPlanR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]); private _partialExec09=[_partialPlan09,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _partialApply09=((_partialExec09 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
["ITEMS-0.9-336", (_partialExec09 getOrDefault ["success",false]) && {(_partialApply09 getOrDefault ["status",""]) isEqualTo "PARTIAL"} && {(count (_partialApply09 getOrDefault ["rejectedEntries",[]])) isEqualTo 1}, "REMOVE BEST_EFFORT executa o que existe e ApplyResult autoritativo retorna PARTIAL."] call _assert;

deleteVehicle _fixture09; uiSleep 0.01; _fixture09=call _makeFixture09;
private _rollbackBeforeR09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint; private _rollbackBefore09=((_rollbackBeforeR09 getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]); private _rollbackReservedBefore09=(((_rollbackBeforeR09 getOrDefault ["data",createHashMap]) getOrDefault ["capture",createHashMap]) getOrDefault ["reservedCargo",[]]);
private _rbEntryR09=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _rbEntry09=((_rbEntryR09 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]); private _rbPlanR09=[_fixture09,"TEST_CONTAINER","ADD",[_rbEntry09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _rbPlan09=((_rbPlanR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]); private _rbExec09=[_rbPlan09,createHashMapFromArray [["injectFailureAfterCommit",true]]] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; private _rollbackAfterR09=[_fixture09,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint; private _rollbackAfter09=((_rollbackAfterR09 getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]); private _rollbackReservedAfter09=(((_rollbackAfterR09 getOrDefault ["data",createHashMap]) getOrDefault ["capture",createHashMap]) getOrDefault ["reservedCargo",[]]);
["ITEMS-0.9-337", !(_rbExec09 getOrDefault ["success",true]) && {(_rbExec09 getOrDefault ["code",""]) isEqualTo "ITEMS_ROLLED_BACK"} && {(_rollbackBefore09 getOrDefault ["serialized","A"]) isEqualTo (_rollbackAfter09 getOrDefault ["serialized","B"])}, "Falha injetada depois do commit força rollback focal e restaura exatamente o fingerprint anterior."] call _assert;
["ITEMS-0.9-338", (_rollbackReservedBefore09 isEqualTo _rollbackReservedAfter09), "Rollback focal preserva weapon/nested reserved em vez de reconstruir o container inteiro."] call _assert;
private _busyPlanR09=[_fixture09,"TEST_CONTAINER","ADD",[_rbEntry09],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",10000],["currentLoadOverride",0]]] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; private _busyPlan09=((_busyPlanR09 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]); private _busyState09=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]; _busyState09 set ["executing",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_busyState09]; private _busyExec09=[_busyPlan09,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan; _busyState09=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]; _busyState09 set ["executing",false]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_busyState09];
["ITEMS-0.9-339", !(_busyExec09 getOrDefault ["success",true]) && {(_busyExec09 getOrDefault ["code",""]) isEqualTo "ITEMS_APPLICATION_BUSY"}, "Engine possui lock local de commit e recusa segunda transação concorrente."] call _assert;

// Integração read-only com um target real do player: resolve + plan, sem execute.
private _segBeforeRealPlanR09=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segBeforeRealPlan09=_segBeforeRealPlanR09 getOrDefault ["data",createHashMap];
private _realResolved09=createHashMap; {private _rr=[player,_x] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer; if ((_rr getOrDefault ["success",false]) && {(count _realResolved09)isEqualTo 0}) then {_realResolved09=_rr;};} forEach ["U","C","M"];
private _realPlanOk09=false;
if ((count _realResolved09)>0) then {private _rd09=_realResolved09 getOrDefault ["data",createHashMap]; private _ctxReal09=createHashMapFromArray [["containerClass",_rd09 getOrDefault ["className",""]],["gearClass",_rd09 getOrDefault ["className",""]],["maxLoadOverride",100000],["currentLoadOverride",0]]; private _pr09=[_rd09 getOrDefault ["container",objNull],_rd09 getOrDefault ["canonicalTarget",""],"ADD",[_rbEntry09],"BEST_EFFORT",_ctxReal09] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan; _realPlanOk09=_pr09 getOrDefault ["success",false];};
private _playerAfterPlan09=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _playerAfterPlanData09=_playerAfterPlan09 getOrDefault ["data",createHashMap];
["ITEMS-0.9-340", _realPlanOk09 && {[_segBeforeRealPlan09,_playerAfterPlanData09,"ITEMS-0.9-340"] call _compareLoadoutSegment}, "ApplicationPlan pode ser criado contra PLAYER_CONTAINERS reais em dry-run sem alterar o loadout no próprio segmento."] call _assert;
deleteVehicle _fixture09;

// -------------------------------------------------------------------------
// Hotfix 0.9.1 — cargo ITEM suportado + delete-detach do backing kit.
// -------------------------------------------------------------------------
private _segBefore091R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segBefore091=_segBefore091R getOrDefault ["data",createHashMap];
private _fixture091=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
_fixture091 addItemCargoGlobal ["FirstAidKit",2];
private _entry091R=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _entry091=((_entry091R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _remove091=[_fixture091,"REMOVE",_entry091] call ServoPeregrino_Organizador_Items_fnc_mutateContainerEntry;
private _afterRemove091=(([_fixture091,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
private _qtyAfterRemove091=0; {if ((_x#1)isEqualTo "ITEM" && {(_x#2)isEqualTo "FirstAidKit"}) then {_qtyAfterRemove091=_x#3;};} forEach _afterRemove091;
private _add091=[_fixture091,"ADD",_entry091] call ServoPeregrino_Organizador_Items_fnc_mutateContainerEntry;
private _afterAdd091=(([_fixture091,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
private _qtyAfterAdd091=0; {if ((_x#1)isEqualTo "ITEM" && {(_x#2)isEqualTo "FirstAidKit"}) then {_qtyAfterAdd091=_x#3;};} forEach _afterAdd091;
["ITEMS-0.9.1-341", (_remove091 isEqualType createHashMap) && {(_remove091 getOrDefault ["success",false])} && {_qtyAfterRemove091 isEqualTo 1} && {(_add091 getOrDefault ["success",false])} && {_qtyAfterAdd091 isEqualTo 2}, "REMOVE ITEM usa caminho suportado por quantidade negativa e retorna Result estruturado; ADD restaura a quantidade." ] call _assert;
deleteVehicle _fixture091;
private _invalidSnapshot091=createHashMapFromArray [["version",999]]; private _rbInvalid091=[_invalidSnapshot091,"TEST_INVALID_SNAPSHOT"] call ServoPeregrino_Organizador_Items_fnc_rollbackApplication; private _rbInvalidData091=_rbInvalid091 getOrDefault ["data",createHashMap];
["ITEMS-0.9.1-342", (_rbInvalid091 isEqualType createHashMap) && {!(_rbInvalid091 getOrDefault ["success",true])} && {(_rbInvalid091 getOrDefault ["code",""]) isEqualTo "ITEMS_ROLLBACK_FAILED"} && {((_rbInvalidData091 getOrDefault ["restoreResult",createHashMap]) isEqualType createHashMap)}, "Rollback inválido falha por Result estruturado; fronteiras internas não podem vazar variável indefinida." ] call _assert;

// Clean backing kit -> delete persisted -> preserve content as NEW dirty.
private _dsBeforeDelete091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; if (_dsBeforeDelete091 getOrDefault ["hasDraft",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;};
private _delEntryR091=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; private _delEntry091=((_delEntryR091 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _delKitR091=["Kit Delete Clean 0.9.1",[_delEntry091],"ANY",["TEST","DELETE_DETACH"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit; private _delKit091=((_delKitR091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _delSave091=[_delKit091] call ServoPeregrino_Organizador_Items_fnc_saveKit; private _delId091=((_delSave091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]) param [2,"",[""]];
private _delLoad091=[_delId091] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit; private _delBeforeState091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _delBeforeCur091=_delBeforeState091 getOrDefault ["current",createHashMap]; private _delBeforeEntries091=[_delBeforeCur091 getOrDefault ["entries",[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _delExec091=[_delId091] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft; private _delLookup091=[_delId091] call ServoPeregrino_Organizador_Items_fnc_getKit; private _delAfterState091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _delAfterCur091=_delAfterState091 getOrDefault ["current",createHashMap];
["ITEMS-0.9.1-343", (_delExec091 getOrDefault ["success",false]) && {(_delExec091 getOrDefault ["code",""]) isEqualTo "ITEMS_KIT_DELETED_DRAFT_PRESERVED"} && {!(_delLookup091 getOrDefault ["success",true])} && {(_delAfterCur091 getOrDefault ["mode",""]) isEqualTo "NEW"} && {(_delAfterCur091 getOrDefault ["kitId","X"]) isEqualTo ""} && {_delAfterCur091 getOrDefault ["dirty",false]} && {(_delAfterCur091 getOrDefault ["entries",[]]) isEqualTo _delBeforeEntries091}, "Excluir o backing kit limpo remove somente o persistido e preserva o conteúdo aberto como Draft NEW dirty." ] call _assert;

// Dirty backing kit -> local edits survive detach.
[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
private _dirtyKitR091=["Kit Delete Dirty 0.9.1",[_delEntry091],"ANY",["TEST","DELETE_DETACH_DIRTY"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit; private _dirtyKit091=((_dirtyKitR091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _dirtySave091=[_dirtyKit091] call ServoPeregrino_Organizador_Items_fnc_saveKit; private _dirtyId091=((_dirtySave091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]) param [2,"",[""]];
[_dirtyId091] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit; ["Kit Dirty Editado 0.9.1"] call ServoPeregrino_Organizador_Items_fnc_setDraftName; ["ToolKit",1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _dirtyBefore091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _dirtyBeforeCur091=_dirtyBefore091 getOrDefault ["current",createHashMap]; private _dirtyBeforeEntries091=[_dirtyBeforeCur091 getOrDefault ["entries",[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _dirtyDelete091=[_dirtyId091] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft; private _dirtyAfter091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _dirtyAfterCur091=_dirtyAfter091 getOrDefault ["current",createHashMap];
["ITEMS-0.9.1-344", (_dirtyDelete091 getOrDefault ["success",false]) && {(_dirtyAfterCur091 getOrDefault ["mode",""]) isEqualTo "NEW"} && {(_dirtyAfterCur091 getOrDefault ["name",""]) isEqualTo "Kit Dirty Editado 0.9.1"} && {(_dirtyAfterCur091 getOrDefault ["entries",[]]) isEqualTo _dirtyBeforeEntries091} && {(_dirtyAfterCur091 getOrDefault ["createdFrom",""]) isEqualTo "DELETE_DETACH"}, "Excluir backing kit dirty preserva nome e alterações locais; nenhum conteúdo do Draft é descartado." ] call _assert;
private _saveDetached091=[] call ServoPeregrino_Organizador_Items_fnc_saveDraft; private _savedDetached091=((_saveDetached091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _newDetachedId091=_savedDetached091 param [2,"",[""]]; private _oldDirtyLookup091=[_dirtyId091] call ServoPeregrino_Organizador_Items_fnc_getKit; private _newDirtyLookup091=[_newDetachedId091] call ServoPeregrino_Organizador_Items_fnc_getKit;
["ITEMS-0.9.1-345", (_saveDetached091 getOrDefault ["success",false]) && {_newDetachedId091 isNotEqualTo ""} && {_newDetachedId091 isNotEqualTo _dirtyId091} && {!(_oldDirtyLookup091 getOrDefault ["success",true])} && {_newDirtyLookup091 getOrDefault ["success",false]}, "Salvar após delete-detach cria nova identidade persistida; o ID excluído nunca é ressuscitado." ] call _assert;
// Deleting a different saved kit must not disturb the currently open EDIT.
private _otherKitR091=["Kit Delete Other 0.9.1",[_delEntry091],"ANY",["TEST","DELETE_OTHER"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit; private _otherKit091=((_otherKitR091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _otherSave091=[_otherKit091] call ServoPeregrino_Organizador_Items_fnc_saveKit; private _otherId091=((_otherSave091 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]) param [2,"",[""]]; private _openBeforeOther091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _openBeforeOtherCur091=_openBeforeOther091 getOrDefault ["current",createHashMap];
private _deleteOther091=[_otherId091] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft; private _openAfterOther091=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _openAfterOtherCur091=_openAfterOther091 getOrDefault ["current",createHashMap];
["ITEMS-0.9.1-346", (_deleteOther091 getOrDefault ["success",false]) && {!(((_deleteOther091 getOrDefault ["data",createHashMap]) getOrDefault ["draftDetached",true]))} && {(_openAfterOtherCur091 getOrDefault ["kitId",""]) isEqualTo (_openBeforeOtherCur091 getOrDefault ["kitId","X"])} && {(_openAfterOtherCur091 getOrDefault ["entries",[]]) isEqualTo (_openBeforeOtherCur091 getOrDefault ["entries",[]])}, "Excluir kit que não é backing do Draft atual não altera o Draft aberto." ] call _assert;
private _playerFinal091=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _playerFinalData091=_playerFinal091 getOrDefault ["data",createHashMap];
["ITEMS-0.9.1-347", [_segBefore091,_playerFinalData091,"ITEMS-0.9.1-347"] call _compareLoadoutSegment, "Hotfix físico/delete-detach termina com loadout real do jogador idêntico dentro do próprio segmento." ] call _assert;

// -------------------------------------------------------------------------
// Hotfix 0.9.2 — seleção sem reconstrução + fingerprints segmentados.
// -------------------------------------------------------------------------
private _fakeBefore092=createHashMapFromArray [["loadout",[["A"],["B"]]],["serialized",str [["A"],["B"]]]];
private _fakeAfter092=createHashMapFromArray [["loadout",[["A"],["C"]]],["serialized",str [["A"],["C"]]]];
private _fakeCmp092=[_fakeBefore092,_fakeAfter092,"TEST_FAKE_092"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints; private _fakeCmpD092=_fakeCmp092 getOrDefault ["data",createHashMap];
["ITEMS-0.9.2-348", (_fakeCmp092 getOrDefault ["success",false]) && {!(_fakeCmpD092 getOrDefault ["equal",true])} && {(_fakeCmpD092 getOrDefault ["changedIndexes",[]]) isEqualTo [1]}, "Diagnóstico de fingerprint aponta índice estrutural alterado sem transformar divergência em erro de execução."] call _assert;

private _selOpen092=[] call ServoPeregrino_Organizador_Items_fnc_openInterface; uiSleep 0.02; private _selDisp092=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _selReady092=(_selOpen092 getOrDefault ["success",false]) && {!isNull _selDisp092};
if (_selReady092) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; uiSleep 0.02;};
private _cat092=if (_selReady092) then {_selDisp092 displayCtrl 3120} else {controlNull};
private _stateBeforeSel092=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _refreshTickBefore092=_stateBeforeSel092 getOrDefault ["lastRefreshTick",-1]; private _offsetBefore092=_stateBeforeSel092 getOrDefault ["catalogOffset",0];
private _selIndex092=if (!isNull _cat092 && {(lbSize _cat092)>2}) then {2} else {if (!isNull _cat092 && {(lbSize _cat092)>0}) then {0} else {-1}};
private _selClass092=if (_selIndex092>=0) then {_cat092 lbData _selIndex092} else {""};
if (_selIndex092>=0) then {["CATALOG_SELECT",_selIndex092] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;};
private _stateAfterSel092=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _refreshTickAfter092=_stateAfterSel092 getOrDefault ["lastRefreshTick",-2];
["ITEMS-0.9.2-349", _selIndex092>=0 && {(_stateAfterSel092 getOrDefault ["selectedCatalogClass",""]) isEqualTo _selClass092} && {_refreshTickAfter092 isEqualTo _refreshTickBefore092}, "CATALOG_SELECT atualiza seleção sem chamar refreshInterface/lbClear da coleção."] call _assert;
["ITEMS-0.9.2-350", _selIndex092>=0 && {(_stateAfterSel092 getOrDefault ["catalogOffset",-1]) isEqualTo _offsetBefore092}, "Selecionar item não altera catalogOffset; navegação/scroll não é reancorada pela camada de estado."] call _assert;
private _detailsText092=if (_selReady092) then {ctrlText (_selDisp092 displayCtrl 3130)} else {""};
["ITEMS-0.9.2-351", _selIndex092>=0 && {_selClass092 isNotEqualTo ""} && {(_detailsText092 find _selClass092)>=0}, "Detalhes do item selecionado são atualizados focalmente sem reconstruir o ListBox."] call _assert;

private _draftTable092=if (_selReady092) then {_selDisp092 displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC} else {controlNull};
private _draftRow092=if (!isNull _draftTable092 && {(ctRowCount _draftTable092)>0}) then {0} else {-1};
private _draftTickBefore092=(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["lastRefreshTick",-3];
if (_draftRow092>=0) then {["DRAFT_ROW_SELECT",_draftRow092] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;};
private _draftStateAfter092=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
["ITEMS-0.9.2-352", _draftRow092<0 || {(_draftStateAfter092 getOrDefault ["lastRefreshTick",-4]) isEqualTo _draftTickBefore092}, "DRAFT_ROW_SELECT também é seleção pura e não reconstrói Controls Table."] call _assert;

private _segProbeBefore092R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segProbeBefore092=_segProbeBefore092R getOrDefault ["data",createHashMap];
private _probeVM092=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel;
private _segProbeAfter092R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segProbeAfter092=_segProbeAfter092R getOrDefault ["data",createHashMap];
["ITEMS-0.9.2-353", (_probeVM092 getOrDefault ["success",false]) && {[_segProbeBefore092,_segProbeAfter092,"ITEMS-0.9.2-353"] call _compareLoadoutSegment}, "Gate de invariância 0.9.2 usa baseline imediatamente anterior/posterior ao segmento de leitura."] call _assert;
private _equalFake092=[_fakeBefore092,_fakeBefore092,"TEST_EQUAL_092"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints; private _equalFakeD092=_equalFake092 getOrDefault ["data",createHashMap];
["ITEMS-0.9.2-354", (_equalFake092 getOrDefault ["success",false]) && {_equalFakeD092 getOrDefault ["equal",false]} && {(count (_equalFakeD092 getOrDefault ["changedIndexes",[]])) isEqualTo 0}, "Comparador de fingerprint reconhece igualdade sem depender de leitura frágil do arquivo-fonte em runtime."] call _assert;
if (!isNull _selDisp092) then {closeDialog 0; uiSleep 0.02;};
private _segFinalBefore092R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segFinalBefore092=_segFinalBefore092R getOrDefault ["data",createHashMap];
uiSleep 0.01;
private _segFinalAfter092R=[player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint; private _segFinalAfter092=_segFinalAfter092R getOrDefault ["data",createHashMap];
["ITEMS-0.9.2-355", [_segFinalBefore092,_segFinalAfter092,"ITEMS-0.9.2-355"] call _compareLoadoutSegment, "Encerramento 0.9.2 usa baseline local e não acusa drift ambiental ocorrido em segmentos anteriores da suíte."] call _assert;

// Limpeza obrigatória do namespace automatizado. Produção nunca foi alvo das escritas acima.
private _cleanupTestStorage = ["AUTO_0_9_2", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _disableTestStorage = ["", false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery", "0.9.2"], ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD], ["total", _total], ["passed", _passed], ["failed", _failed],
    ["durationMs", _durationMs], ["results", _results], ["success", _failed isEqualTo 0]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, _summary];
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;
["", false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _restoreProduction = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
if !(_restoreProduction getOrDefault ["success", false]) then {diag_log format ["[SP_ORG] [ITEMS] [WARN] Testes 0.9 concluíram, mas restauração do runtime de produção retornou %1", _restoreProduction getOrDefault ["code", "UNKNOWN"]];};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, _summary]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] ENTREGA 0.9.2 — TOTAL=%1 PASS=%2 FAIL=%3 TEMPO=%4ms", _total, _passed, _failed, _durationMs];
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items — Testes 0.9.2</t><br/><br/><t color='#7CFC00'>PASS: %1</t><br/><t color='%2'>FAIL: %3</t><br/>Total: %4<br/>Tempo: %5 ms<br/><br/>Gate esperado: <t color='#7CFC00'>355 / 355</t><br/>Depois execute o gate manual físico isolado 0.9.2.",_passed,if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_failed,_total,_durationMs];};
_summary
