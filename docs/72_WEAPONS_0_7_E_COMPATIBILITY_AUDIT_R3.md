# Weapons 0.7-E E1 R3 — Compatibilidade real ACE/Arma e correção do Catálogo

Data: 2026-10-09. Branch candidata `feature/weapons-0.7-e-equipment-capture`.
Display `0.7-E`; semantic `0.7.4.3`; build `0.7.4.3-equipment-compatibility-audit-e1-r3-mission-first`.
**STATIC READY / RUNTIME PENDING**. D2 R1 estável `baseline/weapons-0.7-d2-r1-homologated` **intocada**. Sem merge main.

## Problema reproduzido (RPT E1 R2 anterior)

- `MISSION_FIRST_0_7_E_R2 passed=1408 failed=0 blocked=0 total=1408`.
- 18:17:15: captura física `MCC_RD704_AFG` retorna `success=true`, mas `capturePartial=true`: `MCC_Handbrake_BLK` excluído do campo `bipod`, motivo `ENGINE_ATTACHMENT_INCOMPATIBLE`.
- Aviso de engine próximo: `[weapon MCC_RD704_AFG]: item[rhsusf_acc_grip2] does not match to this weapon!`. **Não confundir** o `rhsusf_acc_grip2` mencionado no aviso com a classe `MCC_Handbrake_BLK` excluída, nem tratar coincidência temporal como prova de equivalência.
- 18:21:08: aplicação de draft à arma `MCC_RD704_AFG` registra `WEAPONS_APPLICATION_APPLIED`, preservando o slot inferior `MSS_EI_Revoloution`. É um item diferente do excluído anteriormente; não prova que o `MCC_Handbrake_BLK` é compatível.
- 18:17:15: após CAPTURAR, `CATALOG_FOCUSED ... projectionBuilt=false` com ID de kit inalterado, sinal de reuso indevido da projeção de acessórios da arma anterior.
- Compatibilidade do módulo: `fn_getWeaponCompatibility` e `fn_validateWeaponConfigurationSemantic` consultam unicamente `compatibleItems [_weapon, "UnderBarrelSlot"]`. O filtro BIPÉ/EMPUNHADURA separa esse mesmo conjunto por heurística de nome, sem resolução própria ACE/CBA.
- No estado NOVO, sem `selectedKitId`, o caminho antigo não obtinha `pendingCapturedDraft` para compor catálogo de acessórios.

## R3 — Alterações de escopo fechado

1. **Invalidar projeção do Catálogo** quando captura modifica o draft do kit selecionado, sem alterar equipamento, persistência ou validador.
2. **Fonte NOVO**: `fn_getUICatalogWindow` extrai `weaponClass` e `targetSlot` de `pendingCapturedDraft`, mesmo sem kit salvo. Não cria WeaponKit.
3. **Slot do draft**: projetar a classe e o slot atual do rascunho, e não o slot original do kit salvo, após captura entre destinos.
4. **Chave da projeção** inclui weaponClass e targetSlot, além de versão/cache/sourceKitId. Rebuild dedicado, preservando janela/scroll e refresh focalizado.
5. **Diagnóstico isolado e genérico**: `fn_diagnoseEquippedWeaponCompatibility.sqf`, função registrada em CfgFunctions > Weapons > Tests. Compara `compatibleItems` (Arma, UnderBarrelSlot), `CBA_fnc_compatibleItems` (CBA, bipod), `BIS_fnc_compatibleItems` quando presentes. Verifica classe física do slot, variante `baseWeapon`, config direta, rascunho e projeção. Apenas **unidade temporária local** recebe `setUnitLoadout` para medir retenção imediata e após pequeno atraso, nunca a unidade do jogador.
6. Os exemplos `MCC_Handbrake_BLK`, `rhsusf_acc_grip2`, `MSS_EI_Revoloution` são passados **somente pela ação LAB**, derivados do RPT observado. O resolvedor permanece genérico para qualquer arma equipada.

**Nenhuma whitelist de mod**; nenhum `CfgRemoteExec`, `remoteExec`, relaxamento do validador semântico, mutação da aplicação física ou absorção automática de diferenças ACE. A R2 continua **captura parcial identificada** até medirmos se há compatibilidade válida que a fonte antiga ignorou.

### Comandos e resultados esperados

