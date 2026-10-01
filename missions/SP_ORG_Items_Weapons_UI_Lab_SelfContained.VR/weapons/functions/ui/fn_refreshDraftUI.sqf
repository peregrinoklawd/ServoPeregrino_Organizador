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
private _slotLabel = {params ["_slot"];[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel};
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

if ((count _kit) isEqualTo 0) then {
 (_display displayCtrl 2001) ctrlSetText "Nenhum kit selecionado"; (_display displayCtrl 2002) ctrlSetText "SEM KIT"; (_display displayCtrl 2002) ctrlSetTextColor [0.70,0.78,0.77,1]; (_display displayCtrl 2003) ctrlSetText "Tipo: -"; (_display displayCtrl 2010) ctrlSetText ""; (_display displayCtrl 2021) ctrlSetText "Nenhuma"; (_display displayCtrl 2021) ctrlEnable false;
 {[_x,"—","Selecione um WeaponKit para consultar compatibilidade."] call _setComboPlaceholder} forEach [2023,2025,2027,2029,2031]; (_display displayCtrl 2140) ctrlEnable false; (_display displayCtrl 2141) ctrlEnable false; (_display displayCtrl 2142) ctrlEnable false; (_display displayCtrl 2001) ctrlEnable false; (_display displayCtrl 1121) ctrlEnable false; (_display displayCtrl 1122) ctrlEnable false; (_display displayCtrl 1123) ctrlEnable false; (_display displayCtrl 2040) ctrlSetStructuredText parseText "<t color='#8FAAA4'>Selecione um kit em MEUS KITS DE ARMAS.</t>";
} else {
 private _dirty=_draft getOrDefault ["dirty",false]; private _recipe=if ((count _draft)>0) then {_draft getOrDefault ["recipe",createHashMap]} else {_kit getOrDefault ["recipe",createHashMap]}; private _cfg=_recipe getOrDefault ["configuration",createHashMap]; private _weaponClass=_cfg getOrDefault ["weaponClass",""];
 private _weaponName=_weaponInfo getOrDefault ["displayName",_weaponClass]; private _picture=_weaponInfo getOrDefault ["picture",if (isClass (configFile >> "CfgWeapons" >> _weaponClass)) then {getText (configFile >> "CfgWeapons" >> _weaponClass >> "picture")} else {""}];
 // Focused draft refresh deliberately preserves the text currently typed in the name edit.
 // A full refresh (kit/context change) remains authoritative for resetting it to the saved kit name.
 (_display displayCtrl 2002) ctrlSetText (if (_dirty) then {"ALTERADO"} else {"SALVO"}); (_display displayCtrl 2002) ctrlSetTextColor (if (_dirty) then {[1.0,0.76,0.28,1]} else {[0.45,0.88,0.69,1]}); (_display displayCtrl 2002) ctrlSetTooltip (if (_dirty) then {"Rascunho diferente do WeaponKit salvo."} else {"Rascunho igual ao WeaponKit salvo."});
 (_display displayCtrl 2003) ctrlSetText format ["Tipo: %1",[(_kit getOrDefault ["targetSlot",""])] call _slotLabel]; (_display displayCtrl 2010) ctrlSetText _picture; (_display displayCtrl 2021) ctrlSetText _weaponName; (_display displayCtrl 2021) ctrlEnable true; (_display displayCtrl 2140) ctrlEnable _dirty; (_display displayCtrl 2141) ctrlEnable _dirty; (_display displayCtrl 2142) ctrlEnable true; (_display displayCtrl 2001) ctrlEnable true; (_display displayCtrl 1121) ctrlEnable true; (_display displayCtrl 1122) ctrlEnable true; (_display displayCtrl 1123) ctrlEnable true;
 (_display displayCtrl 2021) ctrlSetTooltip format ["%1 | Classe: %2 | Origem: %3",_weaponName,_weaponClass,_weaponInfo getOrDefault ["originLabel","Origem não informada"]];
 if ((count _compat)>0) then {private _selectors=_compat getOrDefault ["selectors",createHashMap]; [2023,_selectors getOrDefault ["optic",createHashMap],"Miras compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2025,_selectors getOrDefault ["muzzle",createHashMap],"Acessórios de boca compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2027,_selectors getOrDefault ["pointer",createHashMap],"Apontadores compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2029,_selectors getOrDefault ["bipod",createHashMap],"Underbarrel compatível; altera apenas o rascunho local."] call _populateCompatibilityCombo; [2031,_selectors getOrDefault ["magazineClass",createHashMap],"Carregadores compatíveis; altera apenas o rascunho local."] call _populateCompatibilityCombo;} else {private _tip=format ["Compatibilidade indisponível: %1",_compatCode]; {[_x,"Indisponível",_tip] call _setComboPlaceholder} forEach [2023,2025,2027,2029,2031];};
 private _hint=format ["<t color='#CDE7E1'>%1</t><br/><t color='#8FB7B0'>Classe: %2</t><br/><br/>%3",[_weaponName] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText,[_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText,if (_dirty) then {"Rascunho local ALTERADO. DESCARTAR restaura o kit salvo; SALVAR persiste no repositório desta sessão; SALVAR COMO NOVO cria outro kit."} else {"Rascunho igual ao kit salvo. Selecione acessórios compatíveis ou outra arma do mesmo tipo; edite o nome acima para RENOMEAR/SALVAR COMO NOVO."}]; (_display displayCtrl 2040) ctrlSetStructuredText parseText _hint;
};

_state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap]; private _elapsed=round ((diag_tickTime-_startedAt)*1000);
_state set ["selectedKitName",if ((count _kit)>0) then {_kit getOrDefault ["name",""]} else {""}]; _state set ["selectedKitSlot",if ((count _kit)>0) then {_kit getOrDefault ["targetSlot",""]} else {""}]; _state set ["selectedKitDraftDirty",if ((count _draft)>0) then {_draft getOrDefault ["dirty",false]} else {false}]; _state set ["draftRefreshInProgress",false]; _state set ["draftFocusedRefreshCount",(_state getOrDefault ["draftFocusedRefreshCount",0])+1]; _state set ["lastDraftFocusedRefreshDurationMs",_elapsed]; _state set ["lastRefreshMode","DRAFT_FOCUSED"]; _state set ["lastRefreshTick",diag_tickTime]; missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

private _context=format ["Kit: %1 | Tipo: %2 | Rascunho: %3 | Catálogo: %4/%5 | Equipamento: %6",if ((count _kit)>0) then {_kit getOrDefault ["name","Sem nome"]} else {"Nenhum"},if ((count _kit)>0) then {[(_kit getOrDefault ["targetSlot",""])] call _slotLabel} else {"-"},if ((count _kit)>0) then {if (_draft getOrDefault ["dirty",false]) then {"ALTERADO"} else {"SALVO"}} else {"-"},_state getOrDefault ["catalogTypeFilter","ALL"],_state getOrDefault ["catalogCategoryFilter","ALL"],[(_state getOrDefault ["equipmentSlotView","PRIMARY"])] call _slotLabel];
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#BFEADF'>  •  %1</t>",[_context] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText];
private _message=_state getOrDefault ["temporaryMessage",""]; private _history=_state getOrDefault ["history",[]]; private _historyText=""; {if (_historyText isNotEqualTo "") then {_historyText=_historyText+"   •   "};_historyText=_historyText+_x} forEach (_history select [((count _history)-3) max 0,(3 min (count _history))]); (_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='#7EC8FF'>RESULTADO</t><t color='#DFE6E6'>  •  %1</t>",[_message] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText]; (_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",[_historyText] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText];

diag_log format ["[SP_ORG] [WEAPONS] [UI_PERF] mode=DRAFT_FOCUSED reason=%1 totalMs=%2 kitId=%3 fullRefresh=false",toUpperANSI _reason,_elapsed,_selectedKitId];
[true,"WEAPONS_UI_DRAFT_FOCUSED_REFRESHED","Rascunho atualizado sem reconstruir Catálogo/Equipamento.",createHashMapFromArray [["refreshMs",_elapsed],["kitId",_selectedKitId],["fullRefresh",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
