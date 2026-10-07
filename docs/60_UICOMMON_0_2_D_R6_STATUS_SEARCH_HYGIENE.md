# UICommon 0.2-D R6 — Status Alignment + Search Test Hygiene

Data: 07/10/2026.

## Base

R6 é review fix da R5. R4 continua como fallback homologado.

## 1. Status do rascunho

Em Items e Weapons, o controle de status já estava posicionado imediatamente após a caixa de nome, mas usava alinhamento à direita (`style=1`).

Isso fazia o texto visível `NOVO / ALTERADO / SALVO / SEM KIT` aparecer junto da busca no perfil WIDE.

R6 altera apenas:
- Items `DraftDirty`: `style=1 -> style=0`;
- Weapons `SelectedDirty`: `style=1 -> style=0`.

A geometria da R5 é preservada. O texto agora nasce no lado esquerdo do controle, visualmente colado à caixa de nome.

## 2. "mira" / "laser" nas buscas de Weapons

A origem era o próprio runner 0.6-F R6:
- P2 recebia `mira`;
- P4 recebia `laser`;
- o Catálogo era limpo;
- P2/P4 não eram limpos antes de uma nova abertura usada por outro teste.

R6:
- troca os termos humanos por tokens sintéticos de teste;
- após validar isolamento, executa `P2_SEARCH ""` e `P4_SEARCH ""`;
- mantém o número de asserts em 594, portanto o gate esperado não muda.

## Identidade

- semantic: `0.2.0.8`
- build: `0.2.0.8-status-search-hygiene-d6`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_D_R6.VR`

## Gate

Esperado:
- UICommon 36/36;
- Items + UICommon 16/16;
- Weapons 594/594;
- depois do AUTO TEST, abrir Weapons e confirmar P2/P4 vazios;
- status do rascunho deve aparecer imediatamente depois da caixa de nome em Items e Weapons.

## Depois da aprovação

1. congelar UICommon 0.2-D;
2. UICommon 0.2-E — instrumentação/performance;
3. UICommon 0.2-F — equivalência + cleanup;
4. gate de equivalência Items + Weapons;
5. Weapons 0.7-A — Plan / Snapshot / Dry-Run;
6. depois, 0.7-B Slot-Safe Apply e 0.7-C Post-Validation/Rollback.
