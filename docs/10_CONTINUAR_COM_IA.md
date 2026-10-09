# Como continuar com outra IA / outro chat

> Checkpoint ativo 09/10/2026: **Weapons 0.7-E E1 R3 — auditoria Arma/CBA/BIS e sincronização do Catálogo após captura**. Candidata `feature/weapons-0.7-e-equipment-capture`, **STATIC READY / RUNTIME PENDING**; workflow `37994369636` GREEN com 203/203 verificações estáticas. Missão `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1_R3.VR` em ZIP SHA256 `16b6c82ce4f1a93f218032a13ae8a5b9c4cc013cd21e6a9852d1764273f54ade`. Gate real 1420/1420, zero FAIL/BLOCKED; depois executar ação independente `SP_ORG LAB - DIAGNOSTICAR COMPATIBILIDADE` com MCC_RD704_AFG e anexar RPT. Correções: invalidação de cache no mesmo kit, catálogo de NOVO pending e slot atual do draft. Sem whitelist, mudança de validador nem equipamento físico. D2 R1 permanece baseline estável congelada; sem merge main, MP/JIP/PBO/Undo adiados. Veja `docs/72_WEAPONS_0_7_E_COMPATIBILITY_AUDIT_R3.md`.


## Source of Truth

Use o repositório **`peregrinoklawd/ServoPeregrino_Organizador`**. Para esta frente, use a branch candidata indicada no checkpoint mais recente; `main` não contém a cadeia ativa Weapons 0.7.

Não reconstruir o projeto a partir da memória de chats ou ZIPs se o GitHub estiver disponível.

## Prompt de continuidade sugerido

```text
Estamos continuando o projeto Arma 3 Servo Peregrino Organizador (SP_ORG).
O repositório GitHub peregrinoklawd/ServoPeregrino_Organizador é o Source of Truth.

Antes de alterar qualquer runtime, leia:
- README.md
- docs/00_STATUS_ATUAL.md
- docs/01_ARQUITETURA.md
- docs/08_LICOES_APRENDIDAS_DO_DONT.md
- docs/09_ROADMAP_E_PROXIMO_PASSO.md
- docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md
- docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md
- docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md
- machine/PROJECT_STATE.json
- machine/MODULE_MATRIX.json
- machine/FEATURE_OWNERSHIP.json

Regras obrigatórias:
- nunca reconstruir uma baseline de memória;
- toda entrega parte da baseline/source imediatamente anterior;
- preservar contratos homologados;
- um domínio tem um único módulo proprietário;
- módulos não acessam estado privado de outros módulos;
- integração ocorre por Nexus capabilities/contracts/events/results;
- Application Target e Equipment View são authorities diferentes;
- não corrigir gates históricos 516/523 alterando runtime saudável;
- não chamar Items 0.13-A de persistente/JIP;
- validar Packaging R2 no Arma antes de Items 0.13-B;
- Weapons = identidade/configuração/receitas;
- WeaponCondition = condição/desgaste/manutenção lógica;
- Armorer = bancada/Preview/UI/workflow;
- Hub = navegação/experiência integrada/orquestração; não executa lógica de domínio e é opcional;
- somente um provider de condição pode ser autoritativo por arma/sessão.
```

## Estado imediato

- Nexus 1.1 estável.
- Items 0.12 FINAL homologada manualmente.
- Items 0.13-A implementada.
- Mission Lab R3 carrega e slots funcionam.
- Packaging R2 pendente de validação runtime.
- Armorer possui baseline histórica madura, ainda não importada no monorepo.
- Weapons addon source continua integrado até 0.1-A. 0.6-D R3 está homologada 512/512. **0.6-E R1 fechou 536/536**, mas o gate manual de UX pediu nova composição. **0.6-E R2 — UX Convergence / Direct Draft Equip** é a candidata ativa: static 296/296, runner source 518, runtime projetado ~545.
- Hub/WeaponCondition/Equipment/Sets/Policy/ServerIntegration são planejados.

## Arquivos para alterações

- runtime atual: `addons/`;
- labs: `missions/`;
- API/inventário atual: `machine/FUNCTION_INDEX.json`;
- call graph: `machine/CALL_GRAPH_EDGES.csv`;
- estado: `machine/PROJECT_STATE.json`;
- ownership: `machine/FEATURE_OWNERSHIP.json`;
- matriz modular: `machine/MODULE_MATRIX.json`;
- histórico: `docs/history/`.

## Regra de provenance

Antes de nova entrega/release registrar:
- baseline usada;
- branch/commit;
- arquivos alterados;
- razão;
- hashes;
- testes estáticos;
- testes runtime realmente executados;
- testes ainda pendentes;
- documentação/PROJECT_STATE/ownership atualizados quando necessário.

## Regra de Git

Mudanças relevantes devem preferir:
1. branch;
2. commits pequenos/coerentes;
3. PR;
4. merge após revisão;
5. atualização da documentação de continuidade no mesmo ciclo.

## Continuidade Weapons

O addon source desta PR continua em **0.1-A**; não confundir isso com a linha funcional mission-first.

Baselines mission-first homologadas:
- 0.1-B: 128/128 + 3/3 live;
- 0.2: 175/175;
- 0.3 R2: 213/213;
- 0.4 R5: 251/251;
- 0.5: 301/301;
- 0.6-A R4: 362/362, shell visual congelado;
- 0.6-B R4: 397/397, seleção/informações congeladas.

Última baseline homologada:
- **0.6-C R1 — Compatibility Selectors**;
- build `0.6.2.1-compatibility-selectors-read-only-mission-first`;
- runtime **445/445 PASS**.

