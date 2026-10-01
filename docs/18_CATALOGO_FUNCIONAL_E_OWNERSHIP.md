# Catálogo funcional e ownership por módulo — SP_ORG

Data de consolidação: **29/09/2026**.

## Objetivo

Este documento define **quem é dono de cada funcionalidade** no Servo Peregrino Organizador.

Regra principal:

> **Uma funcionalidade de domínio tem um único módulo proprietário. Outros módulos podem consumir o serviço por Capability/Contract/Event do Nexus, mas não devem criar uma segunda implementação paralela.**

Isso evita duplicações como:
- Items e Equipment criarem dois motores diferentes para o mesmo conteúdo;
- Weapons, WeaponCondition e Armorer criarem estados/lógicas concorrentes para a mesma condição;
- cada módulo implementar sua própria whitelist/blacklist;
- cada módulo integrar diretamente com banco/economia/estoque do servidor.

Os estados usados abaixo são:
- **IMPLEMENTADO** — já existe no runtime atual.
- **AVANÇADO/HISTÓRICO** — existe em uma linha madura anterior e precisa ser migrado/preservado.
- **PLANEJADO** — aceito no desenho, ainda não implementado.
- **FUTURO** — ideia registrada, depende de gates anteriores.

---

# Nexus — infraestrutura compartilhada

**Dono de infraestrutura transversal; nunca de gameplay.**

Funcionalidades:
- **IMPLEMENTADO** — envelope padronizado `Result`;
- **IMPLEMENTADO** — diagnósticos estruturados;
- **IMPLEMENTADO** — logging;
- **IMPLEMENTADO** — registro/consulta de Capabilities;
- **IMPLEMENTADO** — registro/validação de Contracts;
- **IMPLEMENTADO** — Events publish/subscribe;
- **IMPLEMENTADO** — lifecycle e build/version information;
- **PLANEJADO** — catálogo público de contratos entre módulos;
- **PLANEJADO** — discovery de providers opcionais.

Não implementar no Nexus:
- kits;
- armas;
- desgaste;
- preço;
- estoque;
- receitas;
- loadout;
- UI de gameplay.

---

# Hub — Central do Organizador e integração visual

**Dono da experiência integrada e da navegação entre módulos.**

Funcionalidades:
- **PLANEJADO** — menu principal do Organizador;
- **PLANEJADO** — descobrir módulos disponíveis por capabilities públicas;
- **PLANEJADO** — mostrar somente módulos realmente instalados/disponíveis;
- **PLANEJADO** — navegação entre Items, Weapons, Equipment, Sets, Armorer, WeaponCondition e Settings;
- **PLANEJADO** — passagem de contexto entre módulos;
- **PLANEJADO** — resumo integrado de equipamento, arma, condição, carga e alertas;
- **PLANEJADO** — ações contextuais;
- **PLANEJADO** — notificações compartilhadas;
- **PLANEJADO** — orquestrar ações que envolvem vários módulos;
- **PLANEJADO** — abrir o módulo correto já com o item/arma/conjunto selecionado;
- **PLANEJADO** — verificar restrições, estoque e custo antes de uma ação integrada quando os serviços existirem.

Exemplos de orquestração:
- criar conjunto completo a partir do personagem atual;
- aplicar conjunto completo;
- detectar condição ruim da arma e oferecer “Abrir no Armeiro”;
- encaminhar uma caixa para Items/estoque;
- mostrar disponibilidade de um Set sem duplicar sua definição.

Hub **não** deve implementar:
- ItemKit ou mutação de inventário;
- WeaponConfiguration/WeaponInstance;
- desgaste/condição;
- EquipmentKit;
- Set como dado persistente;
- estoque/economia;
- whitelist/blacklist;
- lógica interna do Armorer.

Regra de dependência:

```text
Hub -> descobre/consome módulos
Módulos de domínio -X-> Hub
```

---

