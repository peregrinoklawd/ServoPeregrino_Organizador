# CONTINUIDADE AUTOSSUFICIENTE — SP_ORG Items + UICommon + Policy

**Data de corte:** 22/10/2026  
**Repositório oficial e SOURCE OF TRUTH:** `peregrinoklawd/ServoPeregrino_Organizador`  
**Status:** DOCUMENTO DE HANDOFF para iniciar outro chat **sem depender do histórico desta conversa**.  
**AVISO:** É um mapa de fontes e decisões, **não** homologação nova nem autorização para implementar a próxima etapa automaticamente.

> **Leia este documento do início ao fim antes de programar.** Não use estado de `main`, textos cronológicos antigos ou lembranças de Weapons para reconstruir o Items. Para detalhes e comprovação consultar [auditoria completa](73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md).

---

## 0. Instrução operacional imediata ao novo chat

O usuário quer continuar o desenvolvimento do **Servo Peregrino Organizador (Arma 3)**. A conversa anterior fechou **Items/UICommon R2.2 no escopo single-player**, registrou três imagens finais para ícones mas **suspendeu os botões gráficos**, e aprovou o planejamento de um **módulo Policy opcional** (whitelist/blacklist) e um **Policy Editor** para editar/importar/exportar listas e atualizar caches. No instante deste handoff, **Policy é somente documentação; não existe addon Policy implementado**.

**Próxima frente recomendada, mas ainda não iniciada:** **Policy P0 — contratos, fontes de configuração e estudo técnico de import/export**. Somente depois P1 motor puro. **Não iniciar integração Items/Policy P3** antes dos contratos. **Não criar botões novos em Items/Weapons**.

Na nova conversa:
1. Abrir GitHub, conferir head das refs abaixo e ler este documento + audit + Policy + roadmap.
2. Se o usuário pedir para continuar, trabalhar em branch própria de Policy (a criar então), preservando a base R2.2 homologada.
3. Diferenciar claramente especificação vs código runtime, testes automáticos vs SP manual, e teste SP vs MP.
4. Não precisar pedir ao usuário de novo decisões já fechadas aqui.

## 1. Refs e integridade — não confundir branches

**GitHub:**
- Repo: `https://github.com/peregrinoklawd/ServoPeregrino_Organizador`
- **Branch de documentos/ícones/plano atual:** `feature/items-ui-icons-r1-simple-silhouettes`. Ela contém as **fontes PNG aprovadas**, documentos Policy e o roadmap. Depois da R2.2, não houve mudança de código `addons/` ou `missions/` nessa branch até o corte.
- **Baseline de runtime Items/UICommon R2.2 homologada SP:** `baseline/items-uicommon-r2-2-sp-homologated-20261021`, commit de referência `67f457414c37784ef0469e7235d39006342edb40`. **Não modificar esta ref.**
- **Baseline anterior UICommon 0.2 FINAL (07/10):** `baseline/uicommon-0.2-final-homologated`, UICommon `0.2.0.10`. Fallback histórico de regressão, não substitui R2.2.
- Branch anterior de Items UX R1: `feature/items-0.13-retomada-20261021`.
- Branch de R2 header/footer: `feature/items-uicommon-brand-footer-r2-20261021`.
- Branches de Weapons são **separadas**; não fazer merge/cherry-pick não solicitado.
- **`main` e `machine/PROJECT_STATE.json` podem conter checkpoints mais antigos** de Items e Weapons; não são fonte de verdade para homologação R2.2 ou as decisões 22/10.
- **Nenhum merge de R2.2/Policy na main foi executado nesta conversa.** Criações/alterações desta auditoria foram apenas arquivos `docs/` e `machine/`.

**Arquivos de leitura prioritária (links relativos ao repositório):**
1. `docs/74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md` — este handoff.
2. `docs/73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md` — checklist de cobertura e correção de inconsistências.
3. `docs/70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md` — gate real de Items R2.2.
4. `docs/ITEMS_CONTINUIDADE_RETOMADA_20261021.md` e `docs/ITEMS_ROADMAP_RETOMADA_20261021.md` — história, MP pendente e gates.
5. `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md` — regressão Items, com nota de supersessão para funcionalidades já implementadas.
6. `docs/modules/Policy.md` — contrato funcional e regras de negócio aprovadas.
7. `docs/projects/policy-editor/README.md` e `docs/projects/policy-editor/ROADMAP.md` — projeto e P0–P7.
8. `machine/POLICY_EDITOR_PLANNING_20261022.json`, `machine/ITEMS_CONTINUITY_20261021.json`, `machine/MODULE_MATRIX.json`, `machine/FEATURE_OWNERSHIP.json` — status rastreável.
9. `docs/72_BACKLOG_ICONOGRAFIA_MODULOS.md` e `assets/ui/icons/items/approved/SELECTION_20261021.json` — ícones e pausa.

