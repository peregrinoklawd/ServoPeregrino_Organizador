#include "..\..\script_version.hpp"
params [["_display",displayNull,[displayNull]]];
disableSerialization;
if (isNull _display) exitWith {false};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};
// Every visual opening starts the shared Items-style projection in a deterministic state. Drafts remain session-local and are intentionally preserved.
// This is a UI-session reset only; it never changes WeaponKit repository content.
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

// Public WeaponKit library does not exist yet. Visible placement is intentional,
// but the control is disabled to avoid pretending the backend already exists.
(_display displayCtrl 1107) ctrlEnable false;

["Interface 0.6-F R1 aberta. UI final 0.6 ativa: NOVO aguarda arma, Catálogo envia direto ao rascunho e SALVAR confirma nome + Recipe; aplicação física continua em 0.7.","INFO",true] call ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback;

// Cold-open synchronization.
// During display onLoad, the _display handle already exists but findDisplay may still return displayNull
// until the dialog is registered by the engine. R1 called refreshInterface too early, so the first
// refresh could exit as WEAPONS_UI_NOT_OPEN and the handshake would still accept 0 kits == 0 kits.
// Keep visible loading feedback, then refresh only after findDisplay points to this exact display.
(_display displayCtrl 3122) ctrlSetText "Carregando catálogo de armas...";
(_display displayCtrl 4040) ctrlSetStructuredText parseText "<t color='#8FAAA4'>Lendo o equipamento atual...</t>";

[_display,diag_tickTime] spawn {
 params ["_openedDisplay","_syncStarted"];

 private _displayDeadline = diag_tickTime + 3;
 waitUntil {
  uiSleep 0.01;
  isNull _openedDisplay
  || {_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)}
  || {diag_tickTime >= _displayDeadline}
 };

 if (isNull _openedDisplay || {!(_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD))}) exitWith {
  diag_log "[SP_ORG] [WEAPONS] [UI_INITIAL_SYNC_HOTFIX1] display registration timeout; initial refresh not executed.";
 };

 private _initialRefresh = [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;

 private _refreshDeadline = diag_tickTime + 6;
 waitUntil {
  uiSleep 0.01;
  if (isNull _openedDisplay || {!(_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD))}) exitWith {true};
  private _waitState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  !(_waitState getOrDefault ["refreshInProgress",false]) || {diag_tickTime >= _refreshDeadline}
 };

 if (!isNull _openedDisplay && {_openedDisplay isEqualTo (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)}) then {
  private _syncState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  private _repoResult = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  private _expectedKitRows = if (_repoResult get "success") then {
   count (((_repoResult get "data") getOrDefault ["kits",[]]))
  } else {-1};

  private _kitRows = lbSize (_openedDisplay displayCtrl 1110);
  private _catalogRows = lbSize (_openedDisplay displayCtrl 3120);
  private _catalogExpected = _syncState getOrDefault ["catalogTotalFiltered",-1];
  private _equipmentText = ctrlText (_openedDisplay displayCtrl 4021);
  private _equipmentReady = !(_equipmentText isEqualTo "") && {!(_equipmentText isEqualTo "Lendo o equipamento atual...")};

  // One recovery refresh is allowed only when the opening materialization is incomplete.
  // This validates all visible data-bearing panels rather than only the kit list.
  private _needsRecovery =
   (_expectedKitRows >= 0 && {_kitRows isNotEqualTo _expectedKitRows})
   || {_catalogExpected > 0 && {_catalogRows <= 0}}
   || {!_equipmentReady};

  if (_needsRecovery) then {
   private _idleDeadline = diag_tickTime + 3;
   waitUntil {
    uiSleep 0.01;
    private _idleState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
    !(_idleState getOrDefault ["refreshInProgress",false]) || {diag_tickTime >= _idleDeadline}
   };

   private _beforeRecoveryState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
   if !(_beforeRecoveryState getOrDefault ["refreshInProgress",false]) then {
    [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
   };

   private _recoveryDeadline = diag_tickTime + 6;
   waitUntil {
    uiSleep 0.01;
    private _recoveryState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
    !(_recoveryState getOrDefault ["refreshInProgress",false]) || {diag_tickTime >= _recoveryDeadline}
   };
  };

  private _finalState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  private _finalKitRows = lbSize (_openedDisplay displayCtrl 1110);
  private _finalCatalogRows = lbSize (_openedDisplay displayCtrl 3120);
  private _finalCatalogExpected = _finalState getOrDefault ["catalogTotalFiltered",-1];
  private _finalEquipmentText = ctrlText (_openedDisplay displayCtrl 4021);
  private _finalEquipmentReady = !(_finalEquipmentText isEqualTo "") && {!(_finalEquipmentText isEqualTo "Lendo o equipamento atual...")};
  private _syncOk =
   (_expectedKitRows < 0 || {_finalKitRows isEqualTo _expectedKitRows})
   && {(_finalCatalogExpected <= 0) || {_finalCatalogRows > 0}}
   && {_finalEquipmentReady};

  _finalState set ["initialSyncComplete",_syncOk];
  _finalState set ["initialSyncRows",_finalKitRows];
  _finalState set ["initialSyncExpectedRows",_expectedKitRows];
  _finalState set ["initialSyncCatalogRows",_finalCatalogRows];
  _finalState set ["initialSyncCatalogExpected",_finalCatalogExpected];
  _finalState set ["initialSyncEquipmentReady",_finalEquipmentReady];
  _finalState set ["initialSyncElapsedMs",round ((diag_tickTime - _syncStarted) * 1000)];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_finalState];

  diag_log format [
   "[SP_ORG] [WEAPONS] [UI_INITIAL_SYNC_HOTFIX1] ok=%1 kitRows=%2/%3 catalogRows=%4/%5 equipmentReady=%6 elapsedMs=%7 initialRefresh=%8",
   _syncOk,
   _finalKitRows,
   _expectedKitRows,
   _finalCatalogRows,
   _finalCatalogExpected,
   _finalEquipmentReady,
   _finalState getOrDefault ["initialSyncElapsedMs",-1],
   _initialRefresh getOrDefault ["code","UNKNOWN"]
  ];
 };
};
true