Candidata ativa:
- **0.6-E R2 — UX Convergence / Direct Draft Equip**;
- build `0.6.4.2-ux-convergence-direct-draft-equip-mission-first`;
- baseline funcional: E R1 **536/536**;
- static **296/296**;
- runner source **518**;
- runtime projetado ~**545**, pendente;
- NOVO não depende de pré-seleção: entra em estado pendente e a arma vem do Catálogo;
- seta esquerda / EQUIPAR NO RASCUNHO aplicam arma/acessório ao draft;
- P1: Novo / Duplicar / Excluir / Publicar;
- rename via nome inline + SALVAR no P2;
- P2/P4 search sincronizam a busca do Catálogo;
- P2 ações no topo; Descartar/Limpar destrutivos;
- filtro UNDERBARREL agrega Bipé + Empunhadura;
- P4 usa Visualizar + slots na mesma linha;
- footer sem background externo e Histórico com maior contraste;
- seta física do Catálogo é somente affordance nesta rodada; mutação real continua 0.7;
- **não iniciar 0.6-F antes de RPT + teste manual da R2**.

Continuam abertos: integração mission-first -> addon/PBO, Packaging, 0.6-E R2/0.6-F, 0.7 aplicação slot-safe, 0.8 MP/JIP/reconnect e identidade física intrínseca.


### Regra de UI compartilhada

