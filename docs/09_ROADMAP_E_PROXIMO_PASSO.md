# Roadmap e próximo passo

## Gate imediato — Items

**Validar Addon Packaging R2**. Enquanto o engine não montar os PBOs, não iniciar trabalho funcional 0.13-B.

## Fechar Items 0.13-A

Depois do load gate:
- smoke UI;
- host + amigos;
- cliente -> servidor -> clientes;
- republish/revision;
- dois autores;
- regressão curta de DnD, Whole-Kit, EXACT, Equipment, áudio e carga.

## Items 0.13-B — JIP & State Reconciliation

- bootstrap explícito;
- revisão autoritativa;
- detectar cliente stale;
- refresh/recovery.

## Items 0.13-C — Server Persistence & Recovery

- persistência pública controlada no servidor;
- schema/versioning/migrations;
- last-good/recovery;
- restart.

## Items 0.13-D — Permissions, Concurrency & Moderation

- ACL;
- update/delete autorizados;
- locks/concurrency;
- rate limit;
- moderação server-side.

## Items 0.13-E — Long-session & Large-modset Hardening

- soak;
- pruning/limits;
- telemetria;
- grandes catálogos/modsets;
- timeout/retry/recovery.

## Cross-module foundation

Sequência recomendada para **integrações futuras**, não pré-requisito para iniciar núcleos independentes:
1. congelar contratos públicos relevantes no Nexus;
2. migrar a baseline real do Armorer para o monorepo sem feature nova;
3. provar coexistência Nexus + Items + Armorer;
4. formalizar Weapons;
5. formalizar WeaponCondition;
6. formalizar Equipment/Sets;
7. formalizar Policy/ServerIntegration;
8. formalizar Hub após existirem contratos públicos suficientes para descoberta, navegação e passagem de contexto.

## Weapons

Primeiros gates:
- WeaponInstance/serial lifecycle;
- preservação da identidade em inventário/holder/storage/MP;
- WeaponConfiguration;
- WeaponRecipe;
- compatibilidade;
- troca dinâmica da arma sem alterar o restante do loadout.

## WeaponCondition

Primeiros gates:
- provider autoritativo de condição;
- WeaponConditionState;
- shotsPending;
- água/natação/submersão;
- wear evaluation em lote;
- condition por peça;
- manutenção lógica;
- adapters externos.

## Armorer

- importar baseline histórica;
- validar equivalência;
- integrar Weapons para construção/configuração;
- integrar WeaponCondition para condição/manutenção;
- somente depois evoluir manutenção 2.x.

## Policy

- whitelist/blacklist genérica;
- validação UI + executor/server;
- ownership único.

## ServerIntegration

- PersistenceProvider;
- StockProvider;
- EconomyProvider;
- QUERY/QUOTE -> RESERVE -> COMMIT -> RELEASE/ROLLBACK.

## 1.0 do ecossistema

Não significa todos os módulos terem todas as features futuras. Significa contratos públicos estáveis, baselines homologadas e integração previsível entre os módulos liberados.


## Hub

Primeiros gates:
- contrato de descoberta dos módulos disponíveis;
- padrão de abertura/navegação pública;
- passagem de contexto entre módulos;
- menu principal dinâmico;
- laboratório com Nexus + pelo menos dois módulos;
- provar que módulos continuam funcionando sem Hub;
- somente depois adicionar ações integradas multi-módulo.

## Weapons — progresso mission-first

### 0.1-A — Foundation & Identity Spike

Source integrado na branch. Estabeleceu registry lógico SERVER/SESSION, separação `WeaponConfiguration`/loadedState e observador conservador. Nenhum contrato v1 congelado.

### 0.1-B — WeaponInstance Lifecycle / Event-Delta Evidence — APROVADA EM MISSION-FIRST SP

- AUTO TEST: 128/128.
- Live Take/Put manual: 3/3.
- Evento + delta único => `CORRELATED`.
- Duplicatas indistinguíveis => `AMBIGUOUS`, sem escolher instanceId.
- Sem delta suficiente => `UNPROVEN`.
- `physicalIdentityProven=false` permanece obrigatório.

### 0.2 — WeaponConfiguration — APROVADA EM MISSION-FIRST SP

- AUTO TEST final: 175/175.
- schema candidato fechado para arma + quatro slots de attachment;
- diff explícito;
- apply/verify/rollback;
- loadedState preservado e fora da identidade/configuração;
- no-op sem mutação;
- PRIMARY/HANDGUN/SECONDARY validados.

### Próximo marco: 0.3 — Catalog & Compatibility

Objetivo: derivar do engine, inclusive para armas de mods, quais attachments e magazines são compatíveis por arma/slot sem hardcode por classe. Deve permanecer separado de WeaponCondition, economia/estoque/persistência e UI final.

Gates paralelos ainda abertos: MP/JIP/reconnect, identidade física intrínseca e integração Packaging/PBO. Não congelar `weapons.instance.v1` ou `weapons.configuration.v1` apenas porque os gates mission-first SP passaram.
