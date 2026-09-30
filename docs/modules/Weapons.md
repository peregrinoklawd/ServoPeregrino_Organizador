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

### 0.4 — FUNCTIONAL PASS / FREEZE PENDING

- R3: **245/245 AUTO**;
- WeaponRecipe `0.4-recipe-candidate`;
- Recipe = WeaponConfiguration + `magazineClass` opcional;
- sem `targetSlot`, kit name, identity/serial ou ammoCount;
- sem mutação de inventário;
- SECONDARY runtime variants resolvidas por `baseWeapon`;
- R4 pendente apenas para deduplicar classnames case-insensitively no resultado de compatibilidade.

## Roadmap

1. 0.4 R4 — hygiene/freeze do WeaponRecipe;
2. 0.5 — WeaponKit;
3. 0.6 — Weapons Player UI / Kit Builder;
4. 0.7 — Slot-Safe Weapon Application;
5. 0.8 — Multiplayer Authority / Reconciliation.

Gates paralelos: integração addon/PBO, Packaging, MP/JIP/reconnect e identidade física intrínseca.

Ver:
- `../26_WEAPONS_0_4_WEAPON_RECIPE.md`
- `../24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md`
- `../25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md`
- `Armorer.md`
