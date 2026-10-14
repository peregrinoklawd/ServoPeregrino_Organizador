# Weapons 0.7-E E1 R5 — Auditoria real do RPT / 14 outubro 2026

**Resultado: regressões automáticas aprovadas + usuário confirma testes manuais sem problemas.** Não houve implementação nova nesta revisão. NÃO promover baseline, não fazer merge, não criar PBO nem iniciar MP/Undo sem aprovação distinta.

## Evidência

RPT completo do Arma 3 `Texto colado(20261014-174058).txt`, 10.181 linhas, SHA-256 `763d126c8cec883933825885f7947b8653e868969dcb3edb84c47c36e3e61bcb`; execução local 14/10/2026. Contém as seguintes linhas cumulativas:
- R6 `594/594` (L8837), A `673/673` (L8917), B `890/890` (L9187), C `978/978` (L9310);
- D `1109/1109` (L9523), D2 `1360/1360` (L9928), **E R5 `1446/1446 failed=0 blocked=0 expected=1446` (L10047, às 14:24:44)**.
- R5 tem 86 assertions locais (inclui 16 novas relativas ao SALVAR COMO NOVO pendente), todas PASS. RPT mostra `WEAPONS_0_7_E_R5_AUTO_TEST_COMPLETE success=true` L10048. Não há `[SP_ORG] [WEAPONS] [ERROR]`.

## Evidência do fluxo manual que falhava

- 14:26:56, L10089–10090: equipamento `MCC_RD704_AFG` e carregador `30rnd_762usak_trs_nmg` capturados para `pendingNewKit=true`, `createdNew=true`, `partial=false`, `omissions=[]`, `loadoutMutation=false`. Captura não salva.
- 14:27:15 L10120–10122: clique em `SAVE_AS_NEW` do NOVO sem `kitId`, redirecionado explicitamente `SAVE_AS_NEW_PENDING -> SAVE_DRAFT`; `SAVE_RESULT path=PENDING_FIRST_SAVE success=true code=WEAPONS_KIT_CREATED`.
- 14:27:16 L10123–10125: `pendingNew=false`, ID novo `...-24`, lista 8 → 9 kits.
- 14:28:21 L10167: `SAVE_DRAFT` recebido em kit existente; não possui `SAVE_RESULT` explícito para esse caminho no logger R5, mas refresh executado.
- 14:28:34 L10177–10178: `SAVE_AS_NEW` de kit salvo, `path=EXISTING_SAVE_AS_NEW success=true code=WEAPONS_KIT_CREATED`.
- 14:28:35 L10179–10181: ID novo `...-25`, lista 9 → 10 kits.
- O usuário declara que os testes manuais e automáticos foram realizados sem perceber erro. O RPT não observa diretamente cada clique/qualidade visual e não prova cobertura para todos os mods/armas.

## Ocorrências externas (não silenciar)

Existem **24 erros `Error in expression`** (L8021–8089, 8927–8935, 9191–9199, 9315–9323, 9530–9538, 9935–9943), todos apontando a `/x/cba/addons/common/fnc_addPerFrameHandler.sqf` linha 30 com parâmetros em tipos inválidos (`Strings` em vez de `code`, ou `code` em vez de `Número`). Não há stack do SP_ORG apontada como origem. **Provável problema de integração/uso de CBA por algum mod carregado**, mas a autoria exata não está demonstrada. Ocorrências não falharam os gates, recomendada investigação separada se houver efeitos em jogo.

O RPT contém dezenas/centenas de avisos de stringtable/config, addons conflitantes e script de outros mods não encontrado durante o carregamento. Também registra rollback diagnóstico esperado no D2: `NO_MAG_D2_DIAGNOSTIC success=false` em L9546, mas `failurePhase=POST_MUTATION_ROLLBACK_SUCCEEDED`, `rollbackRestoredExactly=true`; **é teste negativo aprovado, não falha de produção**.

## Performance — apenas observação

Durante toda a sessão: 46 refreshes completos com mediana ~444 ms e máximo 1823 ms (antes do teste automático, L8686). Após R5 automática, refreshes completos observados até 464 ms. Não houve queixa de stutter neste envio; monitorar na expansão UC-001, sobretudo com muitos mods.

## Decisão

- **E1 R5: runtime automático GREEN + evidência manual de salvamento e captura GREEN**; correção de SALVAR COMO NOVO validada. Pode ser proposta para formalização de baseline, **sem alterar a baseline D2 nem fazer merge nesta revisão**.
- **UC-001 continua REQUIRED / NOT_IMPLEMENTED_FULLY**: todas as fontes Arma/CBA/ACE por slot, magazines, variantes, validação semântica/física/rollback. Documento `docs/74_WEAPONS_UNIFIED_COMPATIBILITY_ARCHITECTURE.md`.
- Não confundir sucesso R5 de UnderBarrel + Save com comprovação de compatibilidade completa.
- MP/JIP/PBO/Undo mantidos diferidos; congelar R5 como referência da linha 0.7-E antes de estender UC-001, após decisão explícita.
