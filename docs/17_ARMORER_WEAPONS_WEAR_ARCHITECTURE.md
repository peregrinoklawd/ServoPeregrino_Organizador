# Weapons + WeaponCondition + Armorer — identidade, condição e manutenção

Status: **DESIGN PLANEJADO; NÃO IMPLEMENTADO**.

## Decisão de ownership

A arquitetura foi separada em três responsabilidades:

```text
Weapons
= O QUE A ARMA É

WeaponCondition
= COMO A ARMA ESTÁ

Armorer
= ONDE/COMO O JOGADOR INTERAGE COM ELA
```

Essa separação existe para permitir compatibilidade com mods externos e impedir duas implementações concorrentes de desgaste/manutenção.

---

## Weapons — identidade e construção/configuração

Weapons será dono de:

- WeaponInstance;
- serial/instanceId definitivo;
- weaponClass;
- WeaponConfiguration;
- WeaponRecipe;
- compatibilidade de slots;
- compatibilidade de acessórios;
- compatibilidade de magazines;
- montagem/configuração lógica;
- troca dinâmica da arma sem alterar o restante do loadout.

Modelo candidato:

```text
WeaponInstance
  schemaVersion
  instanceId
  serial
  weaponClass
  configuration
  metadata
  createdAt
  updatedAt
```

A identidade continua existindo mesmo quando o módulo WeaponCondition estiver desligado.

### Gate crítico

Antes de congelar WeaponInstance v1, provar que o mesmo `instanceId`/serial pode ser preservado quando a arma passa por:

- inventário do jogador;
- weapon holder/chão;
- container/caixa;
- armazenamento persistente;
- transferência entre jogadores;
- multiplayer/JIP/reconnect, quando aplicável.

---

## WeaponCondition — condição e manutenção lógica

WeaponCondition será dono de:

- usage counters;
- desgaste;
- sujeira;
- lubrificação;
- corrosão;
- condição das peças;
- confiabilidade;
- panes/jams derivados da condição;
- avaliação da necessidade de manutenção;
- transições lógicas de limpeza/lubrificação/reparo;
- provider autoritativo de condição.

Modelo candidato:

```text
WeaponConditionState
  schemaVersion
  weaponInstanceId

  usage
    shotsTotal
    shotsPending
    waterExposurePendingSeconds
    submergedExposurePendingSeconds
    lastEvaluatedAt

  condition
    barrelWear
    actionWear
    fouling
    lubrication
    corrosion
    reliability

  parts[]
    partType
    partClass
    condition
    usage
```

WeaponCondition referencia a identidade fornecida por Weapons; não cria uma identidade paralela.

---

## Provider autoritativo de condição

Objetivo de compatibilidade:

```text
Armorer
   |
   v
weaponcondition.provider
   |
   +-- SP_ORG WeaponCondition nativo
   |
   +-- Adapter para mod externo
   |
   +-- Provider de servidor
```

Regra:

> Para uma mesma arma/sessão existe somente **um provider autoritativo de condição**.

Isso evita que SP_ORG e outro mod calculem desgaste/jams simultaneamente.

Modos conceituais possíveis:
- NATIVE;
- EXTERNAL;
- HYBRID_OBSERVER;
- DISABLED.

Somente um provider pode ser AUTHORITATIVE.

---

## Armorer — bancada e workflow

Armorer será dono de:

- estação/bancada;
- sessão;
- lease multiplayer;
- Preview 3D;
- montagem/desmontagem visual;
- UI de receitas;
- UI de inspeção;
- UI de manutenção;
- fluxo transacional;
- apresentação de resultados.

Armorer consulta Weapons para saber **o que a arma é** e WeaponCondition para saber **como ela está**.

Exemplo:

```text
ARMORER
  |
  +--> Weapons
  |      identidade
  |      compatibilidade
  |      configuração
  |      receita
  |
  +--> WeaponCondition
  |      condição
  |      desgaste
  |      peças
  |      manutenção
  |
  +--> StockProvider (opcional)
  |      disponibilidade
  |
  +--> EconomyProvider (opcional)
         preço/custo
```

---

## Desgaste por disparo

Não calcular/persistir condição a cada tiro.

Evento barato:

```text
Fired/FiredMan
  -> shotsPending += 1
```

A avaliação real ocorre em lote.

