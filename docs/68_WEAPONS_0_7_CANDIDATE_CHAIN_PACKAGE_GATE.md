# Weapons 0.7 — B2 / C1 / D1

08/10/2026. Todas **STATIC READY / RUNTIME PENDING**. Nenhuma homologada/congelada. Sem merge main. Sem Weapons 0.8, Preview 3D ou PBO final. Items, UICommon e backlog Items 64 intocados.

## Entregas e rastreabilidade

Repositório: https://github.com/peregrinoklawd/ServoPeregrino_Organizador

| Entrega | Branch | Código empacotado | Static local | AUTO esperado no Arma | Workflow oficial |
|---|---|---|---|---|---|
| B2 | feature/weapons-0.7-b-slot-safe-apply | 599c62c12cb7211d1c82c24986195dcfa1660db8 | 139/139 | 890 PASS / 0 FAIL / 0 BLOCKED | https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37722533910 |
| C1 | feature/weapons-0.7-c-post-validation-rollback | 1ebffc47c125c50f4c69f321662101b3bf49c9f7 | 144/144 | 978 PASS / 0 FAIL / 0 BLOCKED | https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37722928050 |
| D1 | feature/weapons-0.7-d-ui-integration | 1997ef420d11313882322f931b771c18c69c26e5 | 148/148 | 1109 PASS / 0 FAIL / 0 BLOCKED | https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37723653489 |

D foi implementada em 264d4c0c509625bcb361987290bc4424783d25a0, seguida da correção de harness 1997ef4 (leitura de footer pelo comando suportado ctrlText). O ZIP entregue usa exclusivamente a última revisão.

A cadeia de código é B2 -> C1 -> D1, com commits parentes correspondentes. Eventual commit de documentação após esses artefatos não muda o source das missões testáveis.

Builds:
- B2: display 0.7-B, semantic 0.7.1.2, build 0.7.1.2-slot-safe-apply-b2-mission-first.
- C1: display 0.7-C, semantic 0.7.2.1, build 0.7.2.1-post-validation-rollback-c1-mission-first.
- D1: display 0.7-D, semantic 0.7.3.1, build 0.7.3.1-ui-integration-d1-mission-first.

## Os três FAILs da B1

RPT real analisado: Texto colado(20261008-030938).txt, 779 PASS / 3 FAIL / 782 executados. R6 594/594 e A 673/673 verdes.

1. PRIMARY operation=RECONFIGURE: fn_diffWeaponConfigurations expõe data.changes com objetos field/from/to. fn_createApplicationPlan procurava data.changedFields e recebia vazio. Troca de óptica na mesma arma/magazine tornava-se NO_OP.
2. PRIMARY physical apply succeeds: executor seguia NO_OP e não instalava óptica. Pós-validação corretamente rejeitava ausência do attachment. B2 deriva nomes de fields dos objetos changes, preserva diff e schema Plan, exige RECONFIGURE real e 17 -> 17 rounds.
3. Cleanup: isNull era consultado imediatamente após deleteVehicle. A documentação oficial esclarece que o objeto torna-se objNull no frame seguinte: https://community.bistudio.com/wiki/deleteVehicle . Isso sustenta a causa de timing do assert. O RPT não comprovou vazamento; a confirmação do cleanup corrigido exige o próximo RPT. B2 exige runner scheduled, aguarda remoção por até 5s e verifica ausência em allUnits/allMissionObjects; não remove o teste.

Nove checks de sucesso dependentes foram omitidos pela B1 quando apply falhou. B2 registra BLOCKED separadamente; não converte dependências bloqueadas em PASS. Expected saudável 890 = 673 legacy + 217 locais.

B2 acrescenta regressões same-class optic/muzzle/pointer/bipod/magazine; mesma configuração/magazine -> NO_OP. Remover magazine também conta como delta. Preserva fullMagazines=false e schema Plan/Snapshot 0.7-A, dryRunOnly=true e mutationAuthorized=false do Plan. Executor mantém autoridade de mutação.

