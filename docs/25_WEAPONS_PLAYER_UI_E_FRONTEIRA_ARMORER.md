# Weapons — Player UI, WeaponKit e fronteira com Armorer

## Decisão

**Weapons é um módulo player-facing independente, assim como Items.**

Não deve ser tratado apenas como backend do Armorer.

O jogador poderá usar Weapons diretamente para organizar, configurar, salvar e equipar armas sem precisar entrar em uma bancada de armeiro.

## Analogia oficial com Items

```text
ITEMS
  UI própria
  -> ItemKit
  -> conteúdo de itens
  -> altera somente o domínio Items

WEAPONS
  UI própria
  -> WeaponKit
  -> arma + configuração
  -> altera somente o slot de arma alvo
```

A regra arquitetural é a mesma: **um domínio não deve alterar silenciosamente o estado pertencente a outros domínios**.

## Conceito de WeaponKit

Um WeaponKit é **uma arma configurada para um único slot**.

Não é um loadout completo.

Exemplo:

```text
WeaponKit
name       = "MK18 CQB Noturno"
targetSlot = PRIMARY
weaponClass
muzzle
pointer
optic
bipod
magazine policy/configuration quando definido pelo contrato futuro
```

Categorias internas continuam exatamente como foram homologadas:

- `PRIMARY`;
- `HANDGUN`;
- `SECONDARY`.

A UI não usa esses nomes técnicos diretamente. Mapeamento player-facing oficial:

| UI | Interno | Significado |
|---|---|---|
| **Principal** | `PRIMARY` | arma primária |
| **Porte** | `HANDGUN` | arma de porte |
| **Secundária** | `SECONDARY` | lançador |

A nomenclatura de apresentação não altera schema, fingerprint, Recipe, WeaponKit ou regras internas.

## Experiência esperada de Weapons

A interface deve manter a mesma gramática visual do **Items**, para reduzir reaprendizado.

Estrutura oficial atual:

```text
+----------------------+--------------------------------+---------------------------+
| MEUS KITS            | KIT SELECIONADO                | CATÁLOGO DE ARMAS         |
|                      |                                |                           |
| [buscar...]          | Nome / Tipo                    | [buscar...]               |
| Tipo:                |                                |                           |
| [Principal]          | [ imagem nativa da arma ]      | lista de armas            |
| [Porte]              |                                |                           |
| [Secundária]         | Arma       [ ... ▼ ]           |                           |
| [Públicos]           | Mira       [ ... ▼ ]           |                           |
|                      | Boca       [ ... ▼ ]           |                           |
| lista de kits        | Pointer    [ ... ▼ ]           |                           |
|                      | Bipé       [ ... ▼ ]           |                           |
|                      | Carregador [ ... ▼ ]           |                           |
|                      |                                |                           |
| Novo / Renomear /    | Descartar / Salvar /           |                           |
| Duplicar / Excluir   | Salvar como novo               |                           |
+----------------------+--------------------------------+---------------------------+
| CONTEXTO / INFORMAÇÃO                                                    |
| MENSAGEM / FEEDBACK                                                      |
| HISTÓRICO                                                                |
+---------------------------------------------------------------------------+
```

Decisões:

- ordem dos painéis preserva familiaridade com Items: **Meus Kits -> Kit Selecionado -> Catálogo**;
- não existe painel separado de **Acessórios Compatíveis**;
- acessórios compatíveis serão apresentados pelos próprios dropdowns do **Kit Selecionado**;
- botões pertencem ao painel que controlam;
- busca, botão limpar, tooltips, tipografia, transparência e rodapé seguem o padrão do Items;
- a área inferior usa as três linhas `Context / Message / History` do Items;
- a UI usa `safeZoneW/safeZoneH` e métricas pixel-aspect-safe para preservar uso em 1080p e telas maiores;
- responsividade será validada durante 0.6, mas não é tratada como feature separada neste primeiro checkpoint;
- `Públicos` ocupa o local planejado, porém só se torna funcional quando houver uma biblioteca pública real de WeaponKits;
- Preview 3D avançado continua pertencendo ao Armorer.

### Checkpoints planejados da 0.6

```text
0.6-A  shell/layout/listas/filtros
0.6-B  seleção de arma + informações
0.6-C  dropdowns de compatibilidade
0.6-D  rascunho de WeaponKit
0.6-E  Novo/Renomear/Duplicar/Excluir/Salvar/Salvar como
0.6-F  polimento visual/foco/regressões
```

A 0.7 continua sendo o primeiro gate autorizado a equipar/aplicar um WeaponKit no jogador.

## Operações da UI

Weapons UI deverá permitir, progressivamente:

