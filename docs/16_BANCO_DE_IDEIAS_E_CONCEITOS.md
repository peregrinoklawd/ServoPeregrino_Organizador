# Banco de ideias, decisões e conceitos — SP_ORG

Data de consolidação: **28/09/2026**.

Este documento existe para impedir que ideias, experiências, decisões e caminhos rejeitados desapareçam entre chats, entregas ou desenvolvedores.

## Como interpretar este arquivo

- **DECIDIDO** — princípio aceito.
- **IMPLEMENTADO** — existe no runtime atual.
- **PLANEJADO** — direção aceita, ainda não implementada.
- **PROPOSTA NOVA** — conceito consolidado agora; requer desenho/gate antes de virar runtime.
- **EXPERIMENTO REJEITADO** — não repetir sem nova evidência.
- **ADIADO** — deliberadamente fora do escopo atual.

Este arquivo não substitui `machine/PROJECT_STATE.json`; ele preserva contexto e raciocínio.

## 1. Arquitetura geral

**DECIDIDO**

O SP_ORG é uma família de módulos independentes distribuídos como PBOs separados, mesmo quando mantidos em um único monorepo.

```text
Nexus
  ↑ capabilities / contracts / events / results
Hub
  ↓ integração visual/orquestração
Items  Weapons  WeaponCondition  Equipment  Sets  Armorer  Settings
```

Regras:
1. um módulo não lê nem altera variáveis privadas de outro;
2. dependências opcionais degradam graciosamente;
3. Nexus permanece neutro de domínio;
4. addon/PBO é o produto; missões são laboratórios;
5. integração externa fica em adapters/providers;
6. módulos versionam independentemente;
7. reutilizar padrões não significa copiar internals.

## 2. Módulos

### Nexus
**IMPLEMENTADO / ESTÁVEL** — Result, Diagnostics, capabilities, contracts, events, lifecycle e logging.

### Hub
**PLANEJADO** — Central opcional do Organizador para navegação, descoberta de módulos, passagem de contexto e ações integradas. O Hub coordena; não executa lógica de domínio. Nenhum módulo deve depender do Hub.

### Items
**IMPLEMENTADO / AVANÇADO** — ItemEntry, ItemKit, Repository, Draft, Catalog, Inventory, Application Engine, Whole-Kit, EXACT, rollback, DnD, UI e PRIVADOS/PÚBLICOS. 0.12 FINAL homologada; 0.13-A em gate runtime/multiplayer.

### Weapons
**FOUNDATION/SPIKE 0.1-A EM SOURCE; GATE FÍSICO ABERTO** — modelos internos candidatos, emissão SERVER/SESSION e observação. Capacidade pública limitada a `weapons.runtime`. Funcionalidades finais ainda **PLANEJADAS** — WeaponKit, WeaponConfiguration, WeaponRecipe, compatibilidade de slots/attachments/magazines, troca dinâmica sem alterar o restante do loadout, WeaponInstance e serial definitivo.

### WeaponCondition
**PLANEJADO** — desgaste, uso, água/submersão, condição de peças, sujeira, lubrificação, corrosão, confiabilidade, panes e manutenção lógica; permite provider nativo ou externo com uma única autoridade de condição.

### Equipment
**PLANEJADO** — loadout estrutural sem duplicar a semântica de conteúdo de Items.

### Sets
**PLANEJADO** — composição por referência; não deve duplicar executores físicos.

### Armorer
**AVANÇADO / CONGELADO** — estação, sessão, lease MP, preview 3D, draft e rollback. Migrar baseline autoritativa ao monorepo antes de 2.x.

### Settings
**PLANEJADO** — preferências/config/feature flags; não virar storage de domínio.

### Adapters
**PLANEJADO** — ACE, CBA e integrações específicas fora dos cores.

## 3. Whitelist / blacklist

**PROPOSTA NOVA**

Uma camada de política reutilizável por Items e Weapons. A regra deve existir na UI/catalog e também no executor/servidor.

```text
PolicyDecision
  allowed
  reason
  matchedRule
  source
  subjectType
```

Critérios: className, baseClass, addon/mod, categoria, tag e padrões explicitamente definidos.

Modos: OPEN, WHITELIST_ONLY, BLACKLIST_ONLY, COMBINED.

Regra inicial: deny explícito vence allow genérico. Em MP, a decisão final é server-authoritative.

## 4. Estoque, quantidade, economia e persistência

**PLANEJADO COMO CAMADA OPCIONAL**

