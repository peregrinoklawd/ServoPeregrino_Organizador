# Catálogo funcional e ownership por módulo — SP_ORG

Data de consolidação: **28/09/2026**.

## Objetivo

Este documento define **quem é dono de cada funcionalidade** no Servo Peregrino Organizador.

Regra principal:

> **Uma funcionalidade de domínio tem um único módulo proprietário. Outros módulos podem consumir o serviço por Capability/Contract/Event do Nexus, mas não devem criar uma segunda implementação paralela.**

Isso evita duplicações como:
- Items e Equipment criarem dois motores diferentes para o mesmo conteúdo;
- Armorer e Weapons manterem dois estados diferentes de desgaste;
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

# Weapons — armas, identidade, construção e configuração

**Dono do que a arma é: identidade, configuração, compatibilidade e receitas.**

Funcionalidades:
- **PLANEJADO** — WeaponKit;
- **PLANEJADO** — WeaponConfiguration;
- **PLANEJADO** — WeaponRecipe como modelo/contrato;
- **PLANEJADO** — compatibilidade de slots;
- **PLANEJADO** — acessórios/muzzle/optic/pointer/bipod;
- **PLANEJADO** — compatibilidade de magazines;
- **PLANEJADO** — trocar arma dinamicamente sem alterar o restante do loadout;
- **PLANEJADO** — aplicar somente arma/configuração desejada;
- **PLANEJADO** — identidade individual `WeaponInstance`;
- **PLANEJADO** — número de série definitivo;
- **PLANEJADO** — metadata/histórico da identidade;
- **PLANEJADO** — persistência opcional da identidade/configuração;
- **PLANEJADO** — contratos públicos para Armorer, WeaponCondition e Sets.

Weapons **não** deve implementar:
- fórmula de desgaste;
- condition state;
- sujeira/lubrificação/corrosão;
- lógica de reparo;
- bancada física;
- UI de manutenção;
- estoque/preço;
- whitelist/blacklist própria.

---

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

# Armorer — bancada, montagem, inspeção e workflow de manutenção

**Dono do workflow físico/visual; consome Weapons e WeaponCondition.**

Funcionalidades:
- **AVANÇADO/HISTÓRICO** — estação/bancada física;
- **AVANÇADO/HISTÓRICO** — sessão de armeiro;
- **AVANÇADO/HISTÓRICO** — exclusividade/lease multiplayer por estação;
- **AVANÇADO/HISTÓRICO** — Preview 3D da arma;
- **AVANÇADO/HISTÓRICO** — montagem/remoção visual de acessórios;
- **AVANÇADO/HISTÓRICO** — rascunho de configuração;
- **AVANÇADO/HISTÓRICO** — `originalConfiguration`;
- **AVANÇADO/HISTÓRICO** — `workingConfiguration`;
- **AVANÇADO/HISTÓRICO** — `confirmedConfiguration`;
- **AVANÇADO/HISTÓRICO** — commit/rollback de configuração;
- **PLANEJADO** — criação/edição de receitas na bancada;
- **PLANEJADO** — salvar receita/configuração preferida;
- **PLANEJADO** — montar arma a partir de receita;
- **PLANEJADO** — UI de inspeção de condição;
- **PLANEJADO** — workflow de manutenção;
- **PLANEJADO** — UI de limpeza;
- **PLANEJADO** — UI de lubrificação;
- **PLANEJADO** — UI de diagnóstico;
- **PLANEJADO** — UI de reparo;
- **PLANEJADO** — workflow de troca de peças;
- **PLANEJADO** — consumir peças/ferramentas de Player/Container/Station Stock;
- **PLANEJADO** — integração com StockProvider;
- **PLANEJADO** — integração com EconomyProvider;
- **PLANEJADO** — integração com PersistenceProvider;
- **FUTURO** — cronógrafo;
- **FUTURO** — zeragem;
- **FUTURO** — agrupamento/estande;
- **FUTURO** — relatório de inspeção.

Divisão:
- **Weapons**: modelo/validação da arma, identidade, configuração, compatibilidade e receita;
- **WeaponCondition**: desgaste, condição, peças e manutenção lógica;
- **Armorer**: bancada, Preview, UI e workflow.

Armorer **não** deve manter uma segunda condição/desgaste da arma.

---

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
| ItemKit / conteúdo | Items | Sets, Equipment, UI |
| WeaponConfiguration / WeaponRecipe | Weapons | Armorer, Sets |
| WeaponInstance / serial | Weapons | WeaponCondition, Armorer, Persistence |
| Desgaste/condição/peças/confiabilidade | WeaponCondition | Armorer, Persistence |
| Manutenção lógica | WeaponCondition | Armorer |
| Bancada/montagem/inspeção/workflow de manutenção | Armorer | jogador/UI |
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
