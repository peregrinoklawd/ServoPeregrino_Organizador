params [["_className","",[""]]];
private _r = [_className] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
if !(_r getOrDefault ["success", false]) exitWith {createHashMapFromArray [["className",_className],["displayName",_className],["picture",""],["available",false],["categoryId","OTHER"],["addon",""]]};
private _item = ((_r getOrDefault ["data",createHashMap]) getOrDefault ["item",createHashMap]);
[_item] call ServoPeregrino_Organizador_Items_fnc_deepCopy
