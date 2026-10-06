# Política de Estabilidade dos Testes Automatizados de UI

Data: 05/10/2026.

## Motivação

Durante Weapons 0.6-F, vários reruns falharam sem regressão funcional porque os testes estavam acoplados a:
- texto literal do header;
- número da revisão;
- schema marker com nome da candidata;
- labels que mudaram deliberadamente durante polish.

Esses checks geram ruído e aumentam o custo de evolução sem proteger comportamento real.

## Regra

Um teste automático deve falhar por mudança de:
- comportamento;
- contrato de dados;
- invariantes;
- segurança;
- ownership;
- layout quando o layout é requisito explícito;
- performance quando performance é gate;
- mutação indevida.

Não deve falhar apenas porque mudou:
- versão exibida;
- número de release;
- nome da candidata;
- texto cosmético não contratual.

## Versão e build

Versão, semantic version e build string continuam obrigatórios em:
- buildInfo;
- logs;
- RPT;
- artefatos;
- documentação de release.

Mas não são, por si só, um gate de comportamento de UI.

## Aplicação imediata

A regra passa a ser aplicada agora, antes da Weapons 0.7.

No RPT C2 de 06/10/2026, Weapons terminou 596/598 porque dois checks antigos ainda comparavam:
- o texto exato de `UI state version`;
- a presença literal de `0.6-F R6` no header.

Esses checks não representam comportamento e foram corrigidos no commit
`7933fbb8a1838bf817c0b809834b8cf105eb6932`.

A partir desse commit:
- estrutura/comportamento continuam em `_assert` e podem falhar;
- versão, revisão, header de release e identificadores de apresentação usam `_observe`;
- observações são registradas como `AUTO_TEST_INFO`, não entram em PASS/FAIL;
- o resultado automático só pode ser aceito com **0 FAIL**.

O runner também deixou de bloquear por `uiCheckpoint`, `uiRevision`, `uiVisualFreeze` e pelo nome textual do grammar de filtros. A geometria e o comportamento reais desses filtros continuam cobertos por asserts funcionais.

## Escopo

Aplica-se a:
- Items;
- Weapons;
- UICommon;
- futuros módulos player-facing.
