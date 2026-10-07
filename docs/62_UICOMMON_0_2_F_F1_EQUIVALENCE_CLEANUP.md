# UICommon 0.2-F F1 — Equivalence + Cleanup

Data: 07/10/2026.

## Base congelada

UICommon 0.2-E E1 está homologada:
- Foundation: **43/43**;
- Items + UICommon: **16/16**;
- Weapons 0.6-F R6: **594/594**, 0 FAIL;
- focused refresh e performance aprovados em Arma real.

A E1 continua sendo o fallback conhecido.

## Objetivo

Fechar a linha UICommon 0.2 com equivalência final e limpeza de rastreabilidade.

A F1 não cria nova infraestrutura compartilhada e não altera regra de domínio.

## Escopo permitido

- atualizar identidade da candidata para 0.2-F F1;
- remover nomenclaturas históricas/enganosas do harness;
- alinhar logs e nomes de actions de teste com Weapons 0.6-F R6;
- consolidar documentação de status e próximos gates;
- validar paridade addon/mission;
- executar novamente o gate combinado Items + Weapons.

## Fora de escopo

- alterar UI visual;
- alterar filtros, seleção, DnD ou aplicação;
- alterar FULL vs focused refresh;
- mover ownership de Items/Weapons para UICommon;
- otimizar CONFIG_ALL;
- iniciar aplicação física de Weapons 0.7;
- alterar autoridade multiplayer.

## Identidade da candidata

- display: `0.2`;
- semantic: `0.2.0.10`;
- build: `0.2.0.10-equivalence-cleanup-f1`;
- missão: `SP_ORG_UI_Lab_UICommon_0_2_F_F1.VR`.

## Limpeza inicial aplicada

No harness da missão:
- `SP_ORG_FullLab_fnc_testWeaponsR2` -> `SP_ORG_FullLab_fnc_testWeaponsR6`;
- `SPORG_FL_WeaponsR2` -> `SPORG_FL_WeaponsR6`;
- log `WEAPONS_0_6_F_R1_TEST` -> `WEAPONS_0_6_F_R6_TEST`.

Nenhuma função Weapons executada mudou:
`ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_6_FR6Tests` permanece a autoridade do runner.

## Gate estático

Obrigatório:
- UICommon addon/mission com mesma identidade e mesmos helpers;
- Foundation continua com **43 checks**;
- Items Equivalence continua com **16 checks**;
- Weapons runner continua com **594 checks**;
- nenhum helper de domínio novo em UICommon;
- nenhuma mudança em refreshers de Items/Weapons nesta F1;
- nenhum evento/handler funcional alterado.

## Gate runtime final

Esperado em Arma real:
1. UICommon Foundation: **43/43**;
2. Items + UICommon Equivalence: **16/16**;
3. Weapons 0.6-F R6: **594/594**, 0 FAIL;
4. wheel/slider de Items e Weapons permanecem focused e `fullRefresh=false`;
5. Equipment e Draft permanecem focused;
6. nenhuma regressão visual/manual;
7. nenhum novo erro SP_ORG.

## Após aprovação

Congelar **UICommon 0.2**.

Próxima frente:
**Weapons 0.7-A — Plan / Snapshot / Dry-Run**, ainda sem mutação física até o gate específico.
