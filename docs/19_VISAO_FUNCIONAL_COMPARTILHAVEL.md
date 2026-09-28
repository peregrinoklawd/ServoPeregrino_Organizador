# Servo Peregrino Organizador — visão funcional por módulo

Documento resumido para apresentação e alinhamento entre equipes.

## Princípio de arquitetura

O SP_ORG é um conjunto de módulos independentes. Cada funcionalidade de domínio possui **um único módulo proprietário**. Outros módulos podem consumir essa funcionalidade por contratos/capabilities do Nexus, mas não devem criar outra implementação paralela.

---

## Nexus

Infraestrutura compartilhada entre os módulos.

- Result padronizado
- Diagnósticos
- Logging
- Capabilities
- Contracts
- Events
- Lifecycle/versionamento
- Discovery futuro de providers opcionais

**Não implementa gameplay.**

---

## Items

Responsável por itens e kits de itens.

- Criação de kit de itens
- Edição de kits
- Renomear kits
- Duplicar kits
- Excluir kits
- Mescla de kits/conteúdo
- Captura do conteúdo de Uniforme/Colete/Mochila
- Catálogo de itens
- Busca, filtros e categorias
- Adição de itens ao kit
- Adição direta de itens ao inventário
- Controle de quantidade
- Remoção de itens
- Drag-and-drop
- Draft antes de salvar/aplicar
- Kits privados
- Kits públicos
- Publicação de kits
- Cópia de kit público para privado
- Aplicação de kit inteiro
- ADD / REMOVE / REPLACE / CLEAR
- Operação BEST_EFFORT
- Operação STRICT/atômica
- Dry-run antes da mutação física
- Fingerprint para detectar alterações inesperadas
- Rollback
- Preservação de magazines parciais/EXACT
- Controle de capacidade de Uniforme/Colete/Mochila
- Carga global do jogador
- Autoridade multiplayer para biblioteca pública
- Futuro JIP/reconciliação/persistência pública
- Integração futura com Policy/Stock/Economy/Persistence

**Não deve implementar:** armas, desgaste, manutenção de arma, economia ou whitelist própria.

---

## Weapons

Responsável pelo que a arma **é**.

- WeaponKit
- WeaponConfiguration
- WeaponRecipe
- Compatibilidade de slots
- Compatibilidade de acessórios
- Compatibilidade de magazines
- Montagem/configuração lógica da arma
- Troca dinâmica de arma sem alterar o restante do loadout
- Aplicar somente arma/configuração desejada
- Identidade individual da arma
- WeaponInstance
- Número de série definitivo
- Metadata/histórico de identidade
- Persistência opcional da identidade/configuração
- Contratos públicos para Armorer, WeaponCondition e Sets

**Não deve implementar:** desgaste, sujeira, lubrificação, corrosão, reparo ou bancada.

---

## WeaponCondition

Responsável por como a arma **está**.

- WeaponConditionState
- Provider autoritativo de condição
- Contador de disparos
- shotsPending / batching
- Desgaste por disparo
- Desgaste do cano
- Desgaste do ferrolho/ação
- Desgaste de mola/sistemas internos
- Sujeira/fouling
- Lubrificação
- Corrosão
- Confiabilidade
- Exposição à água
- Tempo nadando
- Tempo submerso
- Avaliação em lote/event-driven
- Condição por peça/componente
- Avaliação de necessidade de manutenção
- Limpeza como operação lógica
- Lubrificação como operação lógica
- Reparo como operação lógica
- Substituição lógica de peças
- Futuro desgaste por calor/ciclos térmicos
- Futuro efeito de poeira/areia/lama
- Futuro PartInstance/serial individual de peça
- Futuro sistema de panes/jams
- Compatibilidade com provider externo de condição
- Somente um provider autoritativo de condição por arma/sessão

**Não deve implementar:** WeaponRecipe/configuração, bancada/UI, estoque ou economia.

---

## Armorer

Responsável por onde e como o jogador interage fisicamente com a arma.

- Bancada física
- Sessão do armeiro
- Lease/exclusividade multiplayer por estação
- Preview 3D
- Montagem visual de armas/acessórios
- Remoção visual de acessórios
- Rascunho de configuração
- originalConfiguration
- workingConfiguration
- confirmedConfiguration
- Commit/rollback
- Criação visual de receitas de armas
- Edição de receitas
- Salvar receita
- Montar arma a partir de receita
- Inspeção de condição
- Workflow de manutenção
- Interface de limpeza
- Interface de lubrificação
- Interface de diagnóstico
- Interface de reparo
- Troca de peças
- Consumo de peças/ferramentas
- Integração com estoque da bancada
- Integração opcional com custo de serviço/economia
- Integração opcional com persistência/histórico
- Futuro cronógrafo
- Futuro zeramento
- Futuro teste de agrupamento/estande
- Futuro relatório técnico da arma

