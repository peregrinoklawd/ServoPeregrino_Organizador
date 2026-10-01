/*
    Compatibilidade interna com a API de captura 0.4.x.
    A regra de ownership CONTENT deixou de viver em Inventory na 0.5 e passa
    a ser centralizada em Catalog/Domain por classifyContentClass.
*/
params [["_className", "", [""]]];

private _result = [_className, ""] call ServoPeregrino_Organizador_Items_fnc_classifyContentClass;
if ((_result getOrDefault ["success", false]) && {(_result getOrDefault ["code", ""]) isEqualTo "ITEMS_CONTENT_CLASS_CLASSIFIED"}) then {
    _result set ["code", "ITEMS_CARGO_CLASS_CLASSIFIED"];
    _result set ["message", "Classe de cargo classificada sem alterar estado físico."];
};
_result
