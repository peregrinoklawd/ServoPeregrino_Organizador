# Items Header BGD — R2.1 fix do caminho de imagem (21/10/2026)

## Sintoma real / Evidência do operador

A R2 (`SP_ORG_Items_HeaderBGD_FooterR2_UICommon_0_2_0_11.VR`) abriu e exibiu a interface Items, mas **não mostrou o logo BGD** no slot do header. O usuário enviou print e o RPT às 16:53 de 21/10.

Evidências literais do RPT:
```text
13:50:08 Mission file: SP_ORG_Items_HeaderBGD_FooterR2_UICommon_0_2_0_11
13:50:08 Mission directory: C:\Users\win\Documents\Arma 3 - Other Profiles\Peregrino\missions\SP_ORG_Items_HeaderBGD_FooterR2_UICommon_0_2_0_11.VR\
13:50:21 "[SP_ORG] [UICOMMON] [INFO] UICommon inicializado. | CONTEXT=[[""build"",""0.2.0.11-header-brand-slot-r2-candidate""]]"
13:50:40 Warning Message: Picture items\\data\\bgd_logo_ca.paa not found
```

**Causa imediata confirmada**: o atributo `text` de `FutureIconSlot` estava definido estaticamente em HPP com `items\\data\\bgd_logo_ca.paa` (ou equivalente addon absoluto). Ao compilar a missão, o Arma **não resolveu** a referência relativa. O PAA **estava presente** no ZIP em `items/data/bgd_logo_ca.paa`; ambos controles tinham `idc=107`. A etapa de path impediu a visualização, portanto **não há evidência suficiente ainda** para aprovar a qualidade/compatibilidade de decodificação do PAA.

## R2.1 — alteração mínima

- `SPORG_UICommon_HeaderBrand`: continua genérico e imutável nesta correção.
- `SPORG_Items_HeaderBrand` / `FutureIconSlot` (IDC 107): `text=""`; remove inferência de caminho por macro preprocessor no HPP.
- Em `fn_refreshHeaderUI.sqf` do Items, após recuperar o Display real, `ctrlSetText` injeta o caminho resolvido:
  - Lab `CfgFunctions` em missionConfigFile: `getMissionPath "items\data\bgd_logo_ca.paa"` (caminho completo da pasta de missão).
  - Addon real: `"\ServoPeregrino_Organizador_Items\data\bgd_logo_ca.paa"`.
- Bind somente quando `ctrlText` difere do caminho desejado, evitando atualização a cada refresh.
- Diagnóstico emitido na primeira atribuição: `[SP_ORG] [ITEMS] [BRAND_HEADER] resolved=true source=MISSION|ADDON idc=107 fileExists=true|false texture=<path>`.
- Removida a macro `SPORG_ITEMS_MISSION_BRAND_TEXTURE` obsoleta da description.ext; mesmo HPP e SQF mantidos no addon e na missão.
- Futuro: manter permissão para cada consumidor do UICommon fornecer sua própria marca; **nenhuma mudança em Weapons**.
- Não alterado: UICommon 0.2.0.11, Items CAPTURAR/laranja, histórico roxo, equipamentos, DnD, catálogo, persistência.
- Missão de teste: `SP_ORG_Items_HeaderBGD_FooterR2_1_TexturePathFix.VR`. Nova candidata, **não homologada no engine** até novo RPT.

## Padrões verificados no BGD-HQ

O repositório `RicGonzalezb/bgd-hq` tem dois guias relevantes:

1. `development/guides/VISUAL_ASSET_PRODUCTION.md`, seção S13 — Export Qualification: fonte congelada → derivado alvo → decode/round-trip → comparação → alpha/fringe/mips → smoke no engine; uma conversão que termina sem erros **não** equivale a asset aprovado.
2. `development/projects/bgd-environmental-kit/docs/PAA_PRODUCTION_PIPELINE.md`, Watch R4: **ImageToPAA oficial**, decode do PAA exato, validação alpha e headers de mipmaps, prefixes corretos; `watch_r4/baseline_r3/convert_official.ps1` executa ferramentas oficiais e registra hashes/recibos.

Na R2 do Organizador utilizamos `github.com/woozymasta/paa@v0.2.0` para derivar o PAA em GitHub Actions, com formato DXT5 e presença/hash verificados. Esse pipeline **não substitui** a qualificação oficial do BGD-HQ e ainda **não** foi submetido a round-trip ImageToPAA ou engine render aprovado. Não regenerar/alterar a imagem institucional original.

## Próximo teste no Arma

1. Remova a pasta antiga R2 e extraia a missão `SP_ORG_Items_HeaderBGD_FooterR2_1_TexturePathFix.VR`. Não carregar PBOs do SP_ORG.
2. Abra Items no Eden VR; verificar marca branca no canto superior direito ao lado do botão Fechar, transparência e proporção.
3. No RPT, localizar `[BRAND_HEADER]`; esperado `source=MISSION`, `fileExists=true`, e caminho completo `...missions\SP_ORG_Items_HeaderBGD_FooterR2_1_TexturePathFix.VR\items\data\bgd_logo_ca.paa`. Se `fileExists=false`, investigar se diretório/pasta está correto. Se true e imagem ainda invisível, próximo foco é PAA decoding/shader, não path.
4. Verificar ausência de `Picture ...bgd_logo_ca.paa not found`; conferir HISTÓRICO roxo após trocar destinos, CAPTURAR e linhas laranja.
5. Enviar print e RPT. **Não declarar R2.1 homologada até esses checks.**

Observação: `getMissionPath` é suportado desde Arma 3 1.96, e `ctrlSetText` aceita caminhos de imagem em controle estático.
