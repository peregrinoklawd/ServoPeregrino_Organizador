# Estado atual do projeto

Data do snapshot: **30/09/2026**.

## Source of Truth

Repositório oficial: `peregrinoklawd/ServoPeregrino_Organizador`.

O projeto agora é tratado como **monorepo multi-PBO**, com ownership funcional único por módulo.

## Runtime atual implementado

| Componente | Estado |
|---|---|
| Nexus | display 1.1 / semantic 0.1.1 / build `0.1.1-dev-nexus-contract-event-foundation` |
| Items | display 0.13-A / semantic 0.13.0.1 / build `0.13.0.1-a-server-authority-foundation` |
| Baseline funcional congelada | **0.12 FINAL — Integration Freeze**, homologada manualmente |
| Lógica atual Items | **0.13-A — Server Authority Foundation** |
| Addon atual | **Packaging R2**, candidato pendente de validação runtime |
| Missão MP | **8 Slots R3**; lobby/slots já funcionaram |

## Arquitetura global decidida

Módulos atuais/planejados:
- Nexus;
- Hub;
- Items;
- Weapons;
- WeaponCondition;
- Armorer;
- Equipment;
- Sets;
- Policy;
- ServerIntegration;
- Settings;
- Adapters.

Regra oficial: **uma funcionalidade de domínio possui um único módulo proprietário**.

Divisão de armas:
- **Weapons** = identidade, serial, configuração, compatibilidade, receitas, WeaponKit, UI própria de organização/configuração e aplicação slot-safe;
- **WeaponCondition** = uso, desgaste, água/submersão, condição de peças, confiabilidade e manutenção lógica;
- **Armorer** = bancada especializada, Preview 3D, montagem física/visual, inspeção de peças e workflow/UI de manutenção.

## O que aconteceu na migração para addon Items

A missão multiplayer R2 corrigiu os slots e foi carregada corretamente. A R3 acrescentou entrada direta pela ação `addAction` e fallback HOME. No teste R3, a missão rodou, mas `openInterface` permaneceu `nil` porque o Arma registrou `Unable to open` para os PBOs antigos do Nexus e Items. O problema foi isolado como **empacotamento do addon**, não como lógica da missão, slots ou UI.

O **Packaging R2** reempacota os mesmos fontes sem alterar SQF funcional. Ele ainda precisa ser executado no Arma para fechar o gate.

## Próximo teste obrigatório

1. carregar somente `@SP_ORG_Items_0_13_A_R2`;
2. hospedar a missão `SP_ORG_Items_0_13_A_Multiplayer_Lab_8Slots_R3.VR`;
3. confirmar no RPT que NÃO existe `Unable to open ...servoperegrino_organizador_*.pbo`;
4. confirmar que `ServoPeregrino_Organizador_Items_fnc_openInterface` existe;
5. abrir pelo HOME ou ação de scroll;
6. realizar smoke multiplayer: cliente publica, servidor comita, demais clientes enxergam a mesma revisão.

## O que ainda NÃO pode ser afirmado

- Packaging R2 ainda não foi homologado dentro do Arma.
- 0.13-A ainda não foi homologada em multiplayer real com dois ou mais clientes.
- JIP/persistência pública/ACL/rate limit/recovery ainda pertencem ao roadmap 0.13-B+.
- Hub, WeaponCondition, Equipment, Sets, Policy e ServerIntegration ainda são módulos planejados.
- Weapons: source integrado permanece 0.1-A; mission-first 0.1-B (128/128 + 3/3), 0.2 (175/175) e 0.3 R2 Catalog/Compatibility (213/213) estão homologadas em SP; 0.4 R5 WeaponRecipe está homologada em SP com 251/251; 0.5 WeaponKit está homologada com **301/301** e 50/50 gates específicos da camada de kit. Weapons terá UI própria player-facing; identidade física intrínseca, MP/JIP e PBO/addon integrado continuam não validados.
- Armorer possui base histórica madura, mas o runtime autoritativo ainda não foi importado ao monorepo.

