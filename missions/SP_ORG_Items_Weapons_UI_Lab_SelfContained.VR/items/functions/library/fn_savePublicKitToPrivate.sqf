#include "..\..\script_version.hpp"
params [["_publicId","",[""]]];
private _get=[_publicId] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
if !(_get getOrDefault ["success",false]) exitWith {_get};
private _d=_get getOrDefault ["data",createHashMap];
private _kit=_d getOrDefault ["kit",[]];
private _sourceName=_kit param [3,"Kit público",[""]];
private _copyPrefix="Cópia ";
private _maxSourceLength=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_NAME_MAX_LENGTH-(count _copyPrefix)) max 1;
private _copyName=format ["%1%2",_copyPrefix,_sourceName select [0,_maxSourceLength]];
private _cloneR=[_kit,_copyName] call ServoPeregrino_Organizador_Items_fnc_cloneItemKit;
if !(_cloneR getOrDefault ["success",false]) exitWith {_cloneR};
private _clone=((_cloneR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
_clone set [5,["PUBLIC_COPY",_publicId]];
private _valid=[_clone] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};
private _save=[_clone] call ServoPeregrino_Organizador_Items_fnc_saveKit;
if !(_save getOrDefault ["success",false]) exitWith {_save};
private _saved=((_save getOrDefault ["data",createHashMap]) getOrDefault ["kit",_clone]);
diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_LIBRARY] SAVE_PRIVATE publicId=%1 newKitId=%2 author=%3",_publicId,_saved#2,_d getOrDefault ["authorName",""]];
[true,"ITEMS_PUBLIC_KIT_SAVED_PRIVATE","Kit público salvo como cópia privada independente.",createHashMapFromArray [["publicId",_publicId],["kitId",_saved#2],["kit",_saved],["sourceAuthor",_d getOrDefault ["authorName",""]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
