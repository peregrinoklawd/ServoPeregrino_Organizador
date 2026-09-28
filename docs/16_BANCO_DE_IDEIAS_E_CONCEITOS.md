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
Items  Weapons  Equipment  Sets  Armorer  Settings
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

### Items
**IMPLEMENTADO / AVANÇADO** — ItemEntry, ItemKit, Repository, Draft, Catalog, Inventory, Application Engine, Whole-Kit, EXACT, rollback, DnD, UI e PRIVADOS/PÚBLICOS. 0.12 FINAL homologada; 0.13-A em gate runtime/multiplayer.

### Weapons
**PLANEJADO** — WeaponKit, WeaponConfiguration, compatibilidade de slots, attachments, magazines e, se necessário, WeaponInstance.

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

**PROPOSTA NOVA — somente se wear persistente exigir**

ClassName identifica tipo, não instância. Caso seja necessário:

```text
WeaponInstance
  instanceId
  weaponClass
  configuration
  conditionState
  pendingUsage
  metadata
```

Peças podem futuramente ter PartInstance. Não implementar prematuramente. Weapons deve ser dono do modelo; Armorer consome contratos públicos.

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
4. formalizar Weapons/Equipment/Sets;
5. formalizar Policy e Server Providers;
6. só então iniciar wear/parts 2.x;
7. economia/estoque permanecem opcionais.


## 13. Decisão de design — identidade e exposição ambiental da arma (28/09/2026)

**PLANEJADO**

A direção desejada passa a incluir:

- identidade individual de cada arma;
- serial definitivo;
- desgaste por disparos;
- desgaste ambiental por água, natação e submersão;
- desgaste separado por componentes/peças;
- avaliação em lote/event-driven, evitando custo por frame;
- Weapons como dono do estado da arma;
- Armorer como workflow de inspeção/manutenção;
- persistência, estoque e economia opcionais por provider.

A arquitetura detalhada está em `17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md`.

A intenção de gameplay está aceita, mas o schema e as fórmulas permanecem abertos até os gates técnicos provarem como preservar uma WeaponInstance ao mover armas entre inventário, weapon holder, storage e multiplayer.
