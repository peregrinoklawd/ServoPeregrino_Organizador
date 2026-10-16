# UC-001-B R2 — APROVAÇÃO FORMAL COM EXCEÇÃO DE COBERTURA

**Decisão do operador: 16/10/2026.** UC-001-B (resolver unificado de acessórios para Muzzle, Pointer, Optic e Underbarrel) **encerrada e aprovada**, com aceitação explícita de uma lacuna de teste manual.

## Baseline aprovada

- Display `0.7-F`; semantic `0.7.5.2`; build `0.7.5.2-uc001-b-r2-legacy-source-contract-mission-first`.
- Missão `SP_ORG_Weapons_UC_001_B_Unified_Attachments_R2.VR` da CI 38666282681 (33/33 estáticos), artifact 11942210059, ZIP SHA256 `7deef9483c14fdb2fd7ae33daebd032245b740a768a1a54e2370a2c40fcae7db`.
- Arma 3 real, RPT de 14/10: 1518/1518 AUTO, 0 FAIL, 0 BLOCKED; R5 legado 1446/1446; aplicações físicas PRIMARY REPLACE e RECONFIGURE com RHS/ACE aprovadas e pós-validadas.
- Fontes motor/CBA unificadas no catálogo e no validador semântico para quatro campos; rollback D2 preservado. Ver `docs/82_WEAPONS_UC001B_R2_RPT_REVIEW.md`.
- Não confundir aprovação da **UC-001-B** com homologação do requisito global **UC-001 completo**; UC-001-C carregadores e UC-001-D end-to-end ainda não executadas.

## Pendência conhecida aceita por decisão explícita

**UC001B-DEFER-001 — Gate físico manual MCC/CBA-only**
- Não foi executada aplicação física manual de uma empunhadura que conste **exclusivamente na lista CBA** para uma arma MCC (ex. MCC_RD704_AFG); não alegar que foi testada.
- A comparação lógica demonstrou MCC_RD704_AFG 44 acessórios engine contra 87 CBA para bipod (+43).
- O operador **autorizou pular** o teste e **aprovou UC-001-B**; registrar como **KNOWN_ACCEPTED_TEST_GAP**, não como PASS, FAIL ou correção implementada.
- Retomar preferencialmente no gate UC-001-D e2e, antes de distribuir versão PBO/MP; registrar RPT, provar pós-validação D2 ou falha segura com rollback se a arma rejeitar peça.
- O registro da pendência **não bloqueia UC-001-C**.

Outras pendências não bloqueantes herdadas:
- `UC001A-SECONDARY`: diagnóstico de lançador equipado não executado.
- `UC001B-OBS-002`: literal final do runner ainda diz `MISSION_FIRST_UC001B_R1`, enquanto build, asserts e resultado são R2; corrigir na nova linha (não alterar baseline aprovada).
- `UC001B-PERF-003`: atualizar/reduzir custo de `UI_PERF FULL` em grande modset na UC-001-D / etapa própria.
- `EXT-CBA-004`: 24 warnings do perFrameHandler com chamador não identificado, não atribuídos ao SP_ORG.
- `WST-001`: kits privados ainda SESSION_LOCAL; persistência entre missões pendente.
- MP/JIP, addon/PBO, Undo, WUX-002 (magazines para colete), WUX-003 (filtros ícones) fora da B.

**Política:** congelar branch/commit de aprovação por marcador de baseline; manter PR #11 Draft sem merge na main. Continuar UC-001-C em branch filha, nunca editar a baseline de B.
