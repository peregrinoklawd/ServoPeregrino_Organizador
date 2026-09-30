# Weapons 0.6 — Player UI / Kit Builder

## Estado

**0.6-A R2 — CANDIDATE MISSION-FIRST. R1 REPROVADA.**

Baseline funcional:

- 0.4 R5 WeaponRecipe: **251/251**;
- 0.5 WeaponKit: **301/301**;
- 0.6-A R1 static validation: **169/169**, porém runtime **REPROVADO**;
- R1: `CfgFunctions > UI > file` usava barras duplicadas e o Arma não carregou as funções UI;
- R1 runtime: **306/320**, 14 FAIL em cascata após funções UI ausentes;
- 0.6-A R2 hotfix: path corrigido + preflight das 11 funções UI + runner fail-safe;
- R2 static validation: **141/141 PASS**;
- runtime/avaliação visual da R2: pendente.

O source integrado do addon continua em 0.1-A. Esta linha 0.6 permanece mission-first e não representa Packaging/PBO.

## Objetivo da 0.6

Entregar a interface própria player-facing de Weapons sem depender do Armorer.

A 0.6 edita/navega modelos já homologados. Ela **não equipa armas no jogador**.

Aplicação real permanece em:

**0.7 — Slot-Safe Weapon Application.**

## Nomenclatura player-facing

O modelo interno permanece congelado:

```text
PRIMARY
HANDGUN
SECONDARY
```

A interface apresenta:

```text
Principal  -> PRIMARY   -> arma primária
Porte      -> HANDGUN   -> arma de porte
Secundária -> SECONDARY -> lançador
```

Essa tradução existe somente na apresentação.

## Gramática visual compartilhada com Items

Weapons deve parecer parte da mesma família do Items.

Padrões reutilizados:

- `RobotoCondensed`;
- dimensões baseadas em `safeZoneW/safeZoneH`;
- correção pixel-aspect para controles quadrados com `pixelW/pixelH`;
- busca com ícone de lupa;
- botão limpar busca;
- tooltips;
- transparência;
- seleção visual;
- ações dentro do painel proprietário;
- feedback textual;
- rodapé em três linhas:
  - Context;
  - Message;
  - History.

A meta é manter a mesma estrutura em 1080p e em telas maiores, como já acontece no Items. A responsividade será refinada ao longo da 0.6; não é tratada como feature isolada na 0.6-A.

## Layout oficial

```text
┌──────────────────────┬────────────────────────────────┬───────────────────────────┐
│ MEUS KITS            │ KIT SELECIONADO                │ CATÁLOGO DE ARMAS         │
│                      │                                │                           │
│ 🔍 Buscar...         │ Nome / Tipo                    │ 🔍 Buscar...              │
│                      │                                │                           │
│ Tipo:                │ [ imagem nativa da arma ]      │ lista de armas            │
│ [Principal]          │                                │                           │
│ [Porte]              │ Arma       [ ... ▼ ]           │                           │
│ [Secundária]         │ Mira       [ ... ▼ ]           │                           │
│ [Públicos]           │ Boca       [ ... ▼ ]           │                           │
│                      │ Pointer    [ ... ▼ ]           │                           │
│ lista de kits        │ Bipé       [ ... ▼ ]           │                           │
│                      │ Carregador [ ... ▼ ]           │                           │
│                      │                                │                           │
│ Novo / Renomear /    │ Descartar / Salvar /           │                           │
│ Duplicar / Excluir   │ Salvar como novo               │                           │
├──────────────────────┴────────────────────────────────┴───────────────────────────┤
│ CONTEXTO / INFORMAÇÃO                                                             │
│ MENSAGEM / FEEDBACK                                                               │
│ HISTÓRICO                                                                         │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## MEUS KITS

Responsabilidade:

- localizar kits;
- filtrar coleção;
- selecionar kit;
- futuramente executar ações sobre a coleção.

Busca:

- mesmo padrão visual do Items;
- limpa por botão dedicado;
- filtra por nome.

Filtros:

```text
Tipo: [Principal] [Porte] [Secundária] [Públicos]
```

Os três primeiros são filtros de `targetSlot`.

`Públicos` ocupa a posição visual planejada, mas **não é targetSlot**. É uma futura origem/biblioteca de WeaponKits. Na 0.6-A ele permanece visível e desabilitado para não simular um backend que ainda não existe.

Ações locais:

- Novo;
- Renomear;
- Duplicar;
- Excluir.

Na 0.6-A os botões validam posição/vocabulário. A ativação funcional de authoring ocorre nos checkpoints posteriores.

## KIT SELECIONADO

O painel é o editor da arma/WeaponKit.

Não existe painel separado de **Acessórios Compatíveis**.

Campos planejados:

- Arma;
- Mira;
- Boca;
- Pointer;
- Bipé;
- Carregador.

Compatibilidade será apresentada pelo próprio seletor/dropdown.

Exemplo:

```text
Mira
[EOTech EXPS3 ▼]
  -> Nenhuma
  -> ACO
  -> RCO
  -> EOTech EXPS3
  -> ...
