params [["_unit",objNull,[objNull]],["_slot","PRIMARY",[""]]];
private _index = ["PRIMARY","SECONDARY","HANDGUN"] find toUpperANSI _slot;
if (isNull _unit || {!(_unit isKindOf "CAManBase")} || {_index < 0}) exitWith {[false,"WEAPONS_CAPTURE_TARGET_INVALID","Expected unit and PRIMARY/SECONDARY/HANDGUN."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _row = (getUnitLoadout _unit) param [_index,[]];
if (_row isEqualTo [] || {(_row param [0,""]) isEqualTo ""}) exitWith {[false,"WEAPONS_SLOT_EMPTY","No weapon in slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[_row] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray
