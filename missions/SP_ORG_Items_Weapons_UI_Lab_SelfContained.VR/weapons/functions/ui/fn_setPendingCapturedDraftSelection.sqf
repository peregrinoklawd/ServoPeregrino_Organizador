#include "..\..\script_version.hpp"
// Author pending captured draft before its first explicit SAVE.
// Does not create, rename, delete or update any WeaponKit repository entry.
params [["_field","",[""]],["_className","",[""]]];
private _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _draft=_state getOrDefault ["pendingCapturedDraft",createHashMap];
if !(_state getOrDefault ["pendingNewKit",false] && {(_state getOrDefault ["selectedKitId",""]) isEqualTo ""} && {count _draft>0}) exitWith {
 [false,"WEAPONS_UI_PENDING_CAPTURE_MISSING","Não existe rascunho capturado aguardando SALVAR."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _fieldName=if (_field isEqualTo "magazineClass") then {"magazineClass"} else {toLowerANSI _field};
if !(_fieldName in ["optic","muzzle","pointer","bipod","magazineClass"]) exitWith {
 [false,"WEAPONS_UI_DRAFT_FIELD_INVALID","Campo incompatível com a Recipe."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _recipe=[_draft get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _configuration=[_recipe get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _selectorsR=[_configuration getOrDefault ["weaponClass",""],_recipe] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
if !(_selectorsR getOrDefault ["success",false]) exitWith {_selectorsR};
private _selector=(((_selectorsR get "data") get "model") getOrDefault ["selectors",createHashMap]) getOrDefault [_fieldName,createHashMap];
private _options=_selector getOrDefault ["options",[]];
private _at=_options findIf {(toLowerANSI (_x getOrDefault ["className",""])) isEqualTo (toLowerANSI _className)};
if (_at<0) exitWith {
 [false,"WEAPONS_UI_DRAFT_SELECTION_INCOMPATIBLE","A peça selecionada não é compatível com a arma capturada."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _canonical=(_options select _at) getOrDefault ["className",""];
if (_fieldName isEqualTo "magazineClass") then {
 _recipe set ["magazineClass",_canonical];
} else {
 _configuration set [_fieldName,_canonical];
 _recipe set ["configuration",_configuration];
};
private _valid=[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};
private _updated=[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_updated set ["recipe",_recipe];
_updated set ["dirty",true];
_updated set ["revision",(_draft getOrDefault ["revision",0])+1];
_updated set ["updatedAtTick",diag_tickTime];
_state set ["pendingCapturedDraft",_updated];
_state set ["selectedKitDraftDirty",true];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
[true,"WEAPONS_UI_PENDING_CAPTURE_SELECTION_UPDATED","Rascunho capturado atualizado, sem salvar nem equipar.",createHashMapFromArray [
 ["draft",[_updated] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["field",_fieldName],["className",_canonical],["dirty",true],
 ["savedKitMutation",false],["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