# Items — conteúdo consumível e kits de itens

**Dono de ItemEntry, ItemKit, conteúdo de U/C/M e transações físicas de itens.**

Funcionalidades:
- **IMPLEMENTADO** — criação de kit de itens;
- **IMPLEMENTADO** — edição do kit;
- **IMPLEMENTADO** — renomear kit;
- **IMPLEMENTADO** — duplicar/clonar kit;
- **IMPLEMENTADO** — excluir kit;
- **IMPLEMENTADO** — mesclar conteúdo em kit/draft;
- **IMPLEMENTADO** — capturar conteúdo atual de Uniforme/Colete/Mochila;
- **IMPLEMENTADO** — catálogo de itens derivado de configs;
- **IMPLEMENTADO** — busca e filtro de catálogo;
- **IMPLEMENTADO** — categorias de catálogo;
- **IMPLEMENTADO** — adicionar item do catálogo ao kit;
- **IMPLEMENTADO** — adicionar item diretamente ao inventário/equipamento selecionado;
- **IMPLEMENTADO** — aumentar/diminuir/definir quantidade;
- **IMPLEMENTADO** — remover itens;
- **IMPLEMENTADO** — drag-and-drop entre Catálogo/Draft/Equipamento;
- **IMPLEMENTADO** — Draft antes de persistência/aplicação;
- **IMPLEMENTADO** — Repository privado persistente;
- **IMPLEMENTADO** — biblioteca PRIVADOS/PÚBLICOS;
- **IMPLEMENTADO** — publicar snapshot de kit;
- **IMPLEMENTADO** — copiar kit público para privado;
- **IMPLEMENTADO** — aplicação Whole-Kit;
- **IMPLEMENTADO** — ADD/REMOVE;
- **IMPLEMENTADO** — REPLACE;
- **IMPLEMENTADO** — CLEAR;
- **IMPLEMENTADO** — BEST_EFFORT;
- **IMPLEMENTADO** — STRICT/atomicidade;
- **IMPLEMENTADO** — dry-run/planning;
- **IMPLEMENTADO** — fingerprint/drift detection;
- **IMPLEMENTADO** — rollback;
- **IMPLEMENTADO** — preservação de magazines EXACT/parciais;
- **IMPLEMENTADO** — capacidade de Uniforme/Colete/Mochila;
- **IMPLEMENTADO** — carga global do jogador;
- **IMPLEMENTADO** — distinção `applicationTarget` x `equipmentView`;
- **IMPLEMENTADO** — autoridade de servidor para publicação pública em 0.13-A;
- **PLANEJADO** — JIP/state reconciliation da biblioteca pública;
- **PLANEJADO** — persistência pública server-side;
- **PLANEJADO** — integração opcional com Policy;
- **PLANEJADO** — integração opcional com Stock/Economy/Persistence providers.

Items **não** deve implementar:
- desgaste de arma;
- compatibilidade de acessórios de arma;
- WeaponInstance;
- receitas de armas;
- manutenção de bancada;
- economia própria.

---

# Weapons — armas, identidade, kits e organização player-facing

**Dono do que a arma é e da experiência simples/direta de organização de armas.**

Funcionalidades:
- **MISSION-FIRST APROVADO** — WeaponInstance lifecycle/evidência conservadora 0.1-B;
- **MISSION-FIRST APROVADO** — WeaponConfiguration 0.2;
- **MISSION-FIRST APROVADO** — catálogo/compatibilidade 0.3;
- **PLANEJADO 0.4** — WeaponRecipe;
- **PLANEJADO 0.5** — WeaponKit;
- **PLANEJADO 0.6** — UI própria de Weapons / Kit Builder;
- **PLANEJADO 0.6** — catálogo de armas na UI;
- **PLANEJADO 0.6** — visualizar informações da arma;
- **PLANEJADO 0.6** — editar acessórios compatíveis;
- **PLANEJADO 0.6** — gerenciar Meus Kits;
- **PLANEJADO 0.7** — equipar/aplicar somente o slot de arma alvo;
- **PLANEJADO 0.7** — preservar uniforme/colete/mochila/itens/outras armas;
- **PLANEJADO 0.8** — autoridade/reconciliação multiplayer;
- **PLANEJADO** — persistência opcional de kits/identidade/configuração;
- **PLANEJADO** — contratos públicos para Armorer, WeaponCondition, Equipment e Sets.