**Regra de documentação:** se arquivos anteriores se contradizem com esta continuidade e as notas de supersessão, considerar o carimbo temporal e os testes mais recentes. Não reabrir CAPTURAR, correção do logo/footer ou ícones sem pedido.

## 2. Items: estado comprovado e comportamento da interface

### 2.1 Marcos

- **Items 0.12 FINAL — Integration Freeze:** marco histórico manualmente aprovado.
- **Items 0.13-A** — semantic `0.13.0.1`, build `0.13.0.1-a-server-authority-foundation`; código de autoridade da biblioteca pública no servidor existe, porém **PBO e smoke MP completo com host+outro cliente NÃO homologados**. Bibliotecas públicas atuais no escopo da 0.13-A são de **sessão**, sem JIP/persistência de servidor completos.
- **UICommon 0.2.0.10** homologada 07/10; equivalência Items+UICommon 16/16 testes na etapa indicada, diferente de aprovação Public Library MP.
- **Items UX R1** aprovada manualmente SP: CAPTURAR com diálogo e substituição de draft, linhas laranja de alterações vs baseline salvo.
- **R2.2** aprovada manualmente SP após print/RPT: logo BGD no header e HISTÓRICO roxo estável, aviso de path inválido eliminado. UICommon candidato `0.2.0.11-header-brand-slot-r2-candidate` validado neste escopo; **não** chamar de release MP/PBO FINAL.
- Missão usada na homologação: `SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix.VR`, derivada de `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`. Usar estrutura mission-first para novas entregas rápidas e paridade com addon; pacote precisa de seu próprio teste SP.

### 2.2 Layout aprovado — manter

Items usa quatro painéis: **MEUS KITS DE ITENS**, **ITENS DO KIT**, **CATÁLOGO DE ITENS**, **CONTEÚDO DO EQUIPAMENTO**. Header com logo BGD; rodapé **CONTEXTO/RESULTADO/HISTÓRICO**. Preferências de texto atuais: `Qual o destino?`, `Visualizar:`, statuses `SALVO/ALTERADO/NOVO`; manter footer roxo. Botões **apenas com texto**, não implementar iconografia agora.

Fluxos distintos de Items:
- **MEUS KITS:** PRIVADOS/PÚBLICOS; não misturar biblioteca privada com snapshots públicos server authority.
- **Rascunho (ITENS DO KIT):** adicionar, alterar quantidades, salvar/salvar como novo/descartar; DnD e foco; **laranja** nas linhas que divergem do snapshot persistido, com lógica própria Items.
- **CAPTURAR:** ação de CONTEÚDO DO EQUIPAMENTO. Abre diálogo; cancelar não muda nada; confirmar substitui somente `entries` do draft pelas entradas capturadas do equipamento **em visualização**, preservando identidade/nome/destino/preferências/baseline do kit EDIT/NEW; se sem draft cria NEW; não faz merge; não escreve no repository antes do SALVAR, não modifica inventário físico e falha não destrói draft. Sucesso e cancelamento previamente testados UX R1.
- **Destino físico vs conteúdo visualizado:** `APP_TARGET` nos botões `2111/2112/2113` (UNIFORME/COLETE/MOCHILA) e `EQUIPMENT_VIEW` nos botões `4110/4111/4112` são conceitos independentes; nunca fazer seleção de P4 alterar P2. A seleção de conteúdo é usada por CAPTURAR.
- **Fechar Items:** preservar draft em memória na sessão, sem confirmação redundante apenas para fechar.
- **Catálogo:** `CONFIG_ALL` via `CfgWeapons` e `CfgMagazines`; busca/categorias/scroll virtualizado, refresh focal sem recapturar equipamento quando desnecessário.
- **Aplicação:** motor físico com planning `BEST_EFFORT`/`STRICT`, razões de rejeição, capacidade U/C/M e rollback; na evolução Policy manter ADD/REMOVE seguros, preflight SUBSTITUIR/CLEAR. **Não** confundir validação de classe presente com autorização Policy.

### 2.3 Evidências e performance

RPTs de 21/10, em modset grande, relataram:
- `CONFIG_ALL` em torno de **73.470 configs visitadas** e **7.092 itens elegíveis**; duração inicial ~**24–27 s**.
- Refresh focado de catálogo **10–14 ms**, sem rebuild.
- Bug original logo: `Picture items\data\bgd_logo_ca.paa not found`. Resolvido por `getMissionPath` e `ctrlSetText` em `fn_refreshHeaderUI.sqf`.
- R2.1 logo visível mas `fileExists` com path absoluto causava `Invalid path (only relative paths supported)`. Removido R2.2. RPT com `[SP_ORG] [ITEMS] [BRAND_HEADER] pathAssigned=true source=MISSION`, sem warning anterior.
- Bug footer: `fn_refreshPhysicalTargetUI.sqf` escrevia HISTÓRICO cinza `#81918E` no IDC 5002; corrigido via `ServoPeregrino_Organizador_UICommon_fnc_renderFooter`, título `#B9A3E8`, corpo `#D1C2F0`.
- Avisos encontrados em funções CBA/mods externos no RPT **não devem ser atribuídos a Items sem prova**.

**Logo:** fonte no repo `RicGonzalezb/bgd-hq`, caminho `comunicacao-social/identidade/assets/bgd-logo-primary.png`; cópia byte-idêntica `assets/branding/bgd/bgd-logo-primary.png` SHA blob `2916a99374ca8d13602dd7034ede7e2b84000294`; derivado PAA para Items addon e mission; controle genérico `SPORG_UICommon_HeaderBrand` criado no UICommon, porém asset é do Items, IDC 107. Não injetar logo BGD automaticamente em Weapons. Guias BGD Watch para QA arte: `development/guides/VISUAL_ASSET_PRODUCTION.md` e `development/projects/bgd-environmental-kit/docs/PAA_PRODUCTION_PIPELINE.md`. Render comprovado no engine, não alegar ImageToPAA oficial quando o derivado foi convertido por ferramenta alternativa.

### 2.4 Pendências Items ainda reais

**Aberto ou pendente de implementação:**
- UI de nome de kit **vermelho para classe de mod ausente** e linha indisponível vermelha, mesmo sem Policy; observar diagnóstico de peso/nome.
- Após implementar Policy: amarelo para entrada restrita mas disponível, filtragem do catálogo normal, cache de diagnósticos dos kits, aplicação parcial conforme blacklist/whitelist e cores concorrentes.
- `UX-ITEMS-03` microtextos/tooltips desatualizados.
- Semântica do status **ALTERADO** ao modificar e depois restaurar tudo ao snapshot salvo (não confundir com a linha laranja já implementada); requer estudo.
- Tempo inicial do CONFIG_ALL em modsets grandes; cache e benchmark, sem perda de catálogo.
- Whole-Kit, substituição destrutiva/rollback e condições físicas devem preservar não regressão quando Policy for integrado.
- Biblioteca pública 0.13-A: instalação addon/PBO load gate real, dois clientes/snapshot revision/publish/update/cópia privada; testes com outro jogador, ainda indisponível.
- Evoluções **0.13-B JIP**, **C persistência/recovery**, **D ACL/concurrency**, **E soak large-modset**, **F contratos Nexus**; 0.13 FINAL/1.0 não entregue.
- **Ícones gráficos estão pausados**; não transformá-los em prioridade atual.

**Observação ambiental:** no print do usuário, kits com mods desativados exibiam `n/d` e `peso ?`. O usuário atribui a causa à remoção deliberada dos mods de sua modlist. O Items **já** tem `fn_validateItemEntryEnvironmental.sqf`, usando `isClass` em CfgWeapons/CfgMagazines para `ITEMS_CLASS_UNAVAILABLE`; reutilizar essa verificação, não confiar somente no texto `n/d`.

## 3. Policy — decisões fechadas de produto e escopo

### 3.1 Ownership e optionalidade

