# Weapons — Caso de Estudo de Preview 3D: APM x Armorer

Data: 2026-10-05.

## Objetivo

Definir uma direção técnica para o futuro Preview 3D de Weapons a partir de dois históricos já experimentados no projeto:

- APM WEAPON;
- Servo Peregrino Armorer.

Não implementar preview nesta rodada.
Este documento é arquitetura/referência para uma futura entrega específica.

## Fontes consultadas

APM:
- `APM-DATA-001 v2.11.4`, seções 358–363 e 376–381;
- `CONTINUIDADE_NOVO_CHAT_APM_11_9_13`;
- `CONTINUIDADE_NOVO_CHAT_APM_11_9_26`.

Armorer:
- RPTs históricos de `SP_ORG_Armorer 1.17.x`;
- diagnósticos de camera/pivot/render profile;
- testes críticos de preview 3D.

Avaliação do usuário nesta rodada:
- APM: qualidade da arma muito boa e fundo/transparência agradáveis;
- APM: posição inicial percebida como distante e ligeiramente lateralizada;
- APM: controles poderiam ser mais fluidos;
- Armorer: perspectiva/posicionamento bons;
- Armorer: qualidade visual percebida inferior;
- Armorer: controles também podem melhorar.

Quando esta avaliação divergir de métricas técnicas, ambos os fatos devem ser preservados.

---

# APM — o que existe

## Arquitetura PiP composta

O APM usa duas cenas locais PiP:
- SELECTED;
- EQUIPMENT.

Cada cena possui:
- câmera;
- `GroundWeaponHolder`;
- iluminação local.

Os objetos são locais:
- não são transmitidos pela rede;
- são destruídos ao fechar a interface.

Arma + componentes são montados com:
`addWeaponWithAttachmentsCargo`.

## Centro geométrico

O APM usa `boundingBoxReal` para obter:
- mínimo;
- máximo;
- centro;
- dimensão dominante;
- eixo fino.

A recentralização combina:
- `setVectorDirAndUp`;
- origem de cena;
- `modelToWorldVisual`;
- correção para manter centro geométrico fixo.

## Escala natural

No preview composto:
- holder permanece em `objectScale = 1.0`;
- não usar `setObjectScale` para enquadrar;
- tamanho aparente vem de câmera/FOV/distância.

Essa regra converge com a decisão recente da Weapons 0.6:
**não esticar o conteúdo para preencher o painel**.

## Keep aspect / viewport

A 11.9.13 corrigiu distorção de preview usando:
- render target quadrado 512x512;
- viewport interno quadrado;
- mesma dimensão física em pixels;
- Picture/Surface/Object com geometria equivalente;
- keep-aspect;
- margem sobrando em vez de distorcer.

Depois, a linha 11.9.20/11.9.26 também preservou um PiP 1024x512 como fallback de alta qualidade percebida.

Conclusão:
**proporção do render target e proporção do viewport precisam ser tratadas juntas.**

## Controles APM

11.9.13:
- LMB horizontal → yaw do holder;
- LMB vertical → pitch/orbit da câmera;
- RMB → pan;
- wheel → zoom;
- R ou double click → reset.

O usuário avaliou que o resultado visual era bom, mas os controles ainda poderiam ser mais fluidos.

## Pontos fracos conhecidos APM

- posição inicial percebida pelo usuário como distante;
- leve lateralização inicial;
- WORLD/MUN posterior ainda tinha rotação não aprovada;
- duas cenas PiP têm custo próprio;
- separar eixo horizontal entre holder e vertical entre câmera aumenta complexidade mental do gesto.

---

# Armorer — o que existe

## Arquitetura observada

Os RPTs provam:
- `GroundWeaponHolder`;
- câmera dedicada;
- pivot explícito;
- `boundingBox`/centro;
- framing/viewport central amplo;
- preview sob demanda;
- controles diretos de holder;
- pan e zoom;
- perfis de render.

Parâmetros observados em uma baseline:
- FOV ~0.42;
- distância inicial ~1.18;
- minDistance 0.018;
- maxDistance 1.85;
- yaw sensitivity ~185;
- pan sensitivity ~1.68;
- roll sensitivity ~165;
- vista inicial lateral `SIDE_RIGHT_UPRIGHT`.

O usuário avaliou perspectiva/posicionamento como bons.

## Qualidade

Os RPTs mostram perfis:
- 512;
- 1024;
- 2048 DEV.

Também mostram um detalhe importante:
em execuções com `rtt=1024` ou `rtt=2048`, o diagnóstico do engine ainda registrava `pipQuality=512 / VeryLow`.

Isso sugere que:
- aumentar apenas o render target NÃO garante aumento de fidelidade percebida;
- configuração efetiva de PiP/engine pode limitar o resultado.

É uma inferência técnica a ser validada em spike real.

## Pontos fortes Armorer

- framing/perspectiva percebidos como melhores;
- pivot e câmera bastante instrumentados;
- preview on-demand;
- diagnóstico extenso;
- perfis de qualidade;
- centro/viewport grandes;
- arquitetura preparada para calibração.

## Pontos fracos Armorer

Segundo avaliação do usuário:
- arma percebida em baixa qualidade;
- controles ainda pouco naturais.

