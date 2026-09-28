# Hub — Central do Servo Peregrino Organizador

Status: **PLANEJADO; NÃO IMPLEMENTADO**.

## Objetivo

Criar uma porta de entrada única e opcional para o ecossistema SP_ORG, integrando visualmente os módulos sem transformar o Hub em um monólito.

## Definição

```text
Nexus
= integração técnica entre módulos

Hub
= integração funcional e visual para o jogador
```

## Princípio

> **O Hub coordena; não executa lógica de domínio.**

Cada ação continua pertencendo ao módulo responsável.

Exemplos:

```text
Criar kit de itens
  -> Items

Ver condição da arma
  -> WeaponCondition

Abrir no Armeiro
  -> Armorer

Aplicar Set
  -> Sets
      -> Equipment
      -> Weapons
      -> Items
```

## Interface candidata

```text
CENTRAL DO ORGANIZADOR

[ ITENS ]
[ ARMAS ]
[ EQUIPAMENTOS ]
[ CONJUNTOS ]
[ ARMEIRO ]
[ CONDIÇÃO DAS ARMAS ]
[ CONFIGURAÇÕES ]
```

Somente módulos realmente disponíveis devem aparecer.

## Funcionalidades planejadas

### Navegação
- menu principal;
- abrir Items;
- abrir Weapons;
- abrir Equipment;
- abrir Sets;
- abrir Armorer;
- abrir WeaponCondition;
- abrir Settings;
- mostrar somente módulos instalados/disponíveis.

### Visão integrada
- resumo do equipamento atual;
- arma atual;
- condição resumida da arma;
- carga/peso;
- conjunto selecionado;
- alertas;
- restrições do servidor;
- indisponibilidades de estoque/preço quando providers existirem.

### Ações integradas
- criar conjunto completo a partir do personagem;
- aplicar conjunto completo;
- verificar disponibilidade antes de aplicar;
- verificar restrições de Policy;
- verificar estoque;
- verificar custo;
- encaminhar ao módulo correto com contexto.

Exemplo:

```text
Hub detecta desgaste alto
  -> alerta
  -> [ABRIR NO ARMEIRO]
  -> Armorer recebe a arma/contexto selecionado
```

## Descoberta dinâmica

Evitar listas rígidas de módulos no código sempre que possível.

Direção desejada:

1. cada módulo anuncia pelo Nexus que está disponível;
2. expõe sua ação pública de abertura/integração;
3. Hub consulta capacidades;
4. Hub monta a navegação dinamicamente.

Isso permite combinações como:

```text
Nexus + Items + Hub
```

ou:

```text
Nexus + Items + Weapons + WeaponCondition + Armorer + Equipment + Sets + Hub
```

sem obrigar todos os módulos a existirem.

## Ações contextuais

Futuro possível:

- olhando para uma bancada -> destacar "Abrir Armeiro";
- arma selecionada -> "Ver arma", "Ver condição", "Abrir no Armeiro";
- olhando para uma caixa -> "Criar kit", "Capturar itens", "Ver estoque";
- conjunto selecionado -> mostrar disponibilidade/custo/restrições.

## Relação com Sets

Sets possui a **definição persistente do conjunto**.

Hub possui a **experiência integrada** usada pelo jogador.

```text
Sets
= o que compõe o conjunto

Hub
= como o jogador navega, verifica e aciona os módulos
```

## Relação com Nexus

```text
Nexus
faz os módulos conversarem.

Hub
faz o jogador conversar com os módulos.
```

O Hub não substitui o Nexus.

## Dependências

Regra obrigatória:

```text
Hub -> descobre/consome módulos

Módulos de domínio -X-> Hub
```

Nenhum módulo deve exigir Hub para funcionar.

## Regras anti-monólito

O Hub não deve:
- salvar ItemKit diretamente;
- alterar inventário diretamente;
- calcular compatibilidade de arma;
- calcular desgaste;
- modificar WeaponCondition diretamente fora dos contratos;
- criar estoque/economia;
- manter segunda cópia de Sets;
- implementar whitelist/blacklist.

## Gate inicial futuro

Antes de implementar:
1. congelar contrato de descoberta/abertura de interfaces;
2. definir passagem de contexto entre módulos;
3. criar laboratório com Nexus + dois módulos;
4. provar navegação dinâmica;
5. provar ausência de dependência reversa;
6. somente depois criar ações integradas multi-módulo.
