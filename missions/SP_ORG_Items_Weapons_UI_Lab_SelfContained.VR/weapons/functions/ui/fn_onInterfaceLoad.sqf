#include "..\..\script_version.hpp"
params [["_display",displayNull,[displayNull]]];
disableSerialization;
if (isNull _display) exitWith {false};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};
_state set ["open",true];
_state set ["openedAtTick",diag_tickTime];
_state set ["kitQuery",""];
_state set ["kitTypeFilter","ALL"];
_state set ["catalogQuery",""];
_state set ["catalogTypeFilter","ALL"];
_state set ["catalogCategoryFilter","ALL"];
_state set ["catalogOffset",0];
_state set ["selectedCatalogClass",""];
_state set ["selectedCatalogKind",""];
_state set ["equipmentSlotView","PRIMARY"];
_state set ["lastFocus","KITS"];
_state set ["refreshInProgress",false];
_state set ["catalogRefreshInProgress",false];
_state set ["draftRefreshInProgress",false];
_state set ["equipmentRefreshInProgress",false];
_state set ["initialSyncComplete",false];
_state set ["initialSyncRows",-1];
_state set ["initialSyncExpectedRows",-1];
_state set ["initialSyncElapsedMs",-1];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
(_display displayCtrl 1107) ctrlEnable false;
["Interface 0.6-E R1 aberta. Authoring session-local habilitado: Novo/Renomear/Duplicar/Excluir/Salvar/Salvar como novo; aplicação física continua em 0.7.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;
[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
[_display,diag_tickTime] spawn {
 params ["_openedDisplay","_syncStarted"];
 uiSleep 0.01;
 private _deadline = diag_tickTime + 3;
 waitUntil {
  uiSleep 0.01;
  if (isNull _openedDisplay || {!(_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD))}) exitWith {true};
  private _waitState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  !(_waitState getOrDefault ["refreshInProgress",false]) || {diag_tickTime >= _deadline}
 };
 if (!isNull _openedDisplay && {_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)}) then {
  private _syncState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  private _repoResult = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  private _expectedRows = if (_repoResult get "success") then {count (((_repoResult get "data") getOrDefault ["kits",[]]))} else {-1};
  private _rowsBeforeRecovery = lbSize (_openedDisplay displayCtrl 1110);
  private _canonicalOpening = ((_syncState getOrDefault ["kitTypeFilter",""]) isEqualTo "ALL") && {(_syncState getOrDefault ["kitQuery",""]) isEqualTo ""};
  if (_canonicalOpening && {_expectedRows >= 0} && {_rowsBeforeRecovery isNotEqualTo _expectedRows}) then {
   private _idleDeadline = diag_tickTime + 3;
   waitUntil {
    uiSleep 0.01;
    private _idleState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
    !(_idleState getOrDefault ["refreshInProgress",false]) || {diag_tickTime >= _idleDeadline}
   };
   private _beforeRecoveryState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
   if !(_beforeRecoveryState getOrDefault ["refreshInProgress",false]) then {[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;};
  };
  private _finalState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  private _finalRows = lbSize (_openedDisplay displayCtrl 1110);
  _finalState set ["initialSyncComplete",true];
  _finalState set ["initialSyncRows",_finalRows];
  _finalState set ["initialSyncExpectedRows",_expectedRows];
  _finalState set ["initialSyncElapsedMs",round ((diag_tickTime - _syncStarted) * 1000)];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_finalState];
  diag_log format ["[SP_ORG] [WEAPONS] [UI_INITIAL_SYNC_0_6_E_R1] filter=%1 query=%2 rows=%3 expectedRows=%4 elapsedMs=%5 canonical=%6",_finalState getOrDefault ["kitTypeFilter",""],_finalState getOrDefault ["kitQuery",""],_finalRows,_expectedRows,_finalState getOrDefault ["initialSyncElapsedMs",-1],_canonicalOpening];
 };
};
true
