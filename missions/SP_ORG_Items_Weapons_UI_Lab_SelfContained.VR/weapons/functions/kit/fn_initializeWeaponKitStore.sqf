#include "..\..\script_version.hpp"
private _old = missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap];
if ((_old getOrDefault ["schemaVersion",""]) isEqualTo "0.5-kit-store-candidate") exitWith {
 [true,"WEAPONS_KIT_STORE_ALREADY_INITIALIZED","Session-local WeaponKit store preserved.",createHashMapFromArray [
  ["count",count (_old get "kits")],
  ["mode","SESSION_LOCAL_CANDIDATE"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _now = systemTimeUTC;
private _session = format ["%1-%2-%3-%4-%5-%6-%7-%8",
 _now select 0,_now select 1,_now select 2,_now select 3,
 _now select 4,floor (_now select 5),clientOwner,floor (diag_tickTime * 1000)
];

missionNamespace setVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMapFromArray [
 ["schemaVersion","0.5-kit-store-candidate"],
 ["session",_session],
 ["counter",0],
 ["kits",createHashMap]
]];

[true,"WEAPONS_KIT_STORE_INITIALIZED","Session-local WeaponKit repository initialized. Persistence and multiplayer authority are deferred.",createHashMapFromArray [
 ["mode","SESSION_LOCAL_CANDIDATE"],
 ["session",_session]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
