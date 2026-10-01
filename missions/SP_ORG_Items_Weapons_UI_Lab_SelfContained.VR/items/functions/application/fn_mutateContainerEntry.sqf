params [
    ["_container", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_entry", [], [[]]]
];
if (isNull _container) exitWith {[false, "ITEMS_CONTAINER_NULL", "Mutação recusada para container nulo.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(_entry isEqualType [] && {(count _entry) >= 6}) exitWith {[false, "ITEMS_ENTRY_INVALID", "Ação física recebeu ItemEntry inválida.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _op = toUpper _operation;
if !(_op in ["ADD","REMOVE"]) exitWith {[false, "ITEMS_CONTAINER_OPERATION_INVALID", "Mutação de container aceita somente ADD ou REMOVE.", createHashMapFromArray [["operation",_op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _type = _entry # 1;
private _className = _entry # 2;
private _qty = _entry # 3;
private _mode = _entry # 4;
private _states = +(_entry # 5);
private _mutationError = createHashMap;

if (_op isEqualTo "ADD") then {
    if (_type isEqualTo "ITEM") then {
        _container addItemCargoGlobal [_className, _qty];
    } else {
        if !(_mode isEqualTo "EXACT") then {
            _mutationError = [false, "ITEMS_ENTRY_INVALID", "Mutação física de magazine exige entrada EXACT já resolvida pelo plan.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        } else {
            {_container addMagazineAmmoCargo [_className, 1, _x];} forEach _states;
        };
    };
} else {
    if (_type isEqualTo "ITEM") then {
        _container addItemCargoGlobal [_className, -_qty];
    } else {
        if !(_mode isEqualTo "EXACT") then {
            _mutationError = [false, "ITEMS_ENTRY_INVALID", "Remoção física de magazine exige entrada EXACT já resolvida pelo plan.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        } else {
            private _remaining = magazinesAmmoCargo _container;
            private _pool = +_states;
            private _rebuilt = [];
            {
                private _mag = _x;
                private _c = _mag param [0, "", [""]];
                private _ammo = _mag param [1, -1, [0]];
                private _remove = false;
                if (_c isEqualTo _className) then {
                    private _idx = _pool find _ammo;
                    if (_idx >= 0) then {_remove = true; _pool deleteAt _idx;};
                };
                if (!_remove) then {_rebuilt pushBack [_c, _ammo];};
            } forEach _remaining;
            if ((count _pool) > 0) then {
                _mutationError = [false, "ITEMS_MAGAZINE_EXACT_STATE_MISSING", "REMOVE recusado: um ou mais estados EXACT esperados já não existem no container. Nenhum magazine foi reconstruído por esta ação.", createHashMapFromArray [["className",_className],["missingStates",_pool],["requestedStates",_states]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
            } else {
                clearMagazineCargoGlobal _container;
                {_container addMagazineAmmoCargo [_x # 0, 1, _x # 1];} forEach _rebuilt;
            };
        };
    };
};
if ((count _mutationError) > 0) exitWith {_mutationError};
[true, "ITEMS_CONTAINER_ACTION_APPLIED", "Ação física dirigida foi enviada ao container.", createHashMapFromArray [["operation", _op], ["entry", [_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