```

A lista deve ser derivada da compatibilidade real da arma, nunca de hardcode.

Ações locais:

- Descartar;
- Salvar;
- Salvar como novo.

## CATÁLOGO DE ARMAS

Origem:

- catálogo homologado da 0.3;
- `CfgWeapons`;
- conteúdo vanilla e modded;
- provenance preservada.

0.6-A:

- busca;
- lista;
- imagem do config;
- categoria player-facing;
- seleção apenas para informação/navegação.

Selecionar uma arma no catálogo **não altera automaticamente o WeaponKit selecionado**.

## Rodapé

Segue o padrão do Items.

### Context

Mostra o objeto/contexto atualmente relevante.

Exemplos:

```text
Kit | MK18 CQB | Tipo: Principal | Arma: MK18
```

ou:

```text
Catálogo | Principal | HK416 | Classe: ... | Origem: ...
```

### Message

Feedback imediato da última interação.

### History

Histórico curto de feedback da sessão.

## Fronteiras da 0.6

A 0.6 NÃO deve:

- alterar uniforme/colete/mochila;
- equipar arma;
- substituir slot físico do jogador;
- criar Preview 3D avançado;
- executar maintenance;
- assumir autoridade multiplayer;
- implementar biblioteca pública fictícia.

## Checkpoints

```text
0.6-A  Shell/layout/listas/filtros
0.6-B  Seleção de arma + informações
0.6-C  Dropdowns de compatibilidade
0.6-D  Rascunho de WeaponKit
0.6-E  Novo/Renomear/Duplicar/Excluir/Salvar/Salvar como
0.6-F  Polimento visual/foco/regressões
```

Cada checkpoint deve preservar o anterior.

## KEEP / ADAPT / DROP / NEW inicial

### KEEP

Do Items:

- safeZone responsive layout;
- RobotoCondensed;
- busca + limpar;
- tooltips;
- ações dentro do painel proprietário;
- botão de exclusão em linguagem de perigo;
- footer Context/Message/History;
- seleção visual clara;
- feedback sem confirmações desnecessárias.

### ADAPT

- quatro painéis Items -> três painéis Weapons;
- filtros de categorias Items -> filtros de tipo da arma;
- Kit Selecionado baseado em linhas de itens -> Kit Selecionado baseado em slots de configuração;
- catálogo de itens -> catálogo de armas;
- imagem/detalhes simples no lugar de Preview 3D.

### DROP

Para o primeiro ciclo de Weapons:

- painel separado de acessórios compatíveis;
- Drag & Drop como fundamento inicial;
- controles de quantidade;
- Equipment/physical content panel;
- aplicação física dentro da 0.6.

### NEW

- tradução UI `Principal/Porte/Secundária`;
- dropdowns contextuais por slot de attachment;
- WeaponRecipe/WeaponKit como fonte única do editor;
- botão `Públicos` reservado para provider futuro sem fake backend.

## Critério 0.6-A

Automático:

- regressões 0.1-B -> 0.5 verdes;
- labels UI corretos;
- filtros internos corretos;
- busca de kits;
- busca de catálogo;
- dialog abre;
- painéis/rodapé existem;
- Públicos visível-desabilitado;
- ações locais nos painéis;
- controles ficam dentro do safeZone;
- nenhuma mutação de WeaponKit pelo shell;
- nenhuma mutação de loadout.

Manual:

- familiaridade visual com Items;
- leitura em 1080p;
- leitura em monitor maior;
- proporções;
- espaçamentos;
- tooltips;
- clareza dos filtros;
- rodapé;
- comportamento de busca/seleção.

## Rodadas 0.6-A

### R1 — REPROVADA

RPT confirmou:

```text
Script SP_ORG\\Weapons\\functions\\ui\fn_createUIState.sqf not found
...
Script SP_ORG\\Weapons\\functions\\ui\fn_openInterface.sqf not found
```

Causa raiz: `CfgFunctions` da classe UI apontava para `SP_ORG\\Weapons\\functions\\ui` com separadores duplicados. Os arquivos existiam, mas não foram resolvidos pelo Arma.

A ausência das funções provocou cascata no runner antigo (`_ok` indefinido) e impediu a abertura da interface.

### R2 — CANDIDATA ATIVA

Delta estritamente corretivo:

- corrige `file="SP_ORG\Weapons\functions\ui";`;
- `_assert` usa default `false`;
- preflight explícito de todas as 11 funções UI;
- se houver nova falha de carregamento, o bloco UI é pulado e o RPT registra o bloqueio sem cascata;
- nenhum novo comportamento de UI;
- WeaponKit/Recipe/Catalog inalterados;
- aplicação continua em 0.7.

## Artefato candidato

```text
SP_ORG_Weapons_0_6_A_R2_PlayerUI_Shell_Lab_MissionFirst.VR
build = 0.6.0.2-cfgfunctions-ui-path-hotfix-mission-first
```

Depois do gate 0.6-A, continuar para **0.6-B**, sem pular diretamente para aplicação física.
