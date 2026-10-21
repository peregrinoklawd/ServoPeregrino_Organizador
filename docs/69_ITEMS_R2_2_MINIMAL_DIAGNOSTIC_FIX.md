# Items R2.2 — hotfix mínimo de diagnóstico da marca no header

Data: 21/10/2026. Source of truth: `feature/items-uicommon-brand-footer-r2-20261021`.

## Sintoma e evidência R2.1

No R2.1 o usuário confirmou no Arma 3 que o logo BGD está **visível**, que os highlights laranja em Items estão corretos e que as funções observadas trabalham normalmente. No entanto, o RPT produziu:
```text
Invalid path (only relative paths supported): 'C:\...\SP_ORG_Items_HeaderBGD_FooterR2_1_TexturePathFix.VR\items\data\bgd_logo_ca.paa'
[SP_ORG] [ITEMS] [BRAND_HEADER] resolved=true source=MISSION idc=107 fileExists=false texture=C:\...\items\data\bgd_logo_ca.paa
```

**Causa:** uso indevido de `fileExists _logoPath` no `fn_refreshHeaderUI.sqf`, em que `_logoPath` era absoluto por `getMissionPath`. O jogo aceita o path em `ctrlSetText` (logo visível), mas `fileExists` exige relativo. A leitura `fileExists=false` e `resolved=true` eram enganadoras como diagnóstico.

## Delta R2.2 (único código runtime alterado)

Em `fn_refreshHeaderUI.sqf`:
- Removidos `private _textureExists = fileExists _logoPath;` e o argumento correspondente em `diag_log`.
- Alterado o log para `[BRAND_HEADER] pathAssigned=true source=MISSION|ADDON idc=107 texture=<path>`, sem afirmar existência por método incompatível.
- **Preservados**: `getMissionPath`, `ctrlSetText`, controle IDC 107, dimensões, asset PAA, UICommon, Weapons, CAPTURAR, highlight, footer.
- Addon e mission-first têm arquivo SQF byte a byte idêntico.
- CI de pacote valida que não reapareceu `fileExists _logoPath` e que a missão mantém o asset, source em paridade e `HISTÓRICO` roxo.
- Arquivo de missão `SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix.VR`, destinado a smoke SP. SHA256 do ZIP `84473fc1b9de2863d6d86b504dfe69c3d6fc20d3d922ebe5552ae0c774233cc8`.

## Gate curto no Arma

1. Abrir Items com a missão R2.2; checar logo no header e HISTÓRICO roxo mesmo após mudar Qual o destino?
2. Checar highlights e CAPTURAR sem regressão com um kit simples; Weapons não alterado.
3. Validar RPT **sem** `Invalid path (only relative paths supported)` causado pela rotina Items, e log `[BRAND_HEADER] pathAssigned=true`.
4. Não precisar repetir todos os testes de UX R1; gate R2.2 é **somente diagnóstico**, mas RPT é necessário para conclusão em engine.

**Status atualizado em 21/10/2026:** RPT R2.2 recebido, screenshot validado e fechamento **HOMOLOGADO EM SINGLE-PLAYER NO ESCOPO DO HOTFIX**. O novo `[BRAND_HEADER] pathAssigned=true` aparece sem o `Invalid path` anterior. Ver [70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md](70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md). A 0.13-A multiplayer continua NÃO homologada.

## Continuação iconográfica

Requisito visual independente e iniciado em `docs/68_ITEMS_UI_ICON_BUTTONS_CONCEPT_R0.md`. Nenhuma alteração no runtime de botões foi feita nesta entrega.
