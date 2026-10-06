# Weapons 0.6-F R6 — Source Sync Record

Data: 05/10/2026.

## Objetivo

Eliminar a dívida em que a documentação e o artefato executável estavam à frente do source mission-first canônico no GitHub.

A sincronização foi feita a partir da **baseline R6 executável preservada**, sem reconstrução por memória e sem portar manualmente deltas de versões anteriores.

## Baseline de origem

Artefato:
`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R6_UICommon.zip`

SHA-256:
`9ef4374ddf34c8ba5a07f220139ec4e7bd420d9039465226d84faff97ec89bdf`

Identidade Weapons dentro da baseline:
- display: `0.6-F R6`;
- semantic: `0.6.5.6`;
- build: `0.6.5.6-compact-filter-spacing-test-contract-hotfix-uicommon-mission-first`.

## Destino canônico sincronizado

`missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`

Resultado:
- **432 arquivos**;
- Git subtree SHA no repositório:
  `91dae966c4239b3984d21a24916d8e12f811fd2e`;
- transporte temporário removido após materialização;
- workflow temporário de materialização removido após sucesso.

O arquivo `SHA256_MANIFEST.json` da própria missão declara:
- 431 arquivos além do manifest;
- total físico da pasta: 432.

## Commit de materialização

Commit criado pelo GitHub Actions após verificação do pacote:
`ddd9a53afcbffe827a5a663c96f1531623db655f`

Mensagem:
`sync(weapons): materialize exact 0.6-F R6 mission baseline`

## Runtime conhecido da R6

Último gate no Arma:
- 595 PASS;
- 2 FAIL;
- 597 total;
- testes manuais aprovados.

Os 2 FAILs são classificados como:
`HARNESS_ONLY / VERSION_TEXT / NON_FUNCTIONAL / NON_BLOCKING`.

Não criar R7 apenas para corrigi-los.
A política está em:
`docs/43_UI_AUTOMATED_TEST_STABILITY_POLICY.md`.

## Observação sobre README histórico

O pacote R6 preserva alguns arquivos históricos gerados nas candidatas anteriores.
Se algum texto interno ainda disser R5 em um README/nota histórica, ele NÃO deve ser corrigido dentro desta sincronização, porque o objetivo foi manter a baseline R6 exatamente como testada.

A autoridade de identidade é:
- `weapons/script_version.hpp`;
- `DELIVERY_METADATA_WEAPONS_0_6_F_R6.json`;
- `SHA256_MANIFEST.json`;
- RPT da R6.

## Limite desta sincronização

Foi sincronizado o **source mission-first canônico**.

Não foi promovido o addon:
`addons/ServoPeregrino_Organizador_Weapons`

Esse addon permanece na linha antiga integrada e sua migração/PBO continua sendo um gate separado.

Portanto:

```text
Mission-first R6 source no GitHub     = SINCRONIZADO
Addon/PBO Weapons equivalente à R6    = AINDA NÃO
```

## Próximo checkpoint

Não iniciar imediatamente a mutação física 0.7.

O próximo trabalho recomendado é:
**UICommon 0.2-A — Shared Infrastructure Inventory**

Ver:
`docs/48_UICOMMON_0_2_SHARED_INFRASTRUCTURE_PLAN.md`.
