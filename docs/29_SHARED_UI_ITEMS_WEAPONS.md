# UI compartilhada — Items + Weapons

## Objetivo

Registrar decisões visuais que devem permanecer sincronizadas entre **Items** e **Weapons**.

Este documento existe para impedir que uma melhoria seja aplicada em apenas um módulo e que a família visual do SP_ORG se desalinhe.

## Baseline compartilhada

Ambas as interfaces devem preservar, quando aplicável:

- `RobotoCondensed`;
- dimensionamento por `safeZoneW/safeZoneH`;
- correção de aspecto com `pixelW/pixelH`;
- busca com lupa;
- botão dedicado para limpar busca;
- tooltips;
- ações dentro do painel proprietário;
- mesma escala geral de botões e tipografia;
- transparência equivalente;
- feedback textual;
- rodapé semântico:
  - Context;
  - Message;
  - History.

## Decisão — rodapé em três faixas

### Estado atual

Items e Weapons possuem uma única área de fundo no rodapé, contendo três linhas:

```text
Context
Message
History
```

A semântica está correta e deve ser preservada.

### Melhoria futura aprovada conceitualmente

Transformar visualmente essa área em três faixas distinguíveis:

```text
┌────────────────────────────────────────────┐
│ CONTEXT                                    │
├────────────────────────────────────────────┤
│ MESSAGE                                    │
├────────────────────────────────────────────┤
│ HISTORY                                    │
└────────────────────────────────────────────┘
```

A separação pode usar background/divisores sutis, sem alterar a responsabilidade de cada linha.

### Regra obrigatória

A mudança deve ser feita **em Items e Weapons na mesma rodada de padronização**.

Não aplicar apenas em Weapons.

## Momento de implementação

**DEFERRED.**

Não mexer agora.

Weapons seguirá primeiro:
- 0.6-B seleção/informações;
- 0.6-C compatibilidade;
- 0.6-D rascunho;
- 0.6-E lifecycle/authoring dos kits.

Depois que essas funcionalidades estiverem prontas e testadas, a 0.6-F fará a adaptação visual final.

Nessa fase:
1. rever o espaço vertical de KIT SELECIONADO;
2. adaptar layout aos controles que realmente existirem;
3. implementar a separação visual do rodapé;
4. aplicar o mesmo padrão de rodapé em Items;
5. validar 1080p e monitor ultrawide;
6. executar regressão visual/funcional dos dois módulos.

## Decisões que NÃO devem ser revisitadas agora

Até a fase de polish final:
- não aumentar botões do Weapons;
- não aumentar tipografia;
- não alterar opacidade;
- não limitar a largura ultrawide;
- não redesenhar o shell de três painéis;
- não separar o rodapé apenas em um módulo.

## Referências

- Items UI atual: `addons/ServoPeregrino_Organizador_Items/ui/items_dialog.hpp`
- Weapons UI: `docs/28_WEAPONS_0_6_PLAYER_UI.md`

