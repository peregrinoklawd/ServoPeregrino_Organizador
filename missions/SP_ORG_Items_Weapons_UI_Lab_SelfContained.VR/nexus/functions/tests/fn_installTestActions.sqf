#include "..\..\script_version.hpp"

params [["_unit", player, [objNull]]];
if (isNull _unit) exitWith {false};
if (_unit getVariable ["ServoPeregrino_Organizador_Nexus_testActionsInstalled", false]) exitWith {true};

_unit addAction [
    "<t color='#A7D8FF' size='1.15'>[SP_ORG] Executar testes do Nexus 1.1</t>",
    {[] spawn ServoPeregrino_Organizador_Nexus_fnc_runDelivery1_1Tests;},
    nil,
    20,
    false,
    true,
    "",
    "true",
    5
];
_unit addAction [
    "<t color='#9FE6C0'>[SP_ORG] Mostrar informações do Nexus</t>",
    {
        private _build = [] call ServoPeregrino_Organizador_Nexus_fnc_getBuildInfo;
        hint parseText format [
            "<t size='1.25'>SP_ORG — Nexus</t><br/><br/>Versão: %1<br/>Build: %2<br/>Namespace: %3",
            _build getOrDefault ["semanticVersion", ""],
            _build getOrDefault ["build", ""],
            _build getOrDefault ["namespace", ""]
        ];
    },
    nil,
    19,
    false,
    true,
    "",
    "true",
    5
];

_unit setVariable ["ServoPeregrino_Organizador_Nexus_testActionsInstalled", true];
true