- Proprietário único: futuro **`ServoPeregrino_Organizador_Policy`**. Estava planejado antes desta conversa em `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`, `machine/MODULE_MATRIX.json`. **Não está implementado**.
- Dependência técnica prevista do Policy apenas `Nexus`. **Items, Weapons, Equipment** podem consumi-lo via capability opcional; não embutir engine de blacklist no Items, nem lógica de domínio no UICommon.
- **Funciona com ou sem BGD/FTAC/Role Kits**. Sem Policy/configuração: comportamento padrão OPEN para classes elegíveis do modset. Não tentar descobrir blacklists escondidas dentro de todos os mods do servidor. Integração BGD futura deve ser adapter opt-in.
- O usuário está inclinado a **não restringir o equipamento por papel**. Permissões dependentes de Role Kit ficam explicitamente **fora do MVP** e podem nem ser implementadas; registrar como hipótese não obrigatória.

### 3.2 Matriz de autorização aprovada

| Whitelist | Blacklist | Resultado |
|---|---|---|
| `[]` | `[]` | OPEN: permitir classes existentes/elegíveis |
| `[]` | preenchida | tudo exceto blacklist |
| preenchida | `[]` | somente classes da whitelist |
| preenchida | preenchida | **(whitelist − blacklist)**, conflito **DENY vence** |

Somente classnames exatos no primeiro contrato v0.1. Base class, addon, categoria, tag, padrões por mod = ideias futuras. Não tratar whitelist vazia como bloqueio total nem blacklist vazia como permissão de ignorar whitelist preenchida.

### 3.3 Origem da configuração — duas perguntas diferentes

**O usuário respondeu à autoridade**, não escolheu ainda a técnica concreta de armazenamento:

1. **Política interna do próprio Policy addon:** fallback com listas vazias (OPEN), entregue junto ao addon em localização configurável e conhecida; **nome exato/caminho, p.ex. `CfgSPORGPolicy`, ainda é sugestão não decidida**.
2. **Política fornecida pelo servidor/missão:** explicitamente configurada por operador/admin em ponto de entrada documentado pelo Organizador; não obrigatória, não procurar em terceiros. Fonte concreta/config/arquivo/provider e serialização são **P0 EM ABERTO**.
3. **Quem manda:** em servidor MP, o cliente comum **não** altera efetivamente whitelist/blacklist; somente administrador reconhecido **pelo servidor**. Cliente pode criar/editar/exportar **lista local não ativa**. Em SP o jogador local representa a autoridade.
4. **Precedência de origem de trabalho proposta:** revisão ativa publicada pelo servidor > config explícita servidor/missão > fallback do addon. Validar o mecanismo em P0/P2 antes de declarar implementado.
5. **Política estática por padrão:** listas BGD são definidas antes da abertura do servidor; **não precisa checar blacklist inteira a cada ação nem mudar durante a partida**. Futuramente pode haver publicação de revisão ativa por admin, mas isso é recurso opcional e precisa de testes MP/JIP.
6. **Quando política obrigatória está sincronizando:** não presumir OPEN e permitir operação protegida até conhecer o snapshot; quando nenhuma política é exigida, OPEN é comportamento correto.

### 3.4 Catálogos, caches e atualização

- **Catálogo base:** identificar todos os itens elegíveis do modset (sem filtrar Policy), uma vez por modset/build. Preservar metadados para o editor, inclusive de itens proibidos.
- **Catálogo jogador:** projeção filtrada por autorização (proibidos ocultos). O usuário considerou mais adequado **excluir os itens proibidos do catálogo apresentado**, em vez de renderizar todos com `active=false`; isso não significa destruir o catálogo base.
- **Editor:** visão de **todos** os itens elegíveis dos mods ativos, inclusive os atualmente restritos, para permitir marcá-los e desmarcá-los.
- **Índice HashMap por classname**: decisão rápida em memória. Não revarrer dezenas de milhares de configs ao abrir/trocar aba/clicar/mover.
- **Diagnóstico de kits:** classificar na primeira abertura conforme necessário e guardar cache por kitId/snapshot e revisão de política/modset; não recalcular a cada frame. Reclassificar kit quando foi editado, salvo, duplicado, trocado ou quando a política publicada mudar.
- **Execução física:** continuar lookup barato no índice/revisão atual para proteger contra pedidos fora da interface e versões stale. Em MP servidor valida.
- **Atualização inicial:** automática na inicialização da sessão/primeira utilização; não exigir clique.
- **Botão `ATUALIZAR CACHE` do jogador:** disponível a qualquer momento (quando implementado), solicita revisão atual, invalida/reconstrói **somente projeção de autorização/diagnóstico de kit**, não altera lista ativa, nem dispara `fn_invalidateCatalogCache.sqf` indiscriminadamente. Esta função Items **existe** mas apaga cache base e força novo scan; requer mecanismo focal novo.
- **Atualização admin opcional:** ativa nova revisão autoritativa se implementada, sincroniza clientes; escolha de **exibir ou não notificação visual** é do admin, mas a segurança aplica atualização mesmo sem popup. `RECONSTRUIR CATÁLOGO DE MODS` seria comando *separado* e caro.
- **Impacto esperado:** grande parte do ~24–27 s inicial decorre de scanner/metadados CONFIG_ALL; filtrar por lista é barato, mas não prometer speed-up grande sem benchmark com modset igual.

