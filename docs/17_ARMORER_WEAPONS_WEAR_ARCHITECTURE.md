# Weapons + Armorer — identidade, desgaste e manutenção

Status: **DESIGN PLANEJADO; NÃO IMPLEMENTADO**.

## Objetivo

Permitir armas individuais com serial definitivo, desgaste por uso/ambiente e peças com condição, sem processamento contínuo caro.

## Ownership

- **Weapons**: WeaponInstance, serial, configuração, condição, desgaste e peças.
- **Armorer**: estação, sessão, inspeção, manutenção, substituição, preview e workflow transacional.
- **Nexus**: capabilities/contracts/events.
- **Policy**: allow/deny opcional.
- **ServerIntegration**: Persistence/Stock/Economy opcionais.

## WeaponInstance

Modelo candidato:

```text
WeaponInstance
  schemaVersion
  instanceId
  serial
  weaponClass
  configuration
  conditionState
  usageState
  parts
  metadata
  createdAt
  updatedAt
```

O servidor deve criar a identidade definitiva quando persistência autoritativa estiver habilitada.

## UsageState

Acumular deltas baratos; não persistir a cada evento:

```text
shotsPending
waterExposurePendingSeconds
submergedExposurePendingSeconds
mud/dust exposure (futuro)
heatCyclesPending (futuro)
lastEvaluatedAt
```

## Desgaste por disparo

Usar evento local do jogador para acumular `shotsPending`. A avaliação real pode ocorrer em lote.

Não calcular/persistir condition a cada tiro.

## Água / natação

A leitura ambiental deve ser barata e local.

Sinais nativos candidatos:
- `pose unit`: distingue `Swimming`, `SurfaceSwimming`, `Diving`, `BottomSwimming`, etc.;
- `stance unit`: retorna `UNDEFINED` em situações como natação, útil apenas como fallback;
- `surfaceIsWater position`: confirma água no XY;
- `getPosASLW unit`: posição relativa à superfície da água, incluindo ondas/ponds;
- `underwater object`: existe, mas a própria documentação alerta que é mais confiável para mini-submarinos; não usar sozinho para pessoas;
- `eyePos player select 2 < 0`: alternativa documentada para cabeça submersa no mar; validar comportamento em ponds/mod maps antes de congelar contrato.

## Estratégia de amostragem

Não usar onEachFrame.

Opção recomendada:
1. somente o cliente/local owner do jogador mantém um sensor ambiental leve;
2. intervalo baixo, por exemplo 2–5 s, apenas se existir WeaponInstance rastreada;
3. consulta `pose` + água/submersão;
4. acumula segundos em memória;
5. envia/persiste apenas em threshold/checkpoint/transferência/Armorer/disconnect.

A frequência exata deve ser medida em teste; não congelar número antes de profiling.

## Fórmula

Não fixar constantes ainda. O modelo deve permitir componentes independentes:

```text
barrelWear      <- shots, ammo, heat cycles
actionWear      <- shots/cycles
fouling         <- shots + environment
lubrication     <- use + time + water
corrosion       <- water/submersion + protection + time
reliability     <- função dos estados acima
```

Água salgada/do mar pode futuramente ter multiplicador maior que água doce somente se conseguirmos identificar o contexto de forma confiável e barata.

## Parts

Começar com part definitions por tipo, sem serial individual obrigatório.

```text
PartState
  partType
  partClass
  condition
  installedAt
  usage
```

Somente criar `PartInstance` com serial próprio se gameplay/persistência realmente exigir.

Possíveis partes:
- barrel;
- bolt/carrier;
- recoil spring;
- trigger group;
- gas system;
- suppressor/attachment wear, quando suportado.

## Checkpoints de avaliação

- entrada no Armorer;
- arma trocada/guardada;
- transferência de ownership;
- save/checkpoint;
- disconnect;
- threshold de contadores;
- lote de baixa frequência.

## Transação de manutenção

```text
READ CURRENT STATE
  -> BUILD WORKING STATE
  -> QUOTE / RESERVE PARTS (optional)
  -> APPLY / VALIDATE
  -> COMMIT
  -> RELEASE
```

Falha:
```text
ROLLBACK weapon state
+ RELEASE stock
+ REFUND/rollback economy when applicable
```

## Performance invariants

- sem loop por arma;
- sem scan global de armas;
- sem DB write por tiro;
- sem broadcast por tiro;
- aggregation/batching;
- authority server-side no commit;
- clientes podem coletar deltas locais, mas não definir condition final autoritativa.

## Gates futuros

1. definir serial/instance identity lifecycle;
2. provar como uma instância é preservada ao mover arma entre inventários/holders/armazenamento;
3. definir schema v1 de WeaponInstance;
4. laboratório de 1 jogador;
5. multiplayer ownership transfer;
6. water exposure sensor;
7. wear calculation batch;
8. Armorer inspection;
9. parts/repair transaction;
10. persistence/stock/economy providers opcionais.