Consultar `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

Toda melhoria de UI validada em Weapons que também possa melhorar Items deve entrar no `UI_CONVERGENCE_BACKLOG` como SHARED, DOMAIN-SPECIFIC ou CANDIDATE-SHARED antes de ser portada. Não fazer convergência por memória.


## Continuação ativa — UICommon 0.1

Branch ativa: `feature/uicommon-0.1-foundation`.

Estado de entrada:
- Items: última versão PBO multiplayer testada pelo usuário considerada baseline homologada para o conjunto efetivamente testado; Public Loadouts ainda aguardam validação manual específica;
- Weapons: 0.6-E R2 continua candidata/requisito de UX e está congelada enquanto UICommon é construído;
- não iniciar 0.6-F/0.7 antes do gate R2 pós-UICommon.

Já criado:
- addon UICommon 0.1 foundation;
- capability `uicommon.runtime`;
- lifecycle/build/runtime;
- tokens visuais;
- virtual-list helpers iniciais;
- foundation tests;
- contratos 30/31/32.

Próximo passo:
1. validar UICommon foundation isoladamente;
2. preparar `SP_ORG_Items_Weapons_UI_Lab.VR` usando os mesmos fontes/contratos;
3. migrar Items para UICommon em modo equivalência;
4. executar checklist completo de regressão;
5. depois migrar Weapons e implementar integralmente 0.6-E R2.


## Continuação ativa — Gate 2 / Items + UICommon Equivalence R1

Estado em 02/10/2026:
- Hotfix 1 conjunto aceito;
- UICommon anterior 8/8;
- Weapons cold-open corrigido;
- Weapons E R1 preserva 536/536;
- causa de capacidade do Items agora é observável no RPT.

Fonte atual:
- UICommon `0.1.1-items-equivalence-r1`;
- Items `0.13.0.1-a-server-authority-foundation-uicommon-equivalence-r1`.

Primeiro consumo compartilhado:
- escaping de structured text;
- clamp de offset virtual.

Próximo teste:
- UICommon 12/12;
- Items+UICommon 12/12;
- smoke manual de Items;
- Weapons 536/536.

Não aplicar ainda:
- Items Mostrar -> Visualizar;
- Items `Vasculhando inventário e catalogando itens...`;
- convergence/footer/status redesign;
- Weapons R2.

Após equivalência:
1. implementar Weapons 0.6-E R2 sobre UICommon;
2. depois convergência visual explícita de Items.


## Continuação ativa — Weapons 0.6-E R2 + UICommon

Último checkpoint:
- Items + UICommon Equivalence R1 aprovada para Items;
- nova candidata Weapons R2 preparada;
- static 75/75;
- R1 runner histórico preservado;
- R2 runner separado.

Não criar 0.6-F/0.7 antes do RPT/manual/performance da R2.

Não mexer na convergência visual de Items durante o gate R2.

Artefato:
`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_E_R2_UICommon.zip`

SHA-256:
`3c386b4cf5a7fab52633e9dc2f5fe13325c30fdff3eb9e1e5ed65238d0c9ed69`


## Checkpoint de continuidade — 03/10/2026 — Weapons 0.6-E R2 HF1

Não iniciar 0.6-F.

Último runtime real:
- R2 original: 534/554, 20 FAIL;
- UICommon: 12/12;
- Items+UICommon: 12/12.

Candidata atual:
- Weapons **0.6-E R2 Hotfix 1**;
- build `0.6.4.2-ux-convergence-direct-draft-equip-uicommon-mission-first-hotfix1`;
- static 69/69;
- runner 531 assertion sites;
- runtime/manual/performance pendentes.

Foco do próximo teste:
- NOVO não pode selecionar/criar kit antes da primeira arma;
- dropdown Mira e Catálogo ÓTICAS devem refletir a mesma arma do Draft;
- troca da arma-base deve reconstruir compatibilidade do Catálogo;
- Items 0.13-A mission-first não deve falhar por paths de PBO;
- wheel/slider continua sem full refresh por passo.

Auditoria BGD Development: issue #9 importante, timing em avaliação, não é gate atual.


## Checkpoint de continuidade — 04/10/2026 — Weapons 0.6-F R1

Decisão:
- R2 HF1 runtime: **557/558**;
- único FAIL pequeno foi absorvido na 0.6-F;
- não existe R2 HF2 separado.

Candidata ativa:
- **Weapons 0.6-F R1 — Final Visual Adaptation / Regression**;
- semantic `0.6.5.1`;
- build `0.6.5.1-final-visual-regression-uicommon-mission-first`;
- static Weapons **86/86**;
- full-lab static **24/24**;
- runner **537 assertion sites**;
- runtime/manual/performance pendentes.

Hotfix integrado:
- estado `previousKitIdBeforeNew`;
- NOVO memoriza seleção anterior;
- DESCARTAR antes da primeira arma cancela pending-new e restaura o kit anterior quando possível;
- nenhuma criação de WeaponKit apenas para cancelar.

Preservar:
- Items/Nexus/UICommon byte-idênticos à HF1;
- R2 HF1 historical runner byte-idêntico;
- compatibilidade de acessórios engine-derived;
- catalog projection invalidation;
- focused refresh R3;
- nenhuma aplicação física antes de 0.7.

Próximo teste:
1. UICommon 12/12;
2. Items+UICommon 12/12;
3. selecionar kit -> NOVO -> DESCARTAR -> mesmo kit;
4. fluxo NOVO -> arma -> draft;
5. Mira x ÓTICAS;
6. troca da arma-base;
7. AUTO 0.6-F com 0 FAIL;
8. performance manual;
9. enviar RPT + prints.

Somente depois:
- 0.7 Slot-Safe Weapon Application;
- 0.8 Multiplayer Authority/Reconciliation.

Auditoria BGD Development: issue #9 importante; timing em avaliação; não é gate atual.


## Checkpoint de continuidade — 04/10/2026 — Weapons 0.6-F R2

Não iniciar 0.7 antes do próximo RPT.

Candidata:
- 0.6-F R2;
- changed-row semantic diff contra baseRecipe;
- P2/P4 preview-ready convergence;
- static Weapons 69/69;
- full-lab 30/30;
- runner 545 assertion sites.

Teste prioritário:
- kit SALVO sem linhas âmbar;
- mudar um único componente -> somente aquela linha âmbar;
- restaurar valor original -> destaque some;
- SALVAR -> highlights zeram;
- comparar visualmente ARMAS DO KIT x CONTEÚDO DO EQUIPAMENTO;
- AUTO 0.6-F R2 com 0 FAIL;
- performance wheel/slider sem regressão.

Items/UICommon/Nexus permanecem congelados.
Aplicação física é 0.7.
MP/JIP é 0.8.


## Checkpoint de continuidade — 05/10/2026 — Weapons 0.6-F R4

Candidata ativa:
- 0.6-F R4;
- keep-aspect para previews P2/P4;
- filtros Catálogo uniformes;
- header/test drift corrigidos;
- static 86/86;
- runner 560 assertion sites.

Teste prioritário:
1. preview não estica;
2. preview centralizado;
3. filtros Tipo/Acessório uniformes;
4. tooltips corretos;
5. buscas independentes/globais continuam verdes;
6. changed-row highlight continua verde;
7. AUTO R4 com 0 FAIL;
8. wheel/slider sem regressão;
9. RPT + prints.

Não iniciar 0.7 antes deste gate.
Items/Nexus/UICommon permanecem congelados.


## Checkpoint Weapons — 05/10/2026

Candidata atual de teste: **Weapons 0.6-F R5 — Dynamic Draft Authoring**.
Contrato: auto-criação de kit ao enviar arma sem kit, troca dinâmica da arma-base entre categorias internas, `targetSlot` interno/oculto ao jogador, feedback amigável sem códigos internos. Aplicação física segue para 0.7.

Leia também: `docs/42_WEAPONS_0_6_F_R5_DYNAMIC_DRAFT_AUTHORING_CANDIDATE.md`.

Importante: a missão canônica no repositório ainda contém source Weapons E R1. A candidata R5 existe no pacote mission-first e ainda requer sincronização integral de source antes de o GitHub poder ser usado como baseline executável R5.


## Checkpoint de continuidade — 05/10/2026 — Weapons 0.7 liberada

Último runtime:
- Weapons 0.6-F R6;
- AUTO 595/597;
- 2 FAILs = harness/version-text only;
- testes manuais aprovados.

Decisão:
- não criar R7;
- não bloquear continuidade por header/version text;
- próxima entrega deve ser **0.7 Slot-Safe Weapon Application**.

Regra obrigatória de testes:
- não assertar número de revisão em header;
- não assertar texto cosmético de versão;
- não usar schema/version marker de entrega como gate se não houver contrato funcional associado;
- preferir capability/behavior/state/data-contract checks.

Na abertura da 0.7:
1. remover/substituir os 2 asserts frágeis herdados;
2. preservar todo comportamento 0.6 aprovado;
3. sincronizar source avançado mission-first no repositório;
4. implementar aplicação física isolada por slot;
5. provar que os demais slots/loadout ficam intactos;
6. manter MP/JIP para 0.8.

Não regredir:
- auto-criação de Draft ao enviar arma sem kit;
- troca dinâmica da arma entre categorias internas;
- targetSlot oculto ao jogador;
- feedback amigável;
- buscas independentes;
- busca global do Catálogo;
- preview keep-aspect;
- highlights semânticos;
- filtros compactos;
- focused refresh.

Items/Nexus/UICommon continuam congelados durante o primeiro gate 0.7.


## Handoff autoritativo novo — 05/10/2026

As seções históricas acima permanecem para rastreabilidade, mas o estado mais recente para novo chat está em:

`docs/46_NEXT_CHAT_HANDOFF_WEAPONS_0_7.md`

Leia também obrigatoriamente:
- `docs/43_UI_AUTOMATED_TEST_STABILITY_POLICY.md`;
- `docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`;
- `docs/45_WEAPONS_PREVIEW_3D_APM_ARMORER_CASE_STUDY.md`.

Resumo:
- Weapons 0.6-F R6 liberada para continuidade;
- runtime 595/597, 2 FAILs somente de harness/version-text;
- manual aprovado;
- não criar R7;
- próxima frente: 0.7-A Plan/Snapshot/Dry-Run;
- antes, sincronizar source R6 no repositório;
- Preview 3D é estudo separado;
- não reconstruir R6 de memória.


## Checkpoint autoritativo — R6 sincronizada / UICommon 0.2-A

O aviso anterior de que a missão canônica ainda estava atrás da R6 está SUPERADO.

Source mission-first atual no Git:
`missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`

Identidade:
- Weapons 0.6-F R6;
- semantic 0.6.5.6;
- 432 arquivos;
- subtree `91dae966c4239b3984d21a24916d8e12f811fd2e`;
- ZIP de origem SHA-256 `9ef4374ddf34c8ba5a07f220139ec4e7bd420d9039465226d84faff97ec89bdf`.

Leia:
- `docs/47_WEAPONS_0_6_F_R6_SOURCE_SYNC.md`;
- `docs/48_UICOMMON_0_2_SHARED_INFRASTRUCTURE_PLAN.md`.

Próxima ação:
**UICommon 0.2-A Inventory / Classification**.

Não iniciar alteração física Weapons 0.7 antes de:
1. inventariar duplicações reais Items x Weapons;
2. revisar a matriz de ownership compartilhado;
3. definir a primeira extração de baixo risco;
4. preservar equivalência e performance.

Addon/PBO Weapons ainda NÃO foi promovido à R6; esta afirmação vale para o source mission-first canônico.


## Handoff atual — UICommon 0.2-B candidata

O inventário comparativo real Items x Weapons R6 x UICommon foi concluído antes de qualquer refatoração.

Decisões principais:
- compartilhar mecanismo, nunca regra de domínio;
- controles/tokens/footer/virtual navigation/perf são os maiores alvos reais;
- focused refresh permanece decidido por cada consumidor;
- keep-aspect é CANDIDATE-SHARED porque hoje só Weapons o prova;
- row pool, tooltip overlay e drag ghost ficam DEFERRED;
- UI state/view-model/projeção de catálogo continuam DOMAIN-SPECIFIC.

Primeira extração implementada:
- UICommon display `0.2`;
- semantic `0.2.0.1`;
- build `0.2.0.1-pure-shared-primitives-b1`;
- novo `getVirtualScrollState`;
- novo `pointInRect`;
- foundation source agora possui 24 assertion sites;
- Items + UICommon mantém 12 assertion sites, mas não depende mais do texto literal do build.

Commit técnico:
`7fbc103093fedf583ed10c94cc8bb717ea9ba0f4`.

Static:
- addon/mission parity das novas primitivas: OK;
- referências de domínio nas novas primitivas: 0;
- registros CfgFunctions/description.ext: OK;
- balanceamento estrutural dos arquivos alterados: OK.

Importante:
**24/24 em runtime ainda NÃO foi declarado.**
É necessário RPT real do Arma para homologar a candidata 0.2-B.

Próximo gate:
1. UICommon Foundation 0.2-B no Arma;
2. Items + UICommon Equivalence;
3. se verdes, iniciar 0.2-C Virtual Navigation + Footer sem alterar domínio.


## Handoff — UICommon 0.2-B homologada

RPT real do Arma recebido para a missão canônica.

Build executado:
`0.2.0.1-pure-shared-primitives-b1`.

Resultado runtime:
- UICommon Foundation: **24 PASS / 0 FAIL**;
- Items + UICommon Equivalence: **12 PASS / 0 FAIL**;
- UICommon inicializou corretamente;
- Items inicializou corretamente;
- Weapons 0.6-F R6 permaneceu inicializando na mesma missão;
- nenhuma regressão SP_ORG foi observada neste gate.

Conclusão:
**UICommon 0.2-B — HOMOLOGADA / CONGELADA.**

Observação ambiental:
o RPT contém erros de parâmetro em `CBA_fnc_addPerFrameHandler` durante PostInit.
A missão canônica empacotada não contém chamada a `CBA_fnc_addPerFrameHandler`, e os erros não impediram inicialização nem os gates 24/24 e 12/12. Portanto, não são atribuídos à 0.2-B neste checkpoint.

Próximo gate:
**UICommon 0.2-C — Virtual Navigation + Footer Rendering**, preservando focused refresh e sem mover regra de domínio para UICommon.


## Handoff atual — UICommon 0.2-C C1

A 0.2-B permanece homologada como fallback.

Candidata:
- display: `0.2`;
- semantic: `0.2.0.2`;
- build: `0.2.0.2-virtual-navigation-footer-c1`;
- commit técnico base: `70f54e6fad35d775938bd9f0d15c45d488f550cf`;
- correção de revisão: `df0b75ba732397c56536e02b72cf447889ab841e`.

Escopo implementado:
- novo `syncVirtualSlider`, baseado em `getVirtualScrollState`;
- novo `buildFooterBandStructuredText`;
- novo `renderFooter`;
- Items Full/Catalog focused usam slider compartilhado;
- Weapons Full/Catalog focused usam slider compartilhado;
- Items Full/Catalog/Draft/Equipment usam renderer de footer compartilhado;
- Weapons Full/Catalog/Draft usam renderer de footer compartilhado;
- wheel hit testing de Items e Weapons passa a usar `pointInRect`.

Ownership preservado:
- Items/Weapons continuam construindo contexto, mensagem, histórico, filtros, seleção e regras de evento;
- UICommon não conhece ItemKit, WeaponKit, catálogo de domínio, targetSlot ou aplicação física;
- wheel continua chamando `CATALOG_SCROLL` do módulo consumidor;
- nenhuma chamada global de refresh foi introduzida.

Performance contract:
- `CATALOG_SCROLL -> offset -> refreshCatalogWindowUI`;
- focused refresh continua registrando `fullRefresh=false`;
- slider/footer não podem causar recapture de Equipment ou rebuild global por si próprios.

Static gate:
- addon/missão UICommon: paridade preservada;
- addon/missão Items nos arquivos migrados: paridade preservada;
- novas funções UICommon: zero referências de domínio;
- blocos antigos de footer direto removidos dos refreshers migrados;
- blocos manuais de `sliderSetRange` removidos dos refreshers migrados;
- balanceamento estrutural dos arquivos alterados: OK;
- UICommon Foundation: **31 assertion sites**;
- Items + UICommon Equivalence: **16 assertion sites**;
- runner Weapons R6 não foi modificado.

Runtime:
**PENDENTE DE RPT REAL DO ARMA.**

Gate esperado:
1. UICommon Foundation: **31/31**;
2. Items + UICommon Equivalence: **16/16**;
3. regressão Weapons R6 deve manter no máximo os mesmos **2 FAILs NON_FUNCTIONAL/HARNESS-ONLY** já conhecidos; qualquer FAIL novo é bloqueador;
4. abrir Items e Weapons e validar footer CONTEXTO/RESULTADO/HISTÓRICO;
5. wheel/slider de catálogo sem stutter e com `fullRefresh=false` no RPT.

Não iniciar 0.2-D antes deste gate.


## Handoff — UICommon 0.2-C C2

RPT real da C1:
- UICommon Foundation: **31 PASS / 0 FAIL**;
- Items + UICommon Equivalence: **16 PASS / 0 FAIL**;
- Weapons R6: **595 PASS / 2 FAIL / 597**, exatamente os dois FAILs harness/version-text já conhecidos;
- wheel do Weapons: aproximadamente **6–10 ms**, `projectionBuilt=false`, `fullRefresh=false`;
- wheel do Items: aproximadamente **13–14 ms**, sem projection rebuild e sem equipment recapture.

Manual:
- footer e navegação aprovados;
- foi percebido stutter ao enviar/trocar arma-base do Catálogo para o rascunho.

Diagnóstico do RPT:
- após a seleção/equip da arma, o caminho executava `mode=FULL`;
- exemplos manuais: **298 ms**, **246 ms**, **110 ms**, **97 ms**, **281 ms**, **346 ms**;
- nesses eventos `projectionBuilt=true`;
- o custo não vem de autosave nem de mutação física: em kit existente a arma é alterada somente no draft de sessão;
- a persistência real continua acontecendo apenas em SALVAR;
- o excesso era `_refresh=true` em `CATALOG_TO_DRAFT` / `SET_DRAFT_WEAPON`.

C2:
- build `0.2.0.2-virtual-navigation-footer-c2`;
- commit técnico `0d584e3a4b874418de171a753b68292184737a22`;
- base-weapon swap em kit existente agora atualiza somente **P2 Draft + P3 Catalog**;
- P1 e P4 não são reconstruídos;
- accessory Catalog-to-Draft atualiza somente P2;
- auto-create sem kit selecionado mantém FULL porque cria um novo WeaponKit de sessão e P1 realmente muda;
- nova regressão automática garante zero incremento de full refresh e +1 Draft/+1 Catalog focused no base swap.

C1 não é congelada como 0.2-C final por causa do gate de performance manual.
C2 aguarda RPT real.

Runtime esperado da C2:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- Weapons R6+C2: **596 PASS / 2 FAIL / 598 total**, mantendo apenas os dois harness-only conhecidos;
- durante troca de arma-base em kit existente devem aparecer `DRAFT_FOCUSED reason=CATALOG_TO_DRAFT` e `CATALOG_FOCUSED reason=CATALOG_TO_DRAFT`, sem `mode=FULL` provocado por essa operação.


## 06/10/2026 — C2 runtime confirmado; harness endurecido para 0 FAIL

- C2 removeu o FULL refresh do base-weapon Catalog-to-Draft.
- O regression check de Draft+Catalog focused passou no RPT real.
- Stutter residual acompanha a projeção de compatibilidade; aceito para este gate.
- Dois FAILs de versão/header foram removidos do conjunto bloqueante.
- Commit de hardening: `7933fbb8a1838bf817c0b809834b8cf105eb6932`.
- Próximo gate: Weapons **594/594, 0 FAIL**, com 6 observações não bloqueantes.

## 06/10/2026 — UICommon 0.2-C homologada

Runtime real:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- Weapons: **594/594**, **0 FAIL**, 6 observações;
- C2 base-weapon Catalog-to-Draft sem FULL refresh;
- stutter residual de projection rebuild aceito para este gate.

Estado:
**UICommon 0.2-C — HOMOLOGADA / CONGELADA.**

Próxima entrega:
**UICommon 0.2-D — Shared Visual Foundation / HPP.**

Nova regra de pacote de teste:
a missão distribuída deve ter nome próprio por entrega/revisão. O source canônico permanece único no Git; o workflow renomeia a pasta somente no pacote.


## UICommon 0.2-D R1 — Shared Visual Foundation / HPP

Candidata:
- semantic `0.2.0.3`;
- build `0.2.0.3-shared-visual-hpp-d1`;
- commit técnico `7f2d86e406826087a0421282f89b130cf62891d4`;
- missão distribuída: `SP_ORG_UI_Lab_UICommon_0_2_D_R1.VR`.

Extração:
- novo `UICommon/ui/shared_controls.hpp`;
- métricas genéricas de clear/search/header anchor;
- Text / Title;
- Picture e PictureKeepAspect como variantes explícitas;
- SearchIcon e SearchIconKeepAspect;
- Button / ButtonDanger / IconButton;
- Edit;
- List base;
- Structured + três bases de Footer;
- VSlider.

Preservado:
- Items mantém CT_CONTROLS_TABLE e geometrias próprias;
- Weapons mantém Combo, keep-aspect e rowHeight 0.033;
- nenhum IDC mudou;
- nenhuma action/event handler mudou;
- nenhuma geometria de painel mudou;
- domínio e refresh routing não mudaram.

Static gate:
- UICommon addon/mission shared HPP byte-idênticos;
- Items addon/mission byte-idênticos;
- corpo de `SP_ORG_Items_Dialog` byte-idêntico à 0.2-C;
- corpo de `SP_ORG_Weapons_Dialog` byte-idêntico à 0.2-C;
- shared HPP com zero referências Items/Weapons/ItemKit/WeaponKit;
- keep-aspect Weapons preservado;
- Weapons list rowHeight 0.033 preservado;
- delimitadores estruturais balanceados;
- workflow de pacote: sucesso.

Runtime:
**PENDENTE DE RPT REAL.**

Gate:
- UICommon 31/31;
- Items + UICommon 16/16;
- Weapons 594/594, 0 FAIL;
- abrir Items e Weapons e comparar visualmente com a entrega anterior;
- nenhum erro de config/HPP;
- wheel/slider/focused refresh sem regressão.


## 06/10/2026 — UICommon 0.2-D R2 visual polish candidata

R1 runtime-green: 31/31 + 16/16 + Weapons 594/594.

R2:
- build `0.2.0.4-shared-visual-polish-d2`;
- buscas compactas com lupa/X internos;
- superfícies/botões/barras suavizados sem decoração por linha virtualizada;
- MEUS KITS visualmente convergente;
- Items `ITENS DO KIT` + `Visualizar:`;
- footer Items/Weapons alinhado no span completo;
- zero mudança nos eventos dos dialogs contra R1;
- Items DnD mantém hit-test original com visual layer separado.

Gate real: 35/35 + 16/16 + 594/594 0 FAIL + smoke visual/DnD.


## 06/10/2026 — UICommon 0.2-D R3 candidata

R2: funcional 35/35 + 16/16 + Weapons 594/594, porém visual gate de cantos reprovado.

R3:
- build `0.2.0.5-true-rounded-responsive-d3`;
- rounded rect real = 4 círculos alpha + 2 fills;
- painéis/footer/action buttons;
- zero decoração por linha virtualizada;
- acessórios Weapons menores;
- títulos padronizados;
- lower cards P2/P3/P4 alinhados;
- Histórico com contraste recuperado;
- busca na linha do título somente em aspect >=2.0;
- fallback STANDARD preserva layout de duas linhas;
- RPT registra resolução/profile;
- eventos Items 51/51 e Weapons 47/47 idênticos à R2.

Gate: 39/39 + 16/16 + 594/594 0 FAIL + avaliação visual ultrawide e resolução padrão.


## 06/10/2026 — UICommon 0.2-D R4

R3 rejeitada apesar de 39/39 + 16/16 + 594/594: a tentativa de rounded geometry degradou a interface e o responsive Weapons tinha erro por macro não preprocessada.

R4 restaura integralmente o baseline visual/controles da R2 e reaplica somente:
- search-on-title WIDE + fallback STANDARD;
- títulos/acessórios/lower cards Weapons;
- contraste do Histórico.

Rounded panels/buttons foram abandonados nesta fase.
Gate: 36/36 + 16/16 + 594/594, 0 FAIL, sem erro SQF responsive.


## 06/10/2026 — UICommon 0.2-D R5

R4 homologada em Arma real: 36/36 + 16/16 + Weapons 594/594, 0 FAIL, testes manuais aprovados.

R5 é somente polish:
- nome + status do rascunho mais próximos do título em Items/Weapons;
- Items: `Onde aplicar o kit?` -> `Qual o destino?`;
- Histórico em roxo claro (`#B9A3E8` / `#D1C2F0`);
- Items P1/P3 com surface alpha 0.32 para compensar as camadas internas mais escuras.
- handlers funcionais permanecem idênticos à R4.


