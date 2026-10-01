params [
 ["_instanceId","",[""]],
 ["_transition","",[""]],
 ["_fromLocator",createHashMap,[createHashMap]],
 ["_toLocator",createHashMap,[createHashMap]],
 ["_fingerprint","",[""]],
 ["_evidenceCode","",[""]],
 ["_continuityStatus","UNPROVEN",[""]],
 ["_candidateCount",0,[0]]
];

private _status = toUpperANSI _continuityStatus;
if !(_status in ["CORRELATED","AMBIGUOUS","UNPROVEN"]) then {_status = "UNPROVEN"};

createHashMapFromArray [
 ["schemaVersion","0.1-B-evidence-candidate"],
 ["instanceId",_instanceId],
 ["transition",toUpperANSI _transition],
 ["fromLocator",[_fromLocator] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["toLocator",[_toLocator] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["configurationFingerprint",_fingerprint],
 ["evidenceCode",toUpperANSI _evidenceCode],
 ["continuityStatus",_status],
 ["candidateCount",_candidateCount],
 ["physicalIdentityProven",false],
 ["observedAt",systemTimeUTC]
]
