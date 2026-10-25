# ServoPeregrino_Organizador_Policy

**P1 0.1-A CORE CANDIDATE — not engine homologated.** The optional Policy addon source implements pure SQF authorization operations against explicit context, plus Nexus capability registration. No config loader, Policy activation, persistence, UI, integration with Items/Weapons, multiplayer authority, external files or `CfgRemoteExec` policy is installed. Depends only on Nexus and vanilla game.

Functions: `isValidClassname`, `validateExport`, `createContext`, `evaluate`, `snapshot`. CfgFunctions definitions in `config.cpp` are for a future addon/PBO: **no PBO is built or validated by this delivery**. Use the paired `.VR` mission to test the exact code mission-first.

The context is deliberately **non-authoritative** (`revision=0`, fingerprint `P1_NON_AUTHORITATIVE`). Never trust a local context as authorization to modify server equipment; P6 must validate mutations at server-side authority. P2 supplies real source/config startup snapshots.
