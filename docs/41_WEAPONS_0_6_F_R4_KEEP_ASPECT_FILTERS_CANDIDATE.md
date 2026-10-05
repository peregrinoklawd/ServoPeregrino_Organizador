# Weapons 0.6-F R4 — Keep Aspect / Uniform Catalog Filters

Data: 2026-10-05.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Display:
`0.6-F R4`

Semantic:
`0.6.5.4`

Build:
`0.6.5.4-keep-aspect-uniform-catalog-filters-regression-fix-uicommon-mission-first`

## Base real

A 0.6-F R3 foi executada no Arma e terminou:
- **579 PASS**
- **3 FAIL**
- **582 total**

Os três FAILs foram:
1. header ainda exibia `0.6-F R2`;
2. teste legado ainda esperava P2 sincronizar a busca com o Catálogo;
3. teste legado ainda esperava P4 sincronizar a busca com o Catálogo.

Os dois últimos são test drift: o contrato vigente desde a R3 é justamente buscas independentes por painel.

## Escopo fechado R4

### 1. Preview 2D sem distorção

`SPORG_Weapons_Picture` usa:
- ST_PICTURE;
- ST_KEEP_ASPECT_RATIO.

Aplicado em:
- ARMAS DO KIT;
- CONTEÚDO DO EQUIPAMENTO.

Regra:
- preservar proporção;
- centralizar dentro da área reservada;
- nunca esticar para preencher.

A mesma regra fica registrada como requisito para futuro Preview 3D: aumentar/reduzir e centralizar sem deformar o conteúdo.

### 2. Filtros do Catálogo padronizados

Linha Tipo:
- TODOS
- PRINC.
- PORTE
- SEC.

Todos com largura/altura/font-size uniformes.

Linha Acessório:
- TODOS
- ARMA
- ÓTICA
- APONT.
- BIPÉ
- CARREG.
- EMPUNH.

Todos com:
- mesma largura;
- mesma altura;
- mesma fonte;
- mesma linha;
- tooltip com nome/semântica completos.

Botões com imagens estilo Arsenal ficam deliberadamente para uma evolução futura.

### 3. Área do Catálogo

Como filtros de acessórios agora ocupam uma única linha uniforme:
- lista sobe;
- lista ganha altura adicional;
- scrollbar acompanha a nova altura.

Nenhuma mudança de domínio ou compatibilidade.

### 4. Runner

Runner ativo:
`fn_runDelivery0_6_FR4Tests.sqf`

Correções:
- header espera R4;
- antigos asserts de busca sincronizada foram substituídos por asserts de isolamento;
- testes para largura uniforme dos filtros;
- testes para gramática compacta dos filtros;
- runtime markers de keep-aspect/uniform-filter.

Assertion sites:
**560**

## Validação local

- **86/86 PASS**.

Preservação:
- Items: byte-idêntico à R3;
- Nexus: byte-idêntico;
- UICommon: byte-idêntico;
- runner histórico R3: byte-idêntico.

## Runtime markers

- `uiRevision=R4`
- `uiVisualFreeze=FINAL_0_6_F_R4_KEEP_ASPECT_UNIFORM_FILTERS`
- `uiDraftPreviewLayout=EQUIPMENT_MIRRORED_KEEP_ASPECT_PREVIEW_READY`
- `uiPreviewScaleMode=KEEP_ASPECT_CENTERED_2D`
- `uiCatalogFilterGrammar=UNIFORM_TEXT_BUTTONS_R4`

## Gate manual

1. preview de arma em ARMAS DO KIT não pode esticar;
2. preview de arma em CONTEÚDO DO EQUIPAMENTO também preserva proporção;
3. preview deve permanecer centralizado;
4. filtros Tipo visualmente uniformes;
5. filtros Acessório visualmente uniformes e em uma única linha;
6. tooltips deixam claro o significado dos rótulos compactos;
7. busca global/isolada continua funcionando como R3;
8. changed-row highlight continua funcionando;
9. wheel/slider sem regressão;
10. AUTO 0.6-F R4 com 0 FAIL;
11. RPT + prints.

## Não entra

- botões com imagens;
- Preview 3D real;
- aplicação física;
- MP/JIP;
- convergência visual Items.

## Artefato

`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R4_UICommon.zip`

SHA-256:
`bb0360d11bf048f915c1d2a4045d5a37db0ba61050c1ff9a5ff9039dc2c19996`
