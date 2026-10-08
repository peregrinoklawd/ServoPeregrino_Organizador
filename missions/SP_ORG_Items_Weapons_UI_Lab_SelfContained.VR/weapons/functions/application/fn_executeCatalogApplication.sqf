// Catalog intent only. The single physical engine remains applyApplicationPlan (B/C).
params [["_unit",objNull,[objNull]],["_className","",[""]],["_kind","",[""]],["_viewSlot","PRIMARY",[""]],["_labFault","",[""]]];
private _reject = {
 params ["_code","_message"];
 [false,_code,_message,createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false],["sourceKind","CATALOG_SELECTION"],["draftMutation",false],["repositoryMutation",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (isNull _unit || {!local _unit}) exitWith {["WEAPONS_APPLICATION_TARGET_NOT_LOCAL","O destino precisa ser um personagem local."] call _reject};
_kind=toUpperANSI _kind;
if (_className isEqualTo "") exitWith {["WEAPONS_UI_CATALOG_SELECTION_REQUIRED","Selecione um item no Catálogo antes de equipar."] call _reject};
private _slot=toUpperANSI _viewSlot;
private _cfg=createHashMap;
private _mag="";
private _error=createHashMap;
if (_kind isEqualTo "WEAPON") then {
 private _entryR=[_className,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
 if !(_entryR getOrDefault ["success",false]) then {_error=_entryR} else {
  private _entry=(_entryR get "data") get "entry";
  _slot=toUpperANSI (_entry getOrDefault ["category",""]);
  if !(_slot in ["PRIMARY","HANDGUN","SECONDARY"]) then {
   _error=["WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","Esta arma não tem um destino físico seguro."] call _reject;
  } else {
   private _cfgR=[_entry getOrDefault ["weaponClass",_className]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
   if !(_cfgR getOrDefault ["success",false]) then {_error=_cfgR} else {_cfg=(_cfgR get "data") get "configuration"};
  };
 };
} else {
 private _field=switch (_kind) do {
  case "OPTIC": {"optic"}; case "POINTER": {"pointer"};
  case "MUZZLE": {"muzzle"}; case "SUPPRESSOR": {"muzzle"};
  case "BIPOD": {"bipod"}; case "GRIP": {"bipod"};
  case "MAGAZINE": {"magazineClass"}; default {""};
 };
 if (_field isEqualTo "") then {_error=["WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","Esta categoria ainda não possui aplicação física segura."] call _reject} else {
  private _si=["PRIMARY","SECONDARY","HANDGUN"] find _slot;
  if (_si < 0) then {_error=["WEAPONS_UI_CATALOG_DESTINATION_INVALID","Escolha um destino no painel Equipamento."] call _reject} else {
   private _row=(getUnitLoadout _unit) param [_si,[]];
   if ((_row param [0,""]) isEqualTo "") then {_error=["WEAPONS_UI_CATALOG_EMPTY_DESTINATION","Nenhuma arma equipada neste destino."] call _reject} else {
    private _capture=[_row] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
    if !(_capture getOrDefault ["success",false]) then {_error=_capture} else {
     _cfg=[(_capture get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
     _mag=(((_capture get "data") get "loadedState") get "primaryMagazine") param [0,""];
     private _recipeR=[_cfg,_mag] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
     if !(_recipeR getOrDefault ["success",false]) then {_error=_recipeR} else {
      private _modelR=[_cfg get "weaponClass",(_recipeR get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
      if !(_modelR getOrDefault ["success",false]) then {_error=_modelR} else {
       private _selector=(((_modelR get "data") get "model") get "selectors") getOrDefault [_field,createHashMap];
       private _options=_selector getOrDefault ["options",[]];
       private _match=_options findIf {(toLowerANSI (_x getOrDefault ["className",""])) isEqualTo (toLowerANSI _className)};
       // GRIP is representable only when the engine explicitly lists it in UnderBarrelSlot.
       if (_match < 0) then {_error=["WEAPONS_UI_CATALOG_SELECTION_INCOMPATIBLE","Esse item não é compatível com a arma física visualizada."] call _reject} else {
        private _canonical=(_options select _match) get "className";
        if (_field isEqualTo "magazineClass") then {_mag=_canonical} else {_cfg set [_field,_canonical]};
       };
      };
     };
    };
   };
  };
 };
};
if (count _error > 0) exitWith {
 private _d=_error getOrDefault ["data",createHashMap];
 _d set ["failurePhase","PRE_MUTATION"];_d set ["mutationPerformed",false];_d set ["rollbackAttempted",false];_d set ["sourceKind","CATALOG_SELECTION"];
 _error set ["data",_d];_error
};
private _recipeR=[_cfg,_mag] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
if !(_recipeR getOrDefault ["success",false]) exitWith {_recipeR};
// Unsaved transient intent: no UI draft lookup and no repository authoring calls.
private _intent=createHashMapFromArray [["targetSlot",_slot],["recipe",(_recipeR get "data") get "recipe"]];
private _result=[_unit,_intent,_labFault] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
private _d=_result getOrDefault ["data",createHashMap];
_d set ["sourceKind","CATALOG_SELECTION"];_d set ["catalogClass",_className];_d set ["catalogKind",_kind];
_d set ["draftMutation",false];_d set ["repositoryMutation",false];_d set ["autosave",false];_d set ["publish",false];
_result set ["data",_d];_result
