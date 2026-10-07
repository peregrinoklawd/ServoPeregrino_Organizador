# UICommon 0.2-E E1 — Performance Instrumentation

Data: 07/10/2026.

## Base

UICommon 0.2-D R6 está homologada e congelada.

A E1 não altera UI visual, domínio, filtros, seleção, aplicação, DnD ou roteamento de refresh.

## Primitivas compartilhadas

### elapsedMs

Entrada:
- tick inicial;
- tick final opcional.

Saída:
- milissegundos arredondados;
- delta negativo é limitado a 0;
- start inválido retorna -1.

A função não possui estado.

### appendPerfHistory

Entrada:
- histórico;
- sample cuja estrutura continua pertencendo ao consumidor;
- limite máximo.

Saída:
- nova lista limitada;
- não modifica a lista original;
- não interpreta conteúdo de Items ou Weapons.

## Migração

Items usa as primitivas em:
- FULL;
- CATALOG_FOCUSED;
- DRAFT_FOCUSED;
- EQUIPMENT_FOCUSED;
- KIT_SWITCH_FOCUSED;
- PHYSICAL_FOCUSED.

Weapons usa `elapsedMs` em:
- FULL;
- CATALOG_FOCUSED;
- DRAFT_FOCUSED;
- EQUIPMENT_FOCUSED.

## Ownership preservado

UICommon mede e limita histórico.

Items/Weapons continuam donos de:
- decisão FULL/focused;
- contadores;
- reasons;
- projeção/cache;
- captura de equipamento;
- formato e conteúdo do sample;
- formato dos logs `[UI_PERF]`.

## Identidade

- semantic: `0.2.0.9`
- build: `0.2.0.9-performance-instrumentation-e1`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_E_E1.VR`

## Static gate

- helpers addon/mission idênticos;
- tests addon/mission idênticos;
- Items addon/mission preservados nos seis refreshers migrados;
- Foundation passa de 36 para **43 checks**;
- Items Equivalence permanece **16 checks**;
- runner Weapons permanece **594 checks**;
- nenhuma regra de domínio foi movida para UICommon.

## Runtime gate

Esperado:
- 43/43;
- 16/16;
- 594/594;
- Catálogo wheel/slider: focused, `fullRefresh=false`;
- Equipment navigation: focused;
- Draft mutation: focused;
- sem novos stutters atribuíveis à instrumentação.

Após aprovação:
**0.2-F — Equivalence + Cleanup**.

## Runtime homologado

RPT real recebido em 07/10/2026.

Resultado:
- UICommon Foundation: **43/43 PASS**;
- Items + UICommon Equivalence: **16/16 PASS**;
- Weapons 0.6-F R6: **594/594 PASS**, 0 FAIL;
- Catalog scroll de Items permaneceu focused, com `fullRefresh=false`, sem equipment recapture e sem rebuild de projeção durante wheel;
- Catalog scroll de Weapons permaneceu focused, com `fullRefresh=false`, sem rebuild de projeção/filtro durante wheel;
- Equipment e Draft permaneceram em refresh focal;
- nenhuma regressão funcional ou de refresh policy foi atribuída à instrumentação.

Observação:
- o primeiro build CONFIG_ALL de Items permaneceu um custo separado de catálogo e não é classificado como regressão da E1;
- erros ambientais em `CBA_fnc_addPerFrameHandler` ocorreram fora do stack SP_ORG e não bloquearam os gates.

Conclusão:
**UICommon 0.2-E E1 — HOMOLOGADA / CONGELADA.**

Baseline congelada:
- display: `0.2`;
- semantic: `0.2.0.9`;
- build: `0.2.0.9-performance-instrumentation-e1`.

Próximo gate:
**0.2-F — Equivalence + Cleanup**.
