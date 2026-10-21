# Weapons UC-001-C R1 — RPT real, observações de UX e dívidas de integração
**Data:** 21/10/2026 · **Origem:** RPT fornecido pelo operador `Texto colado(20261021-141311).txt` (11.234 linhas, sessão Arma 3 2.22.154089). **Branch:** `feature/weapons-uc-001-c-magazine-compatibility`, PR #12 Draft. **Política:** análise e registro somente; **NÃO modificar código da UI ou D2 nesta rodada**, por instrução explícita do operador. Rever UX depois de concluir botões por linha e funcionalidades correspondentes.

## 1. Teste automático real — 100% PASS; UC-001-C ainda não homologada formalmente
- Inicialização `FULL_UI_LAB READY` linha 8167: `weaponsBuild=0.7.6.1-uc001-c-r1-magazines-wells-variants-mission-first`.
- Às **10:56:42**, linha 10280: `[AUTO_TEST_SUMMARY] mode=MISSION_FIRST_UC001C_R1 passed=1589 failed=0 blocked=0 total=1589 expected=1589 new=71`.
- Retorno `WEAPONS_UC001C_R1_AUTO_TEST_COMPLETE`, `success=true` (linha 10281).
- Marcos cumulativos todos verdes: R6 **594/594**, 0.7-A **673/673**, B **890/890**, C **978/978**, D **1109/1109**, D2 **1360/1360**, E R5 **1446/1446**, UC-001-B R2 **1518/1518**, UC-001-C R1 **1589/1589**.
- Consultas `COMPAT_MAG_RESOLVE` observadas para **22 classes** (vanilla e mods): MX `14` carregadores, um muzzle; MX GL `79` carregadores, **dois muzzles**; P07 `8`; NLAW `engine=0 resolved=1 type4Variants=2`. Também `MCC_RD704_AFG` `engine=61 resolved=61`.
- `COMPAT_MAGWELL_DIFF`: **zero ocorrências** na amostra; isso não comprova ausência de divergências em todo o modset.
- Os testes novos cobrem resolver, catálogo, seletores, receita, muzzles, cache, classes públicas e não mutação lógica, mas **não executam um gate físico manual de magazine de muzzle secundário**.
- Durante a exploração manual posterior ao runner, existem consultas a diversas classes RHS, ACE, TierOne, TOTT e MCC; o RPT não demonstra `DRAFT_APPLY` físico manual após 10:56:42. Único `DRAFT_APPLY` (linha 9581) ocorreu durante o runner herdado, operação `NO_OP` com `mutationPerformed=false`. Portanto não declarar teste físico UC-001-C manual PASS.
- `SAVE_RESULT` três vezes, **dentro dos runners herdados**, `success=true`; não representam persistência entre missões.

## 2. Observações UX do operador — registrar agora, adiar mudança até botões concluídos

### WUX-004 — Nome da arma no painel ARMAS DO KIT não deve equipar a seleção do catálogo
**Reprodução reportada:** selecionar qualquer arma ou acessório no `CATÁLOGO DE ARMAS`; clicar no **nome da arma** em `ARMAS DO KIT`; item do catálogo é transferido para rascunho inesperadamente.