Já havíamos separado conceitualmente Catalog, Stock, Economy e Persistence. A evolução preferida é não obrigar SP_ORG a implementar economia própria.

Providers opcionais:
- `persistence.provider`
- `stock.provider`
- `economy.provider`

Sem provider: modo standalone.

Com provider:
```text
Domain Module → public provider contract → ServerIntegration/Adapter → sistema real do servidor
```

Transação: QUERY/QUOTE → RESERVE → COMMIT → RELEASE/ROLLBACK.

Items/Weapons não devem conhecer banco, extensão, framework econômico ou mod específico.

## 5. Armeiro, desgaste e peças — planejamento anterior

**PLANEJADO ANTERIORMENTE / ADIADO PARA 2.x**

Já estavam no roadmap: desgaste, sujeira, limpeza, lubrificação/manutenção, ferramentas, componentes internos, diagnóstico, reparo, jams/panes, dispersão, confiabilidade, temperatura, cronógrafo, zeragem e agrupamento/estande.

Isso foi adiado enquanto commit, rollback, MP e preview amadureciam. Também havia orientação para não introduzir serialização individual, desgaste ou economia antes do commit básico confiável.

### Conceitos reutilizáveis

- sessão: `originalConfiguration`, `confirmedConfiguration`, `workingConfiguration`;
- station lease/autoridade MP;
- rollback/reconciliation;
- fontes AUTO, VIRTUAL, PLAYER_INVENTORY, CONTAINER, STATION_STOCK;
- preview 3D e estação física.

### Não estava especificado anteriormente

Não havia decisão consolidada sobre algoritmo de desgaste por tiro, identidade/serial definitivo, PartInstance, frequência de persistência ou batching de disparos.

## 6. Desgaste sem custo contínuo

**PROPOSTA NOVA PARA FUTURO 2.x**

Evitar `onEachFrame`/loops contínuos. Usar event-driven + lazy evaluation.

Evento barato:
```text
Fired/FiredMan → shotsPending += 1
```

Avaliação completa em checkpoints: entrada no Armorer, troca/armazenamento, disconnect, save/checkpoint, lote periódico lento ou inspeção.

Estado futuro possível: barrelWear, actionWear, fouling, lubrication, temperatureState e reliabilityModifiers.

Persistência deve aceitar batching; não salvar a cada tiro.

## 7. WeaponInstance e PartInstance

**PLANEJADO**

ClassName identifica tipo, não uma arma individual. A direção aceita é:

```text
Weapons
  WeaponInstance
    instanceId
    serial
    weaponClass
    configuration
    metadata

WeaponCondition
  WeaponConditionState
    weaponInstanceId
    usage
    condition
    parts
```

Weapons é dono da identidade/serial. WeaponCondition é dono da condição/desgaste. Peças começam como PartState; PartInstance/serial próprio só será criado se gameplay/persistência realmente exigirem.

## 8. Regras de desempenho

**DECIDIDO**

Preferir eventos, dirty flags, cache, batching, lazy evaluation, processamento sob demanda, checkpoints, refresh focado e autoridade de servidor apenas onde necessário.

Evitar onEachFrame de domínio, scan global repetitivo, persistência por tiro, broadcast microscópico, rebuild integral de UI e polling desnecessário.

## 9. Lições preservadas

- última baseline real;
- delta pequeno/rastreável;
- source + PBO + hash + homologação;
- diagnóstico por camada/RPT;
- validar mount PBO antes da UI;
- EXACT;
- dry-run/fingerprint/commit/post-validate/rollback;
- authorities separadas;
- não modificar runtime saudável por gate histórico frágil;
- não confiar em identidade enviada pelo cliente;
- RemoteExec mínimo;
- addon produto / missão laboratório;
- adapters para terceiros;
- registrar experimentos rejeitados.

## 10. Rejeitados / estacionados

- **Armorer 1.17.15.1**: RTT 512/1024/2048 sem ganho perceptível e Preview podia ficar preto — rejeitado.
- picking experimental: pesquisa, não baseline.
- Items gates 516/523: dívida aceita, DnD manual aprovado.
- Packaging R1: PBOs não montaram; R2 deve passar no engine antes de 0.13-B.

## 11. Ideias futuras visíveis

Whitelist/blacklist; optional Persistence/Stock/Economy providers; WeaponKit; EquipmentKit; Sets; WeaponInstance sob necessidade; desgaste/limpeza/lubrificação; peças/ferramentas; manutenção/reparo; jams; confiabilidade; temperatura; cronógrafo; zeragem; agrupamento; ACE/CBA adapters; JIP/recovery; ACL/moderação; large-modset/long-session hardening.

