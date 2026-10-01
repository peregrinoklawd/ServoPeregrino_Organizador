#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_display",displayNull,[displayNull]],
    ["_enabled",false,[true]],
    ["_resolvedTarget","",[""]],
    ["_equipmentView","U",[""]],
    ["_capacity",createHashMap,[createHashMap]]
];
if (isNull _display) exitWith {false};
// D.6.2: IDC 101 remains as a hidden compatibility surface for historical callers/tests.
// Operational destination is deliberately not duplicated in the visible header.
private _viewLabel=[_equipmentView] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _ctrl=_display displayCtrl 101;
if (!isNull _ctrl) then {
    _ctrl ctrlSetText format ["Mostrando: %1",_viewLabel];
    _ctrl ctrlSetTooltip "Compatibilidade interna: o destino de arraste físico é o equipamento selecionado em Mostrar.";
};
true
