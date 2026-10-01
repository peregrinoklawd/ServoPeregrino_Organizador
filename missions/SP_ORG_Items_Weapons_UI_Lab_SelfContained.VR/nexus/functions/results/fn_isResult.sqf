#include "..\..\script_version.hpp"

params [["_value", createHashMap]];

if !(_value isEqualType createHashMap) exitWith {false};

(_value getOrDefault ["schema", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_NEXUS_RESULT_MAGIC
&& {(_value getOrDefault ["version", 0]) isEqualTo 1}
&& {(_value getOrDefault ["success", false]) isEqualType false}
&& {(_value getOrDefault ["code", ""]) isEqualType ""}