Possíveis efeitos:
- barrelWear;
- actionWear;
- fouling;
- recoil spring usage;
- gas system usage;
- suppressor/attachment wear, quando suportado;
- reliability.

A fórmula exata e coeficientes permanecem abertos até profiling/testes de gameplay.

---

## Água / natação / submersão

A exposição ambiental deve ser coletada de forma barata pelo owner local do jogador.

Sinais nativos candidatos já considerados:
- `pose unit` para estados como Swimming/Diving;
- `surfaceIsWater position`;
- `getPosASLW unit`;
- outras leituras de submersão somente após validação em mapas/ponds/modsets.

Não usar `underwater` isoladamente como autoridade de personagem sem validação.

### Estratégia

Não usar `onEachFrame`.

Opção recomendada:

1. somente o owner local monitora quando existir WeaponInstance rastreada;
2. baixa frequência, a ser definida por profiling;
3. acumular segundos de exposição em memória;
4. não recalcular condition a cada amostra;
5. consolidar em checkpoint/threshold.

Exemplo:

```text
waterExposurePendingSeconds += delta
submergedExposurePendingSeconds += delta
```

Depois:

```text
WearEvaluator
  -> lubrication
  -> corrosion
  -> fouling
  -> reliability
```

---

## Partes/componentes

Começar com `PartState`, sem serial próprio obrigatório:

```text
PartState
  partType
  partClass
  condition
  installedAt
  usage
```

Possíveis componentes:
- barrel;
- bolt/carrier;
- recoil spring;
- trigger group;
- gas system;
- suppressor/attachments quando apropriado.

Criar `PartInstance`/serial de peça somente se gameplay/persistência realmente exigirem.

---

## Construção x manutenção

### Construção/configuração

Pertence a Weapons como modelo/validação:

- WeaponConfiguration;
- WeaponRecipe;
- compatibilidade;
- montagem lógica.

Armorer fornece a interface física/visual para esse processo.

### Manutenção da condição

Pertence a WeaponCondition:

- avaliação;
- limpeza;
- lubrificação;
- reparo;
- substituição lógica de componente;
- condição resultante.

Armorer fornece a interface/workflow.

---

## Exemplo: troca de cano

```text
Armorer
  -> WeaponCondition: cano precisa ser trocado?
  -> Weapons: quais canos são compatíveis?
  -> StockProvider: existe peça?
  -> EconomyProvider: qual o custo?
  -> Armorer: usuário confirma
  -> RESERVE
  -> WeaponCondition: cria working condition
  -> Weapons: valida configuração/compatibilidade
  -> COMMIT
  -> PersistenceProvider: persiste, se existir
```

Em falha:

```text
ROLLBACK
+ RELEASE stock
+ REFUND/rollback economy
```

---

## Checkpoints de avaliação

Avaliar/consolidar condição apenas quando útil:

- entrada no Armorer;
- arma trocada/guardada;
- transferência de ownership;
- save/checkpoint;
- disconnect;
- threshold de contadores;
- lote periódico de baixa frequência;
- inspeção solicitada.

---

## Performance invariants

- sem loop por arma;
- sem scan global recorrente;
- sem `onEachFrame` para desgaste de domínio;
- sem DB write por tiro;
- sem broadcast por tiro;
- eventos + dirty flags + batching;
- cálculo lazy;
- authority server-side no commit;
- clientes podem coletar deltas locais, mas não definir condition final autoritativa.

---

## Compatibilidade externa

Adapters poderão mapear sistemas externos para os contratos SP_ORG.

Exemplo:

```text
External Weapon Maintenance Mod
        |
        v
SP_ORG Adapter
        |
        v
weaponcondition.provider
        |
        v
Armorer
```

Assim o Armorer pode permanecer utilizável mesmo quando o servidor preferir outro sistema de condição.

---

## Gates futuros

1. WeaponInstance/serial lifecycle;
2. preservação da identidade em inventário/holder/storage/MP;
3. WeaponConfiguration/WeaponRecipe v1;
4. `weaponcondition.provider` contract;
5. WeaponConditionState v1;
6. coleta de shotsPending;
7. sensor de água/submersão;
8. wear evaluation em lote;
9. parts condition;
10. integração de inspeção no Armorer;
11. manutenção transacional;
12. Stock/Economy/Persistence providers opcionais;
13. adapters externos.