- navegar pelo catálogo;
- buscar/filtrar armas;
- escolher uma arma;
- mostrar informações úteis da arma;
- mostrar attachments compatíveis por slot;
- mostrar magazines compatíveis;
- montar uma configuração;
- criar WeaponKit;
- editar;
- renomear;
- duplicar;
- excluir;
- salvar/carregar;
- escolher o slot alvo;
- equipar/aplicar.

## Invariante de isolamento

Aplicar um WeaponKit não significa aplicar um loadout inteiro.

Exemplo de gate:

```text
ANTES
uniforme      = A
colete        = B
mochila       = C
primary       = MX
handgun       = P07
secondary     = NLAW
itens         = X

AÇÃO
equipar WeaponKit targetSlot=PRIMARY

DEPOIS
uniforme      = A
colete        = B
mochila       = C
primary       = arma/configuração do WeaponKit
handgun       = P07
secondary     = NLAW
itens         = X
```

A única mudança intencional é o slot alvo.

Esse comportamento será um gate explícito da **0.7 — Slot-Safe Weapon Application**.

## Relação com APM

A parte de armas do **APM histórico** será usada como fonte de lessons learned para a futura Weapons UI.

Objetivo:

- reaproveitar padrões que já demonstraram ser claros para o jogador;
- reaproveitar comportamentos que funcionaram bem;
- identificar limitações e decisões que não funcionaram;
- evitar recomeçar o design do zero.

Regra importante:

> APM é referência de experiência e lições aprendidas, não uma autorização para copiar automaticamente sua arquitetura antiga.

Antes de fechar a UI 0.6, revisar explicitamente o APM histórico e produzir um pequeno inventário:

```text
KEEP      -> funcionou e deve ser preservado
ADAPT     -> conceito bom, implementação precisa mudar
DROP      -> não funcionou / não pertence ao novo Weapons
NEW       -> requisito que surgiu na arquitetura modular
```

## Fronteira com Armorer

### Weapons

Experiência cotidiana e rápida:

- catálogo;
- WeaponKit;
- configuração;
- compatibilidade;
- informação básica;
- equipar por slot;
- independência de estação física.

### Armorer

Experiência especializada:

- bancada física;
- sessão/lease da estação;
- Preview 3D avançado;
- montagem física/visual detalhada;
- inspeção;
- peças/componentes;
- condição;
- limpeza;
- lubrificação;
- diagnóstico;
- reparo;
- substituição de peças;
- workflow de manutenção.

## Reuso sem duplicação

Armorer pode apresentar e editar WeaponConfiguration/WeaponRecipe/WeaponKit em seu próprio contexto de bancada, mas:

- o modelo pertence a Weapons;
- a validação pertence a Weapons;
- a compatibilidade pertence a Weapons;
- o kit pertence a Weapons;
- a aplicação de arma pertence a Weapons;
- Armorer não mantém uma segunda implementação desses conceitos.

Da mesma forma, Weapons não implementa manutenção, condition state ou peças internas.

## Relação com WeaponCondition

```text
Weapons
= o que a arma é

WeaponCondition
= como a arma está

Armorer
= bancada especializada para construir/inspecionar/manter

Weapons UI
= interface rápida para organizar/configurar/equipar armas
```

## Roadmap atualizado

```text
0.1-A  Foundation / Identity Spike             APPROVED
0.1-B  Lifecycle / Event-Delta Evidence        APPROVED
0.2    WeaponConfiguration                     APPROVED
0.3    Catalog / Compatibility                 APPROVED

0.4    WeaponRecipe                            APPROVED
0.5    WeaponKit                               APPROVED
0.6    Weapons Player UI / Kit Builder         CURRENT
  0.6-A shell/layout/listas/filtros             CANDIDATE
0.7    Slot-Safe Weapon Application
0.8    Multiplayer Authority / Reconciliation
```

## Critério para 0.6

A UI 0.6 só deve congelar seu desenho após:

1. WeaponRecipe 0.4 homologado — **concluído**;
2. WeaponKit 0.5 homologado — **concluído**;
3. revisão explícita de padrões do Items/APM histórico;
4. lista KEEP / ADAPT / DROP / NEW registrada e revisada durante os checkpoints;
5. provar uso em 1080p e em tela maior sem criar duas interfaces diferentes;
6. garantir que a interface não dependa do Armorer;
7. manter equip/application fora da 0.6.

## Critério para 0.7

Aplicar cada tipo de WeaponKit deve provar que nenhum domínio fora do slot alvo foi alterado.

Esse gate deve testar pelo menos:

- PRIMARY;
- HANDGUN;
- SECONDARY;
- attachments;
- loadedState/magazine conforme contrato da entrega;
- uniforme;
- colete;
- mochila;
- assigned items;
- itens de inventário;
- armas não alvo.
