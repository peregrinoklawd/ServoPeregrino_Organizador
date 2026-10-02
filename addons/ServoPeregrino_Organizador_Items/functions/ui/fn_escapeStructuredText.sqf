// Compatibility wrapper kept under the Items API while the generic implementation
// is owned by UICommon. Domain callers do not need to know the shared provider yet.
params [["_text", "", [""]]];
[_text] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText
