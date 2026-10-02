# Items + UICommon Equivalence R1

Data: 2026-10-02.

## Estado

Candidata de Gate 2.

Builds:
- UICommon: `0.1.1-items-equivalence-r1`;
- Items: `0.13.0.1-a-server-authority-foundation-uicommon-equivalence-r1`;
- Weapons permanece na baseline mission-first `0.6.4.1-authoring-lifecycle-session-local-mission-first`.

Esta entrega NÃO é uma rodada de redesign.

## Objetivo

Provar que Items pode começar a consumir infraestrutura compartilhada do UICommon sem perder comportamento, performance ou contratos já homologados.

A regra de sucesso é equivalência:
`Items antes == Items + UICommon depois`, exceto pelos novos markers/diagnósticos da dependência.

## Delta técnico

### UICommon 0.1.1
UICommon passa a possuir:
- escaping genérico de structured text;
- clamp de offset virtual já existente;
- janela virtual já existente;
- foundation tests ampliados de 8 para 12 checks.

Nova função:
- `ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText`.

### Items
Items:
- passa a declarar UICommon em `requiredAddons` no formato PBO;
- valida UICommon no lifecycle;
- publica no runtime que UICommon é obrigatório e qual build está em uso;
- mantém `Items_fnc_escapeStructuredText` como wrapper de compatibilidade;
- usa `UICommon_fnc_clampVirtualOffset` para o clamp da janela do Catálogo;
- ganha `runUICommonEquivalenceTests`.

Nenhuma lógica de domínio foi movida para UICommon.

## Hotfix 1 incorporado ao source oficial de Items

A candidata também carrega os hotfixes já exercitados no laboratório conjunto:
- CLOSE_UI sem modal redundante, preservando rascunho session-local;
- causa de rejeição física player-facing;
- PHYSICAL_FLOW com rejectCode e métricas de capacidade.

## Não muda nesta entrega

Não alterar deliberadamente:
- geometria/layout dos quatro painéis;
- ações e ordem dos botões;
- Draft/Repository/Storage;
- Whole-Kit/Application Engine;
- EXACT;
- DnD/ghost;
- Equipment;
- Public Library;
- áudio;
- authorities de destino;
- Weapons E R1;
- aplicação física de Weapons, ainda 0.7;
- multiplayer/JIP de Weapons, ainda 0.8.

## Mudanças player-facing já aprovadas, mas DEFERIDAS

Entram somente após a equivalência estrutural, em rodada explícita de convergência:
- Items: `Mostrar:` -> `Visualizar:`;
- Items: mensagem `Vasculhando inventário e catalogando itens...`;
- padronização `KIT SELECIONADO / RASCUNHO`;
- estados `SALVO / ALTERADO / NOVO` onde aplicável;
- footer Contexto / Resultado / Histórico compartilhado;
- demais alinhamentos/tokens compartilhados.

O RPT técnico continua livre para registrar `CfgWeapons`, `CfgMagazines`, contadores e tempos.

## Weapons

Weapons permanece byte a byte na baseline E R1 dentro desta candidata de equivalência.

A 0.6-E R2 continua congelada em:
- `docs/32_WEAPONS_0_6_E_R2_UI_FREEZE.md`.

Depois que Items + UICommon fechar equivalência, o próximo gate é implementar Weapons R2 sobre UICommon.

## Testes automáticos esperados

### UICommon
Ação:
`TESTAR UICOMMON`

Esperado:
- **12/12 PASS**.

### Items + UICommon
Ação:
`TESTAR ITEMS + UICOMMON`

Esperado:
- **12/12 PASS**.

Valida:
- funções compartilhadas carregadas;
- wrapper Items mantém escaping anterior;
- caracteres reservados continuam escapados;
- clamp/window compartilhados;
- runtime Items expõe UICommon ready;
- build compartilhado correto.

### Weapons
Runner histórico:
- **536/536 PASS**.

Nenhum teste histórico da Weapons foi alterado.

## Gate manual Items

Usar `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md`.

Smoke mínimo desta candidata:
1. abrir Items;
2. catálogo carregar;
3. busca;
4. wheel;
5. slider;
6. seleção;
7. Draft;
8. fechar/reabrir preservando Draft;
9. DnD Catálogo -> Draft;
10. DnD Catálogo -> Equipment;
11. falha por falta de capacidade mostra motivo;
12. trocar kit sem reconstrução indevida do Catálogo;
13. verificar RPT sem novo erro SP_ORG.

Public Loadouts permanecem pendentes de validação manual específica.

