# UICommon 0.2-D R4 — Safe Responsive Polish

Data: 06/10/2026.

## Decisão

R4 nasce da base visual/funcional da R2.

Removido completamente:
- RoundCorner / RoundFill / RoundButton;
- composição de 4 círculos + 2 fills;
- recoloração composta de DnD;
- IDCs criados exclusivamente para a composição;
- tentativa de arredondamento real em painéis e botões.

A R4 não tentará mais arredondar cantos.

## Preservado da R3

Somente deltas de baixo risco:
- busca no mesmo header do submenu em perfil WIDE;
- fallback STANDARD com busca na segunda linha;
- títulos Weapons padronizados;
- acessórios P2/P4 menores;
- cards inferiores Weapons alinhados;
- Histórico com maior contraste.

## Correção do erro de runtime

`weapons/functions/ui/fn_applyResponsiveVisualLayout.sqf` agora inclui:

`#include "..\\..\\script_version.hpp"`

Assim `SP_ORG_WEAPONS_UI_STATE` volta a ser expandido para a chave string correta antes de `missionNamespace getVariable`.

## Não regressão

Comparação de eventos contra a R2:
- Items: 51 controles funcionais, 0 deltas;
- Weapons: 47 controles funcionais, 0 deltas.

Nenhuma referência RoundCorner/RoundFill/RoundButton permanece nos dialogs ou shared_controls.

## Identidade

- semantic: `0.2.0.6`
- build: `0.2.0.6-safe-responsive-polish-d4`
- missão: `SP_ORG_UI_Lab_UICommon_0_2_D_R4.VR`

## Gate real esperado

- UICommon Foundation: 36/36;
- Items + UICommon: 16/16;
- Weapons R6: 594/594, 0 FAIL;
- nenhum erro de `fn_applyResponsiveVisualLayout.sqf`;
- ultrawide: `profile=WIDE`;
- 16:9/16:10: `profile=STANDARD`;
- DnD Items preservado;
- visual dos botões deve voltar ao padrão aprovado na R2.


## Resultado real — HOMOLOGADA

Teste real em 06/10/2026:
- UICommon Foundation: **36/36**;
- Items + UICommon: **16/16**;
- Weapons 0.6-F R6: **594/594**, 0 FAIL;
- perfil responsivo em 5120x1440: **WIDE**;
- nenhum erro de `fn_applyResponsiveVisualLayout.sqf`;
- testes manuais aprovados.

A R4 passa a ser o fallback visual/funcional homologado para a próxima rodada.
