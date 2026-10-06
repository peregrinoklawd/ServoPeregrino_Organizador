# Weapons 0.6-F R1 — Final Visual Adaptation / Regression

Data: 2026-10-04.

## Base

Runtime real da 0.6-E R2 HF1:
- 557 PASS
- 1 FAIL
- 558 total

Único FAIL:
`DESCARTAR cancels pending-new without creating kit`.

O repository foi restaurado corretamente e o loadout físico permaneceu imutável; o defeito era a seleção visual após cancelar NOVO.

## Hotfix incorporado

A 0.6-F não cria um Hotfix 2 separado.

Novo estado:
`previousKitIdBeforeNew`

Fluxo:
`kit A -> NOVO -> pending draft -> DESCARTAR -> kit A`

Regras:
- não cria WeaponKit para cancelar;
- restaura exatamente o kit anterior se ele ainda existir;
- se não existir, fica sem seleção;
- ao aceitar a primeira arma do novo kit, o contexto anterior é descartado;
- seleção manual de outro kit também limpa o contexto de restauração.

## Freeze visual 0.6-F

Nenhum redesign amplo foi feito. A 0.6-F congela a linguagem visual já validada na R2 HF1:
- 4 painéis;
- ARMAS DO KIT;
- nome inline + estado;
- ações do draft no topo;
- catálogo contínuo;
- filtros por slot e categoria;
- conteúdo do equipamento read-only;
- footer em 3 faixas;
- focused refresh.

Isso reduz risco de regressão antes da 0.7.

## Items

Sem mudança funcional/visual nesta entrega.
A convergência visual de Items continua separada.

## Próximo gate

Se a 0.6-F fechar:
- AUTO 0 FAIL;
- manual verde;
- performance verde;

então a linha UI/authoring 0.6 é homologada e o próximo checkpoint é:
**0.7 — Slot-Safe Weapon Application**.


## Weapons 0.6-F R4
- preview 2D centralizado com proporção preservada;
- filtros Tipo/Acessório do Catálogo padronizados em largura e gramática compacta;
- testes legados de busca sincronizada substituídos pelo contrato R3 de buscas independentes;
- aplicação física continua em 0.7.
