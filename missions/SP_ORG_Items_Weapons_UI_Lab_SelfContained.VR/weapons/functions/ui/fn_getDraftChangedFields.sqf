#include "..\..\script_version.hpp"
params [["_draft",createHashMap,[createHashMap]]];

private _changed = createHashMapFromArray [
 ["weaponClass",false],
 ["optic",false],
 ["muzzle",false],
 ["pointer",false],
 ["bipod",false],
 ["magazineClass",false]
];
private _fields = [];

if ((count _draft) isEqualTo 0) exitWith {
 [true,"WEAPONS_UI_DRAFT_CHANGED_FIELDS","No draft; no changed equipment fields.",createHashMapFromArray [
  ["changed",_changed],["fields",_fields],["count",0]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _recipe = _draft getOrDefault ["recipe",createHashMap];
private _baseCfg = _baseRecipe getOrDefault ["configuration",createHashMap];
private _cfg = _recipe getOrDefault ["configuration",createHashMap];

{
 private _field = _x;
 private _a = toLowerANSI (_baseCfg getOrDefault [_field,""]);
 private _b = toLowerANSI (_cfg getOrDefault [_field,""]);
 private _different = _a isNotEqualTo _b;
 _changed set [_field,_different];
 if (_different) then {_fields pushBack _field};
} forEach ["weaponClass","optic","muzzle","pointer","bipod"];

private _baseMag = toLowerANSI (_baseRecipe getOrDefault ["magazineClass",""]);
private _mag = toLowerANSI (_recipe getOrDefault ["magazineClass",""]);
private _magDifferent = _baseMag isNotEqualTo _mag;
_changed set ["magazineClass",_magDifferent];
if (_magDifferent) then {_fields pushBack "magazineClass"};

[true,"WEAPONS_UI_DRAFT_CHANGED_FIELDS","Draft equipment fields compared against the saved/base Recipe snapshot.",createHashMapFromArray [
 ["changed",_changed],
 ["fields",_fields],
 ["count",count _fields]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
