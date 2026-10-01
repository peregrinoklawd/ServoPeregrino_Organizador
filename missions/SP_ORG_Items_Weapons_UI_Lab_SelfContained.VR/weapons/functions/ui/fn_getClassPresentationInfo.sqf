params [["_class","",[""]],["_kind","ITEM",[""]]];
private _kindU = toUpperANSI _kind;
if (_class isEqualTo "") exitWith {
 [true,"WEAPONS_UI_PRESENTATION_EMPTY","Empty class presentation.",createHashMapFromArray [["info",createHashMapFromArray [["present",false],["className",""],["displayName","Nenhum"],["picture",""],["descriptionShort",""],["kind",_kindU],["sourceAddons",[]],["sourceMods",[]],["originLabel",""]]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _root = if (_kindU isEqualTo "MAGAZINE") then {configFile >> "CfgMagazines"} else {configFile >> "CfgWeapons"};
private _cfg = _root >> _class;
if (!isClass _cfg) exitWith {
 [false,"WEAPONS_UI_PRESENTATION_CLASS_UNKNOWN","Class is not available in config.",createHashMapFromArray [["className",_class],["kind",_kindU]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _canonical = configName _cfg;
private _displayName = getText (_cfg >> "displayName");
if (_displayName isEqualTo "") then {_displayName = _canonical};
private _sourceAddons = configSourceAddonList _cfg;
private _sourceMods = configSourceModList _cfg;
private _originLabel = if (count _sourceMods > 0) then {_sourceMods joinString ", "} else {_sourceAddons joinString ", "};
[true,"WEAPONS_UI_PRESENTATION_INFO","Presentation metadata resolved without mutation.",createHashMapFromArray [["info",createHashMapFromArray [["present",true],["className",_canonical],["displayName",_displayName],["picture",getText (_cfg >> "picture")],["descriptionShort",getText (_cfg >> "descriptionShort")],["kind",_kindU],["sourceAddons",_sourceAddons],["sourceMods",_sourceMods],["originLabel",_originLabel]]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
