# Items + UICommon Equivalence R1

## Objetivo

Primeiro gate em que Items depende e consome UICommon de forma real, sem redesenhar a interface.

## Infraestrutura migrada

- escaping genérico de structured text passa a ser propriedade de UICommon;
- `ServoPeregrino_Organizador_Items_fnc_escapeStructuredText` permanece como wrapper de compatibilidade;
- clamp da janela virtual do Catálogo passa a usar `UICommon_fnc_clampVirtualOffset`;
- Items valida UICommon no lifecycle e publica a dependência no runtime;
- UICommon passa de 0.1.0 para 0.1.1 experimental.

## Não mudou nesta entrega

- layout dos quatro painéis;
- textos player-facing existentes;
- `Mostrar:` ainda não vira `Visualizar:`;
- mensagem do Items ainda não é alterada para `Vasculhando inventário e catalogando itens...`;
- Draft/Repository/Storage/Whole-Kit/EXACT/DnD/Equipment/Public Library;
- Weapons E R1 e seus 536 gates;
- Weapons R2 continua próxima após a equivalência de Items.

## Testes novos

- UICommon foundation: esperado **12/12**;
- Items + UICommon Equivalence R1: esperado **12/12**;
- Weapons AUTO: continua esperado **536/536**;
- regressão manual de Items segue `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md`.

## Texto de catalogação já aprovado para a próxima convergência visual

- Items: `Vasculhando inventário e catalogando itens...`
- Weapons: `Vasculhando inventário e catalogando armas...`

O log técnico continua livre para mencionar CfgWeapons/CfgMagazines.
