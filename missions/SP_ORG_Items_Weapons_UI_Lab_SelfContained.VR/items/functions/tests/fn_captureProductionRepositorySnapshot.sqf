#include "..\..\script_version.hpp"
private _sentinel="__SPORG_PRODUCTION_ABSENT__";
private _primaryKey="ServoPeregrino_Organizador_Items_storage_v1";
private _lastGoodKey="ServoPeregrino_Organizador_Items_storage_lastGood_v1";
private _p=profileNamespace getVariable [_primaryKey,_sentinel];
private _l=profileNamespace getVariable [_lastGoodKey,_sentinel];
private _pPresent=!(_p isEqualType "" && {_p isEqualTo _sentinel});
private _lPresent=!(_l isEqualType "" && {_l isEqualTo _sentinel});
private _pCopy=if (_pPresent) then {[_p] call ServoPeregrino_Organizador_Items_fnc_deepCopy} else {[]};
private _lCopy=if (_lPresent) then {[_l] call ServoPeregrino_Organizador_Items_fnc_deepCopy} else {[]};
createHashMapFromArray [
    ["primaryKey",_primaryKey],["lastGoodKey",_lastGoodKey],
    ["primaryPresent",_pPresent],["lastGoodPresent",_lPresent],
    ["primary",_pCopy],["lastGood",_lCopy]
]
