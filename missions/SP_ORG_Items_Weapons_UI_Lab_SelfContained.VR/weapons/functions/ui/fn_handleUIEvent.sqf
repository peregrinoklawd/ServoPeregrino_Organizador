#include "..\..\script_version.hpp"
params [
 ["_event","",[""]],
 ["_value",nil]
];
disableSerialization;

private _eventName = toUpperANSI _event;
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};

private _refresh = true;
private _focusedRefresh = "";
private _focusedRefreshSecondary = "";
private _focusedReason = _eventName;

// Programmatic lbSetCurSel / sliderSetPosition calls fire UI callbacks while a refresh
// is painting. Those callbacks are not player intent and must never recurse.
if (
 (
  (_state getOrDefault ["refreshInProgress",false])
  || {_state getOrDefault ["catalogRefreshInProgress",false]}
  || {_state getOrDefault ["draftRefreshInProgress",false]}
  || {_state getOrDefault ["equipmentRefreshInProgress",false]}
 )
 && {_eventName in ["KIT_SELECT","CATALOG_SELECT","COMPAT_SELECT","CATALOG_SCROLL_ABSOLUTE"]}
) exitWith {true};

private _clampCatalogOffset = {
 params ["_candidate","_stateMap"];
 private _maxOffset = (_stateMap getOrDefault ["catalogMaxOffset",0]) max 0;
 (round _candidate) max 0 min _maxOffset
};

