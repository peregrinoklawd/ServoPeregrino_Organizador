#include "..\..\script_version.hpp"
params [["_publicId","",[""]]];
if (_publicId isEqualTo "") exitWith {[false,"ITEMS_PUBLIC_ID_INVALID","Identificador do kit público está vazio.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _libR=[] call ServoPeregrino_Organizador_Items_fnc_getPublicLibrary;
if !(_libR getOrDefault ["success",false]) exitWith {_libR};
private _registry=((_libR getOrDefault ["data",createHashMap]) getOrDefault ["library",[]]);
private _idx=(_registry#3) findIf {(_x isEqualType []) && {(count _x) isEqualTo 8} && {(_x#0) isEqualTo _publicId}};
if (_idx<0) exitWith {[false,"ITEMS_PUBLIC_KIT_NOT_FOUND","O kit público selecionado não existe mais nesta sessão.",createHashMapFromArray [["publicId",_publicId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _entry=[((_registry#3)#_idx)] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _kit=_entry#7;
private _valid=[_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_valid getOrDefault ["success",false]) exitWith {[false,"ITEMS_PUBLIC_KIT_INVALID","O snapshot público é inválido e não será utilizado.",createHashMapFromArray [["publicId",_publicId],["validation",_valid]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"ITEMS_PUBLIC_KIT_FOUND","Snapshot público retornado por cópia defensiva.",createHashMapFromArray [["publicId",_publicId],["entry",_entry],["kit",[_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy],["sourceKind",_entry#1],["sourceKitId",_entry#2],["authorName",_entry#3]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