Conceito:

> **WeaponKit = uma arma configurada para um slot.**

Não é um loadout completo.

A parte de armas do APM histórico é referência de UX/lessons learned para a UI de Weapons, mas não é automaticamente fonte de ownership ou arquitetura.

Weapons **não** deve implementar:
- fórmula de desgaste;
- condition state;
- sujeira/lubrificação/corrosão;
- lógica de reparo;
- bancada física;
- Preview 3D avançado de bancada;
- UI de manutenção/peças;
- estoque/preço;
- whitelist/blacklist própria.

# WeaponCondition — desgaste, condição e manutenção lógica

**Dono de como a arma está: uso, condição, ambiente, peças, confiabilidade e manutenção lógica.**

Funcionalidades:
- **PLANEJADO** — `WeaponConditionState`;
- **PLANEJADO** — provider autoritativo de condição;
- **PLANEJADO** — contador total de disparos;
- **PLANEJADO** — `shotsPending` em memória/batching;
- **PLANEJADO** — desgaste por disparo;
- **PLANEJADO** — desgaste do cano;
- **PLANEJADO** — desgaste do conjunto do ferrolho/ação;
- **PLANEJADO** — desgaste de mola/sistemas internos;
- **PLANEJADO** — sujeira/fouling;
- **PLANEJADO** — lubrificação;
- **PLANEJADO** — corrosão;
- **PLANEJADO** — confiabilidade derivada do estado;
- **PLANEJADO** — exposição à água;
- **PLANEJADO** — tempo nadando;
- **PLANEJADO** — tempo submerso;
- **PLANEJADO** — avaliação em lote/event-driven;
- **PLANEJADO** — condition state por componente/peça;
- **PLANEJADO** — avaliação de necessidade de manutenção;
- **PLANEJADO** — limpeza como transição lógica;
- **PLANEJADO** — lubrificação como transição lógica;
- **PLANEJADO** — reparo como transição lógica;
- **PLANEJADO** — substituição lógica de peças;
- **FUTURO** — exposição a lama/poeira/areia, se detectável de forma confiável;
- **FUTURO** — ciclos térmicos/temperatura;
- **FUTURO** — PartInstance/serial individual de peça quando necessário;
- **FUTURO** — panes/jams derivados da condição;
- **PLANEJADO** — adapters/providers externos de condição;
- **PLANEJADO** — somente um provider autoritativo de condição por arma/sessão.

WeaponCondition recebe `WeaponInstance`/serial de Weapons e **não cria uma segunda identidade da arma**.

WeaponCondition **não** deve implementar:
- WeaponConfiguration/WeaponRecipe;
- compatibilidade de acessórios;
- bancada/Preview/UI;
- estoque/preço;
- whitelist/blacklist própria.

---

# Armorer — bancada especializada, inspeção e manutenção

**Dono da experiência física/visual especializada de bancada; consome Weapons e WeaponCondition.**