Pelos RPTs:
- o sistema de controle acumulou muitos modos/versionamentos;
- isso é poderoso para diagnóstico, mas complexo demais como UX final.

---

# Síntese recomendada para Weapons

Não copiar APM.
Não copiar Armorer.

Criar um **Preview Weapons novo**, usando:

## KEEP do APM

- cena local;
- `GroundWeaponHolder`;
- montagem de arma + attachments reais;
- background/transparência visual integrada;
- natural scale 1.0;
- bounding-box center;
- keep-aspect;
- não esticar;
- destruir cena ao fechar;
- preview Selected e Equipment isoláveis.

## KEEP do Armorer

- framing/perspectiva como referência;
- pivot explícito;
- auto-frame;
- diagnóstico de camera/pivot;
- perfis de render;
- preview on-demand;
- infraestrutura de calibração somente em DEV.

## DROP

- controles APM dividindo horizontal em holder e vertical em camera;
- complexidade de múltiplos modos de gesto do Armorer na UX final;
- offsets iniciais laterais fixos sem necessidade;
- setObjectScale para framing;
- dependência de sliders técnicos na UI do jogador;
- tentar resolver baixa qualidade só aumentando RTT.

---

# Proposta de Preview Weapons

## Modelo visual

Dois previews possíveis:
- ARMAS DO KIT;
- CONTEÚDO DO EQUIPAMENTO.

Cada preview:
- arma em escala natural;
- centralizada;
- sem distorção;
- fundo transparente/integrado ao painel;
- frame calculado por bounding box;
- margem visual pequena e consistente.

## Enquadramento inicial

Requisito novo:

```text
offset horizontal inicial = 0
offset vertical inicial = 0
arma centralizada
auto-fit pelo bounding box
margem de segurança
sem lateralização fixa
```

Evitar valores mágicos por classe.
Permitir fallback por família somente se modelos muito anômalos exigirem.

## Qualidade

Spike deve testar lado a lado:
- 512;
- 1024;
- 2048.

Mas também registrar:
- `getVideoOptions`/PiP quality quando acessível;
- resolução efetiva;
- FPS;
- custo por uma e duas cenas.

Critério:
**qualidade percebida + custo real**, não apenas número do render target.

Baseline candidata:
- 1024 como primeira hipótese;
- 2048 somente se o engine realmente entregar benefício perceptível e custo aceitável.

## Controle recomendado — simples

UX proposta:

- LMB drag → gira a arma em yaw + pitch, em screen-space, ao redor de um único pivot;
- RMB drag → pan;
- wheel → zoom;
- double click ou R → reset.

Não expor roll no controle principal.
Se roll for necessário, deixar como ação avançada futura.

### Fluidez

Novo requisito:
- deltas de mouse acumulados;
- atualização somente enquanto gesto estiver ativo;
- interpolação/damping leve opcional;
- sem polling permanente desnecessário;
- velocidade independente de FPS na medida do possível;
- clamp suave de zoom/pan;
- reset imediato e previsível.

A sensação desejada é de manipular o objeto, não de comandar separadamente câmera e holder.

## Pivot

Usar um pivot estável derivado do modelo/bounding box.

O objeto não deve "andar" ao rotacionar.

Testar:
- supressor longo;
- bipé;
- optics grandes;
- pistola;
- SMG;
- rifle;
- launcher.

---

# Transparência e integração

Requisito do usuário:
- preservar a aparência transparente/limpa apreciada no APM.

Isso não significa tornar o render target literalmente alpha em todas as arquiteturas.
O requisito player-facing é:
- não introduzir um bloco opaco visualmente pesado;
- integrar o preview ao painel;
- manter contraste suficiente com a arma.

A técnica exata deve ser escolhida no spike.

---

# Fase recomendada

Preview 3D NÃO deve ser misturado com o primeiro apply da 0.7.

Razão:
- aplicação física mexe em invariantes de loadout;
- preview mexe em câmera/render/input;
- juntar os dois dificulta diagnóstico.

Sequência padrão recomendada:

1. fechar 0.7 aplicação física;
2. fechar 0.8 autoridade MP;
3. Preview 3D Spike separado.

Alternativa:
- spike visual paralelo após 0.7-B estar estável, sem integrar ao runtime final.

Não atribuir número definitivo ao preview ainda.

---

# Gates do Preview Spike

### Visual
- arma nítida;
- proporção preservada;
- centralização;
- posição inicial aprovada;
- fundo/integracão aprovada;
- attachments visíveis.

### Controles
- LMB intuitivo;
- RMB pan;
- wheel zoom;
- reset;
- sem inversão inesperada;
- sem drift do pivot.

### Performance
- 1 cena;
- 2 cenas;
- 512/1024/2048;
- monitor ultrawide;
- modset real.

### Lifecycle
- criar ao abrir/ativar;
- destruir ao fechar;
- sem objeto/camera vazando;
- sem network object;
- troca rápida de kit;
- troca rápida Selected/Equipment.

---

# Decisão

A direção preferida para Weapons é um **híbrido novo**:

**APM fidelity + transparent integration + natural scale**
+
**Armorer framing/pivot/diagnostics**
+
**controles novos e mais simples**.

Nenhum dos dois sistemas históricos deve ser portado literalmente.
