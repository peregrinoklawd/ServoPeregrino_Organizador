#include "..\..\script_version.hpp"
params [["_unit",objNull,[objNull]]];
private _uiR = [] call ServoPeregrino_Organizador_Items_fnc_getUIState;
private _ui = ((_uiR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
private _needleMatch = {params ["_needle","_text"]; _needle isEqualTo "" || {((toLower _text) find (toLower _needle)) >= 0}};

// Kits — D.7.0: a aba ativa decide entre Repository privado persistente e biblioteca pública de sessão.
private _kitLibraryMode=toUpper (_ui getOrDefault ["kitLibraryMode","PRIVATE"]);
if !(_kitLibraryMode in ["PRIVATE","PUBLIC"]) then {_kitLibraryMode="PRIVATE";};
private _kitNeedle = _ui getOrDefault ["kitQuery",""];
private _kits = [];
private _publicRevision=0;
private _publicAuthority="SERVER";
private _publicAuthoritative=false;
private _publicAuthorityPending=false;
if (_kitLibraryMode isEqualTo "PRIVATE") then {
    private _kitsR = [] call ServoPeregrino_Organizador_Items_fnc_listKits;
    private _kitsRaw = ((_kitsR getOrDefault ["data",createHashMap]) getOrDefault ["kits",[]]);
    {
        private _k = _x;
        if ([_kitNeedle, format ["%1 %2",_k getOrDefault ["name",""],_k getOrDefault ["id",""]]] call _needleMatch) then {
            private _kitMass=createHashMapFromArray [["known",false],["totalMass",0],["unknownMassCount",0]];
            private _kitGet=[_k getOrDefault ["id",""]] call ServoPeregrino_Organizador_Items_fnc_getKit;
            if (_kitGet getOrDefault ["success",false]) then {
                private _kitRuntime=((_kitGet getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
                _kitMass=[_kitRuntime] call ServoPeregrino_Organizador_Items_fnc_getUIItemKitAwareness;
            };
            _kits pushBack createHashMapFromArray [
                ["scope","PRIVATE"],["id",_k getOrDefault ["id",""]],["name",_k getOrDefault ["name",""]],["entryCount",_k getOrDefault ["entryCount",0]],
                ["totalMass",_kitMass getOrDefault ["totalMass",0]],["massKnown",_kitMass getOrDefault ["known",false]],["unknownMassCount",_kitMass getOrDefault ["unknownMassCount",0]],
                ["preferredTarget",_k getOrDefault ["preferredTarget","ANY"]],["authorName",profileName],["sourceKind","PRIVATE"],["selected",(_k getOrDefault ["id",""]) isEqualTo (_ui getOrDefault ["selectedKitId",""])]
            ];
        };
    } forEach _kitsRaw;
} else {
    private _pubR=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
    private _pubD=_pubR getOrDefault ["data",createHashMap];
    _publicRevision=_pubD getOrDefault ["revision",0];
    _publicAuthority=_pubD getOrDefault ["authority","SERVER"];
    _publicAuthoritative=_pubD getOrDefault ["authoritative",false];
    _publicAuthorityPending=_pubD getOrDefault ["authorityPending",false];
    {
        private _k=_x;
        private _searchText=format ["%1 %2 %3 %4",_k getOrDefault ["name",""],_k getOrDefault ["publicId",""],_k getOrDefault ["authorName",""],_k getOrDefault ["sourceKind",""]];
        if ([_kitNeedle,_searchText] call _needleMatch) then {
            private _publicGet=[_k getOrDefault ["publicId",""]] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
            private _kitMass=createHashMapFromArray [["known",false],["totalMass",0],["unknownMassCount",0]];
            if (_publicGet getOrDefault ["success",false]) then {
                private _kitRuntime=((_publicGet getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
                _kitMass=[_kitRuntime] call ServoPeregrino_Organizador_Items_fnc_getUIItemKitAwareness;
            };
            _kits pushBack createHashMapFromArray [
                ["scope","PUBLIC"],["id",_k getOrDefault ["publicId",""]],["publicId",_k getOrDefault ["publicId",""]],["sourceKitId",_k getOrDefault ["sourceKitId",""]],
                ["name",_k getOrDefault ["name",""]],["entryCount",_k getOrDefault ["entryCount",0]],["preferredTarget",_k getOrDefault ["preferredTarget","ANY"]],
                ["authorName",_k getOrDefault ["authorName","-"]],["sourceKind",_k getOrDefault ["sourceKind","PLAYER"]],
                ["totalMass",_kitMass getOrDefault ["totalMass",0]],["massKnown",_kitMass getOrDefault ["known",false]],["unknownMassCount",_kitMass getOrDefault ["unknownMassCount",0]],
                ["selected",(_k getOrDefault ["publicId",""]) isEqualTo (_ui getOrDefault ["selectedPublicKitId",""])]
            ];
        };
    } forEach (_pubD getOrDefault ["kits",[]]);
};

// Draft
private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftState = _draftR getOrDefault ["data",createHashMap];
private _draft = _draftState getOrDefault ["current",createHashMap];
private _draftNeedle = _ui getOrDefault ["draftQuery",""];
private _draftRows = [];
private _draftTotalMass = 0;
private _draftUnknownMassCount = 0;
{
    private _entry = _x; private _meta = [_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
    private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
    if (_aware getOrDefault ["known",false]) then {_draftTotalMass=_draftTotalMass+(_aware getOrDefault ["totalMass",0]);} else {_draftUnknownMassCount=_draftUnknownMassCount+1;};
    if ([_draftNeedle, format ["%1 %2",_entry#2,_meta getOrDefault ["displayName",_entry#2]]] call _needleMatch) then {
        _draftRows pushBack createHashMapFromArray [["type",_entry#1],["className",_entry#2],["quantity",_entry#3],["stateMode",_entry#4],["stateData",+(_entry#5)],["displayName",_meta getOrDefault ["displayName",_entry#2]],["picture",_meta getOrDefault ["picture",""]],["available",_meta getOrDefault ["available",false]],["massKnown",_aware getOrDefault ["known",false]],["unitMass",_aware getOrDefault ["unitMass",0]],["totalMass",_aware getOrDefault ["totalMass",0]]];
    };
} forEach (_draft getOrDefault ["entries",[]]);

// Catalog: UI nunca força build aqui. Se cache ainda não existe, onLoad o constrói em thread agendada.
private _catalogStatusR = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogStatus = _catalogStatusR getOrDefault ["data",createHashMap];
private _catalogRows = []; private _catalogTotal = 0; private _catalogBaseCount = _catalogStatus getOrDefault ["itemCount",0];
private _offset = _ui getOrDefault ["catalogOffset",0]; private _window = _ui getOrDefault ["catalogWindowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE];
if (_catalogStatus getOrDefault ["cacheBuilt",false]) then {
    private _windowR=[_ui getOrDefault ["catalogQuery",""],_ui getOrDefault ["catalogCategory","ALL"],_offset,_window] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;
    if (_windowR getOrDefault ["success",false]) then {
        private _wd=_windowR getOrDefault ["data",createHashMap];
        _catalogRows=_wd getOrDefault ["rows",[]];
        _catalogTotal=_wd getOrDefault ["totalFiltered",0];
        _catalogBaseCount=_wd getOrDefault ["baseCount",_catalogBaseCount];
        _offset=_wd getOrDefault ["offset",_offset];
        _window=_wd getOrDefault ["windowSize",_window];
    };
};

// Equipment — read-only capture of currently visualized container.
private _equipmentRows = []; private _equipmentStatus = "SEM DADOS"; private _equipmentContainer = ""; private _equipmentUnchanged = true;
private _equipmentTotalMass=0; private _equipmentUnknownMassCount=0; private _equipmentCapacity=createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]];
if (!isNull _unit) then {
    private _cap = [_unit,_ui getOrDefault ["equipmentView","U"]] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
    if (_cap getOrDefault ["success",false]) then {
        private _cd = _cap getOrDefault ["data",createHashMap]; _equipmentStatus = "OK"; _equipmentContainer = _cd getOrDefault ["containerClass",""]; _equipmentUnchanged = _cd getOrDefault ["loadoutUnchanged",false];
        _equipmentCapacity=_cd getOrDefault ["capacity",_equipmentCapacity];
        private _eqNeedle = _ui getOrDefault ["equipmentQuery",""];
        {
            private _entry=_x; private _meta=[_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
            private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
            if (_aware getOrDefault ["known",false]) then {_equipmentTotalMass=_equipmentTotalMass+(_aware getOrDefault ["totalMass",0]);} else {_equipmentUnknownMassCount=_equipmentUnknownMassCount+1;};
            if ([_eqNeedle,format ["%1 %2",_entry#2,_meta getOrDefault ["displayName",_entry#2]]] call _needleMatch) then {
                _equipmentRows pushBack createHashMapFromArray [["type",_entry#1],["className",_entry#2],["quantity",_entry#3],["stateMode",_entry#4],["stateData",+(_entry#5)],["displayName",_meta getOrDefault ["displayName",_entry#2]],["picture",_meta getOrDefault ["picture",""]],["massKnown",_aware getOrDefault ["known",false]],["unitMass",_aware getOrDefault ["unitMass",0]],["totalMass",_aware getOrDefault ["totalMass",0]]];
            };
        } forEach (_cd getOrDefault ["entries",[]]);
    } else {_equipmentStatus = _cap getOrDefault ["code","ITEMS_CONTAINER_UNAVAILABLE"];};
};

private _selectedCatalog = createHashMap;
private _selectedClass = _ui getOrDefault ["selectedCatalogClass",""];
if (_selectedClass isNotEqualTo "") then {_selectedCatalog = [_selectedClass] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;};
private _draftMode = _draft getOrDefault ["mode","NONE"]; private _dirty = _draft getOrDefault ["dirty",false];
private _physicalR = [_unit,_ui getOrDefault ["applicationTarget","ANY"],_draft getOrDefault ["preferredTarget","ANY"]] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _physical = _physicalR getOrDefault ["data",createHashMap];
private _physicalEnabled = _physical getOrDefault ["physicalMutationEnabled",false];
// D.6.2: Equipment is a separate interaction domain. Its drop readiness is derived from Mostrar (U/C/M).
private _equipmentPhysicalR = [_unit,_ui getOrDefault ["equipmentView","U"],""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _equipmentPhysical = _equipmentPhysicalR getOrDefault ["data",createHashMap];
private _equipmentPhysicalEnabled = _equipmentPhysical getOrDefault ["physicalMutationEnabled",false];
private _kitMode=if !(_draftState getOrDefault ["hasDraft",false]) then {"SEM KIT"} else {if (_draftMode isEqualTo "NEW") then {"NOVO"} else {"EDITANDO"}};
private _requestedLabel=[_ui getOrDefault ["applicationTarget","ANY"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _resolvedLabel=[_physical getOrDefault ["resolvedTarget","-"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _viewLabel=[_ui getOrDefault ["equipmentView","U"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _context = format ["Kit: %1  •  Adicionar em: %2  •  Mostrando: %3  •  Catálogo: %4 de %5 itens  •  %6",_kitMode,_resolvedLabel,_viewLabel,_catalogTotal,_catalogBaseCount,if (_physicalEnabled) then {"Equipamento pronto para receber itens"} else {"Destino indisponível"}];

[
 true,"ITEMS_UI_VIEW_MODEL_READY","View-model dos quatro painéis construído sem mutação física.",
 createHashMapFromArray [
  ["panels",["KITS","DRAFT","CATALOG","EQUIPMENT"]],["readOnlyShell",false],["draftInteractionReady",true],["physicalMutationAvailable",true],["physicalMutationEnabled",false],["physicalCommandEnabled",_physicalEnabled],["physical",_physical],
  ["equipmentViewCommandEnabled",_equipmentPhysicalEnabled],["equipmentPhysical",_equipmentPhysical],["kitLibraryMode",_kitLibraryMode],["publicLibraryRevision",_publicRevision],["publicLibraryAuthority",_publicAuthority],["publicLibraryAuthoritative",_publicAuthoritative],["publicLibraryAuthorityPending",_publicAuthorityPending],["kits",_kits],
  ["draft",createHashMapFromArray [["hasDraft",_draftState getOrDefault ["hasDraft",false]],["mode",_draftMode],["dirty",_dirty],["name",_draft getOrDefault ["name",""]],["kitId",_draft getOrDefault ["kitId",""]],["preferredTarget",_draft getOrDefault ["preferredTarget","ANY"]],["totalMass",_draftTotalMass],["unknownMassCount",_draftUnknownMassCount],["rows",_draftRows]]],
  ["catalog",createHashMapFromArray [["cacheBuilt",_catalogStatus getOrDefault ["cacheBuilt",false]],["buildInProgress",_catalogStatus getOrDefault ["buildInProgress",false]],["buildCurrentRoot",_catalogStatus getOrDefault ["buildCurrentRoot",""]],["buildVisitedCount",_catalogStatus getOrDefault ["buildVisitedCount",0]],["buildCandidateCount",_catalogStatus getOrDefault ["buildCandidateCount",0]],["buildPartialItemCount",_catalogStatus getOrDefault ["buildPartialItemCount",0]],["totalFiltered",_catalogTotal],["baseCount",_catalogBaseCount],["offset",_offset],["windowSize",_window],["rows",_catalogRows],["selected",_selectedCatalog]]],
  ["equipment",createHashMapFromArray [["view",_ui getOrDefault ["equipmentView","U"]],["status",_equipmentStatus],["containerClass",_equipmentContainer],["loadoutUnchanged",_equipmentUnchanged],["totalMass",_equipmentTotalMass],["unknownMassCount",_equipmentUnknownMassCount],["capacity",_equipmentCapacity],["rows",_equipmentRows]]],
  ["applicationTarget",_ui getOrDefault ["applicationTarget","ANY"]],["context",_context],["message",_ui getOrDefault ["temporaryMessage",""]],["history",+(_ui getOrDefault ["history",[]])]
 ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
