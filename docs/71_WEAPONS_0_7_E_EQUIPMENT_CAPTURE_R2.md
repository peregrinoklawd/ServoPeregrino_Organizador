# Weapons 0.7-E E1 R2 — Correção de captura de arma equipada com acessórios incompatíveis

Data: 09/10/2026. Branch: `feature/weapons-0.7-e-equipment-capture`.
Display: `0.7-E`; semantic: `0.7.4.2`; build: `0.7.4.2-equipment-to-draft-e1-r2-mission-first`.
Candidata **não homologada**. Baseline estável `baseline/weapons-0.7-d2-r1-homologated` preservada.

## Evidência do RPT E1

- Execução real de 09/10/2026: `AUTO_TEST_SUMMARY mode=MISSION_FIRST_0_7_E passed=1396 failed=0 blocked=0 total=1396 expected=1396`.
- Uso manual P4 PRIMARY: repetição de `EQUIPMENT_CAPTURE slot=PRIMARY code=WEAPONS_RECIPE_CONFIGURATION_INCOMPATIBLE success=false`, entre 17:59:14 e 18:00:02.
- Mesmo período: mensagens da engine `[weapon MCC_RD704_AFG]: item[rhsusf_acc_grip2] does not match to this weapon!`; **correlação**, não prova do campo exato que invalidou cada clique. A E1 não registrava o `nestedCode/invalidFields`.
- Root cause confirmado: chamada `createWeaponRecipe` rejeitava **a captura inteira** quando `validateWeaponConfigurationSemantic` encontrava qualquer componente físico incompatível pelo `compatibleItems`, sem fornecer o motivo no feedback. O botão/handler estavam operacionais.
- Avisos de CBA (`fnc_addPerFrameHandler.sqf`) e demais addons não foram atribuídos ao SP_ORG e não foram alterados.

## Escopo da correção

Nova função `fn_prepareObservedCaptureRecipe.sqf` em Weapons/UI:
1. Recebe a `WeaponConfiguration` exata capturada de `getUnitLoadout` e classe do magazine; clona, **não modifica a fonte física**.
2. Executa o validador semântico estrito. Se `WEAPONS_CONFIGURATION_INCOMPATIBLE` com `invalidFields` identificados e pertencentes apenas a `muzzle/pointer/optic/bipod`, retira **somente esses componentes da cópia lógica**; cada exclusão contém `field`, `className` e `reason`.
3. Executa o validador novamente; qualquer erro residual impede a captura (fail closed). **Arma-base inválida não é convertida.**
4. Executa `createWeaponRecipe` sem relaxar semântica. Se a classe de magazine observada estiver explicitamente incompatível, tenta novamente sem magazine e registra a exclusão. Outros códigos de erro continuam bloqueantes.
5. Retorna Recipe canônica + `omissions` + sinalizador `partial`, sem salvar kit/alterar equipamento/munição.

Camada UI:
- `CAPTURA PARCIAL` informa o nome **exato** das peças ignoradas; a informação fica também no painel P2 enquanto o rascunho existir.
- No RPT, `EQUIPMENT_CAPTURE_PREPARED` informa `weaponClass`, `magazineClass`, `partial` e `omissions`. `EQUIPMENT_CAPTURE` passa a registrar dados diagnósticos quando a operação falhar.
- **Nunca afirmar captura integral quando ocorreu perda de componente.** Não salvar automaticamente. Não alterar a configuração física.
- D2 pipeline Plan → Snapshot → Apply → Validate → Rollback e validação semântica canônica continuam congelados.
- Se a engine rejeitar uma peça fisicamente presente, o WeaponKit capturado contém **a arma-base e apenas componentes validados**. Para compatibilidade perfeita com mods, será necessária uma evolução específica após nova evidência, sem forjar Recipe.

## Novas regressões R2

Manter 1360 D2 + 36 E1 = 1396 e acrescentar 12 R2, total **1408/1408**, 0 FAIL, 0 BLOCKED.
Casos: pistol `hgun_P07_F` com `optic_Hamr` incompatível (rejeição real pelo validador, fallback, code PARCIAL, nome/campo, classe-base, remoção seletiva, fonte intocada, Recipe válida); arma desconhecida deve permanecer bloqueada; carregador de pistola inválido na `arifle_MX_F` deve ser excluído explicitamente, sem bloquear a arma.

## Procedimento manual indispensável

1. Fechar interface e executar **SP_ORG LAB - TESTAR WEAPONS 0.7-E R2**; aguardar `AUTO_TEST_SUMMARY mode=MISSION_FIRST_0_7_E_R2`.
2. No Arsenal/modset em que a E1 falhou, equipar `MCC_RD704_AFG` e `rhsusf_acc_grip2` se disponível, abrir Weapons, visualizar PRIMARY e clicar **CAPTURAR ARMA EQUIPADA**.
3. A arma deve surgir em ARMAS DO KIT. Se a engine reportar peça incompatível, verificar alerta **CAPTURA PARCIAL** especificando peça/classe, além do RPT. Não exigir preservação de componente que a engine considera incompatível; não removê-lo silenciosamente.
4. Repetir fluxo NOVO → CAPTURAR → editar compatíveis → SALVAR, sem criar kit antes do clique.
5. Verificar que equipamento físico, kits salvos e munição restante não mudam apenas por capturar.
6. Enviar RPT completo, inclusive linhas `EQUIPMENT_CAPTURE_PREPARED`, `EQUIPMENT_CAPTURE`, `AUTO_TEST_SUMMARY`, e percepção visual do painel P2.

**Critério:** auto 1408/1408 + testes manuais acima aprovados, zero crash/SQF errors SP_ORG. GitHub Actions GREEN sozinho não homologa. Sem merge/main/PBO/MP/Undo.