Funcionalidades:
- **AVANÇADO/HISTÓRICO** — estação/bancada física;
- **AVANÇADO/HISTÓRICO** — sessão/lease multiplayer por estação;
- **AVANÇADO/HISTÓRICO** — Preview 3D avançado da arma;
- **AVANÇADO/HISTÓRICO** — montagem/remoção visual de acessórios;
- **AVANÇADO/HISTÓRICO** — draft/original/working/confirmed configuration;
- **AVANÇADO/HISTÓRICO** — commit/rollback em contexto de bancada;
- **PLANEJADO** — consumir WeaponRecipe/WeaponKit de Weapons;
- **PLANEJADO** — editar configuração/receita em contexto de bancada sem duplicar o modelo;
- **PLANEJADO** — UI de inspeção de condição;
- **PLANEJADO** — peças/componentes internos;
- **PLANEJADO** — limpeza/lubrificação/diagnóstico/reparo;
- **PLANEJADO** — workflow de troca de peças;
- **PLANEJADO** — integração Stock/Economy/Persistence;
- **FUTURO** — cronógrafo, zeragem, agrupamento/estande, relatório técnico.

Divisão:
- **Weapons**: arma, identidade, configuração, compatibilidade, Recipe, Kit, UI cotidiana e aplicação slot-safe;
- **WeaponCondition**: condição/desgaste/peças e transições de manutenção;
- **Armorer**: bancada, Preview 3D avançado, inspeção, peças e workflow de manutenção.

Armorer **não substitui a UI própria de Weapons** e não deve manter uma segunda implementação de WeaponKit/WeaponConfiguration.

# Equipment — estrutura de loadout

**Dono do equipamento estrutural do personagem, não do conteúdo interno do ItemKit.**

Funcionalidades planejadas:
- criar EquipmentKit;
- salvar configuração estrutural;
- Uniforme;
- Colete;
- Mochila;
- Capacete;
- NVG;
- Facewear;
- Binocular;
- AssignedItems;
- aplicar/trocar equipamento estrutural;
- trocar equipamento sem alterar domínios que não fazem parte da operação;
- referenciar ItemKit para conteúdo;
- referenciar WeaponKit/WeaponConfiguration quando apropriado;
- validação de slots/equipamentos disponíveis;
- integração opcional com Policy;
- integração opcional com Stock/Persistence.

Equipment **não** deve duplicar:
- conteúdo do Items;
- estado/desgaste de Weapons;
- workflow do Armorer.

---

# Sets — conjuntos completos

**Dono da composição/orquestração de referências a kits de outros módulos.**

Funcionalidades planejadas:
- criar Set;
- editar Set;
- duplicar Set;
- excluir Set;
- combinar ItemKit + WeaponKit + EquipmentKit;
- presets por função/papel;
- aplicar um conjunto completo chamando os módulos proprietários;
- validar disponibilidade dos módulos necessários;
- aplicar parcialmente apenas quando a política do Set permitir;
- compartilhar/publicar Sets futuramente.

Sets **não** deve:
- copiar engines físicos de Items/Weapons/Equipment;
- manipular namespaces privados;
- manter uma segunda versão de um kit.

---

# Policy — whitelist/blacklist

**Dono único das regras de allow/deny.**

Funcionalidades planejadas:
- whitelist de Items;
- blacklist de Items;
- whitelist de Weapons;
- blacklist de Weapons;
- whitelist/blacklist de Attachments;
- whitelist/blacklist de Magazines;
- whitelist/blacklist de Equipment;
- regra por className;
- regra por baseClass;
- regra por addon/mod de origem;
- regra por categoria;
- regra por tag;
- modos OPEN / WHITELIST_ONLY / BLACKLIST_ONLY / COMBINED;
- prioridade de deny explícito sobre allow genérico;
- decisão server-authoritative;
- consulta por contrato `PolicyDecision`;
- filtro de catálogo/UI;
- validação novamente no executor/servidor.

Nenhum outro módulo deve implementar sua própria engine de whitelist/blacklist.

---

# ServerIntegration — ponte opcional com o servidor

**Dono da integração com serviços externos de servidor; não da lógica dos domínios.**

