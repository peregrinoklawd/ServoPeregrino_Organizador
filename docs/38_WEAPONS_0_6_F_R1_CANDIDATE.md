# Weapons 0.6-F R1 — Final Visual Adaptation / Regression

Data: 2026-10-04.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Display:
`0.6-F R1`

Semantic:
`0.6.5.1`

Build:
`0.6.5.1-final-visual-regression-uicommon-mission-first`

## Base real

0.6-E R2 HF1 executada no Arma:
- 557 PASS;
- 1 FAIL;
- 558 total.

O único FAIL foi:
`0.6-E R2 DESCARTAR cancels pending-new without creating kit`.

Repository e loadout físico permaneceram corretos. O defeito restante era de restauração de seleção/contexto após cancelar um NOVO.

## Decisão

Não criar R2 HF2.

O ajuste é incorporado diretamente à 0.6-F, junto do freeze visual/regression final da linha 0.6.

## Hotfix incorporado

Novo campo de estado:
`previousKitIdBeforeNew`

Fluxo:
`kit A -> NOVO -> pending draft -> DESCARTAR -> kit A`

Regras:
- NOVO guarda o kit selecionado antes de limpar `selectedKitId`;
- DESCARTAR antes da primeira arma não cria WeaponKit;
- se o kit anterior ainda existir, ele é restaurado;
- primeira arma aceita pelo pending-new limpa o contexto anterior;
- seleção manual de outro kit também limpa o contexto;
- repository e loadout permanecem imutáveis nesse cancelamento.

## Freeze visual 0.6-F

A candidata não faz redesign amplo.

Ela congela:
- quatro painéis;
- MEUS KITS DE ARMAS;
- ARMAS DO KIT;
- CATÁLOGO DE ARMAS;
- CONTEÚDO DO EQUIPAMENTO;
- nome inline + SALVO/ALTERADO/NOVO;
- NOVO/DUPLICAR/EXCLUIR/PUBLICAR;
- SALVAR/SALVAR COMO NOVO/DESCARTAR/LIMPAR;
- Visualizar: PRINC./PORTE/SEC.;
- catálogo virtualizado de 32 linhas;
- focused refresh/cache;
- footer CONTEXTO/RESULTADO/HISTÓRICO;
- aplicação física reservada para 0.7.

## Compatibilidade

Para evitar quebra de consumidores internos:
- `kitUI` mantém o marcador da R2;
- `uiLayout` mantém `FOUR_PANEL_ITEMS_CONVERGENCE`;
- novos marcadores: `uiCheckpoint=0.6-F`, `uiRevision=R1`, `uiVisualFreeze=FINAL_0_6_F_CANDIDATE`.

## Testes

- static Weapons: 86/86;
- full lab static: 24/24;
- runner ativo: `fn_runDelivery0_6_FTests.sqf`;
- 537 assertion sites;
- runner histórico R2 HF1 preservado byte a byte.

O total real de runtime é definido somente pelo RPT.

## Preservação

- Items: byte-idêntico à HF1;
- Nexus: byte-idêntico;
- UICommon: byte-idêntico;
- aplicação física: DEFERRED_0_7;
- MP/JIP/reconciliação: DEFERRED_0_8.

## Gate humano

1. sem PBOs SP_ORG;
2. UICommon 12/12;
3. Items+UICommon 12/12;
4. kit A -> NOVO -> DESCARTAR -> kit A;
5. NOVO -> arma -> EQUIPAR NO RASCUNHO;
6. dropdown Mira x Catálogo ÓTICAS;
7. troca de arma-base;
8. save lifecycle;
9. PUBLICAR reservado;
10. EQUIPAMENTO -> não mutante;
11. wheel/slider fluido;
12. AUTO 0.6-F com 0 FAIL;
13. RPT + prints.

Se aprovado, 0.6 fica homologada/congelada e 0.7 é liberada.

## Items

A convergência visual de Items continua separada e não entra nesta candidata.

## BGD Development

Issue #9 permanece importante, com timing em avaliação. Não é gate desta candidata.
