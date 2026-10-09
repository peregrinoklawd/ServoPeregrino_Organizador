#include "..\..\script_version.hpp"
params [["_desiredName","",[""]]];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _className = _state getOrDefault ["selectedCatalogClass",""];
private _kind = toUpperANSI (_state getOrDefault ["selectedCatalogKind",""]);
private _kitId = _state getOrDefault ["selectedKitId",""];
private _pending = _state getOrDefault ["pendingNewKit",false];

if (_className isEqualTo "" || {_kind isEqualTo ""}) exitWith {
 [false,"WEAPONS_UI_CATALOG_SELECTION_REQUIRED","Selecione uma arma ou acessório no Catálogo de Armas."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// When a physical capture has staged a truly unsaved NEW kit, author this
// transient Recipe directly; the session repository must stay untouched.
if (_kitId isEqualTo "" && {_pending} && {count (_state getOrDefault ["pendingCapturedDraft",createHashMap])>0}) exitWith {
 private _current=_state get "pendingCapturedDraft";
 if (_kind isEqualTo "WEAPON") exitWith {
  private _entryR=[_className,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
  if !(_entryR getOrDefault ["success",false]) exitWith {_entryR};
  private _entry=(_entryR get "data") get "entry";
  private _slot=toUpperANSI (_entry getOrDefault ["category",""]);
  if !(_slot in ["PRIMARY","HANDGUN","SECONDARY"]) exitWith {
   [false,"WEAPONS_UI_DRAFT_WEAPON_TYPE_UNSUPPORTED","Esta arma não é suportada nos kits de Weapons."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
  };
  private _cfgR=[_entry getOrDefault ["weaponClass",_className]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
  if !(_cfgR getOrDefault ["success",false]) exitWith {_cfgR};
  private _recipeR=[(_cfgR get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
  if !(_recipeR getOrDefault ["success",false]) exitWith {_recipeR};
  private _updated=[_current] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  _updated set ["recipe",(_recipeR get "data") get "recipe"];
  _updated set ["targetSlot",_slot];
  _updated set ["dirty",true];
  _updated set ["revision",(_current getOrDefault ["revision",0])+1];
  _updated set ["updatedAtTick",diag_tickTime];
  _state set ["pendingCapturedDraft",_updated];
  _state set ["selectedKitDraftDirty",true];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
  [true,"WEAPONS_UI_PENDING_CAPTURE_WEAPON_UPDATED","Arma-base trocada no rascunho ainda não salvo.",createHashMapFromArray [
   ["kind",_kind],["className",_className],["sourceResult",createHashMapFromArray [["changed",true]]],
   ["loadoutMutation",false],["savedKitMutation",false]
  ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
 };
 private _field=switch _kind do {
  case "OPTIC": {"optic"};
  case "POINTER": {"pointer"};
  case "MUZZLE": {"muzzle"};
  case "BIPOD": {"bipod"};
  case "GRIP": {"bipod"};
  case "MAGAZINE": {"magazineClass"};
  default {""};
 };
 if (_field isEqualTo "") exitWith {
  [false,"WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","Esta categoria não pode ser enviada ao rascunho."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
 };
 private _changeR=[_field,_className] call ServoPeregrino_Organizador_Weapons_fnc_setPendingCapturedDraftSelection;
 if !(_changeR getOrDefault ["success",false]) exitWith {_changeR};
 [true,"WEAPONS_UI_PENDING_CAPTURE_CATALOG_UPDATED","Seleção adicionada ao rascunho capturado, ainda sem salvar.",createHashMapFromArray [
  ["kind",_kind],["className",_className],
  ["sourceResult",createHashMapFromArray [["changed",true]]],
  ["loadoutMutation",false],["savedKitMutation",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// A weapon may always be sent to ARMAS DO KIT. If no kit exists/was selected,
 // create a new session-local kit automatically and mark it NOVO.
if (_kitId isEqualTo "") exitWith {
 if (_kind isNotEqualTo "WEAPON") exitWith {
  [false,"WEAPONS_UI_DRAFT_BASE_WEAPON_REQUIRED","Escolha primeiro uma arma no Catálogo. Ao enviá-la para ARMAS DO KIT, um novo kit será criado automaticamente."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
 };
 private _name = _desiredName;
 if (_name isEqualTo "") then {_name = _state getOrDefault ["pendingNewName",""]};
 private _createR = [_className,_name] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKitFromCatalogWeapon;
 if !(_createR get "success") exitWith {_createR};
 private _kit = (_createR get "data") get "kit";
 private _newId = _kit getOrDefault ["kitId",""];

 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 _state set ["selectedKitId",_newId];
 _state set ["previousKitIdBeforeNew",""];
 _state set ["pendingNewKit",false];
 _state set ["pendingNewName",""];
 _state set ["selectedKitIsNew",true];
 _state set ["kitTypeFilter","ALL"];
 _state set ["kitQuery",""];
 _state set ["lastFocus","DRAFT"];
 _state set ["catalogOffset",0];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 [_newId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;

 [true,"WEAPONS_UI_DRAFT_AUTO_CREATED","Novo kit criado automaticamente em ARMAS DO KIT com a arma selecionada. Revise o nome e use SALVAR quando terminar.",createHashMapFromArray [
  ["kit",[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["kind",_kind],["className",_className],["loadoutMutation",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _result = switch (_kind) do {
 case "WEAPON": {[_kitId,_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftWeapon};
 case "OPTIC": {[_kitId,"optic",_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection};
 case "POINTER": {[_kitId,"pointer",_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection};
 case "BIPOD": {[_kitId,"bipod",_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection};
 case "GRIP": {[_kitId,"bipod",_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection};
 case "MAGAZINE": {[_kitId,"magazineClass",_className] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection};
 default {[false,"WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","A seleção do catálogo não pode ser aplicada ao rascunho nesta entrega."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
};

if !(_result getOrDefault ["success",false]) exitWith {_result};
[true,"WEAPONS_UI_CATALOG_APPLIED_TO_DRAFT","Seleção do Catálogo enviada ao rascunho. Nenhuma alteração física foi executada.",createHashMapFromArray [
 ["kind",_kind],["className",_className],["kitId",_kitId],["sourceResult",_result],["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
