# UICommon 0.2-D R2 — Shared Visual Polish Candidate

Data: 06/10/2026.

## Identidade

- semantic: `0.2.0.4`
- build: `0.2.0.4-shared-visual-polish-d2`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_D_R2.VR`

## Deltas visuais

- superfícies estáticas P1/P2/P3/P4 com textura vanilla suavizada;
- botões player-facing com gramática vanilla ShortcutButton;
- linhas CT_CONTROLS_TABLE permanecem CT_BUTTON flat;
- buscas dos quatro painéis com lupa + X dentro do campo;
- P4 Weapons com busca alinhada ao topo dos demais painéis;
- MEUS KITS de Items e Weapons usam o mesmo KitList visual;
- Items: `ITENS DO KIT`;
- Items: `Visualizar:`;
- footer Items/Weapons em três faixas com largura total compartilhada;
- Histórico com contraste reduzido;
- barras de carga/capacidade Items usam superfícies suavizadas;
- fallback de build Items: `Vasculhando inventário e catalogando itens...`.

## Segurança funcional

Nenhum handler/action dos dialogs mudou em relação à R1:
- Items: 52 controles funcionais, zero delta de evento;
- Weapons: 47 controles funcionais, zero delta de evento.

Items DnD preserva os hit surfaces originais 2088/4088 e usa camadas visuais separadas 2089/4089.

## Performance

Não existe arredondamento por linha virtualizada.
O custo adicional é fixo: painéis, searches, footer e poucas barras/controles estáticos.

## Gate real Arma

Automático:
- UICommon **35/35**;
- Items + UICommon **16/16**;
- Weapons **594/594, 0 FAIL**.

Manual:
1. cantos dos painéis sem distorção visual;
2. botões legíveis, hover/seleção funcional;
3. quatro buscas digitam, filtram e limpam corretamente;
4. lupa e X realmente aparecem dentro do campo;
5. P4 Weapons: busca no topo; Visualizar abaixo;
6. MEUS KITS mudou somente visualmente;
7. footer Items/Weapons alinhado e com mesma largura;
8. barras de carga/capacidade Items acompanham valor normalmente;
9. DnD Items mantém hover, ghost e drop;
10. nenhuma regressão perceptível em ultrawide.

Se a textura de painel ficar visualmente deformada por stretch, a R2 deve recuar o arredondamento de grandes painéis e mantê-lo somente em controles menores. Não mascarar esse defeito.
