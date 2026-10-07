params [["_unit",objNull,[objNull]]];
if (!hasInterface || {isNull _unit} || {!local _unit}) exitWith {false};
if (_unit getVariable ["SP_ORG_Weapons_labActionsInstalled",false]) exitWith {true};
_unit setVariable ["SP_ORG_Weapons_labActionsInstalled",true];

_unit addAction ["Weapons | AUTO TEST 0.7-B - Slot-Safe Apply",{
 [] spawn ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_BTests
},nil,1.5,true,true,"","isServer"];

_unit addAction ["Weapons | ABRIR UI 0.6-F R6",{
 private _result = [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
 if !(_result get "success") then {
  hint format ["UI falhou: %1",_result get "code"];
 };
}];

_unit addAction ["Weapons | Catalogo base - resumo no RPT",{
 private _result = [false,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalog;
 if (_result get "success") then {
  private _catalog = (_result get "data") get "catalog";
  diag_log format ["[SP_ORG] [WEAPONS] [CATALOG_SUMMARY] total=%1 primary=%2 handgun=%3 secondary=%4 presetSkipped=%5 blankNameSkipped=%6 buildMs=%7",
   _catalog get "total",_catalog get "primary",_catalog get "handgun",_catalog get "secondary",_catalog get "presetSkipped",_catalog get "blankNameSkipped",_catalog get "buildMs"];
  hint format ["Catalogo base\\nTotal: %1\\nPrincipal: %2\\nPorte: %3\\nSecundaria: %4",_catalog get "total",_catalog get "primary",_catalog get "handgun",_catalog get "secondary"];
 } else {hint format ["Catalogo falhou: %1",_result get "code"]};
}];

_unit addAction ["Weapons | Compatibilidade MX - RPT",{
 private _result = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 diag_log format ["[SP_ORG] [WEAPONS] [COMPATIBILITY] weapon=arifle_MX_F result=%1",_result];
 hint "Compatibilidade da MX gravada no RPT.";
}];

_unit addAction ["Weapons | Sobre o teste 0.7-B",{
 hint "0.7-B mantém a UI 0.6-F R6 congelada e executa a primeira mutação física slot-safe no core. O AUTO TEST usa uma unidade isolada, valida PRIMARY/HANDGUN/SECONDARY, partial ammo, NO_OP e stale Snapshot. Integração do botão físico da UI continua deferred para 0.7-D.";
}];

_unit addEventHandler ["Respawn",{params ["_new"];[_new] call ServoPeregrino_Organizador_Weapons_fnc_installLabActions}];
true