switch (_eventName) do {
 case "REQUEST_CLOSE": {
  closeDialog 0;
  _refresh = false;
 };

 case "KIT_SEARCH": {
  _state set ["kitQuery",if (_value isEqualType "") then {_value} else {""}];
  _state set ["lastFocus","KITS"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 };

 case "KIT_TYPE": {
  private _slot = toUpperANSI _value;
  if (_slot in ["ALL","PRIMARY","HANDGUN","SECONDARY"]) then {
   _state set ["kitTypeFilter",_slot];
   _state set ["lastFocus","KITS"];
   missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
   [format ["Filtro de kits: %1",[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   _refresh = false;
  };
 };

 case "KIT_SELECT": {
  // A repeated real click is meaningful: it restores KIT focus without changing the draft.
  _refresh = false;
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (!isNull _display && {_value isEqualType 0} && {_value >= 0}) then {
   private _id = (_display displayCtrl 1110) lbData _value;
   if (_id isNotEqualTo "") then {
    private _sameId = _id isEqualTo (_state getOrDefault ["selectedKitId",""]);
    private _focusChanged = (_state getOrDefault ["lastFocus","KITS"]) isNotEqualTo "KITS";
    if (!_sameId || {_focusChanged}) then {
     _state set ["selectedKitId",_id];
     _state set ["draftNameEditing",false];
     _state set ["draftNameInput",""];
     _state set ["previousKitIdBeforeNew",""];
     _state set ["pendingNewKit",false];
     _state set ["pendingNewName",""];
     _state set ["pendingCapturedDraft",createHashMap];
     _state set ["selectedKitIsNew",false];
     _state set ["lastFocus","KITS"];
     // Accessory catalog depends on selected weapon compatibility. Keep the category,
     // but start its continuous window at the top for deterministic behavior.
     _state set ["catalogOffset",0];
     _state set ["selectedCatalogClass",""];
     _state set ["selectedCatalogKind",""];
     missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

     private _kitR = [_id] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
     private _kitName = if (_kitR get "success") then {((_kitR get "data") get "kit") getOrDefault ["name",""]} else {_id};
     [format ["Kit selecionado: %1",_kitName],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _refresh = true;
    };
   };
  };
 };

 case "CATALOG_SEARCH": {
  _state set ["catalogQuery",if (_value isEqualType "") then {_value} else {""}];
  _state set ["catalogOffset",0];
  _state set ["selectedCatalogClass",""];
  _state set ["selectedCatalogKind",""];
  _state set ["lastFocus","CATALOG"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  _refresh = false;
  _focusedRefresh = "CATALOG";
 };

 case "CATALOG_TYPE": {
  private _slot = toUpperANSI _value;
  if (_slot in ["ALL","PRIMARY","HANDGUN","SECONDARY"]) then {
   _state set ["catalogTypeFilter",_slot];
   _state set ["catalogOffset",0];
   _state set ["selectedCatalogClass",""];
   _state set ["selectedCatalogKind",""];
   _state set ["lastFocus","CATALOG"];
   missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
   [format ["Tipo do catálogo: %1",[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _refresh = false;
   _focusedRefresh = "CATALOG";
  } else {
   _refresh = false;
  };
 };

 case "CATALOG_CATEGORY": {
  private _kind = toUpperANSI _value;
  if (_kind in ["ALL","WEAPON","OPTIC","POINTER","BIPOD","MAGAZINE","GRIP"]) then {
   private _labels = createHashMapFromArray [
    ["ALL","Todos"],["WEAPON","Arma"],["OPTIC","Óticas"],["POINTER","Apontadores"],
    ["BIPOD","Bipés"],["MAGAZINE","Carregadores"],["GRIP","Empunhaduras"]
   ];
   _state set ["catalogCategoryFilter",_kind];
   _state set ["catalogOffset",0];
   _state set ["selectedCatalogClass",""];
   _state set ["selectedCatalogKind",""];
   _state set ["lastFocus","CATALOG"];
   missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
   [format ["Categoria do catálogo: %1",_labels getOrDefault [_kind,_kind]],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _refresh = false;
   _focusedRefresh = "CATALOG";
  } else {
   _refresh = false;
  };
 };

 case "CATALOG_SCROLL": {
  if (_value isEqualType 0) then {
   private _next = [(_state getOrDefault ["catalogOffset",0]) + _value,_state] call _clampCatalogOffset;
   if (_next isNotEqualTo (_state getOrDefault ["catalogOffset",0])) then {
    _state set ["catalogOffset",_next];
    // Preserve the selected row/details while only the visible window moves.
    _state set ["lastFocus","CATALOG"];
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    _refresh = false;
    _focusedRefresh = "CATALOG";
   } else {
    _refresh = false;
   };
  } else {
   _refresh = false;
  };
 };

 case "CATALOG_SCROLL_ABSOLUTE": {
  if (_value isEqualType 0) then {
   private _next = [_value,_state] call _clampCatalogOffset;
   if (_next isNotEqualTo (_state getOrDefault ["catalogOffset",0])) then {
    _state set ["catalogOffset",_next];
    // Preserve the selected row/details while only the visible window moves.
    _state set ["lastFocus","CATALOG"];
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    _refresh = false;
    _focusedRefresh = "CATALOG";
   } else {
    _refresh = false;
   };
  } else {
   _refresh = false;
  };
 };

 case "CATALOG_SELECT": {
  _refresh = false;
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (!isNull _display && {_value isEqualType 0} && {_value >= 0}) then {
   private _ctrl = _display displayCtrl 3120;
   private _class = _ctrl lbData _value;
   private _kindValue = _ctrl lbValue _value;
   private _kind = switch (_kindValue) do {
    case 0: {"WEAPON"}; case 1: {"OPTIC"}; case 2: {"POINTER"};
    case 3: {"BIPOD"}; case 4: {"MAGAZINE"}; case 5: {"GRIP"}; default {""};
   };
   if (_class isNotEqualTo "" && {_kind isNotEqualTo ""}) then {
    private _sameClass = (toLowerANSI _class) isEqualTo (toLowerANSI (_state getOrDefault ["selectedCatalogClass",""]));
    private _sameKind = _kind isEqualTo (toUpperANSI (_state getOrDefault ["selectedCatalogKind",""]));
    private _focusChanged = (_state getOrDefault ["lastFocus","KITS"]) isNotEqualTo "CATALOG";
    if (!_sameClass || {!_sameKind} || {_focusChanged}) then {
     _state set ["selectedCatalogClass",_class];
     _state set ["selectedCatalogKind",_kind];
     _state set ["lastFocus","CATALOG"];
     missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
     private _displayName = _ctrl lbText _value;
     [format ["Catálogo selecionado: %1",_displayName],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _refresh = false;
     _focusedRefresh = "CATALOG";
    };
   };
  };
 };

 case "EQUIPMENT_SLOT": {
  private _slot = toUpperANSI _value;
  if (_slot in ["PRIMARY","HANDGUN","SECONDARY"]) then {
   if (_slot isNotEqualTo (_state getOrDefault ["equipmentSlotView","PRIMARY"])) then {
    _state set ["equipmentSlotView",_slot];
    _state set ["lastFocus","EQUIPMENT"];
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    [format ["Conteúdo do equipamento: %1. Use CAPTURAR para copiar ao rascunho.",[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _refresh = false;
    _focusedRefresh = "EQUIPMENT";
   } else {
    _refresh = false;
   };
  } else {
   _refresh = false;
  };
 };

 case "COMPAT_SELECT": {
  // 0.6-D keeps local draft editing. The combo contains only engine-derived compatible
  // values; this path mutates only the UI-session draft and never repository/loadout.
  _refresh = false;
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (!isNull _display && {_value isEqualType []} && {count _value >= 2}) then {
   _value params ["_field","_index"];
   if (_field isEqualType "" && {_index isEqualType 0} && {_index >= 0}) then {
    private _controlMap = createHashMapFromArray [
     ["optic",2023],["muzzle",2025],["pointer",2027],["bipod",2029],["magazineClass",2031]
    ];
    private _labelMap = createHashMapFromArray [
     ["optic","Mira"],["muzzle","Boca"],["pointer","Apontador"],["bipod","Bipé"],["magazineClass","Carregador"]
    ];
    private _idc = _controlMap getOrDefault [_field,-1];
    private _selectedKitId = _state getOrDefault ["selectedKitId",""];
    if (_idc >= 0 && {_selectedKitId isNotEqualTo "" || {(_state getOrDefault ["pendingNewKit",false]) && {count (_state getOrDefault ["pendingCapturedDraft",createHashMap])>0}}}) then {
     private _ctrl = _display displayCtrl _idc;
     private _chosenClass = _ctrl lbData _index;
     private _chosenText = _ctrl lbText _index;
     private _draftResult = if (_selectedKitId isEqualTo "") then {
      [_field,_chosenClass] call ServoPeregrino_Organizador_Weapons_fnc_setPendingCapturedDraftSelection
     } else {
      [_selectedKitId,_field,_chosenClass] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection
     };
     if (_draftResult get "success") then {
      private _dirty = ((_draftResult get "data") getOrDefault ["dirty",false]);
      [format [
       "%1 no rascunho: %2. Estado: %3. O equipamento real não foi alterado.",
       _labelMap getOrDefault [_field,_field],
       if (_chosenText isEqualTo "") then {"Nenhum"} else {_chosenText},
       if (_dirty) then {"ALTERADO"} else {"SALVO"}
      ],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _refresh = false;
      _focusedRefresh = "DRAFT";
     } else {
      [format ["Não foi possível atualizar o rascunho: %1",_draftResult getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _refresh = false;
      _focusedRefresh = "DRAFT";
     };
    };
   };
  };
 };

 case "DRAFT_DISCARD": {
  _refresh = false;
  private _selectedKitId = _state getOrDefault ["selectedKitId",""];
  if ((_state getOrDefault ["pendingNewKit",false]) && {_selectedKitId isEqualTo ""}) then {
   // 0.6-F: canceling a brand-new draft restores the exact kit that was selected
   // before NOVO, when it still exists. It never creates a kit just to cancel.
   private _previousKitId = _state getOrDefault ["previousKitIdBeforeNew",""];
   private _restoreKitId = "";
   if (_previousKitId isNotEqualTo "") then {
    private _previousKitR = [_previousKitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
    if (_previousKitR getOrDefault ["success",false]) then {_restoreKitId = _previousKitId};
   };
   _state set ["pendingNewKit",false];
   _state set ["pendingNewName",""];
   _state set ["pendingCapturedDraft",createHashMap];
   _state set ["draftNameEditing",false];
   _state set ["draftNameInput",""];
   _state set ["selectedKitIsNew",false];
   _state set ["selectedKitId",_restoreKitId];
   _state set ["previousKitIdBeforeNew",""];
   _state set ["activeDraftKitId",_restoreKitId];
   _state set ["lastFocus","KITS"];
   missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
   [
    if (_restoreKitId isEqualTo "") then {
     "Novo rascunho descartado antes da escolha da arma. Nenhum WeaponKit foi criado."
    } else {
     "Novo rascunho descartado. O kit selecionado antes de NOVO foi restaurado; nenhum WeaponKit foi criado."
    },
    "INFO",
    true
   ] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _refresh = true;
  } else {
   if (_selectedKitId isEqualTo "") then {
    ["Nenhum WeaponKit selecionado para descartar o rascunho.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    private _discardResult = [_selectedKitId] call ServoPeregrino_Organizador_Weapons_fnc_discardWeaponKitDraft;
    if (_discardResult getOrDefault ["success",false]) then {
     _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
     _state set ["draftNameEditing",false];
     _state set ["draftNameInput",""];
     missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
     ["Rascunho descartado. Os valores voltaram ao WeaponKit salvo; repository e equipamento físico não foram alterados.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     // Discard can restore a different base weapon. Rebuild all visible dependent
     // projections once so P2 and Catalog cannot disagree about compatibility.
     _refresh = true;
    } else {
     [format ["Falha ao descartar rascunho: %1",_discardResult getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _focusedRefresh = "DRAFT";
    };
   };
  };
 };

 case "NEW_KIT": {
  _refresh = false;
  private _uniqueR = ["Novo Kit"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
  private _pendingName = if (_uniqueR getOrDefault ["success",false]) then {(_uniqueR get "data") getOrDefault ["name","Novo Kit"]} else {"Novo Kit"};
  private _currentKitBeforeNew = _state getOrDefault ["selectedKitId",""];
  private _previousKitBeforeNew = if (_currentKitBeforeNew isNotEqualTo "") then {
   _currentKitBeforeNew
  } else {
   _state getOrDefault ["previousKitIdBeforeNew",""]
  };
  _state set ["previousKitIdBeforeNew",_previousKitBeforeNew];
  _state set ["pendingNewKit",true];
  _state set ["pendingNewName",_pendingName];
  _state set ["pendingCapturedDraft",createHashMap];
  _state set ["draftNameEditing",false];
  _state set ["draftNameInput",""];
  _state set ["selectedKitIsNew",false];
  _state set ["selectedKitId",""];
  _state set ["activeDraftKitId",""];
  _state set ["lastFocus","DRAFT"];
  // A pending new kit must start from a weapon choice. Remove any previous
  // accessory/search context that could leave the Catalog apparently empty.
  _state set ["catalogCategoryFilter","WEAPON"];
  _state set ["catalogQuery",""];
  _state set ["selectedCatalogClass",""];
  _state set ["selectedCatalogKind",""];
  _state set ["catalogOffset",0];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  ["Novo rascunho preparado. Escolha uma ARMA no Catálogo e use ← / EQUIPAR NO RASCUNHO.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  _refresh = true;
 };

 case "RENAME_KIT": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (_kitId isEqualTo "" || {isNull _display}) then {
   ["Selecione um WeaponKit antes de renomear.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   private _desiredName = ctrlText (_display displayCtrl 2001);
   private _renameR = [_kitId,_desiredName] call ServoPeregrino_Organizador_Weapons_fnc_renameWeaponKit;
   if (_renameR get "success") then {
    private _kit = (_renameR get "data") get "kit";
    _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
    private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
    private _draft = _drafts getOrDefault [_kitId,createHashMap];
    if ((count _draft) > 0) then {
     _draft set ["sourceName",_kit getOrDefault ["name",""]];
     _drafts set [_kitId,_draft];
     _state set ["draftsByKitId",_drafts];
    };
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    [format ["Kit renomeado para: %1",_kit getOrDefault ["name","Sem nome"]],"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _refresh = true;
   } else {
    [format ["Não foi possível renomear: %1",_renameR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   };
  };
 };

 case "DUPLICATE_KIT": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  if (_kitId isEqualTo "") then {
   ["Selecione um WeaponKit antes de duplicar.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   private _sourceR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
   if !(_sourceR get "success") then {
    [format ["Não foi possível ler o kit: %1",_sourceR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    private _source = (_sourceR get "data") get "kit";
    private _uniqueR = [format ["%1 - Cópia",_source getOrDefault ["name","Kit"]]] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
    if !(_uniqueR get "success") then {
     [format ["Não foi possível gerar o nome da cópia: %1",_uniqueR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    } else {
     private _dupR = [_kitId,(_uniqueR get "data") get "name"] call ServoPeregrino_Organizador_Weapons_fnc_duplicateWeaponKit;
     if (_dupR get "success") then {
      private _newKit = (_dupR get "data") get "kit";
      _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
      _state set ["selectedKitId",_newKit getOrDefault ["kitId",""]];
      _state set ["draftNameEditing",false];
      _state set ["draftNameInput",""];
      _state set ["selectedKitIsNew",false];
      _state set ["pendingNewKit",false];
      _state set ["kitTypeFilter","ALL"];
      _state set ["kitQuery",""];
      _state set ["lastFocus","KITS"];
      missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
      [(_newKit getOrDefault ["kitId",""])] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
      [format ["Kit duplicado: %1. A cópia usa o conteúdo SALVO; o rascunho não salvo do original não foi copiado.",_newKit getOrDefault ["name","Sem nome"]],"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _refresh = true;
     } else {
      [format ["Não foi possível duplicar: %1",_dupR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     };
    };
   };
  };
 };

 case "DELETE_KIT": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  if (_kitId isEqualTo "") then {
   ["Selecione um WeaponKit antes de excluir.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   private _beforeR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
   private _oldName = if (_beforeR get "success") then {((_beforeR get "data") get "kit") getOrDefault ["name",_kitId]} else {_kitId};
   private _deleteR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_deleteWeaponKit;
   if (_deleteR get "success") then {
    _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
    private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
    _drafts deleteAt _kitId;
    _state set ["draftsByKitId",_drafts];
    _state set ["selectedKitId",""];
    _state set ["draftNameEditing",false];
    _state set ["draftNameInput",""];
    _state set ["selectedKitIsNew",false];
    _state set ["pendingNewKit",false];
    _state set ["pendingNewName",""];
    if ((_state getOrDefault ["activeDraftKitId",""]) isEqualTo _kitId) then {_state set ["activeDraftKitId",""]};
    _state set ["lastFocus","KITS"];
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    [format ["Kit excluído: %1. Nenhum equipamento físico foi alterado.",_oldName],"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _refresh = true;
   } else {
    [format ["Não foi possível excluir: %1",_deleteR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   };
  };
 };

 case "SET_DRAFT_WEAPON": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  private _catalogClass = _state getOrDefault ["selectedCatalogClass",""];
  private _catalogKind = toUpperANSI (_state getOrDefault ["selectedCatalogKind",""]);
  if (_kitId isEqualTo "") then {
   ["Selecione um WeaponKit antes de trocar a arma-base do rascunho.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   if (_catalogKind isNotEqualTo "WEAPON" || {_catalogClass isEqualTo ""}) then {
    ["Selecione uma ARMA no Catálogo de Armas e depois use ← / EQUIPAR NO RASCUNHO.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    private _setR = [_kitId,_catalogClass] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftWeapon;
    if (_setR get "success") then {
     private _changed = (_setR get "data") getOrDefault ["changed",false];
     if (_changed) then {
      ["Arma do rascunho atualizada. Mira, boca, apontador, bipé/empunhadura e carregador foram recalculados para a nova arma. Use SALVAR quando terminar.","SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
      _state set ["catalogOffset",0];
      missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
      // A base-weapon swap changes P2 plus the compatibility projection in P3.
      // P1 repository rows and P4 physical equipment are unchanged.
      _refresh = false;
      _focusedRefresh = "DRAFT";
      _focusedRefreshSecondary = "CATALOG";
      _focusedReason = "DRAFT_WEAPON";
     } else {
      ["A arma selecionada já é a arma-base do rascunho.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _focusedRefresh = "DRAFT";
     };
    } else {
     private _msg = _setR getOrDefault ["message","Não foi possível trocar a arma do rascunho."];
     [_msg,"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _focusedRefresh = "DRAFT";
    };
   };
  };
 };

 case "SAVE_DRAFT": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (_kitId isEqualTo "" && {_state getOrDefault ["pendingNewKit",false]} && {count (_state getOrDefault ["pendingCapturedDraft",createHashMap])>0} && {!isNull _display}) then {
   private _captured=_state get "pendingCapturedDraft";
   private _typedName=ctrlText (_display displayCtrl 2001);
   private _nameCheck=[_typedName] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
   if !(_nameCheck getOrDefault ["success",false]) then {
    ["Informe um nome válido para salvar a arma capturada.","ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _focusedRefresh="DRAFT";
   } else {
    private _name=(_nameCheck get "data") get "name";
    private _savedR=[_name,_captured getOrDefault ["targetSlot",""],_captured getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
    if !(_savedR getOrDefault ["success",false]) then {
     [_savedR getOrDefault ["message","Nome duplicado ou Recipe inválida. Nada foi salvo."],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _focusedRefresh="DRAFT";
    } else {
     private _saved=(_savedR get "data") get "kit";
     private _newId=_saved getOrDefault ["kitId",""];
     _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
     _state set ["selectedKitId",_newId];
     _state set ["pendingNewKit",false];
     _state set ["pendingNewName",""];
     _state set ["pendingCapturedDraft",createHashMap];
     _state set ["previousKitIdBeforeNew",""];
     _state set ["selectedKitIsNew",false];
     _state set ["draftNameEditing",false];
     _state set ["draftNameInput",""];
     _state set ["selectedKitDraftDirty",false];
     _state set ["kitTypeFilter","ALL"];
     _state set ["kitQuery",""];
     missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
     [_newId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
     ["Arma capturada salva como novo WeaponKit da sessão. O equipamento real permanece inalterado.","SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _refresh=true;
    };
   };
  } else {
   if (_kitId isEqualTo "" || {isNull _display}) then {
   ["O novo rascunho precisa receber uma arma do Catálogo antes de SALVAR.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   private _typedName = ctrlText (_display displayCtrl 2001);
   private _nameCheck = [_typedName] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
   if !(_nameCheck getOrDefault ["success",false]) then {
    ["O nome do WeaponKit não pode ficar vazio. Digite um nome antes de SALVAR.","ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _focusedRefresh = "DRAFT";
   } else {
    _typedName = (_nameCheck get "data") get "name";
    private _kitR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
    private _renameOk = true;
    private _renamed = false;
    if (_kitR getOrDefault ["success",false]) then {
     private _savedName = ((_kitR get "data") get "kit") getOrDefault ["name",""];
     if ((toLowerANSI _typedName) isNotEqualTo (toLowerANSI _savedName)) then {
      private _renameR = [_kitId,_typedName] call ServoPeregrino_Organizador_Weapons_fnc_renameWeaponKit;
      _renameOk = _renameR getOrDefault ["success",false];
      _renamed = _renameOk;
      if (_renameOk) then {
       _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
       private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
       private _draft = _drafts getOrDefault [_kitId,createHashMap];
       if ((count _draft)>0) then {
        _draft set ["sourceName",((_renameR get "data") get "kit") getOrDefault ["name",_typedName]];
        _drafts set [_kitId,_draft];
        _state set ["draftsByKitId",_drafts];
       };
       missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
      } else {
       [format ["Não foi possível salvar o nome: %1",_renameR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      };
     };
    };
    if (_renameOk) then {
     private _saveR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_saveWeaponKitDraft;
     if (_saveR getOrDefault ["success",false]) then {
      _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
      _state set ["selectedKitIsNew",false];
      _state set ["draftNameEditing",false];
      _state set ["draftNameInput",""];
      missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
      [if (_renamed || {((_saveR get "data") getOrDefault ["changed",false])}) then {"Nome/Recipe salvos no WeaponKit da sessão. O equipamento real não foi alterado."} else {"O WeaponKit já estava salvo e sem alterações."},"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _refresh = true;
     } else {
      [format ["Não foi possível salvar: %1",_saveR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      _focusedRefresh = "DRAFT";
     };
    };
   };
  };
  };
 };

 case "SAVE_AS_NEW": {
  _refresh = false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  if (_kitId isEqualTo "" || {isNull _display}) then {
   ["Selecione um WeaponKit antes de usar SALVAR COMO NOVO.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  } else {
   private _kitR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
   private _draftR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
   if !(_kitR get "success" && {_draftR get "success"}) then {
    ["Não foi possível resolver o kit/rascunho para salvar como novo.","ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    private _source = (_kitR get "data") get "kit";
    private _draft = (_draftR get "data") get "draft";
    private _typedName = ctrlText (_display displayCtrl 2001);
    private _sourceName = _source getOrDefault ["name","Kit"];
    private _editingName = _state getOrDefault ["draftNameEditing",false];
    private _nameCheck = [_typedName] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
    if (_editingName && {!(_nameCheck getOrDefault ["success",false])}) then {
     ["O nome do novo WeaponKit não pode ficar vazio.","ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     _focusedRefresh = "DRAFT";
    } else {
     private _name = if (_nameCheck getOrDefault ["success",false]) then {(_nameCheck get "data") get "name"} else {_typedName};
     private _explicitDifferent = _name isNotEqualTo "" && {(toLowerANSI _name) isNotEqualTo (toLowerANSI _sourceName)};
     if (!_explicitDifferent) then {
      private _uniqueR = [format ["%1 - Cópia",_sourceName]] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
      if (_uniqueR get "success") then {_name = (_uniqueR get "data") get "name"} else {_name = ""};
     };
     if (_name isEqualTo "") then {
      ["Não foi possível gerar um nome válido para o novo kit.","ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
     } else {
      private _createR = [_name,_draft getOrDefault ["targetSlot",_source getOrDefault ["targetSlot",""]],_draft getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
      if (_createR get "success") then {
       private _newKit = (_createR get "data") get "kit";
       private _newId = _newKit getOrDefault ["kitId",""];
       _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
       _state set ["selectedKitId",_newId];
       _state set ["selectedKitIsNew",false];
       _state set ["pendingNewKit",false];
       _state set ["pendingNewName",""];
       _state set ["draftNameEditing",false];
       _state set ["draftNameInput",""];
       _state set ["kitTypeFilter","ALL"];
       _state set ["kitQuery",""];
       _state set ["lastFocus","KITS"];
       missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
       [_newId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
       [format ["Rascunho salvo como novo kit: %1. O WeaponKit original não foi alterado.",_newKit getOrDefault ["name","Sem nome"]],"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
       _refresh = true;
      } else {
       [format ["Não foi possível salvar como novo: %1",_createR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
      };
     };
    };
   };
  };
 };

 case "PUBLIC_LIBRARY": {
  ["PÚBLICOS permanece reservado. A 0.6-F R1 continua usando o repositório privado/session-local; biblioteca pública de Weapons é gate futuro.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
 };


 case "DRAFT_NAME_INPUT": {
  // Editing may be temporarily blank. The saved kit name is restored only when editing ends
  // through an explicit state transition, never just because the current text is empty.
  _refresh = false;
  private _typed = if (_value isEqualType "") then {_value} else {""};
  _state set ["draftNameInput",_typed];
  _state set ["draftNameEditing",true];
  if (_state getOrDefault ["pendingNewKit",false]) then {_state set ["pendingNewName",_typed]};
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  _focusedRefresh = "DRAFT";
 };

 case "P2_SEARCH": {
  _state set ["draftQuery",if (_value isEqualType "") then {_value} else {""}];
  _state set ["lastFocus","DRAFT"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  _refresh=false;
  _focusedRefresh="DRAFT";
 };

 case "P4_SEARCH": {
  _state set ["equipmentQuery",if (_value isEqualType "") then {_value} else {""}];
  _state set ["lastFocus","EQUIPMENT"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  _refresh=false;
  _focusedRefresh="EQUIPMENT";
 };

 case "CATALOG_TO_DRAFT": {
  _refresh=false;
  private _display=findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
  private _name=if (isNull _display) then {""} else {ctrlText (_display displayCtrl 2001)};
  private _applyR=[_name] call ServoPeregrino_Organizador_Weapons_fnc_applyCatalogSelectionToDraft;
  if (_applyR getOrDefault ["success",false]) then {
   private _code=_applyR getOrDefault ["code",""];
   private _msg=if (_code isEqualTo "WEAPONS_UI_DRAFT_AUTO_CREATED") then {
    "Nenhum kit estava aberto. Um novo kit foi criado automaticamente em ARMAS DO KIT com a arma selecionada."
   } else {
    "Seleção enviada para ARMAS DO KIT. O equipamento real do jogador não foi alterado."
   };
   [_msg,"SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;

   if (_code isEqualTo "WEAPONS_UI_DRAFT_AUTO_CREATED") then {
    // Auto-create materializes a new session WeaponKit, so P1 really changed.
    _refresh=true;
   } else {
    private _appliedData=_applyR getOrDefault ["data",createHashMap];
    private _appliedKind=toUpperANSI (_appliedData getOrDefault ["kind",_state getOrDefault ["selectedCatalogKind",""]]);
    private _sourceResult=_appliedData getOrDefault ["sourceResult",createHashMap];
    private _changed=_sourceResult getOrDefault ["changed",true];

    _refresh=false;
    _focusedRefresh="DRAFT";
    _focusedReason="CATALOG_TO_DRAFT";

    // Only a changed base weapon invalidates the Catalog compatibility projection.
    // Accessory edits alter P2 only; the compatible option universe remains stable.
    if (_appliedKind isEqualTo "WEAPON" && {_changed}) then {
     _focusedRefreshSecondary="CATALOG";
    };
   };
  } else {
   private _code=_applyR getOrDefault ["code","ERRO"];
   private _msg=switch _code do {
    case "WEAPONS_UI_DRAFT_BASE_WEAPON_REQUIRED": {"Escolha primeiro uma arma no Catálogo. Ao enviá-la para ARMAS DO KIT, um novo kit será criado automaticamente."};
    case "WEAPONS_UI_DRAFT_SELECTION_INCOMPATIBLE": {"Esse acessório não é compatível com a arma que está no rascunho. Escolha outro acessório compatível."};
    case "WEAPONS_UI_CATALOG_SELECTION_REQUIRED": {"Selecione uma arma ou acessório no Catálogo antes de enviar para o rascunho."};
    default {_applyR getOrDefault ["message","Não foi possível concluir a alteração no rascunho."]};
   };
   [_msg,"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _focusedRefresh="DRAFT";
  };
 };

 case "APPLY_DRAFT": {
  _refresh=false;
  private _kitId = _state getOrDefault ["selectedKitId",""];
  private _draft = if (_kitId isEqualTo "" && {_state getOrDefault ["pendingNewKit",false]}) then {
   _state getOrDefault ["pendingCapturedDraft",createHashMap]
  } else {
   (_state getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_kitId,createHashMap]
  };
  private _result = [player,_draft] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
  private _d = _result getOrDefault ["data",createHashMap];
  _state set ["lastApplicationResult",_result];
  if ((_d getOrDefault ["targetSlot",""]) in ["PRIMARY","HANDGUN","SECONDARY"]) then {_state set ["equipmentSlotView",_d get "targetSlot"]};
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  private _feedback = [_result] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationFeedback;
  [_feedback get "message",_feedback get "kind",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  diag_log format ["[SP_ORG] [WEAPONS] [DRAFT_APPLY] result=%1",_result];
  _focusedRefresh="EQUIPMENT";
 };

 case "EQUIPMENT_TO_DRAFT": {
  _refresh=false;
  private _slot=_state getOrDefault ["equipmentSlotView","PRIMARY"];
  private _captureR=[player,_slot] call ServoPeregrino_Organizador_Weapons_fnc_captureEquippedWeaponToDraft;
  if (_captureR getOrDefault ["success",false]) then {
   private _created=(_captureR get "data") getOrDefault ["createdNew",false];
   ["Arma e acessórios capturados em ARMAS DO KIT. SALVAR é opcional para o rascunho atual. A quantidade de tiros não é copiada.","SUCCESS",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _focusedRefresh="DRAFT";
   _focusedRefreshSecondary="CATALOG";
   _focusedReason="EQUIPMENT_TO_DRAFT";
   // A pending NEW draft changes the P1 selection/filters, so refresh once.
   _refresh=_created;
  } else {
   [_captureR getOrDefault ["message","Não foi possível capturar a arma deste destino."],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   _focusedRefresh="EQUIPMENT";
  };
  diag_log format ["[SP_ORG] [WEAPONS] [EQUIPMENT_CAPTURE] slot=%1 code=%2 success=%3",_slot,_captureR getOrDefault ["code",""],_captureR getOrDefault ["success",false]];
 };

 case "CATALOG_TO_EQUIPMENT": {
  _refresh=false;
  private _result=[player,_state getOrDefault ["selectedCatalogClass",""],_state getOrDefault ["selectedCatalogKind",""],_state getOrDefault ["equipmentSlotView","PRIMARY"]] call ServoPeregrino_Organizador_Weapons_fnc_executeCatalogApplication;
  private _d=_result getOrDefault ["data",createHashMap];
  _state set ["lastApplicationResult",_result];
  if ((_d getOrDefault ["targetSlot",""]) in ["PRIMARY","HANDGUN","SECONDARY"]) then {_state set ["equipmentSlotView",_d get "targetSlot"]};
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  private _feedback=[_result] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationFeedback;
  [_feedback get "message",_feedback get "kind",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
  diag_log format ["[SP_ORG] [WEAPONS] [CATALOG_APPLY] code=%1 slot=%2 mutation=%3 rollback=%4",_result getOrDefault ["code",""],_d getOrDefault ["targetSlot",""],_d getOrDefault ["mutationPerformed",false],_d getOrDefault ["rollbackAttempted",false]];
  _focusedRefresh="EQUIPMENT";
  _focusedReason="CATALOG_TO_EQUIPMENT";
 };

 case "DRAFT_CLEAR": {
  _refresh=false;
  private _kitId=_state getOrDefault ["selectedKitId",""];
  if (_kitId isEqualTo "" && {_state getOrDefault ["pendingNewKit",false]} && {count (_state getOrDefault ["pendingCapturedDraft",createHashMap])>0}) then {
   private _old=_state get "pendingCapturedDraft";
   private _updated=[_old] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
   private _recipe=[_updated get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
   private _cfg=[_recipe get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
   {_cfg set [_x,""]} forEach ["optic","muzzle","pointer","bipod"];
   _recipe set ["configuration",_cfg];
   _recipe set ["magazineClass",""];
   private _valid=[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
   if (_valid getOrDefault ["success",false]) then {
    _updated set ["recipe",_recipe];
    _updated set ["revision",(_old getOrDefault ["revision",0])+1];
    _updated set ["updatedAtTick",diag_tickTime];
    _state set ["pendingCapturedDraft",_updated];
    missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
    ["Acessórios e carregador removidos do rascunho NOVO; nada foi salvo.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
    _focusedRefresh="DRAFT";
   } else {
    [_valid getOrDefault ["message","Não foi possível limpar o rascunho."],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   };
  } else {
   if (_kitId isEqualTo "") then {
    ["O novo rascunho ainda não possui arma-base para LIMPAR.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    private _clearR=[_kitId] call ServoPeregrino_Organizador_Weapons_fnc_clearWeaponKitDraft;
   if (_clearR getOrDefault ["success",false]) then {
    ["Rascunho limpo: arma-base preservada; acessórios e carregador removidos. Use SALVAR para persistir.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   } else {
    [format ["Não foi possível limpar: %1",_clearR getOrDefault ["code","ERRO"]],"ERROR",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
   };
   _focusedRefresh="DRAFT";
   };
  };
 };

 case "PUBLISH_KIT": {
  _refresh=false;
  ["PUBLICAR está reservado até existir provider público autoritativo para Weapons. Nenhuma publicação foi executada.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
 };

 case "UI_DEFERRED": {
  [format ["%1 permanece reservado para um gate futuro. A 0.6-F R1 preserva authoring direto no rascunho, mas aplicação física continua em 0.7.",_value],"INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
 };

 default {
  _refresh = false;
 };
};

if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) then {
 if (_focusedRefresh isEqualTo "CATALOG") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshCatalogWindowUI};
 if (_focusedRefresh isEqualTo "DRAFT") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI};
 if (_focusedRefresh isEqualTo "EQUIPMENT") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshEquipmentViewUI};
 if (_focusedRefreshSecondary isEqualTo "CATALOG") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshCatalogWindowUI};
 if (_focusedRefreshSecondary isEqualTo "DRAFT") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI};
 if (_focusedRefreshSecondary isEqualTo "EQUIPMENT") then {[_focusedReason] call ServoPeregrino_Organizador_Weapons_fnc_refreshEquipmentViewUI};
 if (_refresh) then {[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface};
};
true
