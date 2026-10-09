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
