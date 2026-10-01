# Servo Peregrino Organizador — SP_ORG

Monorepo do **Servo Peregrino Organizador**, uma família de addons independentes para Arma 3 integrados por contratos públicos do Nexus.

## Princípio

Um repositório, vários módulos/PBOs. Nenhum módulo deve depender do estado privado de outro módulo. Integrações usam **Capabilities, Contracts, Events e Results** do Nexus.

## Implementado hoje

- `addons/ServoPeregrino_Organizador_Nexus` — Foundation 1.1.
- `addons/ServoPeregrino_Organizador_Weapons` — source integrado ainda em 0.1-A; mission-first homologado funcionalmente até **0.6-D R1 — 471/471**. A **0.6-D R2** fechou AUTO em **500/500**, mas foi **reprovada no gate manual de desempenho** porque scroll/slider ainda disparavam full refresh de ~246–254 ms. **0.6-D R3 — Focused Refresh / Header Polish** é a candidata ativa: static **272/272**, 485 asserts no runner e runtime projetado **512**. Identidade física intrínseca continua não comprovada.
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
- **0.4 — WeaponRecipe**: R5 homologada com 251/251; schema/semântica/fingerprint/deep-copy, higiene case-insensitive e equivalência segura de variantes runtime SECONDARY aprovados.
- **0.5 — WeaponKit**: homologada com **301/301**; lifecycle session-local de kits, PRIMARY/HANDGUN/SECONDARY, CRUD, defensive copy, isolamento de slot e nenhuma mutação do loadout.
- **0.6-A — Player UI Shell**: R4 homologada com **362/362**; shell visual/estrutural congelado, filtros Todos/Principal/Porte/Secundária, catálogo bounded-render e rodapé Context/Message/History.
- **0.6-B — Selection + Information**: R4 homologada com **397/397**; seleção read-only de catálogo/WeaponKit, informações básicas da arma e abertura determinística de MEUS KITS em TODOS, sem mutação de WeaponKit/loadout.
- **0.6-C — Compatibility Selectors**: R1 homologada com **445/445**.
- **0.6-D R1 — WeaponKit Draft**: homologada com **471/471**; draft local por kit, SALVO/ALTERADO e DESCARTAR sem mutar repository/loadout.
- **0.6-D R2 — UI Convergence / Equipment Content**: **500/500 AUTO**, porém **REJEITADA NO GATE MANUAL DE PERFORMANCE**; interações locais ainda reconstruíam a UI inteira.
- **0.6-D R3 — Focused Refresh / Header Polish**: candidata ativa; catálogo/draft/equipamento usam refresh focal, projeção/filtros do catálogo são cacheados e o header é ancorado da direita a partir do X. Static **272/272**; runtime projetado **512**.

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
0.4    WeaponRecipe                            APPROVED 251/251
0.5    WeaponKit                               APPROVED 301/301
0.6    Weapons Player UI / Kit Builder         CURRENT
  0.6-A Player UI Shell                        APPROVED 362/362
  0.6-B Selection + Information                APPROVED 397/397
  0.6-C Compatibility Selectors                APPROVED R1 — 445/445
  0.6-D WeaponKit Draft                         R1 APPROVED 471/471; R2 AUTO 500/500 / MANUAL PERF REJECTED; R3 ACTIVE — FOCUSED REFRESH, STATIC 272/272; RUNTIME PROJECTED 512
  0.6-E Kit Authoring/Lifecycle
  0.6-F Final Visual Adaptation/Regression
0.7    Slot-Safe Weapon Application
0.8    Multiplayer Authority / Reconciliation
```

Documentação: [0.1-A](docs/21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](docs/22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md), [0.2](docs/23_WEAPONS_0_2_WEAPON_CONFIGURATION.md), [0.3](docs/24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md), [conceito de produto/UI](docs/25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md), [0.4](docs/26_WEAPONS_0_4_WEAPON_RECIPE.md), [0.5](docs/27_WEAPONS_0_5_WEAPON_KIT.md) e [0.6](docs/28_WEAPONS_0_6_PLAYER_UI.md).

O desenvolvimento dos núcleos é independente. O gate de Items 0.13-A permanece pendente e não bloqueia Weapons.