## 07/10/2026 — UICommon 0.2-D R6

Review fix da R5:
- status do rascunho passa a alinhar à esquerda do próprio controle, ficando visualmente junto da caixa de nome;
- runner Weapons substitui `mira/laser` por tokens sintéticos e limpa P2/P4 antes de reabrir a UI;
- gate automático permanece 36/36 + 16/16 + 594/594.
- após aprovação, 0.2-D será congelada e o fluxo segue para 0.2-E, 0.2-F e então Weapons 0.7-A.


## 07/10/2026 — UICommon 0.2-D encerrada

R6 homologada e congelada:
- build `0.2.0.8-status-search-hygiene-d6`;
- Foundation 36/36;
- Items+UICommon 16/16;
- Weapons 594/594, 0 FAIL;
- manual aprovado.

Próxima frente: **0.2-E Performance Instrumentation**.
A extração deve compartilhar somente mecanismo genérico de medição/histórico; a decisão de FULL vs focused refresh continua pertencendo a Items/Weapons.


## 07/10/2026 — UICommon 0.2-E E1

Candidata aberta após congelamento da 0.2-D R6.

Escopo:
- `elapsedMs(start,end?)`: medição genérica em ms;
- `appendPerfHistory(history,sample,max)`: histórico limitado e imutável para o chamador;
- Items migra FULL, Catalog, Draft, Equipment, Kit Switch e Physical Focused;
- Weapons migra FULL, Catalog, Draft e Equipment;
- formatos existentes de `[UI_PERF]`, contadores e decisão FULL/focused permanecem nos módulos consumidores.

