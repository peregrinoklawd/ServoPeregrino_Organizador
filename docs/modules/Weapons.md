# Weapons — ownership

## Papel

Dono do que a arma **é** e da experiência simples/direta de organização de armas para o jogador.

Weapons é análogo a Items no princípio de produto:

- Items possui UI própria para ItemKits e conteúdo;
- Weapons possui UI própria para WeaponKits e configurações de armas;
- cada módulo altera somente o domínio que possui.

**Weapons não é apenas backend do Armorer.**

## Ownership funcional

Weapons é dono de:

- WeaponInstance / instanceId / serial;
- WeaponConfiguration;
- WeaponRecipe;
- WeaponKit;
- catálogo de armas;
- catálogo/provenance de armas modded;
- compatibilidade de slots e acessórios;
- compatibilidade de magazines;
- UI player-facing de catálogo/configuração/kit;
- salvar, editar, duplicar e carregar WeaponKits;
- apresentar informações técnicas básicas da arma;
- aplicar/equipar uma arma por slot;
- troca slot-safe sem alterar o restante do loadout;
- contratos públicos consumidos por Armorer, Sets e outros módulos.

## Conceito de WeaponKit

Um **WeaponKit representa uma arma configurada para um único slot**, não um loadout completo.

Exemplo conceitual:

```text
WeaponKit "MK18 CQB Noturno"
targetSlot = PRIMARY
weaponClass = <classe da MK18>
muzzle = <suppressor>
pointer = <laser>
optic = <optic>
bipod = ""
```

Categorias engine atualmente tratadas:

- PRIMARY;
- HANDGUN;
- SECONDARY (launcher no modelo de inventário do Arma).

## UI própria de Weapons

A UI deverá ser simples e direta, deliberadamente próxima da parte de armas do APM histórico.

Deve permitir:

- navegar pelo catálogo de armas;
- escolher uma arma;
- ver informações da arma;
- ver somente acessórios/magazines compatíveis;
- montar uma configuração;
- salvar como WeaponKit;
- editar/duplicar/excluir kits;
- selecionar o slot alvo;
- equipar/aplicar a arma;
- preservar todo o restante do loadout.

### Invariante de aplicação

Aplicar um WeaponKit deve modificar **somente o slot de arma alvo**.

Exemplo:

```text
ANTES:
uniforme  = A
colete    = B
mochila   = C
primary   = MX
handgun   = P07
secondary = NLAW
itens     = X

APLICAR WeaponKit targetSlot=PRIMARY

DEPOIS:
uniforme  = A          (igual)
colete    = B          (igual)
mochila   = C          (igual)
primary   = kit alvo   (única mudança intencional)
handgun   = P07        (igual)
secondary = NLAW       (igual)
itens     = X          (igual)
```

Esse será um gate funcional explícito da 0.7.

## Relação com APM

A parte de armas do APM histórico é uma **fonte de lições aprendidas de UX e comportamento** para a futura Weapons UI.

Regra:

- reaproveitar conceitos que provaram ser claros e úteis;
- registrar o que funcionou e o que não funcionou;
- não copiar automaticamente acoplamentos, ownership ou limitações antigas;
- adaptar a experiência ao novo domínio modular de Weapons.

## Não é dono

Weapons não deve implementar:

- desgaste;
- sujeira/lubrificação/corrosão;
- condição de peças;
- confiabilidade;
- manutenção lógica;
- estação/bancada física;
- Preview 3D avançado de bancada;
- inspeção e manutenção de peças;
- estoque/preço;
- whitelist/blacklist própria.

Esses estados pertencem a **WeaponCondition** e a experiência especializada de bancada pertence ao **Armorer**.

## Fronteira com Armorer

**Weapons UI**:
- organização/configuração cotidiana;
- WeaponKit;
- escolha de arma/acessórios;
- informação básica;
- equipar por slot;
- independente de bancada.

**Armorer UI**:
- estação física;
- Preview 3D avançado;
- montagem física/visual detalhada;
- inspeção;
- peças/componentes;
- condição;
- limpeza/lubrificação/reparo;
- workflow de manutenção.

Armorer consome WeaponConfiguration/Recipe/Kit/Compatibility de Weapons; não cria uma segunda engine desses modelos.

## Estado de implementação e validação

### Source integrado

A branch atual ainda contém o **addon source 0.1-A**. Os deltas mission-first precisam ser integrados ao addon/PBO antes de release.

### 0.1-B — APPROVED SP

- 128/128 AUTO;
- 3/3 Take/Put manual;
- CORRELATED / AMBIGUOUS / UNPROVEN;
- identidade física intrínseca não alegada.

### 0.2 — APPROVED SP

