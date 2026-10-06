# UICommon 0.2-D R3 — True Rounded + Responsive Alignment

Data: 06/10/2026.

## Motivo

A R2 passou todos os gates funcionais, mas o arredondamento visual não existia de fato.
O asset de ShortcutButton aplicado como superfície produzia somente textura/sombra.

R3 corrige isso com geometria real e fecha os demais ajustes identificados no teste visual.

## Identidade

- semantic: `0.2.0.5`
- build: `0.2.0.5-true-rounded-responsive-d3`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_D_R3.VR`

## Arredondamento real

UICommon define:
- `SPORG_UICommon_RoundCorner` usando o círculo alpha vanilla `military\dot_CA.paa`;
- `SPORG_UICommon_RoundFill`;
- métricas separadas para painel e botão.

Cada superfície arredondada é a união de:
- 4 círculos alpha;
- 1 preenchimento horizontal;
- 1 preenchimento vertical.

Logo, o canto possui transparência geométrica real. Não existe stretch de uma única textura.

Aplicado a:
- P1/P2/P3/P4;
- envelope externo do footer;
- botões de ação principais.

Não aplicado por linha virtualizada.

Items DnD:
- hit surfaces originais continuam 2088 / 4088;
- composição visual P2 usa 20890..20895;
- composição visual P4 usa 40890..40895;
- UICommon `setCompositeControlColor` recolore as seis partes durante hover/reset.

## Botões

Botões de ação principais recebem fundo composto real + controle funcional transparente sobreposto.
Filtros/tabs continuam com o controle existente nesta R3, preservando seus estados selecionados atuais.

Assim o arredondamento não exige reescrever a pintura dos filtros.

## Tipografia Weapons

- títulos dos quatro submenus: 0.017 * safeZoneH;
- acessórios P2/P4: 0.0145 * safeZoneH;
- nome/preview da arma preservam hierarquia própria.

## Faixa inferior Weapons

- P2 SelectedHint: y=.657 / h=.148;
- P3 CatalogDetails: y=.657 / h=.148;
- P4 EquipmentStatus: y=.657 / h=.148;
- read-only marker P4 abaixo do card.

O bottom-card grammar fica alinhado.

## Footer

Histórico continua secundário, porém legível:
- label #93A7A4;
- texto #A8B7B5;
- fundo History mais escuro.

## Busca responsiva no header do painel

UICommon fornece `applyResponsiveControlLayout`.

Perfil:
- aspect >= 2.0: `WIDE`;
- abaixo: `STANDARD`.

WIDE:
- busca compacta sobe para a linha do título nos quatro painéis;
- P1/P2 metadata é compactada para abrir espaço;
- comportamento e IDCs da busca permanecem iguais.

STANDARD:
- posições R2 são preservadas;
- busca volta para a segunda linha.

O RPT registra:
`[SP_ORG] [UICOMMON] [RESPONSIVE] tag=... profile=... resolution=... aspect=...`

Nenhuma funcionalidade de busca global foi adicionada.

## Static gate

- eventos dos dialogs versus R2:
  - Items 51/51 sem delta;
  - Weapons 47/47 sem delta;
- addon/mission Items continuam em paridade;
- novo layout SQF não depende de macros HPP;
- delimitadores balanceados;
- arredondamento não cresce com número de itens.

## Gate real

Automático esperado:
- UICommon: **39/39**;
- Items + UICommon: **16/16**;
- Weapons: **594/594, 0 FAIL**.

Manual ultrawide:
1. cantos P1/P2/P3/P4 realmente transparentes/arredondados;
2. botões de ação com cantos realmente arredondados;
3. filtros/tabs continuam funcionais;
4. busca na mesma linha dos títulos;
5. nenhuma colisão de título/nome/estado/search;
6. acessórios Weapons menores e legíveis;
7. títulos uniformes;
8. cards inferiores P2/P3/P4 alinhados;
9. Histórico legível;
10. DnD Items preservado.

Manual resolução padrão/menor:
1. RPT mostra profile=STANDARD;
2. busca retorna à segunda linha;
3. nenhum clipping/overlap;
4. ações continuam acessíveis;
5. footer permanece dentro da safeZone.