Gate esperado:
- UICommon **43/43**;
- Items+UICommon **16/16**;
- Weapons **594/594**;
- wheel/slider continuam `fullRefresh=false`;
- nenhuma recaptura/rebuild adicional causada pela instrumentação.

## 07/10/2026 — UICommon 0.2-E homologada / 0.2-F F1 aberta

0.2-E E1 foi aprovada em Arma real:
- UICommon Foundation: **43/43**;
- Items + UICommon Equivalence: **16/16**;
- Weapons 0.6-F R6: **594/594**, 0 FAIL;
- focused refresh preservado em Items e Weapons;
- nenhuma regressão funcional atribuída à instrumentação.

Baseline congelada:
- semantic `0.2.0.9`;
- build `0.2.0.9-performance-instrumentation-e1`;
- branch marcador: `baseline/uicommon-0.2-e-e1-homologated`.

Candidata atual:
- **UICommon 0.2-F F1 — Equivalence + Cleanup**;
- semantic `0.2.0.10`;
- build `0.2.0.10-equivalence-cleanup-f1`;
- missão `SP_ORG_UI_Lab_UICommon_0_2_F_F1.VR`.

F1 é não funcional:
- limpa nomenclaturas históricas do harness;
- consolida rastreabilidade;
- não altera regras, eventos, UI visual ou refresh routing.

