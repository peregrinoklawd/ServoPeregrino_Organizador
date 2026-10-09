#include "..\..\script_version.hpp"
// E1 R2: Convert an OBSERVED physical weapon to a canonical, safe WeaponRecipe.
// When a modded physical loadout contains components that the current CfgWeapons
// compatibility data rejects, omit only those specific components, REPORT every
// omission, and keep strict domain validators untouched. No inventory mutation.
params [
 ["_observedCfg",createHashMap,[createHashMap]],
 ["_observedMagazine","",[""]]
];
private _cfg=[_observedCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _weaponClass=_cfg getOrDefault ["weaponClass",""];
private _omissions=[];
private _semantic=[_cfg] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_semantic getOrDefault ["success",false]) then {
 private _data=_semantic getOrDefault ["data",createHashMap];
 private _fields=_data getOrDefault ["invalidFields",[]];
 // Reject unrelated structural, missing-weapon or unknown compatibility failures.
 // Never silently strip arbitrary values to turn an invalid weapon into a kit.
 if !((_semantic getOrDefault ["code",""]) isEqualTo "WEAPONS_CONFIGURATION_INCOMPATIBLE"
  && {_fields isEqualType []}
  && {count _fields>0}
  && {(_fields findIf {!(_x in ["muzzle","pointer","optic","bipod"])})<0}) exitWith {};
 {
  private _field=_x;
  private _original=_cfg getOrDefault [_field,""];
  if (_original isNotEqualTo "") then {
   _omissions pushBack (createHashMapFromArray [
    ["field",_field],
    ["className",_original],
    ["reason","ENGINE_ATTACHMENT_INCOMPATIBLE"]
   ]);
   _cfg set [_field,""];
  };
 } forEach _fields;
};
// Errors other than the strictly identified accessory mismatch must be rejected.
private _safeSemantic=[_cfg] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_safeSemantic getOrDefault ["success",false]) exitWith {
 [false,"WEAPONS_UI_CAPTURE_WEAPON_CONFIGURATION_UNSUPPORTED",
  "A configuração da arma equipada não pôde ser convertida com segurança. Nenhum item foi copiado.",createHashMapFromArray [
   ["weaponClass",_weaponClass],
   ["observedConfiguration",[_observedCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
   ["originalSemanticCode",_semantic getOrDefault ["code",""]],
   ["originalInvalidFields",(_semantic getOrDefault ["data",createHashMap]) getOrDefault ["invalidFields",[]]],
   ["safeSemanticCode",_safeSemantic getOrDefault ["code",""]],
   ["safeInvalidFields",(_safeSemantic getOrDefault ["data",createHashMap]) getOrDefault ["invalidFields",[]]]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipeR=[_cfg,_observedMagazine] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
// The installed magazine may similarly be rejected by current modded CfgWeapons.
// Keep the weapon and attachments; exclude only the rejected magazine class.
if !(_recipeR getOrDefault ["success",false]) then {
 if ((_recipeR getOrDefault ["code",""]) isEqualTo "WEAPONS_RECIPE_MAGAZINE_INCOMPATIBLE" && {_observedMagazine isNotEqualTo ""}) then {
  private _withoutMagazine=[_cfg,""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
  if (_withoutMagazine getOrDefault ["success",false]) then {
   _omissions pushBack (createHashMapFromArray [
    ["field","magazineClass"],
    ["className",_observedMagazine],
    ["reason","ENGINE_MAGAZINE_INCOMPATIBLE"]
   ]);
   _recipeR=_withoutMagazine;
  };
 };
};
if !(_recipeR getOrDefault ["success",false]) exitWith {
 [false,"WEAPONS_UI_CAPTURE_RECIPE_UNSUPPORTED",
  "A arma equipada não pôde ser convertida em uma Recipe segura. Nenhum rascunho foi alterado.",createHashMapFromArray [
   ["weaponClass",_weaponClass],
   ["recipeCode",_recipeR getOrDefault ["code",""]],
   ["recipeDiagnostics",_recipeR getOrDefault ["data",createHashMap]],
   ["omissions",_omissions]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _recipe=(_recipeR get "data") get "recipe";
[true,if (count _omissions>0) then {"WEAPONS_UI_OBSERVED_CAPTURE_PARTIAL"} else {"WEAPONS_UI_OBSERVED_CAPTURE_EXACT"},
 if (count _omissions>0) then {
  "Arma capturada com ressalvas. Acessórios ou carregador incompatíveis foram identificados e não copiados para o rascunho."
 } else {
  "Arma capturada integralmente como Recipe compatível."
 },
 createHashMapFromArray [
  ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["omissions",[_omissions] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["partial",count _omissions>0],
  ["weaponClass",_weaponClass],
  ["observedConfiguration",[_observedCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["observedMagazine",_observedMagazine]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