**Causa comprovada no Git:**
- `weapons/ui/weapons_dialog.hpp`, classe `WeaponValue`, IDC **2021** (linha 156), é `SPORG_Weapons_ButtonFlat` com ação direta `['CATALOG_TO_DRAFT']`.
- `weapons/functions/ui/fn_handleUIEvent.sqf`, caso `CATALOG_TO_DRAFT`, delega a `fn_applyCatalogSelectionToDraft.sqf`, usando `selectedCatalogClass` e `selectedCatalogKind`.
- A ação altera **rascunho**, não o loadout físico por esse caminho; não chamar `APPLY_DRAFT`.
- **Há botão explícito no Catálogo** `CATALOG_TO_DRAFT` IDC **3150** e botão físico `CATALOG_TO_EQUIPMENT` IDC **3151**. Ainda **não há setas/botões por linha** como em Items. Adicionalmente `CatalogList` (IDC **3120**) define `onLBDblClick=['CATALOG_TO_DRAFT']`; revisar, pois o requisito do operador é **somente botões NO CATÁLOGO** habilitarem transferência. Clique simples é seleção/consulta, duplo clique não pode alterar sem sua aprovação.
- **Contrato futuro proposto:** clique no nome P2 é **somente seleção/inspeção** ou controle textual inerte; não transfere; clique simples/duplo nas linhas do catálogo sem botão não transfere; apenas ações dedicadas do próprio P3 transferem. Diferenciar P3→P2 (rascunho) de P3→P4 (físico), com indicação e pós-validação D2.
- **Critério negativo obrigatório:** com item no P3 selecionado, clicar 1x/2x no nome P2 **não altera** Recipe, dirty, kit salvo, loadout nem emite `CATALOG_TO_DRAFT`; botão P3→P2 continua transferindo quando clicado explicitamente.

**Status:** `RECORDED_DEFERRED_UNTIL_CATALOG_ROW_BUTTONS`, prioridade UX alta; **nenhum patch nesta rodada**.

### WUX-005 — Preservar posição/seleção da lista de armas ao trocar foco ou arma do kit
**Reprodução reportada:** após equipar/trocar arma em `ARMAS DO KIT`, o `CATÁLOGO DE ARMAS` reaparece do começo; scroll, seleção e contexto são perdidos.

**Causa comprovada no Git:**
- `fn_handleUIEvent.sqf`, `KIT_SELECT` (linhas aprox. 76–104): ao trocar kit **ou só foco de catálogo para kit**, grava `catalogOffset=0`, limpa `selectedCatalogClass` e `selectedCatalogKind`, força `_refresh=true`.
- `SET_DRAFT_WEAPON` (linhas aprox. 473–501): troca arma-base, escreve `catalogOffset=0` e força refresh focado `DRAFT` + `CATALOG`.
- `fn_getUICatalogWindow.sqf` usa projeção cacheada da lista de armas base + acessórios dependentes da arma; `fn_refreshCatalogWindowUI.sqf` reconstrói as linhas visíveis em `lbClear`, respeitando `catalogOffset` que o handler acabou de zerar.
- Portanto **o reset é decisão explícita de UX**, não obrigação técnica de `compatibleItems`/magazines.
- **Contrato futuro proposto:** separar dados imutáveis de arma (`PRIMARY/HANDGUN/SECONDARY`, base catalog e filtros) dos dados dependentes da arma (`optic/muzzle/pointer/bipod/grip/magazine`); recalcular/revalidar **somente acessórios** em mudança de arma. Preservar filtros, texto de busca, posição virtual e item selecionado em listas de armas. Apenas clamp de scroll se o conjunto visível realmente encolheu; definir comportamento para caso da seleção ficar incompatível. Não criar regressão de performance de grandes catálogos.
- **Critérios:** trocar foco de P3 para P2 e clicar kit já selecionado não reposiciona P3; mudar arma-base preserva posição na categoria ARMA e seleção de classes de arma válidas; os acessórios refletem compatibilidade nova; pesquisa/filtros não são zerados por ações sem relação; regressões verificam scroll com >500 linhas e classe em offset alto.

**Status:** `RECORDED_DEFERRED_UNTIL_CATALOG_ROW_BUTTONS`, prioridade UX alta; **nenhum patch nesta rodada**.