B2 arquivos modificados:
- weapons/functions/application/fn_createApplicationPlan.sqf;
- weapons/functions/tests/fn_runDelivery0_7_BTests.sqf;
- weapons/script_version.hpp;
- missions/PACKAGE_MISSION_NAME.txt;
- docs/00, 09, 10, 44, 65;
- machine/PROJECT_STATE.json e MODULE_MATRIX.json;
- tools/validate_weapons_0_7.py.
Todos os caminhos weapons acima pertencem à missão canônica missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR.

Diagnóstico B2: operation, changedFields, configs/magazines current/desired; failed Result code/message/data, postValidationCode/postValidation, rollbackAttempted/rollbackRestoredExactly e target rows. Source de domínio diff não alterado.

## C: rollback explícito

Novas funções rollbackApplicationSnapshot e validateApplicationRollback. Executor após mutação exige pós-validação do target, magazines/ammo, fingerprint protegido e animSpeedCoef. Em FAILED restaura capturedLoadout com fullMagazines=false, restaura animSpeedCoef e verifica loadout exato + fingerprint + animação.

failurePhase distingue PRE_MUTATION, POST_MUTATION_ROLLBACK_SUCCEEDED e POST_MUTATION_ROLLBACK_FAILED. Stale Snapshot continua erro pré-mutação sem rollback.

Faults reais isolados:
- TARGET_DIVERGENCE remove slot alvo após apply;
- PROTECTED_DIVERGENCE troca headgear após apply;
- AMMO_DIVERGENCE muda rounds após apply.

Fault também altera animSpeedCoef. Runner exige mutação efetiva antes da falha, FAILED, rollbackAttempted=true, restauração exata, 10 domínios e fingerprint. Fixture contém PRIMARY/HANDGUN/SECONDARY, magazines parciais, uniforme/colete/mochila com conteúdo, headgear/goggles/binocular/assignedItems.

Guards: LAB enabled, server local, execução não remota, AI marcada isoladamente; jogador não elegível. UI não passa fault. Recusa de fault em AI sem marca é testada sem mutação.

Rollback failure é diagnosticado, mas não provocado artificialmente: destruir/transferir alvo ou mocks não provariam restauração real. Falha de restauração engine/mod-specific permanece limitação explícita de runtime. Não se promete restaurar pose/currentMuzzle exatamente.

Contrato, limitações e teste: docs/66_WEAPONS_0_7_C_POST_VALIDATION_ROLLBACK.md.

## D: draft físico sem autosave

Novo botão EQUIPAR RASCUNHO (IDC 2144) no espaço livre de ARMAS DO KIT; preserva controles/geometria existentes. EQUIPAR NO RASCUNHO do Catálogo continua edição lógica. Controle Catálogo -> equipamento mantém sua reserva, porque sua fonte é diferente do draft exigido.

Handler lê draftsByKitId[selectedKitId] naquele instante, inclusive ALTERADO. executeDraftApplication constrói WeaponKit transitório de Recipe deep-copiada, valida, cria Plan/Snapshot, executa core B/C e retorna Result.

Aplicação não chama save/update/create/publish de repository. Não limpa dirty/alterações, não modifica outros kits ou drafts. Falha mantém dados intactos e usa rollback C.

Refresh somente P4/rodapé, reason=APPLY_DRAFT, fullRefresh=false; instrumentation UICommon mantida. Nenhum rebuild de P1/P2/P3/Catálogo é solicitado pelo apply.

Feedback amigável para SUCCESS, NO_OP, stale, invalid draft, incompatible, FAILED/restaurado e rollback failure; códigos seguem no RPT.

**Undo: UNDO_DEFERRED.** Não há botão, estado de Undo ou promessa de restauração voluntária. Nesta rodada os gates concentram-se em aplicação, rollback e UI; invalidação externa/session lifecycle de Undo ainda não testados.

D runner: seis cenários físicos isolados via função compartilhada com handler, dirty draft, dois kits existentes, outro draft intacto, partial ammo, SECONDARY family-aware, falha pela rota draft e rollback C. Testa mensagens e exerce handler real no jogador somente NO_OP capturado, sem alterar seu loadout; confere P4/rodapé e contadores FULL/P2/P3 inalterados. Aplicação com delta no jogador segue gate manual.

Detalhes: docs/67_WEAPONS_0_7_D_UI_INTEGRATION.md.

