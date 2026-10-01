# SP_ORG Items + Weapons UI Lab

Laboratório mission-first compartilhado criado durante a fundação UICommon 0.1.

## Objetivo
- validar UICommon isoladamente;
- abrir a baseline atual de Items;
- receber a UI mission-first de Weapons sem duplicar implementação;
- comparar as duas interfaces na mesma missão/sessão;
- testar modularidade: ausência de um produto não impede o outro de inicializar.

## Estado inicial
- UICommon: foundation 0.1.
- Items: usa o addon atual; ainda NÃO foi migrado para UICommon.
- Weapons: o addon integrado no monorepo ainda é 0.1-A; a UI 0.6 mission-first não está materializada nesta pasta neste checkpoint.

Por isso a ação ABRIR WEAPONS informa explicitamente quando `ServoPeregrino_Organizador_Weapons_fnc_openInterface` não existe. Não substituir a candidata 0.6 por uma interface 0.1-A.

## Ações
- ABRIR ITEMS
- ABRIR WEAPONS
- TESTAR UICOMMON
- STATUS MODULOS

As ações históricas de teste de Items também são instaladas quando o addon expõe `installTestActions`.

## Regra
Este laboratório não possui domínio. Ele apenas inicializa/chama os entry points dos módulos presentes.
