/* Policy P1 v0.1-A — syntactic class identifier only. Never infer item existence. */
params ["_candidate"];
if !(_candidate isEqualType "") exitWith {false};
private _bytes = toArray (trim _candidate);
if ((count _bytes) < 1 || {(count _bytes) > 128}) exitWith {false};
(_bytes findIf {
    private _c = _x;
    !(((_c >= 65) && {_c <= 90}) || {(_c >= 97) && {_c <= 122}} || {(_c >= 48) && {_c <= 57}} || {_c isEqualTo 95})
}) isEqualTo -1
