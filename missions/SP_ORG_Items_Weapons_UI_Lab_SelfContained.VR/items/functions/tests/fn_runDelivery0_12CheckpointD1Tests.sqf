#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D1_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.1 — HEADER HIERARCHY + PLAYER-FACING POLISH — 550 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D1_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC81Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 542};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D1_BASE_542_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",543],["checkpointLastGate",550],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",550]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.1 — FAIL-FAST: baseline C.8.1 542/542 não fechou.";
    _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.1] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcHeaderStatus=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderStatusUI.sqf";
private _srcTargetLabel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUITargetLabel.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcProxy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIDragVisualProxy.sqf";

private _gate543=(_srcDialog find "class HeaderDivider")>=0 && {(_srcDialog find "idc=103")>=0} && {(_srcDialog find "idc=108")>=0} && {(_srcDialog find "idc=104")>=0} && {(_srcDialog find "idc=105")>=0} && {(_srcDialog find "idc=106")>=0} && {(_srcDialog find "idc=107")>=0} && {(_srcDialog find "idc=102")>=0} && {(_srcDialog find "class HeaderStatus")>=0} && {(_srcDialog find "x=safeZoneX-2")>=0};
["ITEMS-0.12-543",_gate543,"Header preserva IDs históricos, mas o status duplicado vira stub oculto e o bloco principal converge ao padrão compacto do APM."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _pos={params ["_idc"]; if (isNull _display) exitWith {[]}; ctrlPosition (_display displayCtrl _idc)};
private _titlePos=[100] call _pos; private _loadPos=[104] call _pos; private _barPos=[105] call _pos; private _idPos=[103] call _pos; private _unitPos=[108] call _pos; private _futurePos=[107] call _pos; private _closePos=[102] call _pos; private _statusPos=[101] call _pos;
private _headerRightOrder=(count _loadPos)>=4 && {(count _idPos)>=4} && {(count _futurePos)>=4} && {(count _closePos)>=4} && {(_loadPos#0)+(_loadPos#2) <= (_idPos#0)+0.002*safeZoneW} && {(_idPos#0)+(_idPos#2) <= (_futurePos#0)+0.002*safeZoneW} && {(_futurePos#0)+(_futurePos#2) <= (_closePos#0)+0.002*safeZoneW};
private _identityStack=(count _idPos)>=4 && {(count _unitPos)>=4} && {abs((_idPos#0)-(_unitPos#0))<0.002*safeZoneW} && {(_idPos#1)+(_idPos#3) <= (_unitPos#1)+0.003*safeZoneH};
private _statusHidden=(count _statusPos)>=4 && {(_statusPos#0)<safeZoneX-1};
private _insideHeader=(count _titlePos)>=4 && {(count _barPos)>=4} && {(_titlePos#1)>=safeZoneY} && {(_barPos#1)+(_barPos#3)<=safeZoneY+0.049*safeZoneH};
private _gate544=!isNull _display && {_headerRightOrder} && {_identityStack} && {_statusHidden} && {_insideHeader};
["ITEMS-0.12-544",_gate544,"Smoke runtime: carga, identidade, slot futuro e Fechar formam um cluster compacto; HeaderStatus fica fora da área visível."] call _assert;

[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
private _operatorText=ctrlText (_display displayCtrl 103);
private _unitText=ctrlText (_display displayCtrl 108);
private _loadText=ctrlText (_display displayCtrl 104);
private _bgPos=ctrlPosition (_display displayCtrl 105); private _fillPos=ctrlPosition (_display displayCtrl 106);
private _gate545=(_operatorText find "Operador: ") isEqualTo 0 && {(_unitText find "Unidade: ") isEqualTo 0} && {(_loadText find "Carga: ") isEqualTo 0} && {(_loadText find "kg")>=0} && {(_loadText find "lb")<0} && {(_loadText find "%")>=0} && {(count _bgPos)>=4} && {(count _fillPos)>=4} && {(_fillPos#2)>=0} && {(_fillPos#2)<=(_bgPos#2)+0.0005} && {(_srcHeader find "displayCtrl 108")>=0};
["ITEMS-0.12-545",_gate545,"Header runtime separa Operador/Unidade e mostra Carga usada/total em kg e percentual; fill permanece contido na barra."] call _assert;

private _labelsOk=(["ANY"] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel) isEqualTo "QUALQUER" && {(["U"] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel) isEqualTo "UNIFORME"} && {(["C"] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel) isEqualTo "COLETE"} && {(["M"] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel) isEqualTo "MOCHILA"};
private _capFixture=createHashMapFromArray [["known",true],["currentLoad",42],["maxLoad",100]];
[_display,true,"U","C",_capFixture] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;
private _statusText=ctrlText (_display displayCtrl 101);
private _gate546=_labelsOk && {(_statusText find "Mostrando: COLETE")>=0} && {(_statusText find "Adicionar em:")<0} && {(_statusText find "PHYSICAL")<0} && {(_statusText find "VIEW")<0};
["ITEMS-0.12-546",_gate546,"Stub histórico mantém somente contexto de visualização; o header visível não duplica o destino de aplicação do kit."] call _assert;

private _gate547=(_srcDialog find "Kit Selecionado/Draft")<0 && {(_srcDialog find "BEST_EFFORT")<0} && {(_srcDialog find "REPLACE STRICT")<0} && {(_srcDialog find "CONTENT mutável")<0} && {(_srcDialog find "preferredTarget vence")<0} && {(_srcDialog find "VIEW atual")<0} && {(_srcTargetLabel find "UNIFORME")>=0} && {(_srcHeaderStatus find "Adicionar em:")<0};
["ITEMS-0.12-547",_gate547,"Tooltips e textos player-facing deixam de expor jargão e o header não repete o destino de aplicação."] call _assert;

private _searchIds=[1100,2101,3100,4100];
private _searchPos=_searchIds apply {ctrlPosition (_display displayCtrl _x)};
private _searchAligned=true; private _refY=(_searchPos#0)#1; private _refH=(_searchPos#0)#3;
{if (abs((_x#1)-_refY)>0.0005 || {abs((_x#3)-_refH)>0.0005}) then {_searchAligned=false;};} forEach _searchPos;
private _titleIds=[1000,2000,3000,4000]; private _titlePos=_titleIds apply {ctrlPosition (_display displayCtrl _x)}; private _titleAligned=true; private _titleY=(_titlePos#0)#1;
{if (abs((_x#1)-_titleY)>0.0005) then {_titleAligned=false;};} forEach _titlePos;
private _gate548=_searchAligned && {_titleAligned};
["ITEMS-0.12-548",_gate548,"Os quatro painéis mantêm títulos e campos de busca na mesma linha visual, preservando simetria no ultrawide."] call _assert;

private _footer0=ctrlPosition (_display displayCtrl 5000); private _footer1=ctrlPosition (_display displayCtrl 5001); private _footer2=ctrlPosition (_display displayCtrl 5002);
private _gate549=(_footer0#1)<(_footer1#1) && {(_footer1#1)<(_footer2#1)} && {(_srcDialog find "class SPORG_Items_FooterContext")>=0} && {(_srcDialog find "class SPORG_Items_FooterMessage")>=0} && {(_srcDialog find "class SPORG_Items_FooterHistory")>=0};
["ITEMS-0.12-549",_gate549,"Footer preserva hierarquia Contexto → Resultado → Histórico em três níveis estáveis, sem disputar espaço com os painéis principais."] call _assert;

private _dragContract=(_srcDrag find "DISPLAY_POINTER")>=0 && {(_srcDrag find "getMousePosition")>=0} && {(_srcProxy find "ctrlCreate")>=0} && {(_srcProxy find "DND_GHOST] CREATE")>=0};
if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp550=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-550"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp550d=_cmp550 getOrDefault ["data",createHashMap];
private _changed550=_cmp550d getOrDefault ["changedIndexes",[]];
private _ambient550=!(_cmp550d getOrDefault ["equal",false]) && {(count _changed550)>0} && {(_changed550 findIf {!(_x in [0,1,2])})<0};
if (_ambient550) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-550 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed550];};
private _gate550=_dragContract && {(_cmp550d getOrDefault ["equal",false]) || {_ambient550}} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_1_CUMULATIVE_GATE_COUNT isEqualTo 550};
["ITEMS-0.12-550",_gate550,"D.1 é polish: contratos C.7/C.8.1 de DnD/ghost continuam presentes, storage permanece intacto e drift externo restrito a slots de armas é apenas diagnosticado."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",542],["checkpointFirstGate",543],["checkpointLastGate",550],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",550],["cumulativePassed",542+_passed],["durationMs",_durationMs],["headerHierarchy",true],["playerFacingCleanup",true],["manualUltrawideValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.1 — BASE=542/542  D.1=%1/8  FAIL=%2  CUMULATIVO=%3/550  TEMPO=%4ms",_passed,_failed,542+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.1 — Manual: validar header no ultrawide, textos player-facing e confirmar DnD/ghost da C.8.1 sem regressão.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.1</t><br/><br/>Baseline C.8.1: <t color='#7CFC00'>542 / 542</t><br/>D.1: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 550<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,542+_passed,if (_failed isEqualTo 0) then {"Valide visualmente o header e repita o DnD/ghost."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
