# Items — botões por imagem R0 (projeto visual; não implementar no runtime ainda)

Data: 21/10/2026. Estado: **DIREÇÃO CONCEITUAL / AGUARDANDO APROVAÇÃO DO USUÁRIO**.

## Origem

O usuário enviou referências dos ícones usados no ACE Arsenal, solicitando uma família **original** para SP_ORG: primeiro Uniforme, Colete e Mochila em Items; mais adiante Principal, Porte, Lançador e filtros de acessórios em Weapons.

**Diretriz:** inspirar-se apenas na rapidez de leitura e uso por silhueta; não replicar, traçar, reinterpretar pixel a pixel ou usar como base derivada qualquer iconografia proprietária do ACE. Criar gramática SP_ORG coerente, extensível e própria.

## Contrato UI / ownership

- **UICommon:** suporte opcional a controle com imagem, gestão genérica de background hover/pressed/selected/disabled, dimensionamento e tooltip/foco. Não sabe o que é Uniforme/Colete/Mochila e não contém assets institucionais ou de equipamentos.
- **Items:** fornece as texturas originais `Uniforme`, `Colete`, `Mochila`, semântica U/C/M, Tooltips e seleção por destino e visualização.
- **Weapons:** futuramente produz ícones originais próprios de seu domínio; reaproveita gramática, não código Items.
- **Nexus:** não deve ser alterado por escolha de ícones.

### Dois conjuntos de controles, uma família visual

Os ícones U/C/M serão reusados em **dois grupos independentes**; não misturar semânticas:

| Grupo | IDC | Evento | Significado |
|---|---|---|---|
| P2 — Qual o destino? | 2111/2112/2113 | `APP_TARGET` | destino físico de Whole-Kit APLICAR/REMOVER/SUBSTITUIR |
| P4 — Visualizar: | 4110/4111/4112 | `EQUIPMENT_VIEW` | recipiente físico exibido; ações diretas do painel/seleção |
  
A seleção de P4 não muda P2 e vice-versa. Manter posições, dimensões, fluxos, atalhos, tooltip e semântica de seleção homologados inicialmente. Não mudar a paleta global de UICommon para integrar as texturas.

## Linguagem visual recomendada (R0)

Nome interno provisório: **SP/ORG — Tactical Glyphs**, tom técnico/industrial e consistente com o header BGD.

- Silhuetas geométricas originais, sem textura realista, acabamento monocromático off-white sobre transparência. O contraste vem do botão escuro e dos estados já existentes, não de gravar fundo preto na textura.
- Uma moldura *não* pertence aos pixels da imagem: deixar que o controle UICommon desenhe borda/fundo/realce. Evitar desenho dentro de um botão ACE-like.
- Três símbolos semanticamente inequívocos: Uniforme = jaqueta de campo manga longa com gola e pala; Colete = colete modular com duas alças superiores + placas centrais retangulares; Mochila = mochila tática compacta com tampa superior, bolso frontal e laterais. Evitar usar silhueta de soldado inteiro ou apenas um retângulo genérico.
- Peso visual e escala equilibrados, borda interna e área ocupada comparáveis: glifo deve ocupar ~70–78% de uma área quadrada independente; strokes ≥ 2 px na amostra 64×64, sem microdetalhes invisíveis em 24 px.
- Transparência real, sem sombras/neon/contornos de cores fixas. Painéis continuam verdes/escuros quando selecionados. White/off-white na textura normal; hover/selected/disabled podem ser aplicados por `colorText`/estado do botão, não embutidos em múltiplas imagens.
- A arte deverá ser legível em **24, 32 e 48 px** e em tela 1920×1080 e 5120×1440 (padrão do último RPT).
- Famílias futuras Weapons devem compartilhar espessura, alinhamento e cantos angulares; ícones especializados não devem ser derivados de assets ACE.

## Pipeline e critérios de aceite

1. **Prancha conceitual R0**: Uniforme, Colete, Mochila, lado a lado e cada qual em botão neutro + botão selected, para avaliar contraste/semelhança; imagem é somente referência visual, não arquivo final.
2. Aprovar silhueta e granularidade; corrigir antes de derivar assets finais.
3. **Arte mestre**: SVG editável (desenhado/validado manualmente) e PNGs 256×256 transparentes individualizados; fonte de arte no Git; proibição de falso vetor por imagem raster renomeada.
4. **Derivados Arma**: PAA alpha com ImageToPAA oficial ou pipeline comprovado; verificar decodificação/round trip, alfa, mipmaps e render real conforme `bgd-hq/development/projects/bgd-environmental-kit/docs/PAA_PRODUCTION_PIPELINE.md`.
5. **Implementação** (entrega separada da R2.2): adicionar controles picture nos seis botões/overlays sem capturar cliques ou mudar hit testing, conservar dimensões e estados, paridade addons e mission.
6. Teste SP/RPT: os seis controles respondem corretamente, P2/P4 independentes, seleção/hover/disabled legíveis, DnD e ALT/hover não regressam, nenhum warning Picture not found, nenhuma regressão de foco/clique em 1080p e ultrawide.
7. **Weapons** apenas futuro, sem modificar nesta candidata.

## Fora do escopo R0

- Não substituir os botões existentes na missão ou addon antes da aprovação das imagens.
- Não criar automaticamente novas categorias de objetos no catálogo.
- Não iniciar módulo Weapons ou tocar em sua branch.
- Não confundir escolha de assets com homologação de UICommon ou biblioteca pública multiplayer.
