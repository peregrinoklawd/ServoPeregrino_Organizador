# UICommon 0.2-D R1 — Shared Visual Foundation / HPP

Data: 06/10/2026.

## Objetivo

Mover somente a fundação visual comprovadamente duplicada de Items e Weapons para UICommon em compile-time/HPP, mantendo os diálogos funcionais inalterados.

## Arquivo compartilhado

`UICommon/ui/shared_controls.hpp`

Contém exclusivamente:
- métricas genéricas de header/search/clear;
- classes visuais base;
- variantes genéricas de picture normal e keep-aspect;
- button/edit/list/structured/footer/slider.

## Consumer aliases

Items e Weapons mantêm seus nomes locais `SPORG_Items_*` e `SPORG_Weapons_*`, agora como aliases/heranças leves de `SPORG_UICommon_*`.

Isso evita um rename massivo dos controles existentes e reduz o risco de regressão.

## Deliberadamente fora de R1

- Items CT_CONTROLS_TABLE;
- Weapons Combo;
- geometrias de linha;
- ordem/semântica das ações;
- IDCs;
- event handlers;
- regras de seleção;
- domínio;
- keep-aspect de Items;
- redesign visual.

## Provas estáticas

- shared HPP addon == mission;
- Items HPP addon == mission;
- todo o corpo dos dois dialogs permaneceu byte-idêntico à 0.2-C;
- Weapons Picture continua keep-aspect;
- Weapons List continua rowHeight 0.033;
- nenhum domínio vazou para UICommon.

## Runtime gate

A candidata só pode ser homologada com RPT real:
- UICommon 31/31;
- Items/UICommon 16/16;
- Weapons 594/594, 0 FAIL;
- smoke visual manual dos dois módulos.

A 0.2-C continua sendo fallback congelado até esse gate.