## Dívida automática aceita

Os gates históricos **516 e 523** podem falhar no runner de 0.12-C.6 apesar do DnD real ter sido aprovado manualmente. Essa dívida foi aceita no freeze 0.12 FINAL. Não alterar runtime funcional apenas para “deixar verde” esses gates sem regressão humana reproduzível.

## Continuidade

Ler obrigatoriamente:
- `machine/PROJECT_STATE.json`;
- `machine/MODULE_MATRIX.json`;
- `machine/FEATURE_OWNERSHIP.json`;
- `docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md`;
- `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`;
- `docs/19_VISAO_FUNCIONAL_COMPARTILHAVEL.md`;
- `docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md`.

## Frente independente — Weapons

**Source integrado na branch:** 0.1-A. **Validação funcional mission-first homologada:** 0.5. **Candidata atual:** 0.6-A — Player UI Shell.

### 0.1-B — lifecycle/identity evidence

- AUTO TEST final: **128/128 PASS**.
- Gate manual real Take/Put: **3/3 PASS**.
- `TAKE 1→0` e `PUT 0→1`: `CORRELATED/1`.
- `TAKE 2→1` com duas MX idênticas: `AMBIGUOUS/2`, `instanceId=""`.
- `physicalIdentityProven=false`: preservado como invariante.
- Decisão: event-delta é evidência de continuidade lógica quando única; não é serial físico nativo.

### 0.2 — WeaponConfiguration

- AUTO TEST final R3: **175/175 PASS**.
- Schema candidato: `weaponClass`, `muzzle`, `pointer`, `optic`, `bipod`.
- Magazine/ammo continuam em `loadedState` separado e fora do fingerprint.
- Diff e apply com verificação de round-trip no engine.
- PRIMARY preservou 17 tiros durante aplicação/remoção de attachments.
- HANDGUN preservou 11 tiros.
- SECONDARY/NLAW validado via classe realmente observada pelo engine.
- No-op retorna sem mutar o inventário.
- Attachment inválido e weaponClass incompatível falham antes de mutação.

### 0.3 — Catalog & Compatibility

- Candidata final R2: **213/213 PASS**.
- Catálogo-base validado no modset real: **2770** armas (2406 PRIMARY, 279 HANDGUN, 85 SECONDARY).
- Catálogo com presets: **3380**.
- 610 presets excluídos do catálogo-base.
- Compatibilidade de optic/muzzle/pointer/bipod/magazines derivada do engine.
- Conteúdo modded/provenance confirmado.
- Cache de sessão confirmado.
- Reverse lookup global por `compatibleWeapons` foi deliberadamente retirado do gate por produzir varredura ampla e warnings de configs de terceiros; qualquer índice reverso futuro será derivado do catálogo filtrado SP_ORG.

### 0.4 — WeaponRecipe

- R3 runtime: **245/245 PASS / 0 FAIL**.
- Recipe permanece descritivo: nenhuma mutação de inventário.
- Schema candidato: `configuration` + `magazineClass` opcional.
- `targetSlot`, nome de kit, identidade/serial e ammoCount continuam fora de Recipe.
- PRIMARY, HANDGUN e SECONDARY validados.
- Compatibilidade SECONDARY passou a resolver genericamente variantes runtime ligadas por `baseWeapon`.
- No ambiente ACE/NLAW, foram observadas `launch_NLAW_F` e `ACE_launch_NLAW_ready_F` como variantes relacionadas, sem hardcode no resolver.
- R3 revelou apenas dívida de higiene: lista de magazines continha `nlaw_f` e `NLAW_F`, semanticamente a mesma classe.
- R4 higiene: PASS; runtime geral **245/246** por uma única regressão antiga no SECONDARY no-op apply.
- R5 final: **251/251 PASS / 0 FAIL**.
- PRIMARY/HANDGUN permanecem estritos.
- SECONDARY permite equivalência apenas entre classes `type=4` da mesma família `baseWeapon`.
- O RPT provou a transição real `launch_NLAW_F -> ACE_launch_NLAW_ready_F` entre capture/apply sem mutação indevida.
- Higiene R4 preservada: `NLAW_F` aparece uma única vez.
- WeaponRecipe/schema permanecem inalterados.
- **MISSION-FIRST FUNCTIONAL GATE: HOMOLOGADO.**

