# Handoff — Próximo Chat — Servo Peregrino Weapons 0.7

Data: 2026-10-05.

## Leia primeiro

Ordem recomendada:
1. `docs/00_STATUS_ATUAL.md`
2. `docs/09_ROADMAP_E_PROXIMO_PASSO.md`
3. `docs/10_CONTINUAR_COM_IA.md`
4. `docs/43_UI_AUTOMATED_TEST_STABILITY_POLICY.md`
5. `docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`
6. `docs/45_WEAPONS_PREVIEW_3D_APM_ARMORER_CASE_STUDY.md`
7. este documento.

## Estado funcional atual

Weapons 0.6 foi liberada para continuidade.

Último runtime real:
- candidata: **0.6-F R6**;
- AUTO: **595/597**;
- 2 FAILs conhecidos = harness/version-text only;
- testes manuais aprovados;
- UICommon 12/12;
- Items+UICommon 12/12.

Não criar 0.6-F R7 apenas para corrigir texto/header/schema marker.

Política:
- não usar texto cosmético/versionamento como gate funcional;
- remover/substituir esses asserts no início da 0.7.

## Baseline executável

Artefato:
`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R6_UICommon.zip`

SHA-256:
`9ef4374ddf34c8ba5a07f220139ec4e7bd420d9039465226d84faff97ec89bdf`

A baseline mission-first avançada deve ser preservada.

## ATENÇÃO — GitHub ainda não é runtime avançado completo

Branch documental ativa:
`feature/uicommon-0.1-foundation`

O repositório contém documentação avançada, mas a missão canônica/source Weapons no GitHub ainda não deve ser assumida como byte-equivalente à R6 executável.

Antes da primeira implementação 0.7:
1. recuperar/materializar a R6;
2. comparar hashes;
3. sincronizar o source avançado para o repositório;
4. somente então criar a nova baseline 0.7.

Nunca reconstruir a R6 de memória.

## Próximo checkpoint

**Weapons 0.7 — Slot-Safe Weapon Application**

Antes de mutar loadout:
- estudar `docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`;
- implementar Plan/Snapshot/Validation primeiro;
- manter 0.7-A dry-run sem mutação;
- provar invariantes;
- só depois habilitar `setUnitLoadout`/estratégia escolhida.

Contrato:
- alterar somente o slot derivado internamente;
- preservar todo o restante do equipamento;
- post-validation é autoridade;
- falha → rollback;
- `fullMagazines=false`;
- targetSlot continua oculto ao jogador.

## Caso de estudo Preview 3D

Leia:
`docs/45_WEAPONS_PREVIEW_3D_APM_ARMORER_CASE_STUDY.md`.

Direção atual:
- NÃO implementar junto do primeiro apply 0.7;
- arquitetura híbrida nova;
- APM como referência de fidelidade/transparência/natural scale;
- Armorer como referência de framing/pivot/diagnóstico;
- controles simplificados LMB rotate / RMB pan / wheel zoom / reset.

Timing:
- padrão: após 0.7 e 0.8;
- pode existir spike paralelo após 0.7-B estável.

## Não regredir da 0.6

- auto-criação de kit ao enviar arma sem kit;
- troca dinâmica entre categorias internas;
- targetSlot oculto;
- feedback amigável;
- buscas independentes;
- busca global do Catálogo ignorando filtros enquanto ativa;
- preview 2D keep-aspect;
- highlight de campos alterados;
- filtros compactos;
- focused refresh/cache;
- no global CfgRemoteExec mode.

## Items

Items permanece congelado durante o primeiro gate 0.7.

Backlog separado:
- ITENS DO KIT;
- highlight de linhas alteradas;
- Visualizar;
- mensagem amigável de catalogação;
- diferença de transparência mission-first x PBO.

## BGD

Issue #9:
**Auditoria de conformidade com BGD Development**.

Importante, mas timing ainda em avaliação.
Pode ser movida para revisão final antes de packaging/PBO.

## Prompt curto para novo chat

```text
Continuar Servo Peregrino Organizador no checkpoint Weapons 0.7.

Antes de alterar runtime:
- leia docs/00_STATUS_ATUAL.md
- docs/09_ROADMAP_E_PROXIMO_PASSO.md
- docs/43_UI_AUTOMATED_TEST_STABILITY_POLICY.md
- docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md
- docs/45_WEAPONS_PREVIEW_3D_APM_ARMORER_CASE_STUDY.md
- docs/46_NEXT_CHAT_HANDOFF_WEAPONS_0_7.md

Weapons 0.6-F R6 é a baseline executável:
SHA-256 9ef4374ddf34c8ba5a07f220139ec4e7bd420d9039465226d84faff97ec89bdf.
AUTO 595/597, com 2 FAILs apenas de harness/version-text e manual aprovado.

Não crie R7.
Primeiro sincronize o source R6 no repositório sem reconstruir de memória.
Depois inicie 0.7-A Plan/Snapshot/Dry-Run usando o estudo APM como referência de contrato, não como código para copiar.
Preview 3D é estudo separado e não deve contaminar o primeiro gate de aplicação física.
```