### 3.5 Kits preservados, operações e semântica

- **Nunca apagar/regravar kit privado/público automaticamente** porque política mudou ou mod foi removido. Item pode estar indisponível nesta sessão e voltar em outra. Não definir `ALTERADO` só por mudança de regra.
- **Abrir para editar**: conservar todas as entradas e quantidades inclusive restritas/ausentes, com alerta individual.
- **Copiar/combinar para outro draft**: pode mover apenas itens elegíveis conforme operação, sem apagar originais; informar quantidades não copiadas e por quê. Preservar íntegra do draft/kit origem.
- **Aplicar fisicamente (ADD / Whole-Kit)**: somente classes disponíveis e permitidas; ainda respeitar capacidade, contêiner/slot, compatibilidade; aplicação parcial `BEST_EFFORT` com relatório aplicado/rejeitado por motivo (restrição, ausente, capacidade).
- **REMOVER** itens do inventário ou de um kit: blacklist não pode impedir remoção voluntária.
- **SUBSTITUIR/CLEAR**: não deixar filtros da blacklist causarem limpeza inesperada de conteúdo físico; preflight/rollback ou confirmação explícita segura, entrega própria.
- **API Policy futura:** `PolicyDecision` (allowed/reason/matchedRule/source/subjectType + revisão); `PolicySnapshot` com whitelist/blacklist/version/authoritative; nomes e schema definitivos ainda não congelados.
- **Autorização de classe existente** é distinta da existência ambiental. `fn_validateItemEntryEnvironmental.sqf` já verifica a existência, **não** permissões Policy.

### 3.6 UX e prioridade de estados

**Cores aprovadas**:
- **Normal:** disponível/autorizado.
- **VERMELHO:** mod/classe indisponível na modlist, sentido PARE.
- **AMARELO:** item disponível porém proibido por lista, sentido ATENÇÃO.
- **LARANJA:** linha do draft alterada em relação ao SALVO (já existe).
- **VERDE:** feedback de sucesso; **ROXO:** label HISTÓRICO; ambos devem continuar visivelmente distintos.

**Nome do kit em MEUS KITS DE ITENS:**
- Todos autorizados/existentes → normal.
- Um ou mais proibidos, nenhum ausente → **AMARELO**.
- Qualquer classe ausente (mesmo com proibidos e permitidos juntos) → **VERMELHO**.

**Linhas ITENS DO KIT:**
- Classe inexistente → **VERMELHO**; restrita mas instalada → **AMARELO**; somente editada → **LARANJA**.
- Item simultaneamente **ausente+restrito+alterado**: **VERMELHO prevalece**, mas motivos múltiplos acessíveis em tooltip/feedback.
- Item simultaneamente **restrito+alterado (sem ausência)**: amarelo como **proposta a validar visualmente**, sem perder informação de modificação; **não chamar homologado** antes de estudo de contraste.
- Cores de bordas, mensagens e status devem ser distinguidas; teste com paleta real em 1080p/ultrawide.
- O usuário cogitou substituir cores por símbolos de estado nos kits/linhas, porém decidiu **manter cores por enquanto**. Não implantar ícones de estado sem autorização.

**Observação:** `n/d` / `peso ?` são sintomas concretos vistos quando o usuário desativou mods, mas o sistema deve confirmar `isClass` para pintar com precisão e não usar essa string como sinal único.

## 4. Policy Editor: projeto de ferramenta administrativa futura

Criar interface própria (em Policy ou frontend independente — packaging **EM ABERTO**), capaz de mostrar **catálogo completo dos mods ativos** e de manter lista local de whitelist/blacklist com botões:

