# Servo Peregrino Organizador — SP_ORG

Monorepo do **Servo Peregrino Organizador**, uma família de addons independentes para Arma 3 integrados por contratos públicos do Nexus.

## Princípio

Um repositório, vários módulos/PBOs. Nenhum módulo deve depender do estado privado de outro módulo. Integrações usam **Capabilities, Contracts, Events e Results** do Nexus.

## Implementado hoje

- `addons/ServoPeregrino_Organizador_Nexus` — Foundation 1.1.
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
- `machine/PROJECT_STATE.json`

Nunca reconstrua uma entrega por memória. Trabalhe por delta sobre a baseline registrada e preserve contratos homologados.
