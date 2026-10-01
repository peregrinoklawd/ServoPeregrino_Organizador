params [["_kit", [], [[]]]];

private _semantic = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_semantic getOrDefault ["success", false]) exitWith {_semantic};

private _unavailable = [];
{
    private _environmental = [_x] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
    if !(_environmental getOrDefault ["success", false]) then {
        if ((_environmental getOrDefault ["code", ""]) isEqualTo "ITEMS_CLASS_UNAVAILABLE") then {
            _unavailable pushBackUnique (_x # 2);
        } else {
            _unavailable pushBackUnique (_x # 2);
        };
    };
} forEach (_kit # 8);

if ((count _unavailable) > 0) exitWith {
    [
        false,
        "ITEMS_CLASS_UNAVAILABLE",
        "O ItemKit é estruturalmente persistível, mas contém classes indisponíveis na sessão atual.",
        createHashMapFromArray [["level", "ENVIRONMENTAL"], ["available", false], ["unavailableClassNames", _unavailable], ["kit", _kit]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_KIT_ENVIRONMENTAL_VALID",
    "Todas as classes do ItemKit estão disponíveis na sessão atual.",
    createHashMapFromArray [["level", "ENVIRONMENTAL"], ["available", true], ["unavailableClassNames", []], ["kit", _kit]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