Na mesma missão, após equipar a arma/mods desejados:
- `SP_ORG LAB - TESTAR WEAPONS 0.7-E R3`: meta cumulativa **1420/1420**, 0 FAIL, 0 BLOCKED. 1360 D2 + 48 E1/R2 + 12 R3.
- `SP_ORG LAB - DIAGNOSTICAR COMPATIBILIDADE`: **não é teste de aprovação do motor**, mas instrumento de auditoria. Registra `[COMPAT_AUDIT_CONTEXT]`, `[COMPAT_AUDIT_LISTS]`, `[COMPAT_AUDIT_ITEM]`, `[COMPAT_AUDIT_ISOLATED]`, `[COMPAT_AUDIT_SUMMARY]`.
- Reabrir Weapons e executar CAPTURAR com kit selecionado; conferir `CATALOG_FOCUSED reason=EQUIPMENT_TO_DRAFT projectionBuilt=true` quando classe/slot diferir. Filtros BIPÉ/EMPUNHADURA continuam baseados na compatibilidade *vanilla*.
- Repetir NOVO → CAPTURAR → Catálogo/seletores ANTES de SALVAR; não deve faltar fonte de arma. Nenhum salvamento automático.

Os campos `engineRetainedImmediate` e `engineRetainedStable` descrevem o experimento em unidade isolada e **não são prova automática de compatibilidade com ACE Arsenal**; várias configurações de mods podem variar por runtime/preset. Interpretar junto às listas e ao RPT.

## Empacotamento oficial

- Run GitHub Actions [37994369636](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37994369636) — **SUCCESS**, `STATIC SUMMARY 203/203`.
- Commit da missão ZIP: `5936345a44fe6632f8bc2901068ac6b3bc503a14`.
- Artifact oficial `11645798361` (`SP_ORG_UI_Lab`).
- Missão única: `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R3.VR`.
- ZIP `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R3.zip` SHA256 `16b6c82ce4f1a93f218032a13ae8a5b9c4cc013cd21e6a9852d1764273f54ade`.
- Verificado localmente: ZIP com 519 entradas, 1 pasta raiz, CRC sem erros, função de diagnóstico e runner R3 presentes.

**PENDENTE**: RPT do Arma 3 e testes manuais do operador para E1 R3. Não homologar nem congelar E1 nesta fase.

## R3 R1 — Hotfix após RPT real de 09/10/2026

O RPT integral da missão R3, entre 18:41 e 18:45, apontou **1419 PASS / 1 FAIL / 0 BLOCKED**, com único FAIL `E R3 catalog slot follows captured draft`. O Catálogo era reconstruído para a classe correta da arma, mas lia o slot do WeaponKit salvo **antes de buscar o rascunho modificado**; um kit antigo de HANDGUN capturado para PRIMARY expunha o slot anterior. A correção pontual reordena `getOrCreateWeaponKitDraft` e leitura de `targetSlot` em `fn_getUICatalogWindow.sqf`. A CI exige explicitamente essa ordem.

O mesmo RPT confirma capturas parciais às 18:43:20 (kit existente) e 18:45:30 (NOVO), arma `MCC_RD704_AFG`, bipod-slot observado `MCC_Handbrake_BLK`, exclusão `ENGINE_ATTACHMENT_INCOMPATIBLE`. A projeção foi reconstruída (`projectionBuilt=true`). Não há nenhuma linha `COMPAT_AUDIT`: **o diagnóstico específico Arma/CBA/BIS não foi executado ou não foi registrado**; nenhuma conclusão definitiva sobre compatibilidade dinâmica é autorizada por esse RPT. Aviso da engine cita separadamente `rhsusf_acc_grip2`.

- Entrega: `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R3_R1.VR`, semantic **0.7.4.3**, build `0.7.4.3-equipment-compatibility-audit-e1-r3-r1-mission-first`.
- Workflow [37995683506](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37995683506): **SUCCESS**, 204/204 checks estáticos.
- ZIP `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R3_R1.zip`: SHA256 `9d80f9ac0003976a8154e482b0449b87a18ac104e801548e315cd6388fea88d0`; 519 entradas, CRC válido, uma única pasta raiz, laboratório diagnóstico presente.
- **Ainda não homologada.** Novo gate cumulativo: **1420/1420**, 0 FAIL, 0 BLOCKED, seguido de **SP_ORG LAB - DIAGNOSTICAR COMPATIBILIDADE** (com arma MCC equipada, após fechar ACE Arsenal) e avaliação manual em kit existente/NOVO. Sem whitelist, alteração no executor físico, modificações da baseline D2 R1, merge ou PBO.
