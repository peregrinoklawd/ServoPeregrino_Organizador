#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","DRAFT_FOCUSED",[""]]];

private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (isNull _display) exitWith {[false,"WEAPONS_UI_NOT_OPEN","Weapons UI is not open."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if (_state getOrDefault ["draftRefreshInProgress",false]) exitWith {[true,"WEAPONS_UI_DRAFT_REFRESH_REENTRANT_SKIPPED","Nested draft-focused refresh ignored."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_state set ["draftRefreshInProgress",true];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
private _startedAt = diag_tickTime;
private _selectedKitId = _state getOrDefault ["selectedKitId",""];
private _pendingNew = _state getOrDefault ["pendingNewKit",false];
private _isNew = _state getOrDefault ["selectedKitIsNew",false];
private _query = _state getOrDefault ["draftQuery",""];
private _slotLabel = {params ["_slot"];[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel};
(_display displayCtrl 2003) ctrlSetText ""; (_display displayCtrl 2003) ctrlShow false;

// 0.6-F R3: P2 owns an independent query. Never mirror Catalog/P4 text here.
private _draftSearchCtrl = _display displayCtrl 2051;
if ((ctrlText _draftSearchCtrl) isNotEqualTo _query) then {_draftSearchCtrl ctrlSetText _query};

private _setComboPlaceholder = {
 params ["_idc","_label","_tooltip"];
 private _ctrl=_display displayCtrl _idc; lbClear _ctrl; private _idx=_ctrl lbAdd _label; _ctrl lbSetData [_idx,""]; _ctrl lbSetTooltip [_idx,_tooltip]; _ctrl lbSetCurSel _idx; _ctrl ctrlSetTooltip _tooltip; _ctrl ctrlEnable false;
};
private _populateCompatibilityCombo = {
 params ["_idc","_selector","_tooltip"];
 private _ctrl=_display displayCtrl _idc; lbClear _ctrl; private _selectedIndex=_selector getOrDefault ["selectedIndex",-1]; private _options=_selector getOrDefault ["options",[]];
 {private _idx=_ctrl lbAdd (_x getOrDefault ["displayName",_x getOrDefault ["className",""]]); private _className=_x getOrDefault ["className",""]; _ctrl lbSetData [_idx,_className]; _ctrl lbSetTooltip [_idx,if (_className isEqualTo "") then {_tooltip+" | Nenhum"} else {format ["%1 | Classe: %2",_tooltip,_className]}];} forEach _options;
 if (_selectedIndex<0 || {_selectedIndex>=count _options}) then {_selectedIndex=0}; if ((count _options)>0) then {_ctrl lbSetCurSel _selectedIndex}; _ctrl ctrlSetTooltip _tooltip; _ctrl ctrlEnable ((count _options)>0);
};

private _kit=createHashMap; private _draft=createHashMap; private _compat=createHashMap; private _compatCode="NOT_REQUESTED"; private _weaponInfo=createHashMap;
if (_selectedKitId isNotEqualTo "") then {
 private _kitR=[_selectedKitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 if (_kitR get "success") then {_kit=(_kitR get "data") get "kit"};
};
if ((count _kit)>0) then {
 private _draftR=[_selectedKitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 if (_draftR get "success") then {_draft=(_draftR get "data") get "draft"};
 private _recipe=if ((count _draft)>0) then {_draft getOrDefault ["recipe",createHashMap]} else {_kit getOrDefault ["recipe",createHashMap]};
 private _cfg=_recipe getOrDefault ["configuration",createHashMap]; private _weaponClass=_cfg getOrDefault ["weaponClass",""];
 if (_weaponClass isNotEqualTo "") then {
  private _infoR=[_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo; if (_infoR get "success") then {_weaponInfo=(_infoR get "data") get "info"};
  private _compatR=[_weaponClass,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel; _compatCode=_compatR getOrDefault ["code","UNKNOWN"]; if (_compatR get "success") then {_compat=(_compatR get "data") get "model"};
 };
};

private _alteredRowBg = [1.0,0.76,0.28,0.18];
private _clearRowBg = [0,0,0,0];
private _normalButtonBg = [0,0,0,0];
private _normalComboBg = [0.08,0.11,0.12,0.78];
private _changedMap = createHashMapFromArray [["weaponClass",false],["optic",false],["muzzle",false],["pointer",false],["bipod",false],["magazineClass",false]];
private _changedFields = [];
private _effectiveDirtyForState = false;
if ((count _draft)>0) then {
 private _changedR = [_draft] call ServoPeregrino_Organizador_Weapons_fnc_getDraftChangedFields;
 if (_changedR getOrDefault ["success",false]) then {
  _changedMap = ((_changedR get "data") getOrDefault ["changed",_changedMap]);
  _changedFields = ((_changedR get "data") getOrDefault ["fields",[]]);
 };
};
private _paintChangedRow = {
 params ["_bgIdc","_valueIdc","_field","_normalValueBg"];
 private _changed = _changedMap getOrDefault [_field,false];
 (_display displayCtrl _bgIdc) ctrlSetBackgroundColor (if (_changed) then {_alteredRowBg} else {_clearRowBg});
 (_display displayCtrl _valueIdc) ctrlSetBackgroundColor (if (_changed) then {[1.0,0.76,0.28,0.22]} else {_normalValueBg});
};
// Always clear semantic highlighting before applying the current Draft diff.
{(_display displayCtrl _x) ctrlSetBackgroundColor _clearRowBg} forEach [2060,2061,2062,2063,2064,2065];
(_display displayCtrl 2021) ctrlSetBackgroundColor _normalButtonBg;
{(_display displayCtrl _x) ctrlSetBackgroundColor _normalComboBg} forEach [2023,2025,2027,2029,2031];

if ((count _kit) isEqualTo 0) then {
 if (_pendingNew) then {
  private _nameCtrl=_display displayCtrl 2001;
  private _pendingName=_state getOrDefault ["pendingNewName","Novo Kit"];
  private _nameEditing=_state getOrDefault ["draftNameEditing",false];
  private _nameInput=_state getOrDefault ["draftNameInput",""];
  if (_nameEditing) then {
   if ((ctrlText _nameCtrl) isNotEqualTo _nameInput) then {_nameCtrl ctrlSetText _nameInput};
  } else {
   if ((ctrlText _nameCtrl) isNotEqualTo _pendingName) then {_nameCtrl ctrlSetText _pendingName};
  };
  _nameCtrl ctrlEnable true;
  (_display displayCtrl 2002) ctrlSetText "NOVO"; (_display displayCtrl 2002) ctrlSetTextColor [0.35,0.78,1.0,1]; (_display displayCtrl 2002) ctrlSetTooltip "Novo rascunho aguardando arma-base.";
  (_display displayCtrl 2003) ctrlSetText ""; (_display displayCtrl 2003) ctrlShow false;
  (_display displayCtrl 2010) ctrlSetText ""; (_display displayCtrl 2021) ctrlSetText "Aguardando arma do Catálogo"; (_display displayCtrl 2032) ctrlSetText "-"; (_display displayCtrl 2021) ctrlEnable false;
  {[_x,"—","Envie primeiro uma ARMA do Catálogo para habilitar compatibilidade."] call _setComboPlaceholder} forEach [2023,2025,2027,2029,2031];
  (_display displayCtrl 2140) ctrlEnable true; (_display displayCtrl 2141) ctrlEnable false; (_display displayCtrl 2142) ctrlEnable false; (_display displayCtrl 2143) ctrlEnable false;
  (_display displayCtrl 1122) ctrlEnable false; (_display displayCtrl 1123) ctrlEnable false; (_display displayCtrl 1124) ctrlEnable false;
  (_display displayCtrl 2040) ctrlSetStructuredText parseText "<t color='#CDE7E1'>NOVO RASCUNHO</t><br/><br/><t color='#8FB7B0'>Escolha uma ARMA no Catálogo e use ← / EQUIPAR NO RASCUNHO.</t><br/>Nenhum WeaponKit inválido foi criado.";
 } else {
  (_display displayCtrl 2001) ctrlSetText "Nenhum kit selecionado"; (_display displayCtrl 2001) ctrlEnable false;
  (_display displayCtrl 2002) ctrlSetText "SEM KIT"; (_display displayCtrl 2002) ctrlSetTextColor [0.70,0.78,0.77,1]; (_display displayCtrl 2003) ctrlSetText ""; (_display displayCtrl 2003) ctrlShow false; (_display displayCtrl 2010) ctrlSetText ""; (_display displayCtrl 2021) ctrlSetText "Nenhuma"; (_display displayCtrl 2032) ctrlSetText "-"; (_display displayCtrl 2021) ctrlEnable false;
  {[_x,"—","Selecione um WeaponKit ou use NOVO."] call _setComboPlaceholder} forEach [2023,2025,2027,2029,2031];
  {(_display displayCtrl _x) ctrlEnable false} forEach [2140,2141,2142,2143,1122,1123,1124];
  (_display displayCtrl 2040) ctrlSetStructuredText parseText "<t color='#8FAAA4'>Selecione um kit em MEUS KITS DE ARMAS ou use NOVO.</t>";
 };
} else {
 private _dirty=_draft getOrDefault ["dirty",false]; private _recipe=if ((count _draft)>0) then {_draft getOrDefault ["recipe",createHashMap]} else {_kit getOrDefault ["recipe",createHashMap]}; private _cfg=_recipe getOrDefault ["configuration",createHashMap]; private _weaponClass=_cfg getOrDefault ["weaponClass",""];
 private _weaponName=_weaponInfo getOrDefault ["displayName",_weaponClass]; private _picture=_weaponInfo getOrDefault ["picture",if (isClass (configFile >> "CfgWeapons" >> _weaponClass)) then {getText (configFile >> "CfgWeapons" >> _weaponClass >> "picture")} else {""}];
 private _nameCtrl=_display displayCtrl 2001;
 private _nameEditing=_state getOrDefault ["draftNameEditing",false];
 private _nameInput=_state getOrDefault ["draftNameInput",""];
 private _savedKitName=_kit getOrDefault ["name","Sem nome"];
 if (_nameEditing) then {
  if ((ctrlText _nameCtrl) isNotEqualTo _nameInput) then {_nameCtrl ctrlSetText _nameInput};
 } else {
  if ((ctrlText _nameCtrl) isNotEqualTo _savedKitName) then {_nameCtrl ctrlSetText _savedKitName};
 };
 _nameCtrl ctrlEnable true;
 private _nameDirty = _nameEditing && {_nameInput isNotEqualTo _savedKitName};
 private _effectiveDirty = _dirty || {_nameDirty};
 _effectiveDirtyForState = _effectiveDirty;
 private _status=if (_isNew) then {"NOVO"} else {if (_effectiveDirty) then {"ALTERADO"} else {"SALVO"}};
 private _statusColor=if (_isNew) then {[0.35,0.78,1.0,1]} else {if (_effectiveDirty) then {[1.0,0.76,0.28,1]} else {[0.45,0.88,0.69,1]}};
 (_display displayCtrl 2002) ctrlSetText _status; (_display displayCtrl 2002) ctrlSetTextColor _statusColor;
 (_display displayCtrl 2002) ctrlSetTooltip (if (_isNew) then {"WeaponKit criado a partir do Catálogo; use SALVAR para confirmar nome/Recipe."} else {if (_dirty) then {"Rascunho diferente do WeaponKit salvo."} else {"Rascunho igual ao WeaponKit salvo."}});
 (_display displayCtrl 2003) ctrlSetText ""; (_display displayCtrl 2003) ctrlShow false; (_display displayCtrl 2010) ctrlSetText _picture; (_display displayCtrl 2021) ctrlSetText _weaponName; (_display displayCtrl 2032) ctrlSetText _weaponClass; (_display displayCtrl 2021) ctrlEnable true;
 [2060,2021,"weaponClass",_normalButtonBg] call _paintChangedRow;
 [2061,2023,"optic",_normalComboBg] call _paintChangedRow;
 [2062,2025,"muzzle",_normalComboBg] call _paintChangedRow;
 [2063,2027,"pointer",_normalComboBg] call _paintChangedRow;
 [2064,2029,"bipod",_normalComboBg] call _paintChangedRow;
 [2065,2031,"magazineClass",_normalComboBg] call _paintChangedRow;
 (_display displayCtrl 2140) ctrlEnable (_effectiveDirty || {_isNew}); (_display displayCtrl 2141) ctrlEnable (_effectiveDirty || {_isNew}); (_display displayCtrl 2142) ctrlEnable true; (_display displayCtrl 2143) ctrlEnable true;
 {(_display displayCtrl _x) ctrlEnable true} forEach [1122,1123,1124];
 (_display displayCtrl 2021) ctrlSetTooltip format ["%1 | Classe: %2 | Origem: %3",_weaponName,_weaponClass,_weaponInfo getOrDefault ["originLabel","Origem não informada"]];
 if ((count _compat)>0) then {private _selectors=_compat getOrDefault ["selectors",createHashMap]; [2023,_selectors getOrDefault ["optic",createHashMap],"Miras compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2025,_selectors getOrDefault ["muzzle",createHashMap],"Acessórios de boca compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2027,_selectors getOrDefault ["pointer",createHashMap],"Apontadores compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2029,_selectors getOrDefault ["bipod",createHashMap],"Bipés/empunhaduras compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2031,_selectors getOrDefault ["magazineClass",createHashMap],"Carregadores compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo;} else {private _tip=format ["Compatibilidade indisponível: %1",_compatCode]; {[_x,"Indisponível",_tip] call _setComboPlaceholder} forEach [2023,2025,2027,2029,2031];};
 private _fieldLabels = createHashMapFromArray [["weaponClass","Arma"],["optic","Mira"],["muzzle","Boca"],["pointer","Apontador"],["bipod","Bipé/Emp."],["magazineClass","Carregador"]];
 private _changedLabels = _changedFields apply {_fieldLabels getOrDefault [_x,_x]};
 private _changedText = if ((count _changedLabels)>0) then {format ["<t color='#FFC247'>ALTERAÇÕES: %1</t><br/><br/>",_changedLabels joinString ", "]} else {"<t color='#73D6A4'>SEM ALTERAÇÕES DE EQUIPAMENTO</t><br/><br/>"};
 private _hint=format ["%1%2",_changedText,if (_isNew) then {"WeaponKit NOVO. O preview acima usa a mesma composição vertical do equipamento e está preparado para futura evolução 3D. Use SALVAR para confirmar."} else {if (_effectiveDirty) then {"Rascunho ALTERADO. Linhas âmbar indicam diferenças reais de equipamento; mudanças de nome também mantêm o estado ALTERADO até SALVAR."} else {"WeaponKit SALVO. Preview, identificação e componentes seguem a mesma hierarquia visual do CONTEÚDO DO EQUIPAMENTO."}}];
 (_display displayCtrl 2040) ctrlSetStructuredText parseText _hint;
};

// Local P2 search filters only the current ARMAS DO KIT rows. It never mutates Catalog/P4.
private _draftQueryLower = toLowerANSI _query;
private _rowDefs = [
 [2060,[2021,2032],"arma"],
 [2061,[2022,2023],"mira optic ótica"],
 [2062,[2024,2025],"boca muzzle"],
 [2063,[2026,2027],"apontador pointer laser"],
 [2064,[2028,2029],"bipé bipe empunhadura grip"],
 [2065,[2030,2031],"carregador magazine"]
];
{
 _x params ["_bgIdc","_controlIdcs","_keywords"];
 private _haystack = _keywords;
 {
  private _ctrl = _display displayCtrl _x;
  private _text = ctrlText _ctrl;
  if (_x in [2023,2025,2027,2029,2031]) then {
   private _sel = lbCurSel _ctrl;
   if (_sel >= 0) then {_text = format ["%1 %2",_ctrl lbText _sel,_ctrl lbData _sel]};
  };
  _haystack = format ["%1 %2",_haystack,_text];
 } forEach _controlIdcs;
 private _visible = _draftQueryLower isEqualTo "" || {(toLowerANSI _haystack) find _draftQueryLower >= 0};
 (_display displayCtrl _bgIdc) ctrlShow _visible;
 {(_display displayCtrl _x) ctrlShow _visible} forEach _controlIdcs;
} forEach _rowDefs;

_state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap]; private _elapsed=round ((diag_tickTime-_startedAt)*1000);
_state set ["draftChangedFields",+_changedFields]; _state set ["draftChangedFieldCount",count _changedFields]; _state set ["selectedKitName",if ((count _kit)>0) then {_kit getOrDefault ["name",""]} else {if (_pendingNew) then {_state getOrDefault ["pendingNewName",""]} else {""}}]; _state set ["selectedKitSlot",if ((count _draft)>0) then {_draft getOrDefault ["targetSlot",_kit getOrDefault ["targetSlot",""]]} else {if ((count _kit)>0) then {_kit getOrDefault ["targetSlot",""]} else {""}}]; _state set ["selectedKitDraftDirty",_effectiveDirtyForState]; _state set ["draftRefreshInProgress",false]; _state set ["draftFocusedRefreshCount",(_state getOrDefault ["draftFocusedRefreshCount",0])+1]; _state set ["lastDraftFocusedRefreshDurationMs",_elapsed]; _state set ["lastRefreshMode","DRAFT_FOCUSED"]; _state set ["lastRefreshTick",diag_tickTime]; missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

private _contextState=if (_pendingNew && {(count _kit) isEqualTo 0}) then {"NOVO"} else {if ((count _kit)>0) then {if (_isNew) then {"NOVO"} else {if (_draft getOrDefault ["dirty",false]) then {"ALTERADO"} else {"SALVO"}}} else {"-"}};
private _context=format ["Kit: %1 | Rascunho: %2 | Catálogo: %3/%4 | Equipamento: %5",if ((count _kit)>0) then {_kit getOrDefault ["name","Sem nome"]} else {if (_pendingNew) then {_state getOrDefault ["pendingNewName","Novo Kit"]} else {"Nenhum"}},_contextState,_state getOrDefault ["catalogTypeFilter","ALL"],_state getOrDefault ["catalogCategoryFilter","ALL"],[(_state getOrDefault ["equipmentSlotView","PRIMARY"])] call _slotLabel];
private _message=_state getOrDefault ["temporaryMessage",""];
private _history=_state getOrDefault ["history",[]];
private _historyText="";
{if (_historyText isNotEqualTo "") then {_historyText=_historyText+"   •   "};_historyText=_historyText+_x} forEach (_history select [((count _history)-3) max 0,(3 min (count _history))]);
[
 _display,
 [
  [5000,"CONTEXTO",_context,"#6FCBB8","#BFEADF","  •  "],
  [5001,"RESULTADO",_message,"#7EC8FF","#DFE6E6","  •  "],
  [5002,"HISTÓRICO",_historyText,"#93A7A4","#A8B7B5","  •  "]
 ]
] call ServoPeregrino_Organizador_UICommon_fnc_renderFooter;

diag_log format ["[SP_ORG] [WEAPONS] [UI_PERF] mode=DRAFT_FOCUSED reason=%1 totalMs=%2 kitId=%3 pendingNew=%4 fullRefresh=false",toUpperANSI _reason,_elapsed,_selectedKitId,_pendingNew];
[true,"WEAPONS_UI_DRAFT_FOCUSED_REFRESHED","ARMAS DO KIT atualizado sem reconstruir Catálogo/Equipamento.",createHashMapFromArray [["refreshMs",_elapsed],["kitId",_selectedKitId],["pendingNew",_pendingNew],["fullRefresh",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