## 12. Ordem recomendada

1. fechar Items 0.13-A runtime/MP;
2. avançar Items 0.13-B/C;
3. migrar Armorer autoritativo ao monorepo sem feature nova;
4. formalizar Weapons e WeaponCondition;
5. formalizar Equipment/Sets;
6. formalizar Policy e Server Providers;
7. iniciar wear/parts 2.x somente após os contratos de identidade/condição;
8. economia/estoque permanecem opcionais;



## 13. Decisão de design — identidade e exposição ambiental da arma (28/09/2026)

**PLANEJADO**

A direção desejada passa a incluir:

- identidade individual de cada arma;
- serial definitivo;
- desgaste por disparos;
- desgaste ambiental por água, natação e submersão;
- desgaste separado por componentes/peças;
- avaliação em lote/event-driven, evitando custo por frame;
- Weapons como dono da identidade/configuração/receitas da arma;
- WeaponCondition como dono do estado, desgaste e manutenção lógica;
- Armorer como workflow/UI de montagem, inspeção e manutenção;
- persistência, estoque e economia opcionais por provider.

A arquitetura detalhada está em `17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md`.

A intenção de gameplay está aceita, mas o schema e as fórmulas permanecem abertos até os gates técnicos provarem como preservar uma WeaponInstance ao mover armas entre inventário, weapon holder, storage e multiplayer.


## 14. Ownership funcional / anti-duplicação

**DECIDIDO**

Cada funcionalidade de domínio terá um único módulo proprietário. Outros módulos só podem consumir essa capacidade por contratos/capabilities/events do Nexus; não devem criar implementações paralelas.

O catálogo oficial está em `18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md` e a matriz legível por máquina em `../machine/FEATURE_OWNERSHIP.json`.


## 15. Decisão final — separação Weapons / WeaponCondition / Armorer

**DECIDIDO**

A divisão oficial passa a ser:

```text
Weapons
= O QUE A ARMA É
  identidade
  serial
  configuração
  compatibilidade
  receitas
  troca dinâmica

WeaponCondition
= COMO A ARMA ESTÁ
  uso
  desgaste
  água/submersão
  peças
  sujeira
  lubrificação
  corrosão
  confiabilidade
  manutenção lógica

Armorer
= ONDE/COMO O JOGADOR INTERAGE
  bancada
  preview
  montagem
  criação visual de receitas
  inspeção
  manutenção
  reparo
  troca de peças
```

Motivos:
- evitar duas fórmulas de desgaste;
- permitir usar Armorer com provider externo de condição;
- permitir WeaponCondition sem bancada;
- permitir Weapons sem desgaste;
- melhorar compatibilidade com ACE/outros mods;
- preservar ownership único por funcionalidade.

Somente um provider de condição pode ser autoritativo para a mesma arma/sessão.


## 16. Decisão — Hub / Central do Organizador

**DECIDIDO**

Será criado um módulo opcional `ServoPeregrino_Organizador_Hub`.

Definição:

```text
Nexus
= faz os módulos conversarem tecnicamente.

Hub
= faz o jogador conversar com os módulos.
```

Responsabilidades do Hub:
- porta de entrada única opcional;
- navegação entre módulos;
- descoberta dinâmica do que está instalado/disponível;
- mostrar somente ações válidas;
- passagem de contexto entre módulos;
- visão integrada de informações resumidas;
- alertas/notificações compartilhados;
- orquestração de ações que envolvem vários módulos.

Invariantes:
- Hub coordena; não executa lógica de domínio;
- Items/Weapons/Equipment/Sets/Armorer/WeaponCondition continuam funcionais sem Hub;
- Hub pode acionar módulos, mas não reimplementa suas funções;
- Sets continua dono da composição persistente de conjuntos;
- Hub é dono da experiência integrada para o jogador;
- Nexus continua sendo a infraestrutura técnica.

Arquitetura detalhada: `20_HUB_ARQUITETURA_E_INTEGRACAO.md`.

## 17. Execução de núcleos independentes — Weapons 0.1-A

A ordem recomendada acima não estabelece dependências obrigatórias entre núcleos. Weapons iniciou isoladamente com Nexus. Fingerprint, classe, índice e localização foram rejeitados como identidade; dois registros lógicos não provam a associação às duas armas físicas. Sem prova, manter gate aberto e schema interno candidato. Condição permanece exclusivamente em WeaponCondition.
