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

Categorias atuais do engine:

- PRIMARY;
- HANDGUN;
- SECONDARY.

No Arma, SECONDARY é usado para launcher.

## Experiência esperada de Weapons

A interface deverá ser mais simples e direta que Armorer.

Padrão conceitual:

```text
+-----------------------------------------------------+
| WEAPONS                                             |
+----------------------+------------------------------+
| MEUS KITS            | CATÁLOGO DE ARMAS            |
|                      |                              |
| MK18 CQB             | MX                           |
| M4 SOPMOD            | M4A1                         |
| P07 SD               | SCAR                         |
| NLAW                 | AK                           |
+----------------------+------------------------------+
| KIT / ARMA SELECIONADA                              |
| slot alvo: PRIMARY                                  |
| arma: MK18                                           |
| optic: ...                                           |
| muzzle: ...                                          |
| pointer: ...                                         |
| bipod: ...                                           |
| informações básicas / compatibilidade                |
+-----------------------------------------------------+
| SALVAR | SALVAR COMO | DUPLICAR | EQUIPAR           |
+-----------------------------------------------------+
```

A composição visual final será decidida na 0.6; este desenho registra apenas o conceito.

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

0.4    WeaponRecipe                            NEXT
0.5    WeaponKit
0.6    Weapons Player UI / Kit Builder
0.7    Slot-Safe Weapon Application
0.8    Multiplayer Authority / Reconciliation
```

## Critério para 0.6

A UI 0.6 só deve congelar seu desenho após:

1. WeaponRecipe 0.4 estar funcional;
2. WeaponKit 0.5 estar funcional;
3. revisão explícita da UI de armas do APM histórico;
4. lista KEEP / ADAPT / DROP / NEW registrada;
5. garantir que a interface não dependa do Armorer.

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
