# Weapons 0.6-F R6 — Compact Filter Spacing + Test Contract Hotfix

## Escopo fechado

A R6 preserva integralmente o comportamento manual homologado da R5 e altera somente:

- compactação do espaço visual entre `Tipo:` e seus filtros em **MEUS KITS DE ARMAS**;
- compactação do espaço visual entre `Tipo:` e seus filtros em **CATÁLOGO DE ARMAS**;
- compactação do espaço visual entre `Acessório:` e seus filtros em **CATÁLOGO DE ARMAS**;
- correção de dois assertions herdados que ainda esperavam contratos anteriores à R5.

## Falhas do RPT R5

1. `pending draft requires WEAPON first`: o comportamento está correto; o teste ainda esperava o código antigo `WEAPONS_UI_NEW_DRAFT_REQUIRES_WEAPON`. A R5 passou a usar o código interno `WEAPONS_UI_DRAFT_BASE_WEAPON_REQUIRED` com mensagem amigável ao jogador.
2. `SALVAR COMO NOVO leaves source saved Recipe unchanged`: o comportamento está correto; o teste ainda esperava `arifle_MXC_F`, embora a própria R5 tenha salvo anteriormente uma P07 no source durante o teste de troca entre slots. A R6 compara o snapshot salvo antes/depois estruturalmente, sem hardcode de classe.

## Fora de escopo

- botões por imagem;
- aplicação física;
- redesenho de painéis;
- mudanças em Items/UICommon;
- correções em mods externos que chamem CBA PFH incorretamente.

## Gate

A candidata R6 deve retornar `0 FAIL` no AUTO TEST e repetir a validação manual da R5.