Gate final:
**43/43 + 16/16 + 594/594, 0 FAIL**, com focused refresh/manual preservados.

Após aprovação:
**congelar UICommon 0.2 e iniciar Weapons 0.7-A Plan/Snapshot/Dry-Run**.

## Regra operacional — entrega sempre acompanhada de missão para download

Sempre que uma entrega mission-first/testável for preparada para validação em conversa:

1. atualizar o GitHub como Source of Truth;
2. preparar a pasta de missão a partir do estado atual do GitHub, sem reconstrução manual de memória;
3. usar o nome registrado em `missions/PACKAGE_MISSION_NAME.txt`;
4. gerar um arquivo ZIP da missão;
5. disponibilizar o ZIP para download na mesma resposta em que a entrega é apresentada;
6. somente então solicitar o RPT/teste manual ao usuário.

Essa regra existe para manter o fluxo de desenvolvimento dinâmico: **entrega -> download -> teste no Arma -> RPT -> homologação**.

Não considerar uma entrega pronta para teste em conversa se o artefato de missão para download ainda não foi gerado.

## 07/10/2026 — UICommon 0.2-F F1 homologada / linha 0.2 congelada

Runtime final aprovado em Arma real:
- UICommon Foundation: **43/43 PASS**;
- Items + UICommon Equivalence: **16/16 PASS**;
- Weapons 0.6-F R6: **594/594 PASS**, 0 FAIL;
- Items: catalog scroll permaneceu focused, `fullRefresh=false`, sem equipment recapture e sem rebuild de projeção durante scroll;
- Weapons: catalog scroll permaneceu focused, `fullRefresh=false`, sem rebuild de projeção/filtro durante scroll;
- Draft/Equipment focused preservados;
- nenhuma regressão funcional SP_ORG observada.

