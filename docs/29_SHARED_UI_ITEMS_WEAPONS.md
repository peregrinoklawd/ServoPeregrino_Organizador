# UI compartilhada — Items + Weapons

## Objetivo

Registrar decisões visuais e padrões de interação que devem permanecer coerentes entre **Items** e **Weapons**.

Regra de produto:

> Items e Weapons não precisam ser interfaces idênticas, mas precisam parecer partes do mesmo produto.

Sempre que uma solução nascer em um módulo e demonstrar ser melhor, ela deve entrar no **UI_CONVERGENCE_BACKLOG** para avaliação no outro módulo. Não depender de memória informal.

## Classificação

Cada decisão de UI usa uma destas classificações:

- **SHARED** — deve convergir entre Items e Weapons quando aplicável;
- **DOMAIN-SPECIFIC** — linguagem visual compartilhada, mas conteúdo/comportamento pertencem ao domínio;
- **CANDIDATE-SHARED** — nasceu em um módulo e deve ser avaliada no outro após validação.

## Baseline visual compartilhada

A referência atual de transparência e grade é o **SP_ORG Items Multiplayer Lab R3**.

Quando aplicável, Items e Weapons devem compartilhar:
- `RobotoCondensed`;
- dimensionamento `safeZoneW/safeZoneH`;
- controles quadrados corrigidos por `pixelW/pixelH`;
- background geral `{0.01,0.015,0.017,0.12}`;
- header `{0.015,0.09,0.105,0.80}`;
- divider `{0.22,0.46,0.43,0.42}`;
- painéis `{0.015,0.02,0.022,0.44}`;
- busca com lupa + limpar;
- tooltips;
- seleção/foco visual coerente;
- ações dentro do painel proprietário;
- hierarquia **Título → Busca → Filtros → Conteúdo → Ações**;
- feedback sem popup sempre que possível;
- rodapé semântico Contexto / Resultado / Histórico.

## Modelo estrutural de quatro painéis

A partir de Weapons 0.6-D R2, o padrão estrutural compartilhável passa a ser quatro painéis:

```text
P1              P2                         P3                         P4
Biblioteca      Seleção / Rascunho         Catálogo                   Conteúdo real
```

A grade candidata de convergência reutiliza a geometria atual de Items:

```text
P1  x=.012  w=.176
P2  x=.196  w=.252
P3  x=.456  w=.330
P4  x=.794  w=.194
```

O significado é domain-specific:

- Items: kits de itens / draft / catálogo de itens / conteúdo de uniforme-colete-mochila;
- Weapons: kits de armas / draft / catálogo de construção de arma / armas e acessórios atualmente equipados.

Classificação: **SHARED STRUCTURE + DOMAIN-SPECIFIC CONTENT**.

## UI_CONVERGENCE_BACKLOG

| Feature | Origem | Weapons | Items | Classificação | Próxima ação |
|---|---|---|---|---|---|
| Transparência/contraste do Multiplayer Lab R3 | Items | **0.6-D R2 candidata** | existente | SHARED | validar em Weapons e congelar tokens |
| Grade de quatro painéis | Items/APM | **0.6-D R2 candidata** | existente | SHARED STRUCTURE | validar 1080p + ultrawide |
| Catálogo contínuo virtualizado com scrollbar visível + wheel | Items | **0.6-D R2 candidata** | existente | SHARED | validar navegação/consumo do wheel |
| Título **KIT SELECIONADO / RASCUNHO** | Weapons | **0.6-D R2 candidata** | pendente | **SHARED** | levar para Items em rodada de convergência |
| Estado textual **SALVO / ALTERADO** | Weapons | existente desde 0.6-D R1 | avaliar | CANDIDATE-SHARED | validar utilidade em Items |
| Rodapé em três faixas visuais | decisão compartilhada | **0.6-D R2 candidata** | pendente | CANDIDATE-SHARED | se aprovado em Weapons, aplicar em Items |
| Título específico da biblioteca: MEUS KITS DE ARMAS / MEUS KITS DE ITENS | ambos | candidata/ativo | existente | SHARED PATTERN | manter domínio explícito |
| Conteúdo do equipamento como quarto painel | Items/APM | **0.6-D R2 candidata** | existente | SHARED CONCEPT / DOMAIN-SPECIFIC | preservar leitura do estado físico real |
| Separação gestão do kit vs edição do draft | Weapons/Items | candidata | parcialmente existente | SHARED | lifecycle no P1; edição/persistência do draft no P2 |
| Comparação visual Draft vs Equipado | Weapons | futuro | avaliar | CANDIDATE-SHARED | considerar no polish/0.7, não antecipar agora |

