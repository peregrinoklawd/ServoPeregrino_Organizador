# Servo Peregrino Organizador — SP_ORG

Monorepo do **Servo Peregrino Organizador**, uma família de addons independentes para Arma 3 integrados por contratos públicos do Nexus.

## Princípio

Um repositório, vários módulos/PBOs. Nenhum módulo deve depender do estado privado de outro módulo. Integrações usam **Capabilities, Contracts, Events e Results** do Nexus.

## Implementado hoje

- `addons/ServoPeregrino_Organizador_Nexus` — Foundation 1.1.
- `addons/ServoPeregrino_Organizador_Weapons` — source integrado ainda em 0.1-A; validação mission-first avançou até 0.4 R3 (245/245 funcional; baseline freeze pendente de R4 de higiene case-insensitive). Weapons é um módulo player-facing com UI própria para montar/salvar/equipar armas por slot sem alterar o restante do loadout. Identidade física intrínseca continua não comprovada.
- `addons/ServoPeregrino_Organizador_Items` — baseline 0.12 FINAL; lógica 0.13-A em validação runtime/multiplayer.
- `missions/SP_ORG_Items_0_13_A_Multiplayer_Lab_8Slots_R3.VR` — laboratório Items.

Módulos planejados e Armorer histórico estão em `machine/PROJECT_STATE.json` e `docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md`.

## Estado imediato

Items 0.13-A source está implementada; **Packaging R2 permanece pendente de validação no Arma**. Não iniciar 0.13-B antes desse gate.

## Source of Truth

Leia antes de alterar runtime:
- `docs/00_STATUS_ATUAL.md`
- `docs/01_ARQUITETURA.md`
- `docs/08_LICOES_APRENDIDAS_DO_DONT.md`
- `docs/09_ROADMAP_E_PROXIMO_PASSO.md`
- `docs/10_CONTINUAR_COM_IA.md`
- `docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md`
- `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`
- `docs/19_VISAO_FUNCIONAL_COMPARTILHAVEL.md`
- `machine/PROJECT_STATE.json`
- `machine/FEATURE_OWNERSHIP.json`

Nunca reconstrua uma entrega por memória. Trabalhe por delta sobre a baseline registrada e preserve contratos homologados.


## Estrutura modular preparada

O diretório `addons/` agora contém slots explícitos para os módulos futuros. Um slot com apenas `README.md` **não participa do build**.

O Armorer possui diretório reservado em `addons/ServoPeregrino_Organizador_Armorer/`. A baseline histórica será importada somente depois de confirmar o source autoritativo, sem reconstrução de memória.

Design de identidade/desgaste: `docs/17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md`.


## Fronteira Weapons / WeaponCondition / Armorer

- **Weapons**: identidade, serial, configuração, compatibilidade, receitas, WeaponKit, UI própria de montagem/configuração simples e aplicação slot-safe da arma.
- **WeaponCondition**: desgaste, condição, peças, uso, ambiente e manutenção lógica.
- **Armorer**: bancada especializada, Preview 3D avançado, montagem física/visual, inspeção, peças e workflow/UI de manutenção.

Regra conceitual: **Weapons não depende do Armorer para ser utilizável pelo jogador**. Sua experiência é deliberadamente próxima da parte de armas do APM histórico: escolher arma, configurar acessórios, consultar informações, salvar/carregar uma configuração e equipar apenas o slot alvo. O restante do loadout deve permanecer intacto.

Catálogo funcional compartilhável: `docs/19_VISAO_FUNCIONAL_COMPARTILHAVEL.md`.


## Hub / Central do Organizador

O módulo planejado `ServoPeregrino_Organizador_Hub` será a camada opcional de integração voltada ao jogador.

```text
Nexus = faz os módulos conversarem tecnicamente.
Hub   = faz o jogador conversar com os módulos.
```

O Hub poderá oferecer menu principal, navegação dinâmica, passagem de contexto e ações integradas. Ele **não executa lógica de domínio** e nenhum módulo dependerá dele para funcionar.

Detalhes: `docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md`.

## Weapons — estado mission-first

O source integrado nesta branch continua sendo **0.1-A**, sem contratos v1 publicados. Os laboratórios mission-first já validaram:

- **0.1-B — WeaponInstance Lifecycle / Event-Delta Evidence**: AUTO TEST 128/128 + Take/Put 3/3.
- **0.2 — WeaponConfiguration**: AUTO TEST final 175/175; capture/diff/apply/round-trip com loadedState preservado.
- **0.3 — Catalog & Compatibility**: AUTO TEST final R2 213/213; catálogo derivado do engine, conteúdo modded/provenance, compatibilidade de attachments/magazines sob demanda e cache de sessão.
- **0.4 — WeaponRecipe**: R3 funcional 245/245; schema/semântica/fingerprint/deep-copy e PRIMARY/HANDGUN/SECONDARY aprovados. Freeze final aguarda R4 de deduplicação case-insensitive de magazines.

Essas homologações são de **MISSION-FIRST FUNCTIONAL GATE**, não de PBO/addon integrado. MP/JIP, Packaging e identidade física intrínseca continuam gates separados.

### Conceito player-facing de Weapons

Weapons segue o mesmo princípio modular de Items:

- possui **UI própria**;
- permite criar/editar/salvar **WeaponKits**;
- um WeaponKit representa **uma arma configurada para um slot**, não um loadout completo;
- permite escolher a arma e acessórios compatíveis;
- apresenta informações da arma;
- ao equipar/aplicar, modifica somente o slot de arma alvo e preserva uniforme, colete, mochila, itens, outras armas e demais domínios.

A referência de UX/lessons learned será a parte de armas do **APM histórico**, sem copiar automaticamente decisões antigas de arquitetura.

### Roadmap Weapons

```text
0.1-A  Foundation / Identity Spike             APPROVED BASE
0.1-B  Lifecycle / Event-Delta Evidence        APPROVED
0.2    WeaponConfiguration                     APPROVED
0.3    Catalog / Compatibility                 APPROVED
0.4    WeaponRecipe                            FUNCTIONAL PASS 245/245; R4 HYGIENE
0.5    WeaponKit                               NEXT AFTER R4
0.6    Weapons Player UI / Kit Builder
0.7    Slot-Safe Weapon Application
0.8    Multiplayer Authority / Reconciliation
```

Documentação: [0.1-A](docs/21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](docs/22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md), [0.2](docs/23_WEAPONS_0_2_WEAPON_CONFIGURATION.md), [0.3](docs/24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md), [conceito de produto/UI](docs/25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md) e [0.4](docs/26_WEAPONS_0_4_WEAPON_RECIPE.md).

O desenvolvimento dos núcleos é independente. O gate de Items 0.13-A permanece pendente e não bloqueia Weapons.