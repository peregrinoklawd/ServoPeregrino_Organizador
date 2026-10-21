# HANDOFF CANÔNICO — Weapons / Servo Peregrino Organizador — 21/10/2026

> **LEIA PRIMEIRO ao iniciar outro chat.** Este documento substitui os resumos de chat como ponto de entrada operacional. O **GitHub na branch abaixo é a Source of Truth**, não arquivos ZIPs antigos, respostas anteriores nem versões recuperadas de memória. Documentação histórica continua válida para seu período, mas não para o status atual se disser "RPT pendente".
>
> **TIPO DE ENTREGA DESTE CHECKPOINT: documentação e estado somente. Nenhum SQF, HPP, função, teste ou pacote foi modificado; nenhuma nova candidata foi criada, nenhum merge foi feito.**

## 0. Identidade e repositório

- Repo: `peregrinoklawd/ServoPeregrino_Organizador`.
- **Branch ativa de desenvolvimento:** `feature/weapons-uc-001-c-magazine-compatibility`.
- **PR ativa:** [#12 — Weapons 0.7-G / UC-001-C R1](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/pull/12), **Draft**, base `baseline/weapons-uc001b-r2-approved`, **não mergeada**.
- **Baseline anterior aprovada / congelada:** `baseline/weapons-uc001b-r2-approved` @ `6b22783d7a73d279b6af73ba762d422371bfd341`; [PR #11](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/pull/11) também Draft, sem merge.
- Baseline ainda anterior R5: `baseline/weapons-0.7-e-r5-homologated` @ `52dd24af4f54ca9f3c9c6832f55ffdf772ff0314`. **Não alterar as baselines.**
- Filosofia de entrega: **MISSION-FIRST** na missão `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`, testes dentro do Eden/Arma, sem PBO neste ciclo. Não reintroduzir a política global CfgRemoteExec no addon. Não modificar Items, Nexus, UICommon ou D2 sem mudança planejada e validação.

## 1. Estado validado vs estado NÃO homologado

### UC-001-B — formalmente APROVADA pelo operador

- Aprovação explícita: **16/10/2026**, doc `docs/83_WEAPONS_UC001B_R2_APPROVAL_AND_DEFERRED_GATES.md`.
- R2: **1.518/1.518 PASS** no Arma real; estáticos **33/33 PASS**; duas aplicações manuais de arma primária (**REPLACE** e **RECONFIGURE**) com sucesso, ammo preservada / pós-validada.
- **Exceção de cobertura aceita, NÃO testar novamente como bloqueador da C:** `UC001B-DEFER-001`, aplicação física manual de empunhadura MCC que é compatível só pelo CBA não realizada. O operador **autorizou pular e mesmo assim aprovou B**. Guardar como `KNOWN_ACCEPTED_TEST_GAP` e considerar sua revisão em UC-001-D antes de PBO/MP; **não registrar PASS retroativo**.
- Fonte técnica: `docs/82_WEAPONS_UC001B_R2_RPT_REVIEW.md`. Política motor+CBA aprovada para Muzzle, Pointer, Optic e Underbarrel.

### UC-001-C — CANDIDATA R1 com AUTO real verde, não formalmente homologada

- Display **0.7-G**, semantic **0.7.6.1**, build `0.7.6.1-uc001-c-r1-magazines-wells-variants-mission-first`.
- Mission ZIP: `SP_ORG_Weapons_UC_001_C_Magazines_Wells_R1.zip` contendo `SP_ORG_Weapons_UC_001_C_Magazines_Wells_R1.VR`. [Actions run 38862586403](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862586403) e [artifact 12030335992](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862586403/artifacts/12030335992). SHA256 ZIP `da2a23abc445bf5f4724b73013d4ec3ff1e39e5b063269e90b2b373171a4ffe8`.
- **CI estática 37/37 PASS**. **RPT real Arma 3 em 21/10/2026, 11.234 linhas: 1.589/1.589 PASS, 0 FAIL, 0 BLOCKED**, incluindo 71 novos checks e 1.518 herdados da B.
- Casos do RPT: MX 14 magazines; MX GL 79 e **2 muzzles**; P07 8; NLAW 0 na engine direta, 1 resolvido via famílias type4; MCC_RD704_AFG 61; `COMPAT_MAGWELL_DIFF` zero **na amostra**, não uma garantia universal.
- No manual o operador **confirmou visualmente** que o seletor `Carregador` mistura cartuchos do fuzil e munição do lançador quando há GL/múltiplos muzzles. **Não há prova de APPLY físico MANUAL do magazine secundário**, então não afirmar que esta integração está aprovada.
- `24` erros repetidos de `CBA_fnc_addPerFrameHandler.sqf`, sem chamador atribuído; **não** declarar culpa do SP_ORG ou CBA sem stack. Ruído de configs de mods separado do resultado funcional.
- RPT completo e performance: `docs/85_WEAPONS_UC001C_R1_RPT_REVIEW_UX_OBSERVATIONS_2026_10_21.md`. Especificação do R1: `docs/84_WEAPONS_UC001C_R1_MAGAZINE_RESOLVER.md`.
- **Sem regressão confirmada na AUTO**, **porém a ausência de FAIL não resolve a limitação de UX/contrato multi-muzzle**.

## 2. Diagnóstico técnico do magazine por muzzle — UC001C-MUZZLE-001

**Confirmação manual:** arma com lançador acoplado mostra granadas e magazines principais na **mesma lista**.

**Causa encontrada no Git (código atual, não proposta):**
1. `weapons/functions/catalog/fn_resolveMagazineCompatibility.sqf`: fonte única engine-first com `magazinesByMuzzle`, `muzzles` e agregado `magazines`, mais `CfgMagazineWells` **somente para diagnóstico**. Não adicionar classes apenas porque constam num magazine well.
2. `weapons/functions/ui/fn_buildCompatibilitySelectorModel.sqf`: apenas um seletor `magazineClass` alimentado pelo **agregado**.
3. `weapons/functions/recipe/fn_validateWeaponRecipeSemantic.sqf`: valida classe do magazine contra agregado, não contra muzzle específico.
4. `weapons/functions/application/fn_buildApplicationTargetLoadout.sqf`: grava `magazineClass` no `primaryMagazine` da linha do loadout (índice 4); apenas preserva `secondaryMagazine` (índice 5) quando a arma é equivalente. **Risco de aplicar munição GL no slot principal**, ainda não demonstrado por teste físico.
5. `weapons/functions/recipe/fn_validateWeaponRecipeStructural.sqf`: **schema fechado** `0.4-recipe-candidate`, exatas `schemaVersion`, `configuration`, `magazineClass`. Não adicionar campo à revelia: atualizar schema, normalização, fingerprint, comparação, repositório e migrar kits legados.
6. `weapons/functions/ui/fn_prepareObservedCaptureRecipe.sqf` e `fn_captureEquippedWeaponToDraft.sqf` atualmente preparam/registram magazine principal na Recipe, não autoram independentemente magazine carregado no muzzle secundário.

**Solução de UX PROPOSTA (não implementada, aguarda fechamento de desenho):**
- Fuzil comum ou pistola: **um** seletor de carregador.
- MX GL / rifle com lançador ou segundo muzzle com magazines: **dois** controles independentes em **ARMAS DO KIT**, `Carregador do fuzil` e `Munição do lançador`; segundo campo **aparece somente quando cabível**, não cria painel inteiro.
- NLAW/Titan standalone (weapon slot `SECONDARY`): **um** campo de munição; **categoria de arma SECONDARY != muzzle secundário**.
- Mods: agrupar por `muzzleId`, rótulo do cano conforme config; não usar nome de classe como heurística "GL". Com >2 muzzles físicos carregáveis, falhar fechado se o loadout não suportar mapeamento inequívoco.
- Representar `KEEP` (preservar), `CLEAR` (descarregar) e `SET` (escolher classe) independentemente; nunca confundir ausência de seleção e intenção de descarregar.
- Nova Recipe versionada, **sem quebrar kits v0.4**; validação de magazine por muzzle, D2 aplicando e pós-validando índices 4 e 5 com snapshot/rollback e rounds corretos; ampliar captura física.
- **Munição do lançador carregada não é munição RESERVA no colete**; `WUX-002` (carregador para colete) separado.
- Detalhamento integral e critérios: `docs/86_WEAPONS_UC001C_MAGAZINES_BY_MUZZLE_AND_CATALOG_BUTTON_MIGRATION.md`. Trata-se de **proposta técnica**, não afirmar implementada, testada ou formalmente homologada.

## 3. Decisões do operador sobre os quatro painéis / ações

Painéis: P1 `MEUS KITS DE ARMAS`, P2 `ARMAS DO KIT`, P3 `CATÁLOGO DE ARMAS`, P4 `CONTEÚDO DO EQUIPAMENTO`.

- **WUX-004 — ORDEM DE MIGRAÇÃO CONFIRMADA:** reutilizar o **mesmo caminho funcional** `CATALOG_TO_DRAFT` (hoje acionado incorretamente pelo nome da arma P2) ao adicionar setas/botões de ação **por linha em P3**, no padrão do Organizador Items; **após implementar e testar as ações P3**, remover `action=CATALOG_TO_DRAFT` de `WeaponValue` IDC 2021 em `weapons/ui/weapons_dialog.hpp`. Nome da arma passa a ser identificação/seleção, não transferência. Rever também `onLBDblClick` de `CatalogList` IDC 3120 porque o operador quer transferência **somente pelos botões explícitos em P3**.
- Atualmente **já existem botões gerais** `CATALOG_TO_DRAFT` IDC 3150 (P3→P2) e `CATALOG_TO_EQUIPMENT` IDC 3151 (P3→P4); a necessidade adicional é de **botões/setas POR LINHA** iguais aos do Items. Não remover os handlers úteis, migrar e preservar o contrato. Distinguir transferência lógica P3→P2 de aplicação física D2 P3→P4; para magazines por muzzle destino precisa ser explícito.
- **WUX-005 — ATUALIZAÇÃO DO CATÁLOGO:** trocar kit/base weapon atualmente faz `catalogOffset=0` nos eventos `KIT_SELECT` e `SET_DRAFT_WEAPON`, e o painel reconstrói a lista. **Armas PRIMARY/HANDGUN/SECONDARY são estáveis**; devem manter offset, seleção, filtros e busca quando possível. Recalcular/invalidação apenas dos acessórios/munições dependentes da arma do rascunho; fazer clamp se a lista encolheu. **Rever depois de colocar botões por linha e seus contratos**, como o operador pediu.
- Não alterar silenciosamente comportamento do usuário. Botões por linha devem receber **classe/tipo/destino/muzzleId da linha clicada**, não se apoiar indevidamente na última seleção global para efetuar mutação.
- Ao final, cliques no título/nome da arma e no corpo da linha do catálogo (inclusive duplo clique, sem botão) não devem aplicar por efeito colateral. Testar ações negativas.

## 4. Ordem de execução sugerida para o PRÓXIMO CHAT

Esta ordem é uma **proposta de engenharia** baseada no que foi discutido; ajustar com o operador antes da implementação de mudanças sensíveis no D2.

1. **Ler esta continuidade, `machine/PROJECT_STATE.json`, docs 83–86 e os SQFs atuais da branch UC001C.** Verificar HEAD real no Git. Não reconstruir candidate C de ZIP antigo.
2. **Fixar contrato multi-muzzle/Recipe (C2):** mapear `muzzleId` de cada arma/mod, classes autorizadas por muzzle, políticas `KEEP/CLEAR/SET`, migração 0.4 e casos de >2 canos/sem magazine; aceitar ou ajustar desenho antes de alterar D2. Priorizar não perder munição existente.
3. **Implementar serviço/validações antes da UI**, testes automáticos adicionais para: MX simples, MX GL, Katiba GL, P07, NLAW, mods com wells/muzzles, magazines incompatíveis, mesmo magazine em mais de um muzzle, fallback type4, kit legado, cache/dedupe.
4. **Integração física D2 em nova candidata controlada (C3):** loadout row `primaryMagazine` vs `secondaryMagazine`, armas equivalentes vs troca, rounds e rollback, captura P4. **Não modificar D2 congelado da baseline**; todo delta deve ser testado na nova linha.
5. **UX C4:** segundo seletor contextual, botões/setas por linha em P3 usando `CATALOG_TO_DRAFT` reaproveitado; só então desvincular nome P2 e revisar duplo clique; corrigir refresh/scroll WUX-005 após botões funcionais.
6. **C5 + gate manual:** rodar cumulativos (referência anterior 1589/1589; não inventar novo total), CI e RPT Arma. Testar fisicamente MX GL com magazine principal e granada carregada, troca isolada de cada um, KEEP/CLEAR/SET, preservação de rounds, rollback, arma de mod e launcher standalone. Registrar evidência. C só poderá ser homologada depois de aceite real; depois UC-001-D E2E/performance.
7. **Manter PR #12 Draft, sem merge**, até o operador aprovar explicitamente. O próprio plano C2–C5 ainda não é uma série de entregas já emitidas. Não gerar PBO sem solicitação.

## 5. Pendências e compromissos que não podem desaparecer

| ID | Situação no handoff | Gate |
|---|---|---|
| `UC001C-MUZZLE-001` | **Observação manual confirmada** de seletor misturado; risco físico por índice 4, **não testado** | C2–C5, antes de homologar UC-001-C |
| `WUX-004` | Migrar handler para botões por linha em P3, depois remover clique nome P2 e duplo clique de mutação | C4 |
| `WUX-005` | Scroll/seleção do catálogo zerados indevidamente, separar projeções de armas vs acessórios | C4 |
| `UC001B-DEFER-001` | Lacuna manual **aceita** no teste físico MCC com grip CBA-only | Recomendada na UC-001-D antes PBO/MP; não bloqueia C |
| `UC001A-SECONDARY` | Auditoria de compatibilidade de lançador equipado não concluída | E2E futuro |
| `WST-001` | Kits permanecem `SESSION_LOCAL`; SALVAR não garante cross-mission/profileNamespace | Projeto de persistência separado |
| `WUX-002` | Replicar/colocar munição no colete (reserva, não carregada no GL) | Fora da UC-001-C |
| `WUX-003` | Filtros por ícones (ACE Arsenal) | UX futuro |
| `EXT-CBA` | 24 erros de addPerFrameHandler sem chamador identificado | Diagnóstico ambiental isolado |
| `UC-001-D` | Regressão E2E e performance | Após C |
| `MP/JIP/PBO/Undo` | Não homologados neste ciclo | Gate próprio |

## 6. Localização rápida do código / documentos

```text
missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/
  weapons/ui/weapons_dialog.hpp                         # WeaponValue IDC 2021; CatalogList IDC 3120; botoes 3150/3151
  weapons/functions/ui/fn_handleUIEvent.sqf             # KIT_SELECT, SET_DRAFT_WEAPON, CATALOG_TO_DRAFT, CATALOG_TO_EQUIPMENT
  weapons/functions/ui/fn_applyCatalogSelectionToDraft.sqf
  weapons/functions/ui/fn_getUICatalogWindow.sqf        # catalog base + projecao dependente da arma
  weapons/functions/ui/fn_refreshCatalogWindowUI.sqf
  weapons/functions/ui/fn_buildCompatibilitySelectorModel.sqf
  weapons/functions/catalog/fn_resolveMagazineCompatibility.sqf
  weapons/functions/catalog/fn_getWeaponCompatibility.sqf
  weapons/functions/recipe/fn_validateWeaponRecipeStructural.sqf
  weapons/functions/recipe/fn_validateWeaponRecipeSemantic.sqf
  weapons/functions/recipe/fn_createWeaponRecipe.sqf
  weapons/functions/recipe/fn_getWeaponRecipeFingerprint.sqf
  weapons/functions/ui/fn_captureEquippedWeaponToDraft.sqf
  weapons/functions/ui/fn_prepareObservedCaptureRecipe.sqf
  weapons/functions/application/fn_buildApplicationTargetLoadout.sqf
  weapons/functions/tests/fn_runUC001CTests.sqf
  weapons/script_version.hpp
docs/
  82_WEAPONS_UC001B_R2_RPT_REVIEW.md
  83_WEAPONS_UC001B_R2_APPROVAL_AND_DEFERRED_GATES.md
  84_WEAPONS_UC001C_R1_MAGAZINE_RESOLVER.md
  85_WEAPONS_UC001C_R1_RPT_REVIEW_UX_OBSERVATIONS_2026_10_21.md
  86_WEAPONS_UC001C_MAGAZINES_BY_MUZZLE_AND_CATALOG_BUTTON_MIGRATION.md
  87_WEAPONS_CONTINUIDADE_UC001C_PROXIMO_CHAT_20261021.md   # este documento
machine/PROJECT_STATE.json
```

## 7. Texto para abertura do próximo chat (copie e cole)

> Continuar o **Arma 3 Servo Peregrino Organizador — Weapons** pelo GitHub `peregrinoklawd/ServoPeregrino_Organizador`, branch **`feature/weapons-uc-001-c-magazine-compatibility`**, PR **#12 Draft**, base homologada **`baseline/weapons-uc001b-r2-approved`**. O GitHub é a *Source of Truth*. **Leia integralmente `docs/87_WEAPONS_CONTINUIDADE_UC001C_PROXIMO_CHAT_20261021.md`, `machine/PROJECT_STATE.json` e `docs/83–86` antes de alterar qualquer coisa.** A UC-001-B R2 está aprovada com `UC001B-DEFER-001` explicitamente aceita. A UC-001-C R1 0.7-G / 0.7.6.1 passou **1589/1589 AUTO no Arma**, mas não foi homologada fisicamente para multi-muzzle. Foi observado manualmente que munições de lançadores e carregadores do rifle aparecem juntas. Prosseguir no desenho de **dois seletores condicionais por muzzle**, Recipe versionada compatível com v0.4, validação por muzzle, D2 seguro e captura física; depois botões/setas por linha no catálogo **reaproveitando `CATALOG_TO_DRAFT`**, e **só depois** remover a ação do nome da arma (IDC 2021), rever duplo clique e corrigir reset do scroll (WUX-004/005). **Não reconstruir a baseline de memória, não editar baseline aprovada, não alegar testes físicos não executados, não fazer merge/PBO nem criar candidata sem planejar o escopo.** Priorizar testes automatizados e RPT real.