## Gate manual Weapons

Somente regressão:
1. abrir pela primeira vez sem clicar;
2. Catálogo e Equipment devem materializar;
3. `UI_INITIAL_SYNC_HOTFIX1 ok=true`;
4. AUTO 536/536.

## Critério de homologação

Equivalence R1 só fecha quando:
- UICommon 12/12;
- Items+UICommon 12/12;
- Weapons 536/536;
- checklist manual mínimo de Items sem regressão;
- performance igual ou melhor que a baseline;
- nenhum novo erro SP_ORG no RPT.

Depois disso:
1. Gate 3 — Weapons 0.6-E R2 sobre UICommon;
2. depois rodada explícita de convergência visual de Items.


## Resultado de runtime — APROVADA PARA ITEMS

RPT recebido em 02/10/2026:
- UICommon foundation: **12/12 PASS**;
- Items + UICommon Equivalence R1: **12/12 PASS**;
- uso manual extenso de Items sem regressão funcional reportada:
  - troca de kits;
  - DnD KIT -> Draft;
  - DnD Catalog -> Draft;
  - DnD Catalog -> Equipment;
  - botões de transferência;
  - + / - / quantidade;
  - busca/filtro;
  - wheel;
  - slider;
  - U/C/M de visualização;
  - U/C/M de destino;
  - ADD / REMOVE / REPLACE físico;
  - resultado PARTIAL;
  - falta de capacidade com causa exposta.

Decisão:
- **Gate de equivalência Items + UICommon R1: APROVADO para o escopo Items**.
- Este RPT não contém nova abertura nem AUTO TEST da Weapons; portanto a Weapons não é re-homologada por esta execução.
- A baseline Weapons E R1 continua sendo a homologação anterior de 536/536.

Artefatos recebidos:
- RPT SHA-256: `83f576ba34822ef3edc41fb9ff519fda1f6c250d7bc5964e30f3774ff805530b`;
- missão multiplayer R3 PBO SHA-256: `54c7eaf968f5bb1d0bb35ccb11f80e795a14c030696b70f53886000d3fe8325a`.

Observação sobre baseline visual:
- o PBO recebido é o PBO da **missão multiplayer R3**, não o addon Items;
- contém somente a missão e invoca as funções do addon carregado externamente;
- portanto ele NÃO contém `items_dialog.hpp` nem o runtime visual do Items;
- a discrepância de transparência entre a missão atual e o último addon/PBO homologado permanece aberta;
- até recuperar o addon/packaging real, o source atual não deve ser tratado como baseline visual definitiva.


## Reconciliação com o addon PBO homologado — 02/10/2026

Artefato recebido:
- `MODS.rar` SHA-256: `5be99befbcddf7e6cac996c47b07a12a344f21300dc5f42fb75b74ce21a8c133`
- `ServoPeregrino_Organizador_Items.pbo` SHA-256: `0b9ad341f74bbfbd67f9180895365122275a0496eb95b7d312f73511d8b47b0e`
- tamanho do addon Items PBO: 3.802.477 bytes
- arquivos extraídos do addon: 257

Resultado da comparação com a missão Equivalence R1:
- 249/257 arquivos do addon existem na missão e são byte-equivalentes após normalizar CRLF/LF;
- 7 diferenças são exatamente os deltas intencionais desta rodada:
  - script_version.hpp;
  - lifecycle initialize;
  - executeUITransferCommand;
  - requestDraftTransition;
  - getUICatalogWindow;
  - escapeStructuredText;
  - classifyUIOutcome;
- config.cpp do addon não existe como arquivo local na missão, pois a missão registra as classes no description.ext.

Arquivos visuais confirmados IDÊNTICOS entre addon PBO homologado e missão Equivalence R1:
- `ui/items_dialog.hpp`;
- `fn_refreshInterface.sqf`;
- `fn_refreshDraftMutationUI.sqf`;
- `fn_renderCatalogRowsUI.sqf`;
- `fn_refreshHeaderUI.sqf`;
- demais renderers inspecionados.

Conclusão:
- a hipótese de que ajustes finais de transparência ficaram apenas dentro do PBO NÃO foi confirmada;
- o source visual do PBO é o mesmo source visual usado na missão;
- a diferença visual percebida deve ser investigada como diferença de contexto de carregamento/renderização (addon config.cpp vs mission description.ext, interação de configuração, ambiente ou outro fator), não como versão anterior do items_dialog.hpp;
- NÃO alterar transparências até reproduzir e isolar a causa.
