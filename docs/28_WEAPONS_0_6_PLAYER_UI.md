# Weapons 0.6 — Player UI / Kit Builder

## Estado atual

**0.6-A R4 — BASELINE VISUAL/ESTRUTURAL CONGELADA. 0.6-B R4 — SELEÇÃO/INFORMAÇÕES HOMOLOGADA 397/397. 0.6-C R1 — CANDIDATA ATIVA; STATIC 335/335; RUNTIME PENDENTE.**

Baseline anterior:
- 0.4 R5 WeaponRecipe: **251/251**;
- 0.5 WeaponKit: **301/301**;
- 0.6-A R4 runtime: **362/362 PASS / 0 FAIL**;
- refresh reentrante corrigido;
- catálogo completo permanece cacheado/pesquisável;
- projeção visual limitada a 250 linhas;
- gate visual aceito como base para continuar a implementação.

O source integrado do addon continua em 0.1-A. Esta linha permanece mission-first e não representa Packaging/PBO.

## Decisão de processo

A partir da R4, **não vamos continuar polindo o layout durante cada subentrega funcional**.

Sequência decidida:

```text
0.6-A  Shell/layout/listas/filtros                 FROZEN BASELINE 362/362
0.6-B  Seleção de arma + informações              APPROVED R4 397/397
0.6-C  Dropdowns de compatibilidade                ACTIVE R1 — STATIC 335/335; RUNTIME PENDING
0.6-D  Rascunho de WeaponKit
0.6-E  Novo/Renomear/Duplicar/Excluir/Salvar
0.6-F  Adaptação visual final + foco + regressões
```

Regra:
1. primeiro implementar e testar as funcionalidades;
2. preservar a baseline visual R4 durante B–E;
3. depois adaptar o layout ao conteúdo real que passou a existir;
4. só então fazer o polimento visual final.

Isso evita retrabalho visual enquanto os controles ainda estão ganhando comportamento.

## Nomenclatura player-facing

Modelo interno permanece:

```text
PRIMARY
HANDGUN
SECONDARY
```

UI:

```text
Principal  -> PRIMARY
Porte      -> HANDGUN
Secundária -> SECONDARY / lançador
Todos      -> filtro de apresentação, não targetSlot
```

## Layout congelado como baseline

