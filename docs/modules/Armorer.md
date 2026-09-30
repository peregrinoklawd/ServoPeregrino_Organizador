# Armorer — ownership e migração

## Papel

Dono da bancada física e da experiência especializada de construção, Preview 3D, inspeção de peças e manutenção. Armorer não é a UI geral de organização de armas; Weapons possui sua própria interface player-facing.

## Já comprovado historicamente

- estações físicas;
- sessão por operador;
- lease/autoridade multiplayer por estação;
- preview 3D;
- `originalConfiguration`, `confirmedConfiguration`, `workingConfiguration`;
- commit/rollback;
- fontes de conteúdo como AUTO, VIRTUAL, PLAYER_INVENTORY, CONTAINER e STATION_STOCK.

## Construção/montagem

Armorer oferece a experiência **especializada de bancada** para:
- montar/desmontar visualmente;
- trabalhar com Preview 3D;
- escolher acessórios em contexto de bancada;
- manipular uma configuração/receita através dos serviços de Weapons;
- aplicar/confirmar mudanças no workflow da estação.

O modelo, validação, persistência lógica e experiência geral de WeaponKit pertencem a **Weapons**.

Weapons possui UI própria para o jogador escolher uma arma, configurar acessórios, salvar/carregar WeaponKits e equipar somente o slot alvo sem alterar o restante do inventário. Armorer não substitui essa interface.

## Manutenção

Armorer oferece:
- inspeção;
- interface de limpeza;
- interface de lubrificação;
- reparo;
- troca de peças;
- apresentação de condição;
- fluxo transacional do serviço.

O cálculo/estado autoritativo de desgaste e as transições lógicas de manutenção pertencem a **WeaponCondition**.

## Não deve possuir

- catálogo/semântica geral de Items;
- identidade privada de Weapons;
- fórmula própria de desgaste;
- condition state duplicado;
- banco/economia diretamente;
- engine própria de whitelist/blacklist.

## Integrações futuras

- Weapons: identidade, configuração, compatibilidade e receitas;
- WeaponCondition: condição, desgaste e manutenção lógica;
- Stock/Economy/Persistence: opcionais via providers;
- Policy: regras allow/deny;
- Adapters: compatibilidade com mods externos.

## Migração

Importar a baseline histórica autoritativa sem reescrever ou adicionar features. O primeiro gate do Armorer no monorepo é provar equivalência funcional.


## Fronteira de UI — decisão 29/09/2026

```text
Weapons UI
= simples, direta, APM-like
= catálogo + configuração + WeaponKit + equipar por slot

Armorer UI
= bancada especializada
= Preview 3D + peças + inspeção + manutenção + workflow de estação
```

A parte de armas do APM histórico será usada como fonte de lessons learned para Weapons UI. O Armorer histórico continua sendo fonte de lessons learned para Preview/bancada/sessão, sem transferir ownership de WeaponKit para Armorer.

Referência de fronteira: `../25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md`.
