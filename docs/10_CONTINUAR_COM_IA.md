# Como continuar com outra IA / outro chat

## Source of Truth

Use o repositório **`peregrinoklawd/ServoPeregrino_Organizador`**, branch `main`.

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
