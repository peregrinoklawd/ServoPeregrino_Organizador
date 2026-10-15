# Weapons UC-001-B R1 — RPT real, causa-raiz e correção R2 (14/10/2026)

## Evidência de runtime

Fonte: `Texto colado(20261015-012435).txt`, log Arma 3 2.22.154089 com 10.469 linhas (sessão de 14/10/2026). PR #11 Draft; base PR #10 Draft; baseline `baseline/weapons-0.7-e-r5-homologated` intocada.

### Runner UC-001-B R1 — REPROVADO, causa única reproduzida

Às 21:04:34, linha 10137: `mode=MISSION_FIRST_UC001B_R1 passed=1508 failed=8 blocked=0 total=1516 expected=1516`.

Os oito FAIL acumulam **uma falha de regressão original**, e não oito defeitos independentes:

| Teste | PASS/total | Origem |
|---|---|---|
| baseline 0.6-F R6 | 593/594 | FAIL 0.3 compatibility source marker, linha 8312 |
| 0.7-A | 671/673 | falha anterior + baseline cumulativo |
| 0.7-B | 887/890 | idem |
| 0.7-C | 974/978 | idem |
| 0.7-D | 1104/1109 | idem |
| 0.7-D2 | 1354/1360 | idem |
| 0.7-E R5 | 1439/1446 | idem |
| UC-001-B R1 | **1508/1516** | R5 cumulativo único FAIL; **69/70 asserções B passaram** |

O teste original em `fn_runDelivery0_6_FR6Tests.sqf` exige `(_mxCompat get "source") isEqualTo "ENGINE_COMPATIBLE_COMMANDS"`. A implementação UC-001-B R1 em `fn_getWeaponCompatibility.sqf` alterou indevidamente essa propriedade pública para `ENGINE_WITH_OPTIONAL_CBA_ATTACHMENTS`. **Não é erro do CBA, da engine, da instalação do usuário ou das classes MCC.** É regressão interna de contrato/identidade de metadados.

### Compatibilidade funcional e interação manual

- UC-001-B R1 resolveu corretamente rifle vanilla `arifle_MX_F`, pistola `hgun_P07_F`, launcher `launch_NLAW_F` e arma MCC `MCC_RD704_AFG`.
- MCC_RD704_AFG às 21:04:30: `COMPAT_SOURCE_DIFF` (bipod) engine 44, CBA 87, **43 CBA adicionais**. `COMPAT_RESOLVE` quatro slots: muzzle 107, pointer 1528, optic 1270, bipod 87.
- MCC_RattlerLT_7_762x39_BLK_MPLFS_AFG às 22:20:36: engine bipod 0, CBA 43, **43 CBA adicionais**. Muzzle 138, pointer 1559, optic 1107 e bipod 43.
- Três `EQUIPMENT_CAPTURE_PREPARED` / `EQUIPMENT_CAPTURE` manuais foram `success=true, partial=false, omissions=[]`: RD704 duas vezes e Rattler uma vez, 22:19–22:22.
- Três `SAVE_RESULT` manuais: `EXISTING_SAVE_AS_NEW success=true code=WEAPONS_KIT_CREATED` (22:19:32, 22:20:50, 22:22:12). Não é persistência entre missões: SESSION_LOCAL.
- Em 22:19:08: aviso do motor `[weapon MCC_RD704_AFG]: item[rhsusf_acc_grip2] does not match to this weapon!`, como antes; não é prova de erro do resolvedor. Não criar whitelist para forçar arma a aceitar a peça.
- Não há registro de execução manual de `APPLY` ou `ROLLBACK` em RPT pós-autoteste; não declarar esse gate aprovado somente pela captura/salvamento.

### Erros externos / desempenho

- 24 `Error in expression` em `/x/cba/addons/common/fnc_addPerFrameHandler.sqf`, linha 30, tipo inesperado. Aparecem em sessões anteriores, frequentemente durante execuções de hooks; **quem chama com os argumentos errados não foi demonstrado**. Não imputar ao CBA ou ao SP_ORG sem rastrear stack/chamador.
- Warnings `Unsupported language Portuguese`, stringtables duplicadas e configurações de mods com `Missing ';'` ocorrem na inicialização de addons de terceiros; não são indicadores de falha de UC-001-B.
- Nas interações manuais após o runner: `UI_PERF FULL` n=48, mediana **433 ms**, máximo **542 ms**, 42 refreshes acima de 300 ms; `DRAFT_FOCUSED` n=74, mediana **46 ms** e máximo **154 ms**; `CATALOG_FOCUSED` n=3, mediana **310 ms**. Muitos FULL se devem à recomposição de catálogo de 5.481–5.714 linhas potenciais; cache/projection em 217–234 ms. Performance merece registro/gate específico, mas não foi isolado como regressão da UC-001-B sem comparação do mesmo cenário na R5.

### Limitação de cobertura

- RPT confirma testes automáticos 3 armas vanilla e manual MCC; não comprova todas as combinações de acessórios, presets, ACE Arsenal, launchers com muzzle especial ou modsets sem CBA.
- UC-001-A SECONDARY segue pendente por decisão do usuário.
- WST-001 persistência do perfil segue não implementada; nenhum dado deve ser anunciado como persistido entre missões.

## Fix isolado UC-001-B R2

1. Restaurar exatamente `source=ENGINE_COMPATIBLE_COMMANDS` em `getWeaponCompatibility` para o contrato preexistente de 0.3/R5. Preservar novos campos `attachmentSources` e `attachmentResolutionMode` como autoridade da proveniência efetiva Arma+CBA. Não alterar R5 de referência nem o resolvedor, o catálogo de mags ou a física D2.
2. Adicionar **dois** testes novos: marcador legado intacto e metadados de quatro slots presentes; runner R2 almeja **1518 (1446 + 72)**.
3. Atualizar build/identidade da missão para `SP_ORG_Weapons_UC_001_B_Unified_Attachments_R2.VR` e `0.7.5.2`; ação `SP_ORG LAB - TESTAR UC-001-B R2`.
4. Rodar CI estática e gerar o pacote R2; **nenhum PASSED de Arma para R2 pode ser inferido da CI**. Revalidar pela execução real e enviar RPT; até lá PR #11 permanece Draft e não homologada.
5. Após RPT 1518/1518 esperado e validação física/manual, considerar fechar UC-001-B e preparar UC-001-C. O desempenho dos refreshes deve continuar observado.

**Status R1:** `REPROVADA_CONTRATO_LEGADO`. **Status R2:** `CORRECAO_PREPARADA_SEM_RPT_REAL`.
