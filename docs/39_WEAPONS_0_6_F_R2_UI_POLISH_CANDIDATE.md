# Weapons 0.6-F R2 — UI Polish / Changed-State Highlight

Data: 2026-10-04.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Display:
`0.6-F R2`

Semantic:
`0.6.5.2`

Build:
`0.6.5.2-final-visual-regression-changed-rows-preview-ready-uicommon-mission-first`

## Base

Parte exatamente da 0.6-F R1.

Preservação:
- Nexus: byte-idêntico;
- UICommon: byte-idêntico;
- Items: byte-idêntico;
- runner histórico 0.6-F R1: byte-idêntico.

## Escopo fechado

### 1. ARMAS DO KIT — destaque semântico por linha

O estado global `ALTERADO` continua existindo.

Além dele, cada linha de equipamento atual é comparada contra `draft.baseRecipe`:
- Arma-base;
- Mira;
- Boca;
- Apontador;
- Bipé/Empunhadura;
- Carregador.

Quando o valor atual divergir do Recipe salvo/base:
- a linha recebe fundo âmbar translúcido;
- o RGB é a mesma família semântica do texto `ALTERADO`;
- o alpha é reduzido para preservar leitura.

Quando o jogador desfizer a mudança e voltar ao valor do `baseRecipe`, o destaque desaparece automaticamente.

Não é "linha tocada"; é diferença real de estado.

Nova função:
`ServoPeregrino_Organizador_Weapons_fnc_getDraftChangedFields`.

### 2. ARMAS DO KIT — convergência visual com CONTEÚDO DO EQUIPAMENTO

P2 passa a espelhar a hierarquia vertical de P4:
- preview;
- nome;
- classe;
- contexto/tipo;
- componentes;
- retângulo de informações.

Preview/nome/classe usam as mesmas faixas Y de P4.

Objetivo:
- comparação visual mais natural entre Draft e equipamento;
- abrir mais área útil;
- preparar a geometria para futuro preview 3D sem implementar 3D nesta entrega.

### 3. Bloco de informações

O retângulo inferior passa a informar:
- `ALTERAÇÕES: <campos>` quando houver diferenças;
- `SEM ALTERAÇÕES DE EQUIPAMENTO` quando o Recipe atual estiver igual à base;
- orientação sobre SALVAR/DESCARTAR sem introduzir aplicação física.

## Não entra

- Preview 3D real;
- aplicação física;
- comparação física automática;
- multiplayer/JIP;
- convergência visual de Items;
- auditoria BGD.

Aplicação física continua **0.7**.
MP/JIP/reconciliação continua **0.8**.

## Gates automáticos

Validação local Weapons:
- **69/69 PASS**.

Validação full-lab:
- **30/30 PASS**.

Runner ativo:
`fn_runDelivery0_6_FR2Tests.sqf`

Assertion sites:
- **545**.

O total real do AUTO é definido somente pelo próximo RPT.

Novas regressões:
- helper detecta mudança de Mira;
- helper remove mudança quando o valor retorna à base;
- P2/P4 preview alinhados verticalmente;
- P2/P4 nome alinhado;
- P2/P4 classe alinhada;
- seis backgrounds semânticos presentes;
- runtime expõe `BASE_RECIPE_FIELD_DIFF_AMBER`;
- runtime expõe `EQUIPMENT_MIRRORED_PREVIEW_READY`.

## Gate manual

1. abrir Weapons;
2. carregar kit SALVO — nenhuma linha âmbar;
3. alterar Mira — somente Mira âmbar;
4. voltar à Mira original — destaque desaparece;
5. alterar arma-base — arma e qualquer componente realmente divergente devem refletir o diff;
6. SALVAR — todas as marcações devem desaparecer;
7. validar preview/nome/classe de P2 e P4 visualmente alinhados;
8. confirmar maior área útil para preview em ARMAS DO KIT;
9. wheel/slider continuam focused-refresh;
10. AUTO 0.6-F R2 com 0 FAIL;
11. enviar RPT + prints.

## Artefato

`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R2_UICommon.zip`

SHA-256:
`29fb6cb7274dd32e3dacd518b977083d947957ac0e8c3d2f8b2077f964b0f821`
