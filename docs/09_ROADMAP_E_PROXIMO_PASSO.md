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

## Weapons 0.1-A — núcleo independente

Foundation, modelos candidatos, emissão SERVER/SESSION e laboratório implementados em source. Validar carga e AUTO TEST; investigar gates físicos A–E. A estratégia observacional **não preserva identidade física nas transferências** e não fecha o gate E.

Proposta 0.1-B: somente após revisão humana, buscar evidência reproduzível de identificador nativo estável ou desenhar transações controladas com limites explícitos. Não iniciar kits/receitas nem congelar `weapons.instance.v1` para contornar o problema. Items e Armorer mantêm gates próprios.
