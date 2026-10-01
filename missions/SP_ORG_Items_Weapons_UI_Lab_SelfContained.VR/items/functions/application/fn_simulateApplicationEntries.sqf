params [
    ["_currentEntries", [], [[]]],
    ["_actions", [], [[]]]
];
private _working = [_currentEntries] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _failed = false;
{
    if !(_x isEqualType createHashMap) then {_failed = true;} else {
        private _op = _x getOrDefault ["operation", ""];
        private _entry = _x getOrDefault ["entry", []];
        if !(_entry isEqualType [] && {(count _entry) >= 6}) then {_failed = true;} else {
            if (_op isEqualTo "ADD") then {
                private _norm = [_working + [[_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy]] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
                if !(_norm getOrDefault ["success", false]) then {_failed = true;} else {_working = ((_norm getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]);};
            } else {
                private _type = _entry # 1;
                private _className = _entry # 2;
                private _qty = _entry # 3;
                private _mode = _entry # 4;
                private _idx = _working findIf {(_x # 1) isEqualTo _type && {(_x # 2) isEqualTo _className} && {(_x # 4) isEqualTo _mode}};
                if (_idx < 0) then {_failed = true;} else {
                    private _cur = [_working # _idx] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
                    if (_mode isEqualTo "EXACT") then {
                        private _states = +(_cur # 5);
                        private _removeStates = +(_entry # 5);
                        {
                            private _sidx = _states find _x;
                            if (_sidx < 0) then {_failed = true;} else {_states deleteAt _sidx;};
                        } forEach _removeStates;
                        if (!_failed) then {
                            if ((count _states) isEqualTo 0) then {_working deleteAt _idx;} else {_cur set [3, count _states]; _cur set [5, _states]; _working set [_idx, _cur];};
                        };
                    } else {
                        private _newQty = (_cur # 3) - _qty;
                        if (_newQty < 0) then {_failed = true;} else {if (_newQty isEqualTo 0) then {_working deleteAt _idx;} else {_cur set [3, _newQty]; _working set [_idx, _cur];};};
                    };
                };
            };
        };
    };
    if (_failed) exitWith {};
} forEach _actions;
if (_failed) exitWith {[false, "ITEMS_PLAN_SIMULATION_FAILED", "Não foi possível simular as ações planejadas.", createHashMapFromArray [["entries", _working]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _normFinal = [_working] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normFinal getOrDefault ["success", false]) exitWith {_normFinal};
[true, "ITEMS_PLAN_SIMULATION_READY", "Estado físico esperado foi simulado sem mutação.", createHashMapFromArray [["entries", (_normFinal getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
