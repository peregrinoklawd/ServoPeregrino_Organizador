params [["_plan",false]];

if !(_plan isEqualType createHashMap) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_TYPE_INVALID","ApplicationPlan must be a HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_plan getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-plan-candidate") exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_SCHEMA_INVALID","Unsupported ApplicationPlan schema."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _slot = _plan getOrDefault ["targetSlot",""];
private _index = ["PRIMARY","SECONDARY","HANDGUN"] find _slot;
if (_index < 0 || {!((_plan getOrDefault ["targetSlotIndex",-1]) isEqualTo _index)}) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_SLOT_INVALID","ApplicationPlan target slot/index pair is invalid."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_plan getOrDefault ["strategy",""]) isEqualTo "FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_CANDIDATE") exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_STRATEGY_INVALID","0.7-A accepts only the full-loadout clone candidate strategy."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_plan getOrDefault ["fullMagazines",true]) isEqualTo false) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_FULLMAGAZINES_INVALID","0.7-A requires future setUnitLoadout fullMagazines=false semantics."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_plan getOrDefault ["dryRunOnly",false]) && {!(_plan getOrDefault ["mutationAuthorized",true])}) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_MUTATION_FORBIDDEN","0.7-A is dry-run only and cannot authorize physical mutation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _operation = _plan getOrDefault ["operation",""];
if !(_operation in ["INSERT","REPLACE","RECONFIGURE","NO_OP"]) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_OPERATION_INVALID","Unsupported application operation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipe = _plan getOrDefault ["desiredRecipe",false];
private _recipeValid = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_recipeValid getOrDefault ["success",false]) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_RECIPE_INVALID","ApplicationPlan desired Recipe is not semantically valid.",createHashMapFromArray [["nestedCode",_recipeValid getOrDefault ["code",""]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _configuration = _plan getOrDefault ["desiredConfiguration",false];
private _cfgValid = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_cfgValid getOrDefault ["success",false]) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_CONFIGURATION_INVALID","ApplicationPlan desired configuration is not semantically valid.",createHashMapFromArray [["nestedCode",_cfgValid getOrDefault ["code",""]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipeCfg = _recipe get "configuration";
private _cfgCompare = [_recipeCfg,_configuration] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponConfigurations;
if !(_cfgCompare getOrDefault ["success",false] && {((_cfgCompare get "data") getOrDefault ["equal",false])}) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_CONFIGURATION_DRIFT","ApplicationPlan configuration must equal its nested Recipe configuration."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_plan getOrDefault ["desiredMagazineClass",""]) isEqualTo (_recipe getOrDefault ["magazineClass",""])) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_MAGAZINE_DRIFT","ApplicationPlan magazine must equal its nested Recipe magazine."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _weaponClass = _configuration getOrDefault ["weaponClass",""];
private _type = getNumber (configFile >> "CfgWeapons" >> _weaponClass >> "type");
private _expectedSlot = switch (_type) do {
 case 1: {"PRIMARY"};
 case 2: {"HANDGUN"};
 case 4: {"SECONDARY"};
 default {""};
};
if (_expectedSlot isEqualTo "" || {!(_expectedSlot isEqualTo _slot)}) exitWith {
 [false,"WEAPONS_APPLICATION_PLAN_SLOT_RECIPE_MISMATCH","Plan target slot must match the desired weapon engine category."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_APPLICATION_PLAN_VALID","ApplicationPlan passed 0.7-A pre-validation; physical mutation remains forbidden.",createHashMapFromArray [
 ["targetSlot",_slot],
 ["targetSlotIndex",_index],
 ["operation",_operation]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
