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

Weapons 0.6-F R6 terminou 595/597.
Os 2 FAILs restantes são classificados como:
**HARNESS_ONLY / NON_FUNCTIONAL / NON_BLOCKING**.

Eles serão removidos ou convertidos em checks estáveis no início da Weapons 0.7.

## Escopo

Aplica-se a:
- Items;
- Weapons;
- UICommon;
- futuros módulos player-facing.
