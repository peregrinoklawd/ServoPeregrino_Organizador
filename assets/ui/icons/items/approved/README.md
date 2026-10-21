# SP_ORG Items — três imagens selecionadas em 21/10/2026

## Seleção canônica do usuário

O usuário escolheu **três imagens renderizadas específicas**, não os protótipos SVG anteriores:

1. **UNIFORME** — `ícone_minimalista_de_camisa_com_gola_v.png` — camisa de gola V aprovada na última revisão, sem modificações.
2. **COLETE** — **Colete 1**, `ícone_de_colete_tático_branco.png` — formato liso com decote arredondado e recortes laterais. Não usar Colete 2.
3. **MOCHILA** — `silhueta_branca_de_mochila.png` — **última imagem corrigida**, corpo central totalmente branco/preenchido, alças superiores e laterais visíveis. Não usar as versões anteriores com buraco central ou o SVG R1 antigo.

Todas as três são imagens PNG RGBA 1254×1254. Os SHA-256 dos arquivos exatos e os tamanhos em bytes estão em [SELECTION_20261021.json](SELECTION_20261021.json).

## Backup dos masters e estado de importação

O pacote `SPORG_Items_Icones_Selecionados_ORIGINAIS_20261021.zip` foi gerado durante a conversa e contém **os três PNGs originais, com bytes inalterados**, além do manifesto de hashes. SHA-256 do ZIP: `9d4473a2647cd7c9d689e1bcb5476ffeb981f54ed631d6580d6cf1bb035df2b4`.

**ATENÇÃO:** os PNGs originais **ainda precisam ser importados como arquivos binários para esta branch**. O conector GitHub disponível neste momento não oferece upload diretamente a partir dos arquivos da conversa; este manifesto NÃO é substituto para os masters, e o ZIP da conversa **ainda não está versionado no repositório Git**. Não declarar o salvamento no Git concluído até comparar a SHA-256 dos arquivos efetivamente commitados.

Caminhos planejados no Git (ainda não existem):
- `assets/ui/icons/items/approved/uniforme_aprovado_original.png`
- `assets/ui/icons/items/approved/colete_1_aprovado_original.png`
- `assets/ui/icons/items/approved/mochila_corrigida_aprovada_original.png`

## Invariantes para trabalhos seguintes

- Preservar imagens aprovadas; nenhuma regeneração automática sem decisão.
- PNG é master visual aprovado. Texturas `.paa` e versões 256px/512px são **derivados separados**, não fontes canônicas.
- Preferência por ícone **+ texto**, mantendo `APP_TARGET` e `EQUIPMENT_VIEW` independentes.
- Não modificar os controles de Items nem UICommon nesta etapa de registro de arte.
- Weapons continua separado.
- A baseline do runtime homologado permanece `baseline/items-uicommon-r2-2-sp-homologated-20261021`.
