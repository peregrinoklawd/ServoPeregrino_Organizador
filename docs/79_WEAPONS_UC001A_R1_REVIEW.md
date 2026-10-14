# Revisão do RPT UC-001-A R1 — 14/10/2026

Arquivo recebido: Texto colado(20261014-212800).txt (10.201 linhas).

## Resultado

- Regressão R5 aprovada: 1446/1446, 0 FAIL/BLOCKED, às 18:15:34.
- Auditoria de fontes executada duas vezes: 18:24:48 e 18:25:54.
- Cada rodada: PRIMARY + HANDGUN auditadas; SECONDARY vazia; failures=0 e playerLoadoutUnchanged=true.
- MCC_RD704_AFG: consultas engine/CBA idênticas para muzzle (107), pointer (1528), optic (1270) e magazines (61). Slot inferior: engine 44 vs CBA 87, diferença 43 opções presentes apenas no CBA.
- MPP_STI_DE_FDE_45: muzzle 8/8, pointer 24/24, optic 85/85, inferior 0/0, magazines 8/8, sem divergência.
- ACE Arsenal e CBA detectados. A autoridade de compatibilidade ACE ainda não foi comprovada.
- Cobertura de THIRD/SECONDARY e variantes com muzzle adicional pendente.
- 24 erros externos de CBA_fnc_addPerFrameHandler, com autoria não identificada. Não atribuídos ao SP_ORG.

## Persistência de kits: comportamento atual confirmado

- RPT linha 10198: WEAPONS_KIT_CREATED após SAVE_DRAFT às 18:27:14.
- RPT linha 10200: lista cresce de 8 para 9 kits.
- fn_initializeWeaponKitStore.sqf mantém coleções em missionNamespace, com modo SESSION_LOCAL_CANDIDATE.
- É esperado perder kits ao iniciar outra missão. SALVAR ainda NÃO significa persistência entre missões.

## Requisito futuro WST-001

Introduzir biblioteca pessoal persistente de WeaponKits entre missões, associada ao perfil Arma 3, em entrega separada da UC-001-A. Usar formato versionado e validação de dados; carregar e salvar mediante ações confirmadas; proteger dados reais durante testes automáticos; preservar kits de addons ausentes; verificar reinicialização do jogo e migração; não confundir persistência local com autoridade multiplayer. Enquanto não implementado, informar SALVO NESTA MISSÃO na interface.

Decisão de gate: UC-001-A foi executada sem erros observados nos dois slots ocupados, mas permanece cobertura parcial pela ausência de SECONDARY. Não alterar a baseline R5 nem fazer merge.