### 0.5 — WeaponKit

- static validation: **131/131 PASS**;
- runtime final: **301/301 PASS / 0 FAIL**;
- **50/50 gates específicos de WeaponKit aprovados**;
- schema: `kitId`, `name`, `targetSlot`, `recipe`;
- repository mode: `SESSION_LOCAL_CANDIDATE`;
- PRIMARY/HANDGUN/SECONDARY aprovados;
- create/get/list/rename/duplicate/update Recipe/delete aprovados;
- nomes únicos case-insensitively;
- defensive copies aprovadas;
- content fingerprint exclui kitId/nome;
- Recipe/targetSlot incompatível é rejeitado;
- nenhuma operação 0.5 altera o loadout;
- UI permanece em 0.6;
- aplicação/equipar permanece em 0.7;
- autoridade multiplayer permanece em 0.8;
- **MISSION-FIRST FUNCTIONAL GATE: HOMOLOGADO.**

### 0.6-A — Player UI Shell

- baseline: 0.5 homologada em **301/301**;
- static validation da candidata: **169/169 PASS**;
- ordem de painéis: **MEUS KITS | KIT SELECIONADO | CATÁLOGO DE ARMAS**;
- nomenclatura UI: **Principal -> PRIMARY**, **Porte -> HANDGUN**, **Secundária -> SECONDARY/lançador**;
- busca, limpar, tooltips, transparência, RobotoCondensed, safeZone e rodapé seguem o padrão Items;
- filtros em Meus Kits: Principal / Porte / Secundária / Públicos;
- Públicos visível porém desabilitado até existir biblioteca pública real de WeaponKits;
- botões Novo/Renomear/Duplicar/Excluir ficam em Meus Kits;
- Descartar/Salvar/Salvar como novo ficam em Kit Selecionado;
- acessórios compatíveis não possuem painel próprio; serão dropdowns contextuais dentro de Kit Selecionado;
- rodapé global: **Context / Message / History**, como Items;
- 0.6-A não edita Recipe/WeaponKit e não altera loadout;
- aplicação/equipar continua exclusivamente no gate 0.7;
- runtime/avaliação visual ainda pendentes.

### Decisão conceitual — Weapons é player-facing

Weapons possui UI própria, semelhante em conceito à parte de armas do APM histórico:

- escolher arma;
- consultar informações;
- escolher somente acessórios compatíveis;
- montar/salvar/editar WeaponKit;
- equipar apenas o slot alvo;
- preservar todo o restante do loadout.

**WeaponKit = uma arma configurada para um único slot**, não um loadout completo.

Armorer continua separado: bancada, Preview 3D avançado, peças, inspeção e manutenção.

**Gate mission-first ativo:** **0.6-A — Player UI Shell**.

**Gates ainda abertos:** identidade física intrínseca, multiplayer/JIP/reconnect, integração real ao addon/PBO e Packaging Gate. Próximo teste: **0.6-A — AUTO TEST + avaliação visual da UI**.

Ver [0.1-A](21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md), [0.2](23_WEAPONS_0_2_WEAPON_CONFIGURATION.md), [0.3](24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md) e [conceito UI](25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md) e [0.4](26_WEAPONS_0_4_WEAPON_RECIPE.md) e [0.5](27_WEAPONS_0_5_WEAPON_KIT.md).