`ADICIONAR À WHITELIST`, `ADICIONAR À BLACKLIST`, `REMOVER`, `LIMPAR`, `IMPORTAR`, `EXPORTAR`, `ATUALIZAR CACHE`, `VALIDAR`; **`ATIVAR/PUBLICAR POLÍTICA` e eventual `NOTIFICAR JOGADORES` são exclusivos do admin autenticado em servidor**.

- Exportar/importar lista de classnames de forma portátil e versionada, com validação de formato/duplicatas e prévia de diferenças; **nunca executar `compile` em texto recebido**.
- **Player comum** pode preparar/exportar lista, não ativa no servidor. O editor deve informar claramente `LISTA LOCAL / NÃO ATIVA`.
- **Admin** (futuro) pode publicar novo snapshot/revision e escolher aviso, sem interferir na sincronização obrigatória de segurança.
- **Botão local de atualização** deve refletir revisão corrente e reclassificação de kits mesmo que administração não emita aviso.
- Import/export: **experimentar limitações reais do Arma** quanto a clipboard e acesso a arquivo externo, especialmente multiplayer; *não* presumir leitura/escrita arbitrária de arquivos via SQF. Método definitivo pendente no P0/P5.
- Para não criar dependência Policy → Items, decidir provider opcional de enumeração de classes no P0; o Editor pode usar Items quando presente e fallback/provider próprio bem delimitado, sem duplicar scan 70k configs.
- **Role Kits e bloqueio por função fora do escopo**, mesmo que FTAC/BGD disponha de ferramentas de controle.

## 5. Pesquisa BGD já feita — conhecimento contextual, integração não autorizada

O repositório externo `RicGonzalezb/bgd-hq` foi consultado neste projeto. Foram observados:
- `BGD_Arsenal_BL`: blacklist relacionada ao BGD Arsenal Redux/ACE virtual, consultada também pelo BGD Garage.
- FTAC Admin Tools inclui Role Kits e **Loadout Limiter** com whitelist/blacklist configuráveis e tratamentos de inventário. São mecanismos distintos: catálogo de arsenal, kit/função e remoção/restrição de equipamento.
- `development/projects/FTAC_Admin_Tools/src/FTAC_Admin_Tools/XEH_preInit.sqf`;
- `development/projects/FTAC_Admin_Tools/src/FTAC_Admin_Tools/functions/fn_BGD_callRoleKits.sqf`;
- `development/projects/FTAC_Admin_Tools/src/FTAC_Admin_Tools/functions/fn_BGD_initLoadoutLimiter.sqf`.

**Não** copiar comportamento de Role Kits como requisito, **não** transformar descoberta em dependência. A primeira versão de Policy deve rodar sem BGD.

## 6. Roadmap aprovado em planejamento (TUDO PENDENTE)

Documento fonte: `docs/projects/policy-editor/ROADMAP.md`.

| Fase | O que entregar | Estado/gate |
|---|---|---|
| **P0 — Contratos / spikes** | Origem interna vs servidor; modo estático; esquema PolicySnapshot/Decision; data-only import/export; authority; enumeração de catálogo; falhas; testes de contrato | **PRÓXIMA RECOMENDAÇÃO**, não iniciada |
| **P1 — Núcleo** | Addon opcional Policy, OPEN + whitelist/blacklist/COMBINED, lookup por classname, DENY prioritário | NÃO INICIADO, teste SP |
| **P2 — Configuração** | Fallback interno vazio; origem explícita servidor/missão; precedência configurada; diagnosticar policyHash/revision; testar sem Policy/BDG | NÃO INICIADO, SP/host |
| **P3 — Integração Items/cache/cores** | Catálogo base + projeção filtrada, awareness por kit, cores vermelho/amarelo/laranja, não revarrer CONFIG_ALL | NÃO INICIADO, SP |
| **P4 — Execução parcial segura** | Rejeições POLICY_DENIED, ITEM_CLASS_UNAVAILABLE, ADD parcial, remoção permitida, REPLACE/CLEAR seguro | NÃO INICIADO, SP |
| **P5 — Editor local** | Catálogo completo, add/remove, importar/exportar/validar, botão refresh de sessão local | NÃO INICIADO, SP + spike clipboard |
| **P6 — Admin/sync MP** | Ativação server-authoritative por admin, policyRevision, JIP, refresh cliente, aviso admin opcional | NÃO INICIADO, precisa MP real |
| **P7 — Adapters/hardening** | BGD opcional, testes multiconfig/performance/PBO, Role Kit somente se nova decisão | NÃO INICIADO |

