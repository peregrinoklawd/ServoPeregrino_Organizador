# SP_ORG Items — três imagens selecionadas em 21/10/2026

## Seleção canônica do usuário

O usuário escolheu **três imagens renderizadas específicas**, não os protótipos SVG anteriores:

1. **UNIFORME** — `ícone_minimalista_de_camisa_com_gola_v.png` — camisa de gola V aprovada na última revisão, sem modificações.
2. **COLETE** — **Colete 1**, `ícone_de_colete_tático_branco.png` — formato liso com decote arredondado e recortes laterais. Não usar Colete 2.
3. **MOCHILA** — `silhueta_branca_de_mochila.png` — **última imagem corrigida**, corpo central totalmente branco/preenchido, alças superiores e laterais visíveis. Não usar as versões anteriores com buraco central ou o SVG R1 antigo.

Todas as três são imagens PNG RGBA 1254×1254. Os SHA-256 dos arquivos exatos e os tamanhos em bytes estão em [SELECTION_20261021.json](SELECTION_20261021.json).

## PNGs originais agora versionados e verificados

O usuário enviou os três PNGs e o `MANIFEST_ORIGINAIS.json` para a raiz desta branch em 21/10/2026. Os hashes de blob Git dos uploads correspondem **exatamente** aos hashes dos masters escolhidos, calculados a partir dos bytes do ZIP preservado em conversa. Em commit `92b864b8913d5490ece6df04a53518b39683f394`, os quatro arquivos foram movidos em uma única operação Git, sem recompressão nem alteração de bytes.

| Símbolo | Master PNG canônico | Git blob SHA-1 |
|---|---|---|
| Uniforme | [uniforme_aprovado_original.png](uniforme_aprovado_original.png) | `2178eaeb7596573993cb50d15231d10881de5ff9` |
| Colete 1 | [colete_1_aprovado_original.png](colete_1_aprovado_original.png) | `a78ecf87ef6c3a90e982d5be96e3f240178eaaf1` |
| Mochila corrigida | [mochila_corrigida_aprovada_original.png](mochila_corrigida_aprovada_original.png) | `7e846f1bf4de8ad7c5fe66b4312a26b74d21c6fb` |

O [MANIFEST_ORIGINAIS.json](MANIFEST_ORIGINAIS.json) contém os SHA-256 originais e foi igualmente movido sem alteração de bytes. O [SELECTION_20261021.json](SELECTION_20261021.json) atualiza o estado canônico para `COMMITTED_TO_GIT`.

O pacote de backup `SPORG_Items_Icones_Selecionados_ORIGINAIS_20261021.zip` continua válido (SHA-256: `9d4473a2647cd7c9d689e1bcb5476ffeb981f54ed631d6580d6cf1bb035df2b4`), mas já não é o único local de preservação.

**Estado:** três masters originais PNG guardados no GitHub e hashes conferidos. **Ainda não há PAA gerado, nem integração dos ícones à UI.** Os antigos SVGs R0/R1 são apenas histórico conceitual, não representam os desenhos aprovados.

## Invariantes para trabalhos seguintes

- Preservar imagens aprovadas; nenhuma regeneração automática sem decisão.
- PNG é master visual aprovado. Texturas `.paa` e versões 256px/512px são **derivados separados**, não fontes canônicas.
- Preferência por ícone **+ texto**, mantendo `APP_TARGET` e `EQUIPMENT_VIEW` independentes.
- Não modificar os controles de Items nem UICommon nesta etapa de registro de arte.
- Weapons continua separado.
- A baseline do runtime homologado permanece `baseline/items-uicommon-r2-2-sp-homologated-20261021`.
