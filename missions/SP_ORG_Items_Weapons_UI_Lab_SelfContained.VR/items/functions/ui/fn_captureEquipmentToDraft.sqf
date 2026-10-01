#include "..\..\script_version.hpp"
params [["_unit",objNull,[objNull]],["_target","U",[""]]];
private _capture = [_unit,_target] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
if !(_capture getOrDefault ["success",false]) exitWith {_capture};
private _d = _capture getOrDefault ["data",createHashMap];
private _draftR = [_d getOrDefault ["entries",[]],_d getOrDefault ["canonicalTarget","ANY"],format ["Captura %1",_d getOrDefault ["canonicalTarget",_target]]] call ServoPeregrino_Organizador_Items_fnc_createCaptureDraft;
if !(_draftR getOrDefault ["success",false]) exitWith {_draftR};
private _draft = ((_draftR getOrDefault ["data",createHashMap]) getOrDefault ["draft",createHashMap]);
[_draft] call ServoPeregrino_Organizador_Items_fnc_openCaptureDraft
