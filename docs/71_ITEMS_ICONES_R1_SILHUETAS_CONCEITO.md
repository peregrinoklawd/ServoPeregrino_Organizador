# SP_ORG Items — Iconografia R1, silhuetas simplificadas

Data: 2026-10-21. Branch: `feature/items-ui-icons-r1-simple-silhouettes`.

## Origem e controle de regressão

A referência funcional imutável é `baseline/items-uicommon-r2-2-sp-homologated-20261021` — **R2.2 homologada em Arma SP** (logo BGD, footer roxo, CAPTURAR e linhas laranja preservados).

A R0 de ícones foi apresentada ao usuário e rejeitada como detalhada demais para o tamanho real de botão. A direção aprovada para **nova proposta**: **silhueta identificável primeiro, detalhes internos mínimos**. A arte R1 ainda requer revisão do usuário; não é asset final nem UI integrada.

## R1 — três silhuetas originais

Os mestres vetoriais editáveis desta candidata estão em:

- `assets/ui/icons/items/r1/uniforme.svg`: jaqueta/túnica simples em frente, mangas pronunciadas, pescoço em V.
- `assets/ui/icons/items/r1/colete.svg`: colete tático compacto, volume distinto da jaqueta e duas alças; somente um recorte horizontal opcional.
- `assets/ui/icons/items/r1/mochila.svg`: mochila tática compacta com alça superior e uma divisão principal; sem compartimentos microscópicos.

São desenhos originais feitos em shapes SVG, sem reprodução ou derivação dos assets ACE. SVG tem transparência, viewBox quadrado 64×64, preenchimento off-white `#F3F6F4`; não há moldura, fundo escuro, hover, sombra, contraste de estado ou branding embutidos nos assets. Os recortes internos (gola, separação frontal do colete e bolso da mochila) são **vazados transparentes verdadeiros**, usando `fill-rule="evenodd"` no SVG: não gravar cor do painel sobre os assets. Este requisito já foi aplicado aos três vetores R1, mas a exportação PAA ainda precisa de qualificação.

### Critérios obrigatórios para aprovação

1. Reconhecimento **sem rótulos** em 24px, depois 32px e 48px: uniforme não parece colete; colete não parece mochila.
2. Alinhamento óptico e peso visual equilibrados em três botões do mesmo tamanho.
3. Uso de **ícone + texto** na primeira integração. Não criar uma barra nova e não alterar dimensões/hitboxes homologadas.
4. Selected/hovers dependem do componente da UI, **não** de PNG diferente e não de cores gravadas no ícone.
5. Testar no SP_ORG usando os dois grupos independentes:
   - destino físico `APP_TARGET`: Uniforme/Colete/Mochila, IDCs **2111/2112/2113**;
   - recipiente mostrado `EQUIPMENT_VIEW`: mesmos ícones, IDCs **4110/4111/4112**.
6. Nenhuma mudança Weapons, Nexus, física de Items ou integração multiplayer nesta etapa de arte.

## Próximas entregas

- **R1 Visual Review** — protótipos SVG e prancha normal/selected em 24, 32, 48 px. Verificar fidelidade dos formatos e corrigir baseado no feedback.
- **R1 Assets Qualified** — exportar PNG masters e PAA de transparência verificada; seguir pipeline qualificado do BGD-HQ (ImageToPAA, round-trip, alpha/mips e Arma). Registrar SHA e paridade entre addon/mission.
- **R1 UI integration** — componente de imagem genérico no UICommon se necessário, mantendo eventos e botões existentes. Fonte Icons pertence a Items. Visualizar: nunca altera Qual o destino?. Testar SP + RPT e regressão UX R1 / R2.2.
- **Futuro** — somente depois estender família ao Weapons (Principal, Porte, Lançador e filtros); planejar arte própria sem copiar ACE.

## Estado

**CONCEITO R1 DESENHADO, AGUARDANDO AVALIAÇÃO VISUAL. NÃO INTEGRADO NO ARMA.**

No Git, as mudanças desta branch relativas aos ícones devem ser só em `assets/ui/icons/items/r1/` e docs; não alterar arquivos `addons/`, `missions/` ou versão UICommon até aprovação.

## Prancha vetorial e arquivos de revisão

A prévia R1 foi renderizada diretamente da geometria SVG em 256 px e apresentada também em botões com imagem de 48 px e texto, em 24/32/48/16 px, sobre fundo escuro e selecionado (verde). Pacote de revisão local: `SPORG_Items_Icones_R1.zip` (SVG, PNG transparentes e prancha `prancha_vetorial_R1.png`). SHA256 do ZIP: `5b2a5ea8ad7af03acd87844e6d845d2772b8267c9ed5b9c2d0fcfd97bc47712b`. **O arquivo ZIP foi produzido no chat; a fonte controlada em Git são os 3 SVGs.**

As imagens conceituais em contexto de interface podem ser ilustrativas. A referência executável das formas é `assets/ui/icons/items/r1/*.svg`; nenhum botão do jogo foi alterado.