Identidade final congelada:
- display: `0.2`;
- semantic: `0.2.0.10`;
- build: `0.2.0.10-equivalence-cleanup-f1`.

Artefato mission-first efetivamente testado:
- package: `SP_ORG_UI_Lab_UICommon_0_2_F_F1.VR`;
- commit de empacotamento testado: `4e87ce134c117a0a1586a4f82c41ffbaaf6a5890`.

Ruído externo não bloqueante observado no RPT:
- chamadas inválidas em `CBA_fnc_addPerFrameHandler` durante inicialização, sem stack SP_ORG identificado;
- duas localization strings externas ausentes;
- warning ACE refuel sobre Camera.

Conclusão:
**UICommon 0.2 — HOMOLOGADA / CONGELADA.**

Próxima frente:
**Weapons 0.7-A — Plan / Snapshot / Dry-Run**.

## 07/10/2026 — Weapons 0.7-A aberta

UICommon 0.2 está homologada/congelada.

Candidata atual:
- branch: `feature/weapons-0.7-a-plan-snapshot-dry-run`;
- display `0.7-A`;
- semantic `0.7.0.1`;
- build `0.7.0.1-plan-snapshot-dry-run-mission-first`.

Escopo:
- ApplicationPlan;
- ApplicationSnapshot;
- fingerprint explícito dos domínios não alvo;
- pre-validation;
- Dry-Run;
- regressão cumulativa 0.6-F R6.

Regra absoluta:
**0.7-A não pode mutar o loadout físico.**

O primeiro gate de mutação continua sendo **0.7-B Slot-Safe Apply**.

Documento:
`docs/63_WEAPONS_0_7_A_PLAN_SNAPSHOT_DRY_RUN.md`.

## 07/10/2026 — Backlog Items: confirmação no CAPTURAR

Registrar para entrega futura de Items:

- o botão **CAPTURAR** do painel **CONTEÚDO DO EQUIPAMENTO** deve abrir confirmação;
- a confirmação deve explicar que o conteúdo atual de **ITENS DO KIT** será limpo;
- confirmar deve substituir o rascunho pelo conteúdo atualmente exibido em **CONTEÚDO DO EQUIPAMENTO**;
- não fazer merge com o rascunho anterior;
- cancelar não altera rascunho, kit persistido ou inventário;
- a captura continua sendo somente rascunho até **Salvar**;
- falha de captura não pode destruir o rascunho anterior.

Especificação:
`docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md`.

