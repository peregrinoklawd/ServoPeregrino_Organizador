# Weapons UC-001-B R2 — Revisão do RPT real (14/10/2026)

**Status: AUTO TEST PASS, validação manual física parcial PASS, homologação final de compatibilidade CBA-exclusiva pendente.**

- RPT do usuário: `Texto colado(20261015-024245).txt`, Arma 3 2.22.154089.
- Sessão às 23:30:31–23:40:22 (horário exibido pelo RPT); arquivo de 10.358 linhas.
- Build carregado, linha 8111: `weaponsBuild=0.7.5.2-uc001-b-r2-legacy-source-contract-mission-first`.
- Baseline homologada R5 intacta e PR #11 Draft, sem merge.

## Regressão automática — PASS

| Marco | PASS | FAIL | BLOCKED |
|---|---:|---:|---:|
| 0.6-F R6 | 594/594 | 0 | — |
| 0.7-A | 673/673 | 0 | — |
| 0.7-B | 890/890 | 0 | 0 |
| 0.7-C | 978/978 | 0 | 0 |
| 0.7-D | 1109/1109 | 0 | 0 |
| 0.7-D2 | 1360/1360 | 0 | 0 |
| 0.7-E R5 | 1446/1446 | 0 | 0 |
| **UC-001-B R2** | **1518/1518** | **0** | **0** |

Resumo às 23:37:25, linha 10141: `passed=1518 failed=0 blocked=0 total=1518 expected=1518`. As **72 asserções B**, incluindo o marcador legado e metadados da fonte em quatro slots, passaram. Build, logs dos checks e resultado `WEAPONS_UC001B_R2_TEST` confirmam R2.

**Defeito textual NÃO funcional:** a linha `AUTO_TEST_SUMMARY` ainda traz `mode=MISSION_FIRST_UC001B_R1`, devido a uma literal remanescente em `weapons/functions/tests/fn_runUC001BTests.sqf`. Os checks individuais usam R2. Corrigir esse marcador no próximo ciclo de mudança, sem adulterar o ZIP R2 aprovado nem pedir novo reteste integral somente pela etiqueta. Registrar uma verificação estática para prevenir repetição.

## Resolvedor e compatibilidade (amostra)

- `MCC_RD704_AFG`: `COMPAT_SOURCE_DIFF` em bipod/underbarrel: 44 engine, 87 CBA, **43 CBA adicionais**; 107 muzzle, 1528 pointer, 1270 optic, 87 bipod.
- As 72 asserções de R2 cobrem catálogo e resolvedor nas armas vanilla `arifle_MX_F`, `hgun_P07_F`, `launch_NLAW_F`, compatibilidade de quatro slots, dedupe, cache e rejeição de classe inexistente.
- `COMPAT_REJECT` para classes impossíveis é esperado e protege o mecanismo fail-closed.
- O diagnóstico UC-001-A em SECONDARY equipado segue pendente por decisão do operador.

## Teste físico manual real, posterior ao runner

- Às 23:39:31: `DRAFT_APPLY`, `success=true`, `WEAPONS_APPLICATION_APPLIED`, `operation=REPLACE`, `mutationPerformed=true`, `targetSlot=PRIMARY`, `rollbackAttempted=false`. `AMMO_D2_ROW` idêntico em EXPECTED, IMMEDIATE_AFTER_SET e POST_VALIDATION. A configuração incluía `muzzle_snds_65_TI_ghex_F`, `rhsusf_acc_anpeq15_bk_ih_25MRAD`, `121_USASOC_PVPS_ANPVS30_PAINT`, `bipod_02_F_arid`, carregador `30Rnd_65x39_caseless_khaki_mag` 30/30.
- Às 23:39:40: `DRAFT_APPLY`, `success=true`, `WEAPONS_APPLICATION_APPLIED`, `operation=RECONFIGURE`, `mutationPerformed=true`, `targetSlot=PRIMARY`, `rollbackAttempted=false`. `AMMO_D2_ROW` idêntico nas três fases. Novos acessórios `rhsusf_acc_anpeq15_bk_top_al` e `ACE_optic_Hamr_2D`; carregador observado preservado 30/30.
- Isso confirma duas mutações físicas bem-sucedidas em uma arma vanilla com acessórios modded. **Não** comprova uma aplicação física de arma MCC usando uma empunhadura que apenas CBA listou; tal teste permanece exigência de homologação plena UC-001-B.
- `DRAFT_APPLY` no runner também confirmou `WEAPONS_APPLICATION_ALREADY_APPLIED` e ausência de mutação em NO_OP.
- Três `SAVE_RESULT` ocorreram durante auto-testes R5 (não significam persistência em perfil). WST-001 não implementado.

## Outros eventos e desempenho

- **24** `Error in expression` da função `/x/cba/addons/common/fnc_addPerFrameHandler.sqf`, linha 30, reclamando String em vez de Code e Code em vez de Number. O log não revela chamador; erros recorrentes anteriores. Não atribuir ao SP_ORG nem concluir falha do CBA sem stack/chamador.
- Avisos de inicialização de outros addons: idiomas stringtable, chaves duplicadas, `Missing ';'`. Não constituem falha demonstrada no Organizador.
- `[CBA] (optics) INFO: Switched ACE_optic_Hamr_2D to ACE_optic_Hamr_PIP` após a segunda aplicação: mudança feita por mod óptico, não é prova de rollback.
- `Fresnel k must be >0` segue aviso do motor/gráfico sem nexo demonstrado com UC-001-B.
- `UI_PERF` de Weapons neste RPT: FULL **n=30**, mediana **541,5 ms**, máximo **1768 ms**; DRAFT_FOCUSED **n=48**, mediana **82,5 ms**, máximo **312 ms**; CATALOG_FOCUSED **n=17**, mediana **196 ms**, máximo **1282 ms**. Inclui auto-testes e não deve ser diretamente comparado com subconjuntos manuais de R1. No trecho manual após runner, FULL de 23:39:18 foi **282 ms**, e seletores `COMPAT_SELECT` ficaram **25–27 ms**.
- A interface Items também abriu no final com `OPEN_ITEMS ... success=true`; a construção do catálogo estava em curso ao término do RPT.

## Encaminhamento

1. **R2 aceita no gate automático**: 1518/1518, 0/0; corrigida a falha contratual de R1. Preservar o arquivo mission-first, o SHA e a baseline R5.
2. **Manual parcialmente comprovado**: duas aplicações reais no slot PRIMARY usando alguns acessórios RHS/ACE. Para fechar homologação UC-001-B, testar peça de underbarrel realmente CBA-only em arma MCC, confirmar resultado físico e pós-validação/rejeição segura; comparar com ACE Arsenal se disponível.
3. Corrigir em próxima candidata a literal `AUTO_TEST_SUMMARY mode=...R1` e adicionar gate estático. Não falsear nem reescrever o resultado do RPT recebido.
4. Manter PR #11 **Draft, sem merge** até decisão do operador. Depois, UC-001-C magazines/wells, UC-001-D e2e, WST-001 persistência de perfil antes da distribuição.

Evidência na sessão local do operador: `Texto colado(20261015-024245).txt`. RPT completo foi auditado como fonte anexa; o arquivo não é incorporado ao repositório por conter lista extensa de mods e dados operacionais.
