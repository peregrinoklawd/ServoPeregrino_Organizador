#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_control",controlNull,[controlNull]],
    ["_key",-1,[0]],
    ["_shift",false,[false]],
    ["_ctrlKey",false,[false]],
    ["_alt",false,[false]]
];
if (isNull _control) exitWith {false};
// DIK_RETURN=28; DIK_NUMPADENTER=156.
if !(_key in [28,156]) exitWith {false};
[_control] call ServoPeregrino_Organizador_Items_fnc_commitDraftQuantityFromControl;
true
