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
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.5] [%1] %2 — %3", _status, _id, _detail];
};

[] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;
private _testModeSetup = ["AUTO_0_5", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;

// -------------------------------------------------------------------------
// Regressão da fundação 0.1
// -------------------------------------------------------------------------
private _build = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
["ITEMS-0.4-001", (_build getOrDefault ["component", ""]) isEqualTo "Items", "getBuildInfo identifica Items."] call _assert;
["ITEMS-0.4-002", (_build getOrDefault ["displayVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION, "displayVersion corresponde ao header da candidata 0.5."] call _assert;
["ITEMS-0.4-003", (_build getOrDefault ["semanticVersion", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION, "semanticVersion corresponde ao header da candidata 0.5."] call _assert;

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
["ITEMS-0.4-013", !(_uiMetadata getOrDefault ["ready", true]) && {(_uiMetadata getOrDefault ["status", ""]) isEqualTo "SKELETON"}, "UI continua stub; escopo não foi antecipado."] call _assert;
private _uiStub = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
["ITEMS-0.4-014", !(_uiStub getOrDefault ["success", true]) && {(_uiStub getOrDefault ["code", ""]) isEqualTo "ITEMS_UI_NOT_IMPLEMENTED"}, "openInterface continua falhando de forma controlada."] call _assert;
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
private _clearAgain = ["AUTO_0_5", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
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

// Fixture físico isolado: a suíte NÃO substitui o loadout real do jogador.
private _playerBeforeFixture = [player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _playerBeforeFixtureData = _playerBeforeFixture getOrDefault ["data", createHashMap];
// A 0.4.1 mostrou que mods externos (ex.: sistemas que observam inventário do player)
// podem reagir entre os fingerprints e gerar falsos negativos quando o próprio player
// é desmontado/reconstruído pelo runner. O alvo físico agora é um agent local temporário.
private _fixtureUnit = createAgent ["B_Soldier_F", getPosATL player, [], 0, "NONE"];
private _fixtureWasIsolated = !(isNull _fixtureUnit) && {_fixtureUnit isNotEqualTo player};
if !(isNull _fixtureUnit) then {
    _fixtureUnit hideObject true;
    _fixtureUnit allowDamage false;
    _fixtureUnit disableAI "ALL";
};
removeAllWeapons _fixtureUnit;
removeAllItems _fixtureUnit;
removeAllAssignedItems _fixtureUnit;
removeUniform _fixtureUnit;
removeVest _fixtureUnit;
removeBackpack _fixtureUnit;
removeHeadgear _fixtureUnit;
removeGoggles _fixtureUnit;
_fixtureUnit forceAddUniform "U_B_CombatUniform_mcam";
_fixtureUnit addVest "V_PlateCarrier1_rgr";
_fixtureUnit addBackpack "B_AssaultPack_mcamo";
_fixtureUnit addItemToUniform "FirstAidKit";
_fixtureUnit addItemToUniform "FirstAidKit";
(uniformContainer _fixtureUnit) addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag", 1, 30];
(uniformContainer _fixtureUnit) addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag", 1, 17];
(uniformContainer _fixtureUnit) addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag", 1, 6];
(vestContainer _fixtureUnit) addItemCargo ["H_HelmetB", 1];
(backpackContainer _fixtureUnit) addWeaponCargo ["arifle_MX_F", 1];

private _fixtureBefore = [_fixtureUnit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _fixtureBeforeData = _fixtureBefore getOrDefault ["data", createHashMap];
private _resolveU = [_fixtureUnit, "U"] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
["ITEMS-0.4-109", (_resolveU getOrDefault ["success", false]) && {(((_resolveU getOrDefault ["data", createHashMap]) getOrDefault ["canonicalTarget", ""]) isEqualTo "UNIFORM")}, "PLAYER_CONTAINERS resolve Uniforme real."] call _assert;
private _captureU = [_fixtureUnit, "U"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
private _captureUData = _captureU getOrDefault ["data", createHashMap];
private _captureUEntries = _captureUData getOrDefault ["entries", []];
private _capItemIdx = _captureUEntries findIf {(_x # 1) isEqualTo "ITEM" && {(_x # 2) isEqualTo "FirstAidKit"}};
private _capMagIdx = _captureUEntries findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo "30Rnd_65x39_caseless_mag"}};
["ITEMS-0.4-110", _captureU getOrDefault ["success", false], "Captura real do Uniforme é bem-sucedida."] call _assert;
["ITEMS-0.4-111", _captureUData getOrDefault ["loadoutUnchanged", false], "Captura real declara loadoutUnchanged=true."] call _assert;
["ITEMS-0.4-112", _capItemIdx >= 0 && {((_captureUEntries # _capItemIdx) # 3) isEqualTo 2}, "Captura real agrupa 2 FirstAidKit."] call _assert;
["ITEMS-0.4-113", _capMagIdx >= 0 && {((_captureUEntries # _capMagIdx) # 5) isEqualTo [30,17,6]}, "Captura real preserva munição individual [30,17,6]."] call _assert;
private _fixtureAfterU = [_fixtureUnit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _fixtureAfterUData = _fixtureAfterU getOrDefault ["data", createHashMap];
["ITEMS-0.4-114", (_fixtureBeforeData getOrDefault ["serialized", "A"]) isEqualTo (_fixtureAfterUData getOrDefault ["serialized", "B"]), "Fingerprint completo é idêntico antes/depois da captura U."] call _assert;

private _repoBeforeCapture = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoBeforeCaptureData = _repoBeforeCapture getOrDefault ["data", createHashMap];
private _repoBeforeCaptureStorage = _repoBeforeCaptureData getOrDefault ["storage", []];
private _captureAny = [_fixtureUnit, "ANY"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainers;
private _captureAnyData = _captureAny getOrDefault ["data", createHashMap];
private _captureAnyDraft = _captureAnyData getOrDefault ["draft", createHashMap];
["ITEMS-0.4-115", (_captureAny getOrDefault ["success", false]) && {(_captureAny getOrDefault ["code", ""]) isEqualTo "ITEMS_CAPTURE_COMPLETED"} && {_captureAnyData getOrDefault ["loadoutUnchanged", false]}, "Captura agregada ANY/U/C/M é somente leitura."] call _assert;
["ITEMS-0.4-116", (_captureAnyDraft getOrDefault ["mode", ""]) isEqualTo "NEW" && {(_captureAnyDraft getOrDefault ["createdFrom", ""]) isEqualTo "CAPTURE"}, "Captura ANY produz Draft NEW em memória."] call _assert;
private _repoAfterCapture = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryStatus;
private _repoAfterCaptureData = _repoAfterCapture getOrDefault ["data", createHashMap];
private _repoAfterCaptureStorage = _repoAfterCaptureData getOrDefault ["storage", []];
["ITEMS-0.4-117", _repoBeforeCaptureStorage isEqualTo _repoAfterCaptureStorage, "Captura não grava nem altera Repository."] call _assert;
private _captureC = [_fixtureUnit, "C"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
private _captureCReserved = ((_captureC getOrDefault ["data", createHashMap]) getOrDefault ["reservedCargo", []]);
["ITEMS-0.4-118", (_captureC getOrDefault ["success", false]) && {(_captureCReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "EQUIPMENT" && {(_x getOrDefault ["className", ""]) isEqualTo "H_HelmetB"}}) >= 0}, "Equipamento vestível real é observado mas reservado."] call _assert;
private _captureM = [_fixtureUnit, "M"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
private _captureMReserved = ((_captureM getOrDefault ["data", createHashMap]) getOrDefault ["reservedCargo", []]);
["ITEMS-0.4-119", (_captureM getOrDefault ["success", false]) && {(_captureMReserved findIf {(_x getOrDefault ["kind", ""]) isEqualTo "WEAPON" && {(_x getOrDefault ["className", ""]) isEqualTo "arifle_MX_F"}}) >= 0}, "Weapon cargo real é observado mas reservado."] call _assert;

removeBackpack _fixtureUnit;
private _missingM = [_fixtureUnit, "M"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
["ITEMS-0.4-120", !(_missingM getOrDefault ["success", true]) && {(_missingM getOrDefault ["code", ""]) isEqualTo "ITEMS_CONTAINER_ABSENT"}, "Container ausente retorna ITEMS_CONTAINER_ABSENT sem exceção."] call _assert;
private _anyMissingM = [_fixtureUnit, "ANY"] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainers;
private _anyMissingData = _anyMissingM getOrDefault ["data", createHashMap];
["ITEMS-0.4-121", (_anyMissingM getOrDefault ["success", false]) && {"M" in (_anyMissingData getOrDefault ["absentTargets", []])}, "Captura ANY tolera container ausente e o diagnostica explicitamente."] call _assert;

deleteVehicle _fixtureUnit;
private _playerAfterFixture = [player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
private _playerAfterFixtureData = _playerAfterFixture getOrDefault ["data", createHashMap];
["ITEMS-0.4-122", (_playerBeforeFixtureData getOrDefault ["serialized", "A"]) isEqualTo (_playerAfterFixtureData getOrDefault ["serialized", "B"]), "Runner isolado não altera, restaura nem substitui o loadout do jogador."] call _assert;
["ITEMS-0.4.1-123", (_captureUData getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER, "Regressão 0.4.1: capturePlayerContainer devolve provider PLAYER_CONTAINERS sem erro de preprocessor/macro."] call _assert;
["ITEMS-0.4.2-124", _fixtureWasIsolated, "Fixture físico da suíte usa unidade sintética isolada; nunca usa player como alvo mutável."] call _assert;


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

private _invalidateBefore = _catalogStatusAfterFilterData getOrDefault ["invalidationCount", 0];
private _invalidate = ["AUTO_TEST_0_5"] call ServoPeregrino_Organizador_Items_fnc_invalidateCatalogCache;
private _statusInvalidated = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusInvalidatedData = _statusInvalidated getOrDefault ["data", createHashMap];
["ITEMS-0.5-159", (_invalidate getOrDefault ["success", false]) && {(_invalidate getOrDefault ["code", ""]) isEqualTo "ITEMS_CATALOG_CACHE_INVALIDATED"} && {!(_statusInvalidatedData getOrDefault ["cacheBuilt", true])} && {(_statusInvalidatedData getOrDefault ["itemCount", -1]) isEqualTo 0}, "invalidateCatalogCache remove explicitamente o cache da sessão."] call _assert;
["ITEMS-0.5-160", (_statusInvalidatedData getOrDefault ["invalidationCount", 0]) isEqualTo (_invalidateBefore + 1) && {(_statusInvalidatedData getOrDefault ["lastInvalidationReason", ""]) isEqualTo "AUTO_TEST_0_5"}, "Invalidação é observável e registra razão sem varrer configs."] call _assert;

private _buildCountBeforeRebuild = _statusInvalidatedData getOrDefault ["buildCount", 0];
private _scanBeforeRebuild = _statusInvalidatedData getOrDefault ["configScanCount", 0];
private _rebuild = [] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
private _statusRebuilt = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusRebuiltData = _statusRebuilt getOrDefault ["data", createHashMap];
["ITEMS-0.5-161", (_rebuild getOrDefault ["success", false]) && {(_statusRebuiltData getOrDefault ["buildCount", 0]) isEqualTo (_buildCountBeforeRebuild + 1)}, "Primeira consulta após invalidação executa exatamente um novo build."] call _assert;
["ITEMS-0.5-162", (_statusRebuiltData getOrDefault ["configScanCount", 0]) isEqualTo (_scanBeforeRebuild + 1), "Rebuild explícito é a única razão para nova varredura global."] call _assert;
["ITEMS-0.5-163", (_statusRebuiltData getOrDefault ["itemCount", 0]) > 0, "Rebuild restaura catálogo elegível sem perda de classes."] call _assert;

private _scanBeforePostFilter = _statusRebuiltData getOrDefault ["configScanCount", 0];
private _allFilter = ["", "ALL"] call ServoPeregrino_Organizador_Items_fnc_filterCatalog;
private _allFilterData = _allFilter getOrDefault ["data", createHashMap];
private _statusAfterPostFilter = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _statusAfterPostFilterData = _statusAfterPostFilter getOrDefault ["data", createHashMap];
["ITEMS-0.5-164", (_allFilter getOrDefault ["success", false]) && {(_allFilterData getOrDefault ["count", -1]) isEqualTo (_statusRebuiltData getOrDefault ["itemCount", -2])}, "Filtro ALL sem busca representa a visão integral do cache."] call _assert;
["ITEMS-0.5-165", (_statusAfterPostFilterData getOrDefault ["configScanCount", -1]) isEqualTo _scanBeforePostFilter, "Filtros posteriores ao rebuild continuam operando somente sobre cache."] call _assert;

private _resolveMag = ["30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
private _resolveMagItem = ((_resolveMag getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
["ITEMS-0.5-166", (_resolveMag getOrDefault ["success", false]) && {(_resolveMagItem getOrDefault ["magazineCapacity", 0]) > 0} && {(_resolveMagItem getOrDefault ["categoryId", ""]) isEqualTo "MAGAZINES"}, "CatalogItem de magazine expõe capacidade derivada de runtime e categoria sem persistir isso no ItemKit."] call _assert;

// Limpeza obrigatória do namespace automatizado. Produção nunca foi alvo das escritas acima.
private _cleanupTestStorage = ["AUTO_0_5", true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _disableTestStorage = ["", false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery", "0.5"],
    ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["total", _total],
    ["passed", _passed],
    ["failed", _failed],
    ["durationMs", _durationMs],
    ["results", _results],
    ["success", _failed isEqualTo 0]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, _summary];

// Restaurar runtime normal de produção após a suíte; não faz parte do gate 124/124.
[] call ServoPeregrino_Organizador_Items_fnc_resetRuntimeForTests;
["", false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _restoreProduction = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
if !(_restoreProduction getOrDefault ["success", false]) then {
    diag_log format ["[SP_ORG] [ITEMS] [WARN] Testes 0.5 passaram, mas restauração do runtime de produção retornou %1", _restoreProduction getOrDefault ["code", "UNKNOWN"]];
};
// resetRuntimeForTests limpa a variável de resultado; republicar o summary após restaurar produção.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, _summary];

diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] ENTREGA 0.5 — TOTAL=%1 PASS=%2 FAIL=%3 TEMPO=%4ms", _total, _passed, _failed, _durationMs];
diag_log "============================================================";

if (hasInterface) then {
    hint parseText format [
        "<t size='1.25'>SP_ORG_Items — Testes 0.5</t><br/><br/><t color='#7CFC00'>PASS: %1</t><br/><t color='%2'>FAIL: %3</t><br/>Total: %4<br/>Tempo: %5 ms<br/><br/>Gate esperado: <t color='#7CFC00'>166 / 166</t><br/>Consulte o RPT para os IDs individuais.",
        _passed,
        if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},
        _failed,
        _total,
        _durationMs
    ];
};

_summary
