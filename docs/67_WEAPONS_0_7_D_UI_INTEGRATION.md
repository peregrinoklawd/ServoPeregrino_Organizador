# Weapons 0.7-D — UI Integration D1

08/10/2026. **STATIC READY / RUNTIME PENDING**.
Branch: `feature/weapons-0.7-d-ui-integration`.
Base C: `1ebffc47c125c50f4c69f321662101b3bf49c9f7`; B2/C aguardam RPT real.
Semantic `0.7.3.1`; build `0.7.3.1-ui-integration-d1-mission-first`.

## Fonte e semântica

APLICAR/EQUIPAR NÃO É SALVAR.

Novo controle mínimo `2144`, EQUIPAR RASCUNHO, no espaço livre do painel ARMAS DO KIT (y=0.615), alinhado à altura das ações existentes do Catálogo. Nenhuma geometria existente foi alterada.

Antes da implementação foram inspecionados dialog canônico, handler, draft store e refreshers. O controle reservado `3151` fica no Catálogo e tem fonte de seleção do Catálogo: mantê-lo reservado evita equipar uma fonte diferente daquela anunciada. EQUIPAR NO RASCUNHO continua authoring lógico; EQUIPAR RASCUNHO aplica fisicamente o draft exibido.

APPLY_DRAFT lê `draftsByKitId[selectedKitId]` no momento do clique. `executeDraftApplication` recebe esse draft, deep-copia Recipe e constrói WeaponKit transitório de schema 0.5, com WKT-TRANSIENT-DRAFT; nunca chama create/update/save/publish do repository.

Fluxo: validar Recipe/Kit -> Plan -> Snapshot -> executor B/C -> pós-validação -> rollback em FAILED -> Result estruturado. ALTERADO pode aplicar. Apply não altera recipe, dirty, revision, outros drafts ou kits. SALVAR continua a única ação de commit do draft.

Falha não limpa draft nem repository. Não implementar MP/remote authority/JIP; nenhum RemoteExec policy alterado.

## Refresh e mensagens

Handler faz `_refresh=false`, atualiza `equipmentSlotView` para slot aplicado e solicita somente EQUIPMENT_FOCUSED reason=APPLY_DRAFT. P4 recaptura o estado observado após apply/rollback. Rodapé usa renderer UICommon existente. Contadores e medição via UICommon preservados. Nenhum refresh P1/P2/P3 ou rebuild de Catálogo é provocado pelo apply.

Feedback human-readable para SUCCESS, NO_OP, stale, invalid draft, incompatible configuration, FAILED com restauração confirmada e rollback failure. Códigos e snapshots ficam no RPT/diagnóstico; mensagem principal não contém códigos crus.

O Catálogo direto -> equipamento permanece deferred; D integra exclusivamente a fonte exigida: draft atual de ARMAS DO KIT.

## Undo

**UNDO_DEFERRED**. Não existe armazenamento/controle de Undo.
C ainda não foi homologada com engine/modset real; Snapshot não formaliza restauração exata de pose/currentMuzzle. Nesta rodada concentramos os gates determinísticos em rollback automático e UI/apply; não oferecemos Undo antes de testar invalidação externa e lifecycle de sessão. Rollback continua obrigatório e independente.

## Testes

Cumulativo: R6 594 -> A 673 -> B2 890 -> C 978 -> D **1109/1109 esperado** (131 locais).

Seis cenários reais isolados via a mesma `executeDraftApplication` utilizada pelo handler:
- PRIMARY INSERT;
- HANDGUN REPLACE P07 -> ACP-C2;
- SECONDARY INSERT NLAW;
- PRIMARY RECONFIGURE optic_Hamr, 17 -> 17 rounds;
- PRIMARY NO_OP, 11 rounds preservados;
- SECONDARY RPG32, validação strict/family-aware de variant observada.

Cada cenário tem 16 checks (ou BLOCKED): source draft ALTERADO, persistência independente, dois kits repository existentes, outro draft intacto, fingerprint, ammo, slot/operation, fullMagazines=false e feedback.

Sete checks da rota FAILED provam mutação antes da falha, rollback C, estado físico exato, draft/repository intactos, draft inválido e configuração incompatível sem mutação.
Sete checks verificam mensagens por código.

Handler real APPLY_DRAFT é executado no player somente com Recipe capturada NO_OP: 14 checks para loadout/repository/drafts intactos, P4 refletindo o estado observado, refresh P4 +1, FULL/P2/P3 sem incremento, botão e feedback. O harness não equipa arma nova no player. Aplicação com delta no jogador é gate manual obrigatório.

Nenhum teste engine anterior removido. Runner B aceita o marker UI D como evolução explícita, mantendo contagem e assertions de core. D exige comportamento físico/ownership/performance adicional.

## Teste real sequencial

1. Aprovar B2 real antes de C; C real antes de D. Parar em qualquer FAIL/BLOCKED.
2. Extrair `SP_ORG_Weapons_0_7_D_UI_Integration_D1.VR` para as missões Arma. Não carregar PBO SP_ORG.
3. Executar `SP_ORG LAB - TESTAR WEAPONS 0.7-D`: esperado 1109 PASS, 0 FAIL, 0 BLOCKED.
4. Abrir Weapons. Criar/selecionar kit, editar draft e deixar ALTERADO.
5. EQUIPAR RASCUNHO: conferir arma/acessórios/ammo no personagem e P4; status ALTERADO deve permanecer. Fechar/reabrir: draft de sessão permanece; kit salvo não mudou.
6. Repetir aplicação: feedback NO_OP. Repetir PRIMARY/HANDGUN/SECONDARY com modset ACE/CBA/RHS/Tier One; verificar 17 rounds no RECONFIGURE.
7. Conferir U/V/B/conteúdos/outras armas/assignedItems; conferir UI_PERF EQUIPMENT_FOCUSED reason=APPLY_DRAFT, fullRefresh=false, sem FULL/CATALOG/DRAFT triggered pelo apply.
8. Enviar RPT completo e observações visuais/manual.

Não homologar por Actions verde; não merge main; não iniciar 0.8.