**Importante:** documentação P0–P7 ≠ código pronto. Esta conversa até agora **não** implementou Policy nem seu editor.

## 7. Backlog de ícones (preservado, não executar agora)

**DECISÃO ATUAL:** botões de Items e Weapons permanecem **APENAS TEXTO** por consistência. UICommon não deve receber controles de ícones nesta frente.

**Três masters Items APROVADOS** foram enviados pelo usuário ao Git e organizados sem alteração de bytes:
- Uniforme: `assets/ui/icons/items/approved/uniforme_aprovado_original.png`, SHA-256 `93e50ec9756bd635403c45b9a7bf374101d850bc5dff11c2855385cd495e1fb7`.
- Colete **1**: `assets/ui/icons/items/approved/colete_1_aprovado_original.png`, SHA-256 `37890a2476dec579a90a72d31c37718c0a48c1940a9cf1cacf111df0f0fed105`.
- Mochila **corrigida com centro branco preenchido**: `assets/ui/icons/items/approved/mochila_corrigida_aprovada_original.png`, SHA-256 `908cbc604658e13eab8571ee7bbf0e87878665cb5b934b6ea488674d2207bb5c`.
- Os SVGs R0/R1 antigos **não** são fontes visuais aprovadas; manifesto `assets/ui/icons/items/approved/SELECTION_20261021.json`.
- Integração futura, só se aprovada novamente: derivar PAA, QC alfa, icon + texto nos IDCs P2 2111–2113 e P4 4110–4112, testar, sem trocar semântica.

**9 Weapons pendentes:** Arma Principal, Arma Porte, Arma Lançador, Mira, Apontador, Boca, Bipe, Carregador, Carregador Secundário (segundo cano/lançador).  
**9 outros módulos pendentes:** Capacete/Gorro (headgear), Facewear, NVG, Binóculo/Telemetro, Mapa, Terminal/UAV, Bússola, Rádio, Relógio.

**Nota Weapons:** segundo carregador exige *separação funcional* de slots de alimentação/compatibilidade, além de um ícone; não misturar este backlog com o código Weapons sem gate próprio.

Documento: `docs/72_BACKLOG_ICONOGRAFIA_MODULOS.md`.

## 8. Regras técnicas de trabalho e QA para o novo chat

1. **GitHub é a fonte de verdade:** buscar estado mais recente da branch, ler documentos/artefatos canônicos. Não reconstruir baselines de memórias ou resumos de mensagens. Se algum artefato RPT/ZIP não está no Git, dizer exatamente qual prova falta; não inventar arquivo de missão.
2. **Isolar branches/commits:** preservar `baseline/items-uicommon-r2-2-sp-homologated-20261021`. Nova frente Policy deve nascer em branch própria. Hoje `feature/items-ui-icons-r1-simple-silhouettes` traz docs e PNGs, sem delta de runtime após freeze; pode ser origem de **documentos**, não requer merge de runtime.
3. **Mission-first inicialmente:** como Items/Weapons, scripts e testes automáticos em missão VR; gerar zip para teste do usuário somente quando explicitamente solicitado. Addon/PBO real só após gates; não afirmar homologação MP com teste SP.
4. **Não tocar na UI aprovada** enquanto Policy P0/P1: nomes, quatro painéis, footer roxo, marca BGD, botões texto, linhas laranja, CAPTURAR.
5. **Capacidades opcionais:** quando Policy ausente, Items/Weapons não devem lançar erros e seguem comportando-se como antes. Registrar discovery de capabilities via Nexus; não criar dependências rígidas nem `CfgRemoteExec` global que bloqueie BIS/outros addons.
6. **Performance:** baseline scanner ~7.092 elegíveis/73.470 configs/24–27s; refresh ~10–14 ms; não reconstruir para atualizar allow/deny; checar orçamento com RPT e scripts instrumentados.
7. **Preservação e segurança:** não apagar persistidos, não fazer publish por cliente, evitar SQF importado executável, cache inválido não dá autorização automática quando política obrigatória pendente; remover item restrito continua permitido.
8. **Feedback:** usuário prefere parceiro técnico crítico, pedir evidência quando necessário e confrontar contradições. Já decidiu as regras de negócio; **não perguntar novamente se deseja whitelist vazia OPEN, deny-wins, sem BGD obrigatório ou ícones pausados**.
9. **Documentação permanente:** toda nova decisão/bug/entrega deve atualizar doc canônico, roadmap, máquina e handoff, com data, branch, commit, escopo de teste, regressões e pendências.
10. **Não desenvolver por conta própria** novas features não solicitadas apenas porque constam como futuro.