- 175/175 AUTO;
- WeaponConfiguration 0.2-candidate;
- PRIMARY/HANDGUN/SECONDARY;
- loadedState preservado;
- no-op sem mutação.

### 0.3 — APPROVED SP

- candidata final R2;
- **213/213 AUTO**;
- catálogo-base no modset de validação: 2770 armas;
- catálogo com presets: 3380;
- compatibilidade de attachments e magazines derivada do engine;
- provenance de conteúdo modded;
- cache de sessão;
- reverse global scan deliberadamente evitado.

### 0.4 — APPROVED SP

- R5 final: **251/251 AUTO**;
- WeaponRecipe `0.4-recipe-candidate`;
- Recipe = WeaponConfiguration + `magazineClass` opcional;
- sem `targetSlot`, kit name, identity/serial ou ammoCount;
- sem mutação de inventário;
- SECONDARY runtime variants resolvidas por `baseWeapon`;
- compatibilidade deduplicada case-insensitively;
- PRIMARY/HANDGUN strict class guard preservado;
- SECONDARY aceita somente variantes type=4 da mesma família `baseWeapon`;
- baseline mission-first congelada.

### 0.5 — APPROVED SP

- schema `0.5-kit-candidate`;
- WeaponKit = `kitId + name + targetSlot + recipe`;
- repository `SESSION_LOCAL_CANDIDATE`;
- create/get/list/rename/duplicate/update Recipe/delete;
- nomes únicos case-insensitively;
- content fingerprint não inclui kitId/nome;
- UI/aplicação/MP continuam deferred;
- static validation **131/131**;
- runtime final **301/301 PASS / 0 FAIL**;

### 0.6-A — FROZEN UI SHELL BASELINE

- R4 runtime: **362/362 AUTO**;
- layout: Meus Kits | Kit Selecionado | Catálogo de Armas;
- UI labels: Principal / Porte / Secundária;
- filtros privados: Todos / Principal / Porte / Secundária;
- filtros catálogo: Todos / Principal / Porte / Secundária;
- internal slots unchanged: PRIMARY / HANDGUN / SECONDARY;
- Items-style search, tooltips, panel-local actions and Context/Message/History footer;
- Públicos visible-disabled until a real public WeaponKit provider exists;
- no separate Compatible Accessories panel;
- compatible choices belong to Selected Kit selectors;
- bounded catalog projection: 250 rows;
- zero WeaponKit/loadout mutation in 0.6-A;
- shell visual/estrutural congelado durante 0.6-B..E.

### 0.6-B — APPROVED SP / FROZEN R4

- final build: `0.6.1.4-initial-sync-handshake-test-timing-mission-first`;
- runtime final: **397/397 PASS / 0 FAIL**;
- R1: 392/392, rejeitada apenas por structured-text entity noise;
- R2: 392/392, higiene corrigida; manual revelou abertura inicial sem linhas em MEUS KITS;
- R3: comportamento manual corrigido; 391/396 por race de timing no teste;
- R4: handshake explícito de sincronização inicial e gate automático corrigido;
- `MEUS KITS` abre em **TODOS/ALL**, busca vazia;
- visible rows == repository rows no gate inicial;
- primeiro kit selecionado quando existem kits;
- catalog selection = read-only information context;
- saved-kit selection = read-only information context;
- information: displayName, category, weaponClass, picture, origin, baseWeapon, description;
- catalog preview does not fabricate accessory compatibility;
- no compatibility query in UI yet;
- no draft;
- no WeaponKit authoring;
- no loadout mutation;
- no WeaponKit mutation;
- geometry remains frozen from 0.6-A R4;
- **mission-first functional gate homologado**.

**Próximo gate: 0.6-C — Compatibility Selectors.**

### Visual polish deferred

Depois de implementar e testar as funcionalidades da 0.6:
- reavaliar composição vertical de Kit Selecionado;
- separar visualmente Context / Message / History;
- aplicar a mesma separação de rodapé em Items e Weapons;
- validar 1080p e ultrawide.

Ver `../29_SHARED_UI_ITEMS_WEAPONS.md`.

## Roadmap

1. 0.6-C — Seletores de compatibilidade;
2. 0.6-D — Rascunho de WeaponKit;
3. 0.6-E — Authoring/lifecycle;
4. 0.6-F — Adaptação visual final + regressões;
5. 0.7 — Slot-Safe Weapon Application;
6. 0.8 — Multiplayer Authority / Reconciliation.

Gates paralelos: integração addon/PBO, Packaging, MP/JIP/reconnect e identidade física intrínseca.

Ver:
- `../26_WEAPONS_0_4_WEAPON_RECIPE.md`
- `../27_WEAPONS_0_5_WEAPON_KIT.md`
- `../24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md`
- `../25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md`
- `Armorer.md`