## 3. Achado adicional da auditoria UC-001-C — potencial lacuna multi-muzzle, ainda NÃO provado defeito em jogo
**ID: UC001C-MUZZLE-001, status `DESIGN_RISK_REQUIRES_PHYSICAL_EVIDENCE`.**
- `fn_resolveMagazineCompatibility.sqf` gera `magazinesByMuzzle`, mas o catálogo expõe também o agregado de todos os muzzles em `magazines`.
- `fn_buildCompatibilitySelectorModel.sqf` alimenta um único campo `magazineClass` com esse agregado; `fn_validateWeaponRecipeSemantic.sqf` valida somente inclusão no agregado.
- `fn_buildApplicationTargetLoadout.sqf` escreve `_desiredMagazineClass` no campo 4 do row físico (**primaryMagazine**), mantendo secondaryMagazine separadamente. **Risco**: munição do lançador secundário em `arifle_MX_GL_F` ser interpretada como magazine principal, levando a falha segura em D2 ou resultado não pretendido. **Não foi reproduzido pelo RPT**; não afirmar que aconteceu.
- **Gate futuro antes de homologação de compatibilidade física abrangente:** testar seleção de magazines de cano primário vs secundário, verificar mapeamento/muzzle/magazine por física e rollback seguro. Considerar modelagem explícita por muzzle se comprovado necessário. D2 congelado até planejamento e aprovação.

## 4. Performance e erros externos
- `UI_PERF` agregado com auto + manual: `FULL` **n=31 mediana 450 ms, máximo 1550 ms**; `DRAFT_FOCUSED` **n=73 mediana 52 ms, máximo 294 ms**; `CATALOG_FOCUSED` **n=902 mediana 7 ms, máximo 1064 ms**; `EQUIPMENT_FOCUSED` **n=9 mediana 1 ms máximo 14 ms**.
- **Trecho manual pós-auto** (a partir da linha 10282): `CATALOG_FOCUSED` **n=885, mediana 7 ms, máximo 325 ms**, sendo **637** scroll de roda (mediana 7 ms) e **148** slider absoluto (mediana 8 ms). `DRAFT_FOCUSED` **n=33 mediana 27 ms máximo 116 ms**, `FULL` **n=2 282/286 ms**. Muito mais responsivo que os `FULL` da fixture automatizada; não somar latências dissimilares para afirmar piora ao usuário.
- Os maiores picos `FULL` até 1550 ms são da **fixture automática** com `projectionBuilt=true`; a repetição do refresh/reprojeção de >1000 acessórios continua uma área de otimização independente da correção UX.
- **24 blocos `Error in expression`** apontam para `/x/cba/addons/common/fnc_addPerFrameHandler.sqf` linha 30, tipo String no lugar de Code e Code no lugar de Number, todos antes do teste terminar; recorrência de RPTs anteriores. **Não há chamador identificado nem erro SQF demonstrado em arquivo SP_ORG.** Registrar incidente externo/ambiente sem culpar CBA ou Organizador sem stack.
- Warnings de `stringtable` de addons, `Missing ';'` em configs de terceiros, conflitos de addon e afinidade de CPU ocorrem no carregamento do jogo, não são evidência de regressão funcional da missão.
- `COMPAT_REJECT` durante auto para optic incompatível = verificações negativas esperadas.

## 5. Encaminhamento e status
**UC-001-B:** aprovada, frozen `baseline/weapons-uc001b-r2-approved`; teste físico MCC/CBA-only `UC001B-DEFER-001` continua diferido pelo usuário.
**UC-001-C R1:** *AUTO RUNTIME* **1589/1589 PASS**, **manual físico/multi-muzzle pendente**, PR #12 segue Draft sem merge, nenhum pacote R2 gerado neste review.
**UX:** `WUX-004` e `WUX-005` documentadas para revisão após implementar botões de linha do catálogo (padrão Items), sem mudança de UI agora.
**Outros backlogs:** `UC001A_SECONDARY`, `WST-001` (perfil), `WUX-002` (magazines no colete), `WUX-003` (filtros com ícones), UC-001-D E2E/performance, PBO/MP/JIP/Undo.

**Próxima etapa**: somente revisão de implementação e testes de botões/funções P3→P2/P4, depois UX WUX-004/005 com regressão; validar `UC001C-MUZZLE-001` antes de reivindicar cobertura integral de magazines por muzzle. Sem merge nem alteração da baseline aprovada.
