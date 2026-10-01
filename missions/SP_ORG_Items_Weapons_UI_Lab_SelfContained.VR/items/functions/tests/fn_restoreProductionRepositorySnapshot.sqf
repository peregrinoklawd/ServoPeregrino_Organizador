#include "..\..\script_version.hpp"
params [["_snapshot",createHashMap,[createHashMap]]];
private _primaryKey=_snapshot getOrDefault ["primaryKey","ServoPeregrino_Organizador_Items_storage_v1"];
private _lastGoodKey=_snapshot getOrDefault ["lastGoodKey","ServoPeregrino_Organizador_Items_storage_lastGood_v1"];
if (_snapshot getOrDefault ["primaryPresent",false]) then {
    profileNamespace setVariable [_primaryKey,[(_snapshot getOrDefault ["primary",[]])] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
} else {
    profileNamespace setVariable [_primaryKey,nil];
};
if (_snapshot getOrDefault ["lastGoodPresent",false]) then {
    profileNamespace setVariable [_lastGoodKey,[(_snapshot getOrDefault ["lastGood",[]])] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
} else {
    profileNamespace setVariable [_lastGoodKey,nil];
};
saveProfileNamespace;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR,""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR,createHashMap];
private _reload=[] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
createHashMapFromArray [["restored",true],["reload",_reload]]
