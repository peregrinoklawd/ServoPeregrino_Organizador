# UICommon 0.2 — Shared Infrastructure Consolidation Plan

Data: 05/10/2026.

## Contexto

UICommon 0.1.1 está funcional e validado, mas ainda representa apenas a fundação da infraestrutura compartilhada.

Estado comprovado:
- UICommon foundation: concluída;
- Items + UICommon Equivalence: concluída;
- regressões conjuntas: UICommon 12/12 e Items+UICommon 12/12;
- Weapons 0.6-F R6 agora está materializada no GitHub e fornece uma segunda implementação real para comparação.

Isso cria o momento correto para consolidar UICommon antes de aumentar novamente o domínio Weapons com aplicação física 0.7.

## Objetivo da 0.2

Extrair somente infraestrutura de UI que:
1. já existe em pelo menos dois consumidores ou possui reutilização evidente;
2. não contém semântica de domínio;
3. pode ser migrada mantendo comportamento equivalente;
4. possui teste de regressão claro;
5. melhora manutenção sem criar dependência Items <-> Weapons.

Arquitetura continua:

```text
        Nexus
          ↑
      UICommon
      ↑      ↑
   Items   Weapons
```

Proibido:
- UICommon conhecer ItemKit;
- UICommon conhecer WeaponKit/WeaponRecipe;
- UICommon decidir compatibilidade de armas;
- UICommon executar aplicação física;
- Items depender de Weapons;
- Weapons depender de Items.

## 0.2-A — Shared Infrastructure Inventory

**Esta é a próxima ação imediata.**

Não alterar runtime nesta etapa.

Comparar lado a lado:
- Items atual da missão conjunta;
- Weapons 0.6-F R6 sincronizada;
- UICommon 0.1.1.

Para cada subsistema, classificar:

- `SHARED`: claramente genérico e pronto para extração;
- `CANDIDATE-SHARED`: parecido nos dois módulos, mas precisa contrato;
- `DOMAIN-SPECIFIC`: deve permanecer no módulo;
- `DEFERRED`: compartilhável, mas arriscado demais para a primeira rodada.

Saída obrigatória:
- matriz função/arquivo por módulo;
- ownership proposto;
- dependências;
- risco;
- ordem de extração;
- testes de equivalência necessários.

## Candidatos prioritários

### 1. Feedback Footer — prioridade alta

Gramática comum:
- CONTEXTO;
- RESULTADO;
- HISTÓRICO.

UICommon pode possuir:
- geometria;
- tokens;
- atualização visual;
- escaping;
- severidade/estilo genérico.

Domínio continua responsável por:
- mensagem;
- código semântico;
- dados de contexto;
- histórico lógico.

Classificação inicial:
`SHARED`.

### 2. Keep-Aspect / Preview Surface — prioridade alta

Regra genérica já validada em Weapons:
- preservar proporção;
- centralizar;
- não esticar;
- permitir margem.

Não incluir lógica de arma/Item/3D.

Classificação inicial:
`SHARED`.

### 3. Focused Refresh / Invalidation — prioridade alta

Compartilhar mecanismo:
- marcar superfície inválida;
- atualizar somente painel necessário;
- medir duração;
- impedir refresh global acidental.

Não compartilhar decisões como:
- "troca de WeaponKit invalida compatibilidade";
- "mudança de destino Items recalcula capacidade".

Essas decisões pertencem ao consumidor.

Classificação inicial:
`CANDIDATE-SHARED`.

### 4. Search Plumbing — prioridade média

Compartilhar:
- normalização de query;
- binding/event helpers;
- estado/control utilities;
- composição genérica quando possível.

Não compartilhar política Weapons:
- query global ignorar filtros enquanto não vazia.

Não compartilhar semântica específica Items.

Classificação inicial:
`CANDIDATE-SHARED`.

### 5. Virtual List / Window / Wheel / Slider — prioridade média/alta

UICommon já possui:
- `clampVirtualOffset`;
- `getVirtualWindow`.

Próxima evolução possível:
- window state;
- row reuse/pool;
- wheel delta;
- slider mapping;
- performance markers.

Preservar como requisito:
- wheel/slider não podem provocar full refresh;
- performance Weapons R3+ não pode regredir.

Classificação inicial:
`SHARED / CANDIDATE-SHARED`.

### 6. Theme / Generic Controls — prioridade média

Compartilhar:
- tamanhos;
- spacing;
- opacidade;
- destructive style;
- changed-state token;
- disabled/hover/selected grammar;
- botões textuais padronizados.

Não mover ordem/semântica de ações do domínio.

Classificação inicial:
`SHARED`.

### 7. Tooltip / Pointer / Drag Visual — prioridade posterior

Há bastante aprendizado em Items.
Antes de extrair:
- comparar comportamento real;
- preservar ghost;
- preservar hit-test;
- preservar wheel guard;
- não acoplar payload do drag ao UICommon.

Classificação inicial:
`DEFERRED / CANDIDATE-SHARED`.

## Ordem recomendada de implementação após o inventário

