#include "..\..\script_version.hpp"
params [["_target","",[""]]];
private _key=toUpper _target;
switch (_key) do {
    case "ANY": {"QUALQUER"};
    case "U": {"UNIFORME"};
    case "UNIFORM": {"UNIFORME"};
    case "UNIFORME": {"UNIFORME"};
    case "C": {"COLETE"};
    case "VEST": {"COLETE"};
    case "COLETE": {"COLETE"};
    case "M": {"MOCHILA"};
    case "BACKPACK": {"MOCHILA"};
    case "MOCHILA": {"MOCHILA"};
    case "TEST_CONTAINER": {"TESTE"};
    case "": {"—"};
    default {_target};
};