**Divisão:** Weapons fornece identidade/configuração; WeaponCondition fornece condição/manutenção lógica; Armorer fornece a bancada/UI/workflow.

---

## Equipment

Responsável pela estrutura do loadout do personagem.

- EquipmentKit
- Uniforme
- Colete
- Mochila
- Capacete
- NVG
- Facewear
- Binóculo
- AssignedItems
- Salvar configuração estrutural
- Aplicar/trocar equipamento estrutural
- Trocar equipamento sem alterar outros domínios
- Referenciar ItemKit para conteúdo
- Referenciar WeaponKit
- Validar equipamentos disponíveis
- Integração futura com Policy/Stock/Persistence

**Não deve duplicar:** conteúdo de Items, condição de WeaponCondition ou workflow do Armorer.

---

## Sets

Responsável pela composição de kits completos.

- Criar Set
- Editar Set
- Duplicar Set
- Excluir Set
- Combinar ItemKit + WeaponKit + EquipmentKit
- Presets por função/papel
- Médico
- Fuzileiro
- AT
- Marksman
- Operador
- Aplicar Set completo
- Validar disponibilidade dos módulos necessários
- Aplicação parcial controlada
- Futuro compartilhamento/publicação de Sets

**Não implementa motores físicos próprios.**

---

## Policy

Responsável por whitelist/blacklist.

- Whitelist de Items
- Blacklist de Items
- Whitelist de Weapons
- Blacklist de Weapons
- Whitelist/blacklist de Attachments
- Whitelist/blacklist de Magazines
- Whitelist/blacklist de Equipment
- Regras por className
- Regras por baseClass
- Regras por addon/mod
- Regras por categoria
- Regras por tag
- OPEN
- WHITELIST_ONLY
- BLACKLIST_ONLY
- COMBINED
- Decisão server-authoritative
- Filtro no catálogo/UI
- Validação novamente no executor/servidor

**Regra:** deny explícito vence allow genérico.

---

## ServerIntegration

Responsável por conectar SP_ORG aos sistemas do servidor, quando existirem.

- PersistenceProvider
- StockProvider
- EconomyProvider
- Quantidade disponível
- Estoque global
- Estoque por facção
- Estoque por base
- Estoque por estação
- Estoque de peças do Armorer
- Preço de compra
- Preço de venda
- Custo de manutenção/reparo
- QUERY / QUOTE
- RESERVE
- COMMIT
- RELEASE
- ROLLBACK
- REFUND
- Integração com banco/extensão/framework externo

**Sem provider externo, os módulos continuam funcionando em modo standalone.**

---

## Settings

Responsável por configuração e preferências.

- Preferências de UI
- Configuração administrativa
- Feature flags
- Configuração por módulo
- Ativar/desativar integrações
- Parâmetros de servidor
- Presets de configuração

**Não armazena estado de gameplay.**

---

## Adapters

Responsável por integração com mods/frameworks terceiros.

- ACE
- CBA
- Mods externos de armas/manutenção
- Sistemas externos de economia
- Sistemas externos de persistência
- Inventários específicos
- Tradução de contratos externos para SP_ORG
- Registro condicional de capabilities

Objetivo: evitar código específico de terceiros espalhado pelos módulos principais.

---

# Resumo de ownership

| Funcionalidade | Módulo proprietário |
|---|---|
| Kits de itens / conteúdo | Items |
| Aplicação física de itens | Items |
| Arma, configuração e receitas | Weapons |
| Identidade/serial da arma | Weapons |
| Troca dinâmica de arma | Weapons |
| Desgaste/condição | WeaponCondition |
| Água/submersão/uso acumulado | WeaponCondition |
| Estado das peças | WeaponCondition |
| Manutenção lógica | WeaponCondition |
| Bancada/Preview/montagem | Armorer |
| UI/workflow de manutenção | Armorer |
| EquipmentKit/loadout estrutural | Equipment |
| Composição completa de kits | Sets |
| Whitelist/blacklist | Policy |
| Estoque/quantidade | ServerIntegration / StockProvider |
| Preço/economia | ServerIntegration / EconomyProvider |
| Persistência externa | ServerIntegration / PersistenceProvider |
| Configurações/feature flags | Settings |
| ACE/CBA/terceiros | Adapters |
| Contracts/Capabilities/Events | Nexus |

---

## Regra anti-duplicação para novos mods

Antes de implementar uma nova feature:

1. verificar se ela já possui módulo proprietário;
2. se possui, consumir via contrato/capability;
3. não copiar a implementação para outro módulo;
4. se não possui proprietário, definir ownership antes de escrever runtime;
5. registrar a nova decisão no catálogo oficial.

Essa regra existe para impedir ações, menus, estados e engines duplicados entre os mods SP_ORG.