```text
┌──────────────────────┬────────────────────────────────┬───────────────────────────┐
│ MEUS KITS            │ KIT SELECIONADO                │ CATÁLOGO DE ARMAS         │
│                      │                                │                           │
│ Buscar               │ Nome / Tipo                    │ Buscar                    │
│                      │                                │                           │
│ Todos                │ imagem nativa da arma          │ Todos                     │
│ Principal            │                                │ Principal                 │
│ Porte                │ Arma       [ ... ▼ ]           │ Porte                     │
│ Secundária           │ Mira       [ ... ▼ ]           │ Secundária                │
│                      │ Boca       [ ... ▼ ]           │                           │
│ lista de kits        │ Pointer    [ ... ▼ ]           │ lista de armas            │
│                      │ Bipé       [ ... ▼ ]           │                           │
│                      │ Carregador [ ... ▼ ]           │                           │
│                      │                                │                           │
│ Novo/Renomear/       │ Descartar/Salvar/              │                           │
│ Duplicar/Excluir     │ Salvar como novo               │                           │
├──────────────────────┴────────────────────────────────┴───────────────────────────┤
│ Context                                                                            │
│ Message                                                                            │
│ History                                                                            │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## Gramática compartilhada com Items

Manter:
- `RobotoCondensed`;
- dimensões por `safeZoneW/safeZoneH`;
- pixel-aspect para controles quadrados;
- busca com lupa;
- botão limpar;
- tooltips;
- mesma escala de fontes e botões;
- transparência atual;
- ações dentro do painel proprietário;
- rodapé semântico `Context / Message / History`;
- mesma estrutura em 1080p e telas maiores.

### Decisões explícitas de freeze

Não alterar agora:
- largura geral em ultrawide;
- escala de botões;
- escala de textos;
- opacidade;
- estrutura geral de três painéis;
- rodapé semântico;
- comportamento responsivo base.

O painel **KIT SELECIONADO** ainda possui bastante espaço vazio. Isso é aceito temporariamente porque as próximas subentregas vão inserir informações e comportamento reais. A composição vertical será reavaliada somente na fase final de adaptação visual.

## MEUS KITS

Filtros privados:

```text
Todos | Principal | Porte | Secundária
```

`Todos` mostra todos os WeaponKits privados/session-local do jogador.

`Públicos` não é tipo de arma. É uma futura origem/biblioteca e permanece separada e desabilitada até existir backend real.

Ações permanecem dentro do painel:
- Novo;
- Renomear;
- Duplicar;
- Excluir.

## KIT SELECIONADO

É o editor do WeaponKit.

Não existe painel separado de acessórios compatíveis.

Campos:
- Arma;
- Mira;
- Boca;
- Pointer;
- Bipé;
- Carregador.

As opções compatíveis serão apresentadas nos próprios seletores/dropdowns.

Ações:
- Descartar;
- Salvar;
- Salvar como novo.

## CATÁLOGO DE ARMAS

Filtros:

```text
Todos | Principal | Porte | Secundária
```

Busca textual e filtro de tipo são combináveis.

O catálogo usa a baseline homologada da 0.3:
- base real: 2770 armas;
- categorias: PRIMARY/HANDGUN/SECONDARY;
- conteúdo vanilla e modded;
- provenance preservada.

A UI renderiza no máximo 250 resultados por refresh, mantendo o catálogo completo cacheado e pesquisável.

## Rodapé — decisão atual e melhoria futura compartilhada

Hoje Items e Weapons usam uma única superfície de fundo com três linhas semânticas:

```text
Context
Message
History
```

**Não alterar durante 0.6-B até 0.6-E.**

Foi registrada uma melhoria visual futura:

> separar visualmente o rodapé em três faixas distintas — Context, Message e History — mantendo exatamente a mesma semântica.

Essa mudança **não deve ser feita somente em Weapons**. Deve ser aplicada de forma coordenada em:
- Items;
- Weapons.

Motivo: preservar a gramática visual compartilhada do SP_ORG.

Referência oficial: `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

## Fronteiras da 0.6

A 0.6 não deve:
- alterar uniforme/colete/mochila;
- equipar a arma no jogador;
- substituir slot físico;
- criar Preview 3D de bancada;
- implementar condição/manutenção;
- assumir autoridade multiplayer;
- criar biblioteca pública fictícia.

Aplicação real permanece em **0.7 — Slot-Safe Weapon Application**.

## Histórico 0.6-A

### R1 — REPROVADA
- funções UI não carregaram;
- causa: path incorreto no `CfgFunctions`.

### R2 — REPROVADA
- funções UI carregaram;
- dialog abriu;
- refresh entrou em ciclo por seleção programática/evento;
- catálogo integral também criava risco de custo excessivo.

### R3 — FUNCIONAL, 1 FALSO NEGATIVO
- refresh reentrante corrigido;
- projeção limitada a 250;
- runtime: **345/346**;
- única falha: teste verificava `findDisplay` antes do `onUnload`.

### R4 — BASELINE CONGELADA
- fechamento aguardando frame do `onUnload`;
- filtros Todos/Principal/Porte/Secundária em Meus Kits;
- mesmos filtros no Catálogo;
- busca + filtro combináveis;
- runtime: **362/362 PASS / 0 FAIL**;
- shell visual aceito como base de continuidade.

## 0.6-B — Seleção de arma + informações — HOMOLOGADA R4

Final mission-first:

`0.6.1.4-initial-sync-handshake-test-timing-mission-first`

Runtime final: **397/397 PASS / 0 FAIL**.

### Contrato funcional congelado

Seleção é contexto de **leitura**, não edição.

Ao selecionar uma arma no Catálogo:
- resolve `weaponClass`;
- mostra `displayName`;
- mostra tipo player-facing;
- usa `picture` nativo do config;
- apresenta origem/mod/addon;
- apresenta `baseWeapon`;
- apresenta descrição curta quando disponível;
- pode indicar preset/variant;
- não consulta compatibilidade ainda;
- não cria draft;
- não altera WeaponKit;
- não altera loadout.