Funcionalidades planejadas:
- descobrir PersistenceProvider;
- descobrir StockProvider;
- descobrir EconomyProvider;
- adaptar frameworks externos para contratos SP_ORG;
- QUERY/QUOTE;
- RESERVE;
- COMMIT;
- RELEASE;
- ROLLBACK/refund quando aplicável;
- armazenamento server-side;
- integração com banco/extensão/framework sem vazar detalhes para Items/Weapons/Armorer;
- estoque global;
- estoque por base;
- estoque por facção;
- estoque por estação;
- quantidade disponível;
- preço de compra;
- preço de venda;
- custo de serviço/reparo;
- histórico persistente quando o provider suportar.

Sem provider, o restante do SP_ORG continua funcionando em modo standalone.

---

# Settings — configuração e preferências

**Dono de configuração compartilhável/administrativa; não de estado de domínio.**

Funcionalidades planejadas:
- preferências de UI;
- feature flags;
- configuração administrativa;
- ativar/desativar integrações opcionais;
- parâmetros de módulos;
- presets de servidor;
- consulta padronizada de configuração.

Settings não deve armazenar WeaponInstance, ItemKit, estoque ou estado de sessão.

---

# Adapters — compatibilidade com terceiros

**Dono de integração específica com mods/frameworks externos.**

Funcionalidades planejadas:
- Adapter ACE;
- Adapter CBA;
- adapters para sistemas de economia;
- adapters para persistência;
- adapters para inventário/mods específicos;
- registro condicional de capabilities quando dependência externa existir;
- tradução entre contratos externos e contratos SP_ORG.

O core não deve ficar cheio de `if ACE...`, `if framework X...`.

---

# Ownership de funcionalidades transversais sensíveis

| Funcionalidade | Único proprietário | Consumidores permitidos |
|---|---|---|
| Navegação e experiência integrada entre módulos | Hub | jogador/UI |
| ItemKit / conteúdo | Items | Sets, Equipment, UI |
| WeaponConfiguration / WeaponRecipe / WeaponKit | Weapons | Armorer, Sets, Equipment |
| WeaponInstance / serial | Weapons | WeaponCondition, Armorer, Persistence |
| Desgaste/condição/peças/confiabilidade | WeaponCondition | Armorer, Persistence |
| Manutenção lógica | WeaponCondition | Armorer |
| UI simples de organização/configuração/equipar arma por slot | Weapons | jogador/UI, Hub |
| Bancada/Preview 3D/inspeção/peças/workflow de manutenção | Armorer | jogador/UI |
| EquipmentKit | Equipment | Sets |
| Composição completa | Sets | jogador/UI |
| Whitelist/blacklist | Policy | Items, Weapons, Equipment, Armorer |
| Estoque/quantidade | ServerIntegration/StockProvider | Items, Weapons, Armorer, Equipment |
| Preço/economia | ServerIntegration/EconomyProvider | Items, Weapons, Armorer, Equipment |
| Persistência de servidor | ServerIntegration/PersistenceProvider | todos os domínios que precisarem |
| Contracts/Capabilities/Events | Nexus | todos |
| Preferências/feature flags | Settings | todos |
| Integração ACE/CBA/terceiros | Adapters | módulos que consumirem capability |

---

# Regra anti-duplicação

Antes de criar uma funcionalidade nova:

1. procurar neste catálogo quem é o proprietário;
2. se já existe proprietário, adicionar contrato/capability ao proprietário;
3. o consumidor chama o proprietário;
4. não copiar implementação para o consumidor;
5. se não existir proprietário, decidir ownership antes de escrever runtime;
6. registrar a decisão em `machine/FEATURE_OWNERSHIP.json` e neste documento.

Esse catálogo deve ser tratado como contrato arquitetural do projeto.

## Nota de implementação — Weapons 0.1-A

Os itens planejados de Weapons descrevem o produto final. Nesta entrega existem foundation e implementações internas candidatas de configuração/instância/serial. A identidade física não está comprovada, nenhum contrato v1 está publicado e nenhuma integração de domínio está ativa. Ownership permanece igual.
