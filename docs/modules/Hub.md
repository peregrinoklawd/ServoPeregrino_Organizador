# Hub — ownership

## Papel

Camada opcional de integração **voltada ao jogador**.

Definição curta:

```text
Nexus
= faz os módulos conversarem tecnicamente.

Hub
= faz o jogador conversar com os módulos.
```

## Planejado

- Central do Organizador;
- menu principal;
- navegação entre módulos;
- descoberta dinâmica de módulos disponíveis;
- mostrar apenas funcionalidades realmente instaladas;
- visão resumida do personagem/equipamento/arma/condição;
- encaminhar o jogador ao módulo correto já com contexto;
- ações integradas que coordenam vários módulos;
- notificações e alertas compartilhados;
- atalhos contextuais;
- shell visual/navegação compartilhada.

## Não deve possuir

- ItemKit;
- WeaponInstance;
- condição/desgaste;
- EquipmentKit;
- Set como dado persistente;
- estoque/economia;
- regras de whitelist/blacklist;
- lógica do Armorer.

## Relação com Sets

- **Sets** é dono do dado/composição de um conjunto.
- **Hub** é dono da experiência/orquestração usada para criar/aplicar/navegar entre funcionalidades.

## Relação com Nexus

- **Nexus** é infraestrutura técnica.
- **Hub** é integração funcional/visual.

## Dependência

O Hub depende do Nexus para descobrir capacidades. Os módulos de domínio **não dependem do Hub**.
