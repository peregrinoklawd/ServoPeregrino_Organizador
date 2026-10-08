# Weapons 0.7-C — Post-Validation / Rollback C1

08/10/2026. **STATIC READY / RUNTIME PENDING**.

Branch: `feature/weapons-0.7-c-post-validation-rollback`.
Base: B2 `599c62c12cb7211d1c82c24986195dcfa1660db8`; B2 ainda aguarda runtime.
Semantic: `0.7.2.1`; build: `0.7.2.1-post-validation-rollback-c1-mission-first`.

## Arquitetura

Plan/Snapshot mantêm seus schemas congelados 0.7-A. O executor conserva a autoridade de mutação:
Plan -> Snapshot -> clone/target mutation -> post-validation -> SUCCESS, ou rollback -> validateApplicationRollback -> FAILED estruturado.

`rollbackApplicationSnapshot` restaura capturedLoadout com `setUnitLoadout [clone,false]` e animSpeedCoef. `validateApplicationRollback` compara loadout completo exato, fingerprint protegido, todos os 10 domínios e coeficiente de animação. Pós-validação de sucesso também exige animSpeedCoef preservado.

Códigos/phase:
- PRE_MUTATION: inválido/stale; mutationPerformed=false, rollbackAttempted=false;
- POST_MUTATION_ROLLBACK_SUCCEEDED: FAILED, rollbackAttempted=true, rollbackSucceeded=true, rollbackRestoredExactly=true;
- POST_MUTATION_ROLLBACK_FAILED: FAILED, código WEAPONS_APPLICATION_ROLLBACK_FAILED; diagnóstico contém validação, rollbackCode e estado observado.

Erro de rollback nunca vira SUCCESS. Rollback é automático; não é Undo.

## Fault injection restrito

Quarto argumento opcional do executor, vazio por padrão. Permitido somente em LAB local server, não remoto, unidade não-player explicitamente marcada `SP_ORG_Weapons_IsolatedFaultTarget=true`. UI normal não fornece argumento nem marca jogador.

- TARGET_DIVERGENCE: remove a linha alvo após aplicar;
- PROTECTED_DIVERGENCE: troca headgear após aplicar;
- AMMO_DIVERGENCE: altera rounds observados após aplicar.

Todos executam a mutação planejada antes do fault, registram `mutatedBeforeFault` e exigem que esse estado difira do Snapshot. Fault também altera animSpeedCoef; restauração deve devolver 0.9 observado no Snapshot.
Não é fake FAILED: a pós-validação física existente detecta a divergência real. Não substituímos o validador, não reduzimos asserts.
Fault em alvo sem marca é recusado PRE_MUTATION e não deixa delta.

## Gate cumulativo

R6 594 -> A 673 -> B2 890 -> C **978/978 esperado** (88 locais).
Cada um dos três faults tem 28 checks registrados ou BLOCKED; exige restauração exata dos índices 0..9, cobrindo target e não-target weapons, magazines/ammo, U/V/B com conteúdos, headgear/goggles/binocular/assignedItems e fingerprint. Cleanup espera scheduler até 5s e verifica objeto removido. Player intacto.

Stale continua coberto pelo runner B2: falha antes da mutação não é rollback.

## Limitação explícita

Rollback failure tem resultado distinto, mas não forçamos falha da engine de restauração. Destruir/locality-transferir o alvo não provaria restauração e manipular mocks criaria garantia enganosa. Gate de rollback failure engine/mod-specific permanece manual; não homologado por um cenário artificial. Nenhuma falha é mascarada.

A validação de loadout + animação não promete restaurar pose/animação ou currentMuzzle exatamente. Não iniciamos animação própria nesta fase.

## Teste real

Extrair missão `SP_ORG_Weapons_0_7_C_Post_Validation_Rollback_C1.VR` na pasta de missões Arma; não carregar PBO SP_ORG.
Somente após B2 verde, executar `SP_ORG LAB - TESTAR WEAPONS 0.7-C`. Enviar RPT completo com três ROLLBACK_DIAGNOSTIC e SUMMARY. Exigir 978 PASS, 0 FAIL, 0 BLOCKED.
UI física ainda deferred. Não merge main, não freeze, não 0.8.