## O que foi verificado

Static local: delimitadores SQF, resolução e registro de funções, schemas/flags Plan congelados, fullMagazines=false em application, JSON, ownership/protected paths e pré-processamento de todos os SQF Weapons + mission description/includes.

Esse gate não é compilador SQF nem execução Arma. Workflows oficiais de packaging concluíram success; não executam o engine Arma e não homologam runtime.

Artefatos oficiais baixados, ZIP/CRC verificados, digest do artifact comparado ao GitHub e SHA256 da missão conferido com arquivo oficial. Conteúdo da missão comparado ao commit correspondente (normalização de CRLF/LF somente em arquivos textuais): B2 454 arquivos; C 457; D 460. Não houve reconstrução manual ou reempacotamento local de entrega.

## SHA256 das missões

| ZIP | SHA256 |
|---|---|
| SP_ORG_Weapons_0_7_B_Slot_Safe_Apply_B2.zip | cfce85b1d61b681989fe474697e4d063c4df185c8870c63ae53e10553ec13531 |
| SP_ORG_Weapons_0_7_C_Post_Validation_Rollback_C1.zip | 881bb254b19fbb218d6231e29c7a2189e16a269b26b52310ad34a232d6fe0be7 |
| SP_ORG_Weapons_0_7_D_UI_Integration_D1.zip | 19a146c56b552cf0c17db1c25cf2a7e7fd84af3c40045d140e85f8e9547dc3c1 |

Artifacts: B2 11526219044; C 11525519646; D 11527480050. Mission source único no Git; nomes específicos somente no pacote, conforme PACKAGE_MISSION_NAME.txt e workflow oficial.

## Ordem exata de testes

Extrair cada ZIP e mover sua pasta .VR inteira para a pasta de missões do Arma que você já usa. Não carregar PBOs SP_ORG. Utilizar seu modset habitual, incluindo ACE/CBA/RHS/Tier One, e enviar RPT completo.

1. B2: carregar SP_ORG_Weapons_0_7_B_Slot_Safe_Apply_B2.VR e executar **SP_ORG LAB - TESTAR WEAPONS 0.7-B**. Esperado 890 PASS / 0 FAIL / 0 BLOCKED. Conferir player intacto. Se falhar, parar a sequência e enviar RPT.
2. C: somente depois de B2 verde, carregar SP_ORG_Weapons_0_7_C_Post_Validation_Rollback_C1.VR e executar **SP_ORG LAB - TESTAR WEAPONS 0.7-C**. Esperado 978 PASS / 0 FAIL / 0 BLOCKED e três faults seguidos de rollback confirmado. FAILED dos cenários de fault é esperado como dado do executor; os asserts AUTO devem ser PASS. Se houver FAIL/BLOCKED, parar e enviar RPT.
3. D: somente depois de C verde, carregar SP_ORG_Weapons_0_7_D_UI_Integration_D1.VR e executar **SP_ORG LAB - TESTAR WEAPONS 0.7-D**. Esperado 1109 PASS / 0 FAIL / 0 BLOCKED.
4. D manual: **SP_ORG LAB - ABRIR WEAPONS**. Criar/selecionar kit, editar óptica/carregador e manter ALTERADO. **EQUIPAR RASCUNHO**: conferir personagem/P4 e status ALTERADO; kit salvo deve permanecer igual. Repetir: NO_OP. SALVAR é ação separada.
5. D manual: repetir PRIMARY/HANDGUN/SECONDARY, REPLACE/INSERT/RECONFIGURE, partial ammo (17 -> 17), acessórios do modset. Verificar demais armas, U/V/B/conteúdos e assignedItems preservados. Não há Undo nesta candidata.
6. Conferir RPT UI_PERF EQUIPMENT_FOCUSED reason=APPLY_DRAFT fullRefresh=false, sem FULL/CATALOG/DRAFT provocado pela aplicação. Enviar RPT e observações visuais/manual de cada missão separadamente.

Nenhuma candidata passa a HOMOLOGATED/FROZEN automaticamente. O próximo trabalho é analisar esses RPTs, corrigir qualquer FAIL e só então decidir homologação.
