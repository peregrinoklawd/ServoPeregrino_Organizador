[] spawn {
 waitUntil {!isNull player};
 if (isNil "ServoPeregrino_Organizador_Weapons_fnc_installLabActions") exitWith {
  hint "Weapons nao carregou. Verifique PBOs Nexus + Weapons e RPT antes de testar.";
  diag_log "[SP_ORG] [WEAPONS] [LAB_ADDON_MISSING]";
 };
 [player] call ServoPeregrino_Organizador_Weapons_fnc_installLabActions;
 hint "Weapons 0.1-A | Use acoes de scroll. Caixas TRANSFER e DUPLICATES. AUTO TEST no host. Identidade fisica permanece NAO COMPROVADA.";
};
