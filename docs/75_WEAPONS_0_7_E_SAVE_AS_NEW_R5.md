# Weapons 0.7-E E1 R5 — Consertar SALVAR COMO NOVO em captura NOVO

Data: 09/10/2026. Branch: `feature/weapons-0.7-e-equipment-capture`.
**CANDIDATA — AUTOMÁTICO/TESTE MANUAL R5 PENDENTES**.
Display `0.7-E`, semantic `0.7.4.5`,
build `0.7.4.5-pending-save-as-new-e1-r5-mission-first`.
Base de continuidade R4, sem alterar `baseline/weapons-0.7-d2-r1-homologated`.

## RPT real recebido

Arquivo `Texto colado(20261009-223935).txt`, 2747 linhas, com sessão R4:
- `MISSION_FIRST_0_7_E_R4 passed=1430 failed=0 blocked=0 total=1430 expected=1430` (19:36:13).
- `COMPAT_AUDIT_SUMMARY isolatedDummyDeleted=true playerLoadoutMutated=false` (19:37:33).
- `EQUIPMENT_CAPTURE` existente (19:37:46) e NOVO (19:37:52; 19:38:40): `MCC_RD704_AFG` `partial=false omissions=[]`; `MCC_Handbrake_BLK` mantido no WeaponRecipe.
- `DRAFT_APPLY` `WEAPONS_APPLICATION_APPLIED` (19:38:53), `AMMO_D2_ROW` pós-validação conserva `MCC_Handbrake_BLK`; sem rollback.
- Várias edições `DRAFT_NAME_INPUT`, mas **nenhum evento SAVE_REQUEST/SAVE_RESULT no R4** (o log R4 não os possuía): o clique no botão desabilitado não alcançava `handleUIEvent`. O evento SAVE_AS_NEW quando `selectedKitId=""` também rejeitava a operação.

## Causa e mudança cirúrgica

1. `fn_refreshDraftUI.sqf`: IDC `2141` (SALVAR COMO NOVO) era expressamente desabilitado se `_capturedNew`. Na R5, habilita quando o rascunho NOVO tem Recipe, com tooltip explicando que equivale ao primeiro SALVAR. O botão SALVAR original (IDC `2140`) mantém a função existente.
2. `fn_handleUIEvent.sqf`: evento `SAVE_AS_NEW` com `pendingNewKit=true`, `selectedKitId=""` e `pendingCapturedDraft` válido é encaminhado a `SAVE_DRAFT` **somente nesse estado**. Usa a validação de nome e Recipe existente, cria **exatamente um WeaponKit**, seleciona-o e limpa o pending. Para kit previamente salvo, `SAVE_AS_NEW` mantém o comportamento de duplicação independente e preservação da origem.
3. Trilha de auditoria `SAVE_REQUEST`, `SAVE_ALIAS` e `SAVE_RESULT`: evento, contexto pending, código de sucesso/falha. Evita diagnosticar clique inerte quando não há handler.
4. Removida chamada extra incondicional ao getter em `fn_refreshDraftUI`; fica apenas o caminho correspondente a draft normal ou pending capturado.
5. **Nenhuma alteração de semântica física**: sem autosave, sem mutar loadout, sem modificar `fn_applyApplicationPlan`, `fn_validateAppliedApplicationState`, `fn_rollbackApplicationSnapshot`, nem UICommon/Items/Nexus.

## Regressões de R5

São **16 novas assertions** em `fn_runDelivery0_7_ETests.sqf`, acrescidas às 1430 da R4. Meta: **1446/1446, 0 FAIL, 0 BLOCKED**.
Elas exercitam um rascunho físico NOVO real, ausência de registro antes do clique, refresh/IDCs habilitados, nome preservado, evento `SAVE_AS_NEW`, criação de ID independente, preservação da Recipe, somente 1 novo WeaponKit, limpeza do pending, kit salvo anterior intacto e equipamentos físico/jogador inalterados.

Teste manual indispensável: NOVO → CAPTURAR (MCC + Handbrake) → editar nome → SALVAR COMO NOVO → verificar lista/status SALVO e reabrir kit; repetir com SALVAR e com SALVAR COMO NOVO de kit já existente. Encaminhar RPT integral.

## Requisito de produto que NÃO pode ser esquecido

O pedido do operador de compatibilidade completa virou **UC-001 — Compatibilidade Unificada Completa**, documentado em `docs/74_WEAPONS_UNIFIED_COMPATIBILITY_ARCHITECTURE.md`.

Abrange todas as miras, acessórios de boca, apontadores, bipés/empunhaduras, carregadores, magazine wells, lançadores e variantes de armas, harmonizando as fontes Arma 3/CBA e interfaces públicas disponíveis do ACE/ACE Arsenal com catálogo, seletores, captura e validação. **Pendente de implementação:** apenas UnderBarrel já usa CBA na R4/R5. Após R5 homologada, UC-001 é o próximo gate funcional prioritário, em entregas separadas, sem whitelist por mod.

Baseline D2 R1 preservada; nenhum merge/PBO/MP/JIP/Undo nessa etapa.