Ao selecionar um WeaponKit:
- a mesma camada básica de informação é derivada da arma contida em sua Recipe;
- o kit salvo continua sendo a fonte do painel quando o foco retorna a MEUS KITS.

### Abertura de MEUS KITS

Toda nova abertura da interface inicia deterministicamente com:

```text
kitTypeFilter = ALL
kitQuery      = ""
lastFocus     = KITS
```

Regras homologadas:
- **TODOS** é o filtro inicial;
- todos os kits privados/session-local disponíveis aparecem sem exigir clique;
- número de linhas visíveis deve corresponder ao repository na abertura canônica;
- primeiro kit é selecionado quando houver kits;
- um handshake explícito marca a sincronização inicial concluída;
- o recovery refresh só ocorre se a abertura ainda estiver na projeção canônica;
- a sincronização atrasada não deve sobrescrever filtro escolhido pelo jogador após interação.

### Histórico da 0.6-B

#### R1 — funcional verde, higiene rejeitada
- runtime **392/392**;
- `Selection & Information` gerava milhares de `Unknown entity: ' Information'`;
- causa: `&` em texto player-facing interpretado pelo Arma.

#### R2 — higiene corrigida
- runtime **392/392**;
- warning de structured text removido;
- manual revelou que MEUS KITS podia abrir vazio até clicar em um filtro.

#### R3 — comportamento manual corrigido, race de teste
- abertura em TODOS corrigida;
- usuário confirmou MEUS KITS abrindo corretamente;
- AUTO: **391/396**;
- teste lia `rows=0` enquanto a sincronização ainda estava rodando;
- logo depois o runtime registrava `rows=3 success=true`.

#### R4 — final homologada
- handshake `initialSyncComplete`;
- teste aguarda o refresh inicial realmente concluir, em vez de usar sleep fixo;
- gate inicial confirmou `rows=3 expectedRows=3 selected=0`;
- prévia do catálogo voltou a passar;
- zero mutação de WeaponKit/loadout;
- runtime: **397/397 PASS / 0 FAIL**.

### Próximo passo: 0.6-C

Implementar **Compatibility Selectors** dentro de KIT SELECIONADO, sem criar painel separado.

Escopo planejado:
- Mira;
- Boca;
- Pointer;
- Bipé;
- Carregador;
- somente opções compatíveis com a arma em contexto;
- usar a engine de compatibilidade já homologada em 0.3;
- preservar modo read-only/sem draft até 0.6-D onde aplicável;
- nenhuma aplicação física da arma, que permanece em 0.7.

Não abrir nova rodada de polimento visual antes de concluir as funcionalidades planejadas da 0.6.


## 0.6-C — Compatibility Selectors — R1 candidata

Build mission-first:

`0.6.2.1-compatibility-selectors-read-only-mission-first`

Estado: **CANDIDATA / NÃO HOMOLOGADA EM RUNTIME**.

Validação estática da candidata: **335/335 PASS / 0 FAIL**. O runner cumulativo contém 418 pontos de asserção no source e a execução esperada no Arma é **445 checks**.

Delta funcional:
- os controles existentes de Mira, Boca, Pointer, Bipé e Carregador passam a ser dropdowns;
- as opções são derivadas exclusivamente de `getWeaponCompatibility`, a engine homologada na 0.3;
- a geometria da 0.6-A R4 permanece congelada;
- o valor atualmente salvo no WeaponRecipe permanece selecionado;
- os seletores são **read-only** nesta etapa;
- escolher outra opção serve somente para consultar compatibilidade e a UI restaura o valor salvo;
- nenhum draft é criado;
- nenhum WeaponKit é alterado;
- nenhum loadout é alterado.

Gates preservados:
- draft: **0.6-D**;
- authoring/lifecycle: **0.6-E**;
- polish final: **0.6-F**;
- aplicação física slot-safe: **0.7**;
- multiplayer/authority: **0.8**.

Não avançar para 0.6-D antes de runtime + avaliação manual da 0.6-C R1.
