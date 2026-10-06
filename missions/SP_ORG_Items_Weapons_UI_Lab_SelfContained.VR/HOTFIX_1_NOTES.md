# SP_ORG — Integration Hotfix 1

Data: 2026-10-02.

Esta missão continua FULL SELF-CONTAINED: não carregar PBOs SP_ORG.

## Escopo deliberadamente pequeno

Este pacote NÃO implementa a Weapons 0.6-E R2 visual.
Ele corrige apenas três regressões/UX encontrados no primeiro teste conjunto:

1. Items — falha física agora apresenta a causa do plano.
   - Falha por falta de capacidade: informa que não há espaço suficiente no destino.
   - Falha por classe indisponível: informa indisponibilidade.
   - Remoção sem conteúdo suficiente: informa a causa.
   - RPT passa a registrar rejectCode + availableLoad/currentLoad/maxLoad.

2. Items — fechar a interface com Draft alterado não pede confirmação.
   - O Draft session-local permanece em memória.
   - Confirmação continua existindo para ações destrutivas/substitutivas:
     LOAD_KIT, NEW_DRAFT e DISCARD_DRAFT.

3. Weapons 0.6-E R1 — cold-open.
   - R1 chamava refreshInterface dentro de onLoad antes de findDisplay registrar o dialog.
   - Quando havia zero kits, o handshake aceitava 0/0 e não recuperava Catálogo/Equipamento.
   - Agora aguarda o display real, executa refresh e valida Kit + Catálogo + Equipamento.
   - Novo log: UI_INITIAL_SYNC_HOTFIX1.

## Baselines preservadas

- Weapons runner histórico continua intacto: expectativa 536/536.
- UICommon foundation: expectativa 8/8.
- As alterações são de integração/hotfix; não alteram os requisitos congelados da R2.

## Teste manual principal

A) Abra Items:
- tente enviar um item para um destino sem capacidade suficiente;
- confirme que o rodapé informa o MOTIVO;
- altere um Draft e feche no X;
- não deve haver modal;
- reabra e confirme que o Draft continua alterado.

B) Feche Items e abra Weapons pela PRIMEIRA VEZ após iniciar a missão:
- não clique em nenhum filtro/botão;
- Catálogo deve preencher sozinho;
- Conteúdo do Equipamento deve preencher sozinho;
- RPT deve conter UI_INITIAL_SYNC_HOTFIX1 ok=true.

C) Rode AUTO TEST da Weapons:
- esperado: 536/536.

D) Rode UICommon:
- esperado: 8/8.

Envie o RPT completo.
