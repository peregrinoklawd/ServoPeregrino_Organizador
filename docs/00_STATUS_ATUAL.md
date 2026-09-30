# Estado atual do projeto

Data do snapshot: **29/09/2026**.

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
- **Weapons** = identidade, serial, configuração, compatibilidade, receitas e troca dinâmica;
- **WeaponCondition** = uso, desgaste, água/submersão, condição de peças, confiabilidade e manutenção lógica;
- **Armorer** = bancada, Preview, montagem, inspeção e workflow/UI de manutenção.

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
- Weapons: source integrado permanece 0.1-A; mission-first 0.1-B foi homologada em SP (AUTO TEST 128/128 + live Take/Put 3/3) e WeaponConfiguration 0.2 foi homologada em SP (175/175). Identidade física intrínseca, MP/JIP e PBO/addon integrado continuam não validados.
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

**Source integrado na branch:** 0.1-A. **Validação funcional mission-first atual:** 0.2.

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

**Gates ainda abertos:** identidade física intrínseca, multiplayer/JIP/reconnect, integração real ao addon/PBO e Packaging Gate. Próximo marco mission-first: **0.3 — Catalog & Compatibility**.

Ver [0.1-A](21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md) e [0.2](23_WEAPONS_0_2_WEAPON_CONFIGURATION.md).