## 9. Pontos específicos AINDA ABERTOS para P0/UX — não tratar como acordados

1. Nome real e semântica de `CfgSPORGPolicy` (ou outra fonte interna do addon); hierarquia de arquivo/config missão/servidor, capacidade Arma de carregar alterações fora do PBO.
2. Fonte externa concreta e precedência quando há múltiplas fontes explícitas além da autoridade global já decidida. **Servidor manda**, mas mecanismo técnico de configuração não foi escolhido.
3. `PolicySnapshot`, `PolicyDecision`, schema de exportação/importação seguro, validação, versionamento, canonicalização de classnames e conflitos.
4. API de provider de catálogo independente de Items para editor opcional (evitar duplicate scan); exibição de addon/source com mod ausente.
5. Viabilidade do clipboard, leitura/escrita de arquivos e eventual adapter na engine especialmente em MP; não prometer filesystem liberado.
6. UI exata do Policy Editor, IDC, tamanho de controles, permissões de abertura e layout; esboço em `README.md` é **conceito**, não UI aprovada.
7. Gestão segura de snapshots/revision/hashes em MP, autenticação do admin, JIP, comportamento no resync obrigatório e regra de fail-closed quando exigida.
8. Decisão final de contraste/color coding para **restrito+alterado**, legibilidade de todas as cores na interface com foto de fundo e eventual futuro símbolo; vermelho para ausente já foi explicitamente escolhido.
9. Cópia lógica parcial vs edição integral vs salvar draft; semântica para kits mistos e conflitos em operações destrutivas.
10. Status dirty total ao reverter alterações e auditoria de microtextos; não confundir com Policy.
11. Quando/como iniciar Role Kits se algum dia — usuário ainda não deseja restrição baseada em papel.
12. Modo de atualização administrativa **durante a partida** é opcional e posterior; listas estáticas devem ser primeiro caso suportado.

## 10. Pedido inicial sugerido ao novo chat

> Estamos continuando o projeto Arma 3 — Servo Peregrino Organizador. GitHub é a fonte de verdade: `peregrinoklawd/ServoPeregrino_Organizador`. Leia integralmente `docs/74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md`, a auditoria `docs/73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md` e os documentos `docs/modules/Policy.md`, `docs/projects/policy-editor/README.md` e `ROADMAP.md`, na branch `feature/items-ui-icons-r1-simple-silhouettes`. Preserve a baseline R2.2 SP `baseline/items-uicommon-r2-2-sp-homologated-20261021`. Items UX R1 e R2.2 estão homologados em SP, mas biblioteca pública 0.13-A MP está pendente. Botões ficam SOMENTE TEXTO; imagens escolhidas estão guardadas no Git. Policy é opcional, ainda não implementado, BGD e Role Kits não são requisitos. Quero começar pelo **P0 do Policy** (contratos e prova técnica de fontes/import-export), sem mexer no runtime Items, e que você apresente evidências e registre os resultados no Git.

## 11. Estado ao encerrar esta conversa

- **Items:** R2.2 HOMOLOGADA no escopo SP aprovado; efeitos públicos MP pendentes.
- **UICommon:** R2.2 SP validada sobre 0.2.0.11 candidate, com fallback estável 0.2.0.10 de 07/10.
- **Policy:** PLANEJADO, 0 linhas de runtime do addon próprio implementadas por esta conversa.
- **Policy Editor:** PLANEJADO, sem UI nem botões funcionais.
- **Iconografia Items:** três PNGs aprovados e SHA verificados no Git; **BOTÕES TEXTO, IMPLEMENTAÇÃO GRÁFICA PAUSADA**.
- **Iconografia Weapons/outros:** 18 ideias em backlog, nenhuma implementação nesta frente.
- **BGD:** integração opcional futura; não exigir para funcionamento.
- **QA:** nenhum teste Arma adicional foi executado durante a auditoria documental de 22/10.
- **Git:** sem alterações em `addons/` ou `missions/` na etapa documental; sem merge em `main`. Próximo agente deve confirmar `git diff`/compare antes de tocar código.
