# Arquitetura

## Visão global

O SP_ORG é um **monorepo com vários addons/PBOs independentes**.

```text
Nexus
  |
  +-- Items
  +-- Weapons
  |     |
  |     +-- WeaponCondition
  |
  +-- Armorer
  +-- Equipment
  +-- Sets
  +-- Policy
  +-- ServerIntegration
  +-- Settings
  +-- Adapters
```

A seta acima representa integração por contratos/capabilities, não acesso a estado privado.

## Regra de isolamento

- um módulo não lê/altera namespace privado de outro;
- integrações usam Capabilities, Contracts, Events e Results do Nexus;
- dependências opcionais degradam graciosamente;
- cada funcionalidade de domínio tem um único proprietário;
- módulos podem ser ativados/desativados independentemente quando os contratos permitirem.

## Fronteira de armas

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
  ambiente
  peças
  confiabilidade
  manutenção lógica

Armorer
= ONDE/COMO O JOGADOR INTERAGE
  bancada
  preview
  montagem
  inspeção
  manutenção
```

Somente um provider de condição pode ser autoritativo para a mesma arma/sessão.

## Runtime implementado hoje

### Nexus

Infraestrutura transversal: Result, Diagnostics, Capabilities, Contracts, Events, lifecycle e logging.

### Items

Domínio de ItemKit, Repository, catálogo, inventário, Draft, Application Engine, UI e biblioteca PRIVADOS/PÚBLICOS.

`Items` declara dependência de `ServoPeregrino_Organizador_Nexus` em `CfgPatches.requiredAddons`.

## Produto vs laboratório

O addon/PBO é o produto. Missões são laboratórios de teste.

A missão ativa de Items permanece no path histórico enquanto o gate 0.13-A não fecha. Não mover runtime ativo somente por estética.

## Camadas de Items

- `domain` — ItemEntry, ItemKit, validação, normalização, IDs.
- `storage` — persistência privada via `profileNamespace`, primary + lastGood.
- `library` — biblioteca pública de sessão; em 0.13-A a mutação é server-authoritative.
- `catalog` — catálogo derivado de configs.
- `inventory` — captura de U/C/M, fingerprints e capacidade.
- `application` — dry-run, planos, lock, commit, rollback, EXACT, Whole-Kit.
- `draft` — edição lógica antes de persistir/aplicar.
- `ui` — view-model, renderers, DnD, ghost, ações e feedback.
- `tests` — regressão histórica e checkpoints; não é API de gameplay.

## Authorities de Items que NÃO devem ser misturadas

**`applicationTarget`**: “Onde aplicar o kit?”; autoridade para ações Whole-Kit.

**`equipmentView`**: “Mostrar”; autoridade para ações físicas diretas no painel Conteúdo do Equipamento e seta direita do Catálogo.

Essa separação é contrato congelado.

## Privado vs público

- **PRIVADOS**: Repository persistente do perfil local.
- **PÚBLICOS**: snapshots separados/read-only para consumo; em 0.13-A continuam `SESSION` scoped.
- publicação não compartilha o Repository privado.
- servidor deriva identidade do remetente e controla `publicId`/`revision`.

## UI/DnD

DnD moderno usa o display como autoridade do gesto para Catálogo/Equipment/Draft, hit-test amplo e ghost runtime/top-layer. Tooltips são pass-through e desaparecem durante drag.

## Carga

Não confundir:
- carga global do jogador: `loadAbs player`, `load player`, `maxSoldierLoad`;
- capacidade do container: `loadAbs container` + `maximumLoad`.

## Providers opcionais

ServerIntegration pode expor:
- PersistenceProvider;
- StockProvider;
- EconomyProvider.

Sem provider, módulos continuam em modo standalone.

## Policy

Whitelist/blacklist pertence somente a Policy. UI pode filtrar; executor/servidor valida novamente.
