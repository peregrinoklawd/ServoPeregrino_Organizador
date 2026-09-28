# WeaponCondition — ownership

## Papel

Dono do estado de condição da arma e das transições lógicas de manutenção.

## Planejado

- condition state;
- usage counters;
- shots pending / shots total;
- exposição à água;
- natação/submersão;
- barrel wear;
- action wear;
- fouling;
- lubrication;
- corrosion;
- part condition;
- reliability;
- jams/panes derivados;
- avaliação em lote/event-driven;
- cleaning operation;
- lubrication operation;
- repair operation;
- part replacement state transition;
- provider autoritativo de condição.

## Dependência de identidade

WeaponCondition referencia `WeaponInstance`/serial fornecido por Weapons. Ele não cria uma segunda identidade da arma.

## Armorer

Armorer é consumidor do estado e das operações de manutenção. A bancada exibe e orquestra; WeaponCondition calcula/valida/commita o estado lógico.

## Compatibilidade externa

O desenho deve permitir:
- provider nativo SP_ORG;
- adapter para mod externo;
- provider externo de servidor.

Somente um provider pode ser autoritativo para a condição da mesma arma/sessão.

## Performance

Sem `onEachFrame` para lógica de domínio, sem persistência por tiro e sem scan global de armas. Usar eventos + batching + lazy evaluation.
