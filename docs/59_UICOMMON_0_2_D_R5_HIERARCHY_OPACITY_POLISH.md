# UICommon 0.2-D R5 — Hierarchy / Wording / Opacity Polish

Data: 06/10/2026.

## Base

R5 parte exclusivamente da R4 homologada.

Nenhum handler funcional foi alterado:
- Items: 51 controles com eventos antes/depois, 0 deltas;
- Weapons: 47 controles com eventos antes/depois, 0 deltas.

## Mudanças

### 1. Cabeçalho do rascunho

Items e Weapons:
- caixa de nome aproximada do título do painel;
- status `SEM KIT / NOVO / ALTERADO / SALVO` aproximado da caixa de nome;
- ajuste aplicado tanto no perfil STANDARD quanto no perfil WIDE.

No WIDE, a sequência passa a usar gaps de aproximadamente `0.001 * safeZoneW` entre título/nome/status.

### 2. Destino em Items

Texto:
- antes: `Onde aplicar o kit?`
- agora: `Qual o destino?`

O tooltip também passa a falar em escolher o equipamento como destino, sem sugerir que a seleção por si só já executa uma aplicação.

### 3. Histórico

Paleta:
- label: `#B9A3E8`;
- conteúdo: `#D1C2F0`.

O roxo claro foi escolhido para separar visualmente Histórico do verde de Contexto e do azul de Resultado sem disputar atenção com eles.

### 4. Transparência visual de Items

`MEUS KITS DE ITENS` (P1) e `CATÁLOGO DE ITENS` (P3) possuíam camadas internas de lista/tabela que faziam o resultado final parecer mais escuro que P2/P4, embora o alpha do painel-base fosse igual.

Para compensar a composição visual, apenas o surface-base de P1/P3 foi reduzido:
- alpha anterior: `0.44`;
- alpha R5: `0.32`.

P2/P4, linhas, botões e lógica de DnD permanecem intactos.

## Identidade

- UICommon semantic: `0.2.0.7`
- build: `0.2.0.7-hierarchy-opacity-polish-d5`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_D_R5.VR`

## Gate real esperado

- UICommon Foundation: 36/36;
- Items + UICommon: 16/16;
- Weapons R6: 594/594, 0 FAIL;
- sem novos erros SQF;
- manual:
  - nome/status visualmente mais próximos do título;
  - `Qual o destino?` correto;
  - Histórico em roxo claro;
  - P1/P3 de Items visualmente equilibrados com P2/P4;
  - DnD e demais interações preservados.
