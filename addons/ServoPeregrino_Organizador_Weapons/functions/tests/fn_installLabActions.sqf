params [["_unit",objNull,[objNull]]];
if (!hasInterface || {isNull _unit} || {!local _unit}) exitWith {false};
if (_unit getVariable ["SP_ORG_Weapons_labActionsInstalled",false]) exitWith {true};
_unit setVariable ["SP_ORG_Weapons_labActionsInstalled",true];
missionNamespace setVariable ["SP_ORG_Weapons_labSlot","PRIMARY"];
_unit addAction ["Weapons | Alternar PRIMARY / SECONDARY / HANDGUN",{
 private _slots = ["PRIMARY","SECONDARY","HANDGUN"];
 private _old = missionNamespace getVariable ["SP_ORG_Weapons_labSlot","PRIMARY"];
 private _next = _slots select (((_slots find _old) + 1) mod 3);
 missionNamespace setVariable ["SP_ORG_Weapons_labSlot",_next]; hint ("Slot: " + _next);
}];
{
 _x params ["_label","_operation"];
 _unit addAction [_label,{
  params ["_target","_caller","_actionId","_operation"];
  [_caller,_operation,missionNamespace getVariable ["SP_ORG_Weapons_labSlot","PRIMARY"],cursorObject] remoteExecCall ["ServoPeregrino_Organizador_Weapons_fnc_serverHandleLabRequest",2];
 },_operation];
} forEach [
 ["Weapons | Registrar referencia logica (nao prova identidade fisica)","REGISTER"],
 ["Weapons | Consultar serial, instanceId e configuracao","QUERY"],
 ["Weapons | Atualizar configuracao da referencia (gate A)","UPDATE"],
 ["Weapons | Inspecionar caixa/holder sob a mira","OBSERVE"],
 ["Weapons | Diagnostico do registry no servidor","DIAGNOSTICS"]
];
_unit addAction ["Weapons | Capturar evidencias locais (RPT)",{
 params ["_target","_caller"];
 private _c = cursorObject;
 diag_log format ["[SP_ORG] [WEAPONS] [PROBE_LOCAL] unit=%1 owner=%2 loadout=%3 weaponsItemsExtended=%4 weaponsInfo=%5",netId _caller,owner _caller,getUnitLoadout _caller,weaponsItems [_caller,true],_caller weaponsInfo ["",false]];
 if (!isNull _c && {_caller distance _c < 10}) then {diag_log format ["[SP_ORG] [WEAPONS] [PROBE_CARGO] carrier=%1 standard=%2 extended=%3",netId _c,weaponsItemsCargo _c,weaponsItemsCargo [_c,true]]};
 hint "Evidencias locais no RPT: PROBE_LOCAL / PROBE_CARGO. Nao sao prova de identidade.";
}];
_unit addAction ["Weapons | AUTO TEST (somente host/servidor)",{[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_1ATests},nil,1.5,true,true,"","isServer"];
// Native inventory UI performs the physical moves. No remove/recreate emulation of identity.
_unit addAction ["Weapons | Instrucoes de movimentacao",{hint "Use I para largar/recuperar e mover armas para a caixa. Outro jogador retira a mesma arma. Consulte antes/depois e capture RPT. Transferencias permanecem UNPROVEN. Caixa DUPLICATES contem duas armas fisicamente iguais."}];
{
 private _event = _x;
 _unit addEventHandler [_event,{
  params ["_unit","_container","_item"];
  diag_log format ["[SP_ORG] [WEAPONS] [INVENTORY_EVENT] unit=%1 container=%2 item=%3",netId _unit,netId _container,_item];
  [_unit,"EVENT","PRIMARY",_container] remoteExecCall ["ServoPeregrino_Organizador_Weapons_fnc_serverHandleLabRequest",2];
 }];
} forEach ["Take","Put"];
_unit addEventHandler ["Respawn",{params ["_new"];[_new] call ServoPeregrino_Organizador_Weapons_fnc_installLabActions}];
true
