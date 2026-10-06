params [
 ["_className","",[""]],
 ["_kind","WEAPON",[""]]
];

private _kindU = toUpperANSI _kind;
private _root = if (_kindU isEqualTo "MAGAZINE") then {configFile >> "CfgMagazines"} else {configFile >> "CfgWeapons"};

if (_className isEqualTo "") exitWith {
 [true,"WEAPONS_UI_CLASS_PRESENTATION_EMPTY","Empty class represented as none.",createHashMapFromArray [[
  "info",createHashMapFromArray [
   ["present",false],["className",""],["displayName","Nenhum"],["picture",""],["descriptionShort",""],
   ["kind",_kindU],["sourceAddons",[]],["sourceMods",[]],["originLabel",""]
  ]
 ]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfg = _root >> _className;
if (!isClass _cfg) exitWith {
 [false,"WEAPONS_UI_CLASS_PRESENTATION_UNKNOWN","Class does not exist in the expected config root.",createHashMapFromArray [
  ["className",_className],["kind",_kindU]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _canonical = configName _cfg;
private _displayName = getText (_cfg >> "displayName");
if (_displayName isEqualTo "") then {_displayName = _canonical};
private _sourceAddons = configSourceAddonList _cfg;
private _sourceMods = configSourceModList _cfg;
private _originLabel = "Origem não informada";
if ((count _sourceMods) > 0) then {
 _originLabel = _sourceMods joinString ", ";
} else {
 if ((count _sourceAddons) > 0) then {_originLabel = _sourceAddons joinString ", "};
};

[true,"WEAPONS_UI_CLASS_PRESENTATION","Generic catalog/equipment presentation resolved without mutation.",createHashMapFromArray [[
 "info",createHashMapFromArray [
  ["present",true],
  ["className",_canonical],
  ["displayName",_displayName],
  ["picture",getText (_cfg >> "picture")],
  ["descriptionShort",getText (_cfg >> "descriptionShort")],
  ["kind",_kindU],
  ["sourceAddons",_sourceAddons],
  ["sourceMods",_sourceMods],
  ["originLabel",_originLabel]
 ]
]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
