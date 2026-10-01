# Weapons 0.6-E R1 — Source Recovery Record

Data: 2026-10-01.

## Recuperação

A missão-fonte original da candidata **Weapons 0.6-E R1 — Authoring / Lifecycle** foi recuperada a partir do ZIP fornecido novamente pelo usuário:

`SP_ORG_Weapons_0_6_E_R1_AuthoringLifecycle_TestPackage(1).zip`

SHA-256 autoritativo:

`e504188631231ae837d8105481a48989f9726e0348db1dc45afdf5cd2ee3a855`

O mesmo pacote também foi localizado na Library histórica com o nome sem o sufixo `(1)`.

## Conteúdo confirmado

A missão recuperada contém a implementação mission-first completa da 0.6-E R1:
- WeaponConfiguration / identity;
- Catalog + engine compatibility;
- WeaponRecipe;
- WeaponKit session-local;
- four-panel player UI;
- draft authoring/lifecycle;
- continuous catalog + focused refresh herdado da 0.6-D R3;
- equipment read-only;
- laboratório de lifecycle;
- testes cumulativos até `fn_runDelivery0_6_ETests.sqf`.

Evidência histórica de runtime: **536/536 PASS**.

## Relação com 0.6-E R2

R1 é a baseline funcional anterior às mudanças de UX pedidas pelo usuário.

Não confundir recuperação da R1 com cancelamento da R2. Os requisitos de R2 continuam congelados em:
- `docs/32_WEAPONS_0_6_E_R2_UI_FREEZE.md`.

A R1 mantém deliberadamente o fluxo antigo:
- RENOMEAR em P1;
- NOVO dependente da seleção de arma no Catálogo;
- layout anterior do P2.

Esses pontos são justamente parte do delta R2.

## Missão conjunta

Foi gerada uma missão FULL SELF-CONTAINED combinando:
- Nexus;
- UICommon 0.1;
- Items 0.13-A;
- Weapons 0.6-E R1 recuperada.

Nenhum PBO SP_ORG é necessário no laboratório.

Auditoria estática do pacote combinado:
- **35/35 PASS**;
- **101/101 arquivos Weapons idênticos byte a byte** à fonte recuperada.

O pacote combinado é um **baseline de comparação**, não a implementação final de R2.

## Próximo gate

1. executar a missão conjunta no Arma sem PBOs SP_ORG;
2. UICommon foundation: 8/8;
3. smoke de Items;
4. abrir Weapons E R1;
5. Weapons AUTO: expectativa histórica 536/536;
6. enviar RPT;
7. depois iniciar Items-equivalence/UICommon e Weapons R2 sem perder a baseline.