A ordem só será congelada depois da 0.2-A, mas a hipótese inicial é:

```text
0.2-A  Inventory / Classification          ← AGORA
0.2-B  Footer + visual primitives
0.2-C  Focused invalidation/perf helpers
0.2-D  Virtual list / row/window helpers
0.2-E  Search/control plumbing
0.2-F  Equivalence + cleanup
```

Não é obrigatório transformar cada letra em ZIP separado.
Podem ser agrupadas quando o risco for baixo.

## Gate de equivalência

Cada extração precisa provar:

### UICommon
- self tests verdes;
- nenhuma dependência de domínio.

### Items
- checklist `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md`;
- comportamento visual e funcional igual ou melhor;
- DnD/ghost/quantidade/capacidade/applicationTarget/equipmentView preservados;
- Public Loadouts continuam com o status de validação que já possuem; não inventar homologação.

### Weapons
- auto-criação de Draft;
- troca dinâmica de arma-base;
- buscas independentes;
- busca global do Catálogo;
- filtros;
- changed-row highlight;
- keep-aspect;
- focused refresh;
- nenhuma aplicação física antecipada.

### Performance
- nenhuma interação local pode voltar ao padrão de full refresh;
- wheel/slider devem manter ordem de grandeza do gate aprovado.

## Relação com Weapons 0.7

O estudo APM para 0.7 já está pronto:
`docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`.

Ele NÃO será perdido.

A sequência recomendada passa a ser:

```text
R6 source sync
      ↓
UICommon 0.2-A inventory
      ↓
UICommon 0.2 equivalence/consolidation
      ↓
Weapons 0.7-A Plan/Snapshot/Dry-Run
      ↓
0.7-B Slot-Safe Apply
```

Motivo:
evitar criar mais infraestrutura local em Weapons que depois precise ser extraída.

## Primeiro trabalho do próximo chat

1. ler R6 diretamente do GitHub;
2. ler Items e UICommon atuais;
3. listar funções/UI helpers de Items e Weapons;
4. construir matriz SHARED / CANDIDATE-SHARED / DOMAIN-SPECIFIC / DEFERRED;
5. apontar duplicações reais por arquivo/função;
6. propor a menor primeira extração;
7. **não alterar código runtime até a matriz ser revisada**.


## Resultado da 0.2-A — inventário concluído

A comparação foi executada sobre o HEAD canônico com Weapons 0.6-F R6 sincronizada.

Classificação congelada para início da consolidação:

### SHARED / primeira linha
- theme/tokens e controles-base;
- structured text;
- footer como mecanismo de render;
- virtual offset/window/scroll state;
- slider synchronization;
- geometry/hit testing puro;
- performance instrumentation.

### CANDIDATE-SHARED
- feedback history contract;
- focused invalidation;
- search normalization/plumbing;
- selection/focus;
- keep-aspect/centralização;
- geometria interna além das métricas comprovadamente equivalentes.

### DOMAIN-SPECIFIC
- UI state completo;
- view-model;
- projeção/cache de Item catalog;
- projeção/cache de Weapon catalog;
- regras de filtro;
- selection fallback;
- refreshers que conhecem ItemKit/WeaponKit/Equipment;
- aplicação física.

### DEFERRED
- row pool;
- tooltip overlay avançado;
- drag snapshot/ghost;
- DnD compartilhado;
- Preview 3D.

Correções de hipótese:
- keep-aspect só está provado em Weapons;
- Items usa CT_CONTROLS_TABLE e Weapons ListBox, portanto não existe row pool comum real hoje;
- focused refresh está correto nos dois módulos e não deve virar dispatcher global;
- UICommon precisa no futuro de infraestrutura HPP/compile-time, não apenas tokens SQF runtime.

## Sequência revisada após o inventário

A hipótese anterior de sequência foi refinada pela evidência real:

```text
0.2-A  Inventory / Classification            CONCLUÍDO
0.2-B  Pure Shared Primitives                CANDIDATA ESTÁTICA
0.2-C  Virtual Navigation + Footer Rendering PRÓXIMO APÓS RUNTIME
0.2-D  Shared Visual Foundation / HPP
0.2-E  Performance Instrumentation
0.2-F  Equivalence + Cleanup
```

### 0.2-B — candidata atual

Implementado sem migrar consumidores:
- `getVirtualScrollState(offset,totalCount,windowSize)`;
- `pointInRect(x,y,rect)`.

A candidata não altera regra de domínio, UI state, view-model, wheel routing ou refresh routing.

Identidade:
- display `0.2`;
- semantic `0.2.0.1`;
- build `0.2.0.1-pure-shared-primitives-b1`;
- commit técnico `7fbc103093fedf583ed10c94cc8bb717ea9ba0f4`.

Test policy:
- o assert de Items que exigia literalmente `0.1.1-items-equivalence-r1` foi substituído por identificação funcional do componente;
- build/revisão continuam registrados, mas não são gate cosmético.

Runtime:
**PENDENTE DE RPT REAL.**


## Gate 0.2-B — APROVADO

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
