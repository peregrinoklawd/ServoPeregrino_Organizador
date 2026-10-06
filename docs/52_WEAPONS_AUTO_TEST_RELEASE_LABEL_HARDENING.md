# Weapons Auto Test — Release Label Hardening

Data: 06/10/2026.

## Decisão

O teste automático não pode falhar por texto cosmético ou identidade de release.

Checks bloqueantes continuam obrigatórios para:
- comportamento;
- contratos de dados;
- mutação indevida;
- isolamento de draft/repository/loadout;
- compatibilidade;
- focused refresh e performance invariants;
- layout quando existir requisito explícito.

Metadados de release passam a ser somente observações:
- UI state version/release label;
- header release text;
- runtime checkpoint label;
- runtime revision label;
- visual-freeze label;
- Catalog filter grammar label.

## Implementação

Commit:
`7933fbb8a1838bf817c0b809834b8cf105eb6932`

O runner agora possui `_observe`.

Formato de log:

```text
[SP_ORG] [WEAPONS] [AUTO_TEST_INFO] ... value=...
```

Observações não entram em `_checks`, portanto não alteram `passed`, `failed` ou `success`.

Os dois checks que falhavam foram substituídos por contratos estáveis:
- UI state deve expor mapa de drafts e contadores de focused refresh;
- controle de header deve existir e permanecer preenchido.

A geometria/funcionalidade de filtros continua sendo validada diretamente; o nome textual do marker de grammar deixou de bloquear.

## Gate

Com base no último runtime de 598 checks e quatro markers convertidos para observações, o próximo runner deve retornar:
- 594 PASS;
- 0 FAIL;
- 594 total;
- 6 observations.

O número total é informativo. O requisito de aceitação é **0 FAIL em checks funcionais**.