## KIT SELECIONADO / RASCUNHO

Decisão semântica compartilhada:

`KIT SELECIONADO` sozinho deixou de ser suficiente quando a UI passou a manter alterações locais não persistidas.

Novo título:

```text
KIT SELECIONADO / RASCUNHO
```

Interpretação:
- há um kit selecionado como origem;
- o conteúdo exibido pode divergir do kit persistido;
- **SALVO** = draft igual ao snapshot persistido;
- **ALTERADO** = draft diferente.

Weapons adota em 0.6-D R2. Items deve receber a mesma nomenclatura em futura rodada de convergência, sem misturar essa mudança no gate funcional atual de Items.

## Catálogo contínuo e scrollbar

Weapons 0.6-D R2 importa o padrão já provado em Items:
- janela virtualizada de 32 linhas;
- catálogo completo continua pesquisável;
- wheel sobre o catálogo move o offset em blocos;
- slider vertical visível representa offset real;
- mudança de busca/filtro volta ao topo;
- wheel é consumido pela UI para não acionar `PrevAction/NextAction` do gameplay.

Classificação: **SHARED**.

## Rodapé — Contexto / Resultado / Histórico

Semântica padronizada:

```text
CONTEXTO   — onde estou / qual kit / filtros / destino visualizado
RESULTADO  — consequência da última ação
HISTÓRICO  — sequência recente de ações
```

Weapons 0.6-D R2 experimenta três faixas visuais sutis, preservando a semântica já existente.

Classificação: **CANDIDATE-SHARED**. Se o gate visual for aprovado, Items deve adotar o mesmo tratamento visual.

## Weapons — decisões domain-specific da 0.6-D R2

### Catálogo em duas dimensões

Filtro por slot:
- Todos;
- Principal;
- Porte;
- Secundária.

Filtro por conteúdo:
- Todos;
- Arma;
- Óticas;
- Apontadores;
- Bipés;
- Carregadores;
- Empunhaduras.

A compatibilidade continua derivada da engine 0.3. A UI não inventa whitelist.

**Empunhaduras** é uma classificação visual de opções do `UnderBarrelSlot`. Classes cujo displayName/classname indica bipod são exibidas como Bipé; as demais opções compatíveis desse slot podem ser apresentadas como Empunhadura. Isso é heurística de apresentação, não regra de compatibilidade.

`muzzle/Boca` permanece no editor do draft. Não foi criada uma categoria de catálogo específica nesta rodada porque a lista player-facing acordada para o filtro não inclui Boca.

### CONTEÚDO DO EQUIPAMENTO

Weapons mostra:
- Principal;
- Porte;
- Secundária;
- arma realmente equipada;
- Mira/Boca/Apontador/Bipé/Carregador observados.

Na 0.6-D R2 esse painel é **somente leitura**.

Aplicação física continua exclusivamente em **0.7**.

## Fronteiras de convergência

Padronização de UI não pode:
- criar dependência runtime Items → Weapons ou Weapons → Items;
- mover ownership de domínio;
- fazer Weapons manipular conteúdo de uniforme/colete/mochila;
- fazer Items possuir configuração de arma;
- transformar o Hub em dono de lógica de domínio;
- antecipar persistência/authoring ou aplicação física apenas por conveniência visual.

Compartilhar **gramática**, não estado privado.

## Processo

1. uma melhoria nasce em um módulo;
2. entra neste backlog;
3. passa pelo gate runtime/manual do módulo de origem;
4. classifica-se como SHARED, DOMAIN-SPECIFIC ou CANDIDATE-SHARED;
5. só depois é levada ao outro módulo em uma rodada explícita de convergência;
6. regressão visual/funcional deve validar ambos.

## Referências

- Items UI atual: `addons/ServoPeregrino_Organizador_Items/ui/items_dialog.hpp`
- Weapons UI: `docs/28_WEAPONS_0_6_PLAYER_UI.md`
- APM histórico: referência de UX/lessons learned, não source of truth arquitetural.