Não implementar durante Weapons 0.7-A/0.7-B.

## 07/10/2026 — Weapons 0.7-A homologada

RPT real da missão `SP_ORG_Weapons_0_7_A_Plan_Snapshot_DryRun.VR` aprovado.

Resultado:
- regressão congelada 0.6-F R6: **594/594 PASS**;
- checks locais 0.7-A: **79/79 PASS**;
- total cumulativo: **673/673 PASS / 0 FAIL**;
- PRIMARY, HANDGUN e SECONDARY: Dry-Run aprovado;
- `mutationPerformed=false`;
- loadout físico exatamente inalterado;
- preservation fingerprint validado para domínios não alvo;
- ApplicationPlan e ApplicationSnapshot aprovados;
- mutação física permaneceu proibida conforme contrato.

Identidade homologada:
- display: `0.7-A`;
- semantic: `0.7.0.1`;
- build: `0.7.0.1-plan-snapshot-dry-run-mission-first`;
- código testado/empacotado: `9f1b4a4e3195a4fb93beb6bee7cf50efa5e31198`;
- baseline marker: `baseline/weapons-0.7-a-homologated`.

Ruído externo conhecido no RPT:
- erros recorrentes em `CBA_fnc_addPerFrameHandler.sqf`, sem stack SP_ORG identificado;
- localization strings externas ausentes.
Esses eventos não bloquearam o gate SP_ORG.

Conclusão:
**Weapons 0.7-A — HOMOLOGADA / CONGELADA.**

Próximo gate formal:
**Weapons 0.7-B — Slot-Safe Apply**.

0.7-B será a primeira entrega autorizada a executar mutação física controlada, preservando os contratos Plan/Snapshot homologados em 0.7-A. Multiplayer/authority continua reservado para a linha 0.8.

## 07/10/2026 — Weapons 0.7-B B1 aberta

Baseline:
- UICommon 0.2 congelada;
- Weapons 0.7-A homologada: 673/673, 0 FAIL;
- marker: `baseline/weapons-0.7-a-homologated`.

Candidata:
- branch: `feature/weapons-0.7-b-slot-safe-apply`;
- display: `0.7-B`;
- semantic: `0.7.1.1`;
- build: `0.7.1.1-slot-safe-apply-b1-mission-first`.

Escopo B1:
- consumir Plan/Snapshot congelados da 0.7-A;
- build do target loadout;
- primeira mutação física via `setUnitLoadout [loadout,false]`;
- somente target slot pode mudar;
- pós-validar configuração, magazine/ammo e preservation fingerprint;
- stale Snapshot aborta antes da mutação;
- NO_OP não toca no engine;
- safety rollback imediato se pós-validação divergir;
- runner usa unidade isolada e não altera o player.

Política candidata:
- mesmo magazine observado -> preservar ammo observado;
- magazine novo/diferente -> capacidade cheia de CfgMagazines;
- sem magazine na Recipe -> target sem primary magazine.

UI física continua deferred para 0.7-D.
Rollback/fault-injection formal continua 0.7-C.
Multiplayer continua 0.8.

Documento:
`docs/65_WEAPONS_0_7_B_SLOT_SAFE_APPLY.md`.


## 08/10/2026 — B2 candidata (STATIC READY / RUNTIME PENDING)

B1 real: 779 PASS / 3 FAIL / 782 executados; 9 checks dependentes não executados.
Causa confirmada no source dos dois FAILs PRIMARY: diff expõe `changes` (objetos com `field`), consumidor buscava `changedFields`; RECONFIGURE virava NO_OP e pós-validação recusava óptica ausente.
B2 adapta somente o consumidor, preservando schema/diff e a força da pós-validação.
Magazine removido também conta como delta. Added same-class optic/muzzle/pointer/bipod/magazine regressions; partial ammo continua 17 -> 17.
Cleanup: scheduler obrigatório, espera bounded de 5s e gate de objeto ausente em allUnits/allMissionObjects. B1 só provou falha da observação imediata, não vazamento; a confirmação do cleanup corrigido depende do RPT B2.
Dependentes são BLOCKED; total esperado estável 890 = 673 legacy + 217 local, aprovação exige zero FAIL/BLOCKED.
Branch `feature/weapons-0.7-b-slot-safe-apply`; semantic `0.7.1.2`.
Executar `SP_ORG LAB - TESTAR WEAPONS 0.7-B`; entregar RPT completo. UI física segue deferred.
B2 não homologada. C/D podem ser preparadas encadeadas, mas gates reais são sequenciais B2 -> C -> D. Não merge main.


## 08/10/2026 — Weapons 0.7-C candidata

**STATIC READY / RUNTIME PENDING**. Branch `feature/weapons-0.7-c-post-validation-rollback`; semantic `0.7.2.1`; build `0.7.2.1-post-validation-rollback-c1-mission-first`.
B2 -> C -> D são candidatas encadeadas. Gate real obrigatório sequencial; nenhum merge main, nenhum freeze/homologação sem RPT.
UICommon 0.2 e Items funcionalmente intocados. Plan/Snapshot 0.7-A congelados; fullMagazines=false. Multiplayer 0.8 deferred.


## 08/10/2026 — Weapons 0.7-D candidata

**STATIC READY / RUNTIME PENDING**. Branch `feature/weapons-0.7-d-ui-integration`; semantic `0.7.3.1`; build `0.7.3.1-ui-integration-d1-mission-first`.
B2 -> C -> D são candidatas encadeadas. Gate real obrigatório sequencial; nenhum merge main, nenhum freeze/homologação sem RPT.
UICommon 0.2 e Items funcionalmente intocados. Plan/Snapshot 0.7-A congelados; fullMagazines=false. Multiplayer 0.8 deferred.
