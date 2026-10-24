# Auditoria de decisões — conversa de retomada Items / UICommon / Policy

**Data:** 22/10/2026 · **Escopo:** todas as decisões relevantes desta longa conversa, desde a retomada do Items em UICommon 0.2 até a criação planejada do Policy Editor.  
**Natureza:** AUDITORIA DOCUMENTAL. Não constitui novo gate de runtime e não altera o funcionamento do Arma.  
**Fonte prioritária para o próximo chat:** [continuidade autossuficiente](74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md).

## Legenda

- **DECIDIDO:** comportamento ou direção explicitamente aceitos pelo usuário.
- **IMPLEMENTADO:** existe em source Git revisado.
- **HOMOLOGADO SP:** executado pelo usuário no Arma com print/RPT no escopo identificado.
- **PLANEJADO:** decisão registrada, sem código implementado.
- **EM ABERTO:** depende de spike/validação, não inventar decisão.
- **SUPERADO:** registro antigo preservado por histórico mas substituído por decisão mais recente.

## 1. Retomada Items: branch, baseline, gates

| Decisão/evidência da conversa | Situação verificada | Registro canônico |
|---|---|---|
| Retomar Items sobre UICommon 0.2 FINAL de 07/10, **não** sobre `main` antiga nem Weapons R6 reconstituído | DECIDIDO, baseline preservada | `baseline/uicommon-0.2-final-homologated`, `docs/ITEMS_CONTINUIDADE_RETOMADA_20261021.md` |
| Items 0.12 FINAL histórico + Items 0.13-A com autoridade de biblioteca pública em desenvolvimento | Source existe; MP real não homologado | `machine/MODULE_MATRIX.json`, `machine/ITEMS_CONTINUITY_20261021.json` |
| Sem segundo jogador no momento; trabalhar em SP antes do gate MP | DECIDIDO | `docs/ITEMS_ROADMAP_RETOMADA_20261021.md` |
| CAPTURAR abre confirmação; cancelar não muta; confirmar **substitui entries** do draft de modo atômico, preserva identidade/nome/destino/baseline; sem salvar nem alterar inventário físico | IMPLEMENTADO e manualmente aprovado UX R1 | `docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md`, `docs/70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md` |
| Linhas alteradas em relação ao snapshot SALVO ficam **laranja**; comparação do Items específica, embora padrão visual semelhante já aparecesse no Weapons | IMPLEMENTADO e manualmente aprovado; não reabrir UICommon como proprietário da lógica | `docs/ITEMS_ROADMAP_RETOMADA_20261021.md`, `docs/70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md` |
| CAPTURAR e realce laranja não autorizam concluir testes públicos 0.13-A MP | DECIDIDO | `docs/70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md` |
| UICommon compartilha infraestrutura/controle; Items possui semântica de inventário, kits, draft e aplicação | DECIDIDO / código existente | `docs/31_UICOMMON_ARCHITECTURE_AND_MIGRATION.md` |

### Nota de fonte histórica corrigida nesta auditoria

`docs/30_ITEMS_UI_REGRESSION_CONTRACT.md` dizia que CAPTURAR e a marcação por linha eram **futuros**. `docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md` dizia **candidata pendente de RPT**. Essas frases pertencem a 07/10 e ao começo de 21/10. **Não são o estado atual**: ambos foram implementados e aprovados em UX R1. O R2.2 também já passou o smoke SP descrito abaixo. Manter os documentos históricos, mas colocar cabeçalho de supersessão em vez de apagá-los.

## 2. Logo BGD, footer e R2.2

| Decisão/evidência | Resultado |
|---|---|
| Encontrar logo oficial no BGD-HQ e copiar bytes, não redesenhar | Feito: `RicGonzalezb/bgd-hq/comunicacao-social/identidade/assets/bgd-logo-primary.png`, Git blob `2916a99374ca8d13602dd7034ede7e2b84000294`; cópia master `assets/branding/bgd/bgd-logo-primary.png` |
| Slot genérico no header pertence ao UICommon; imagem/textura é responsabilidade do consumidor | IMPLEMENTADO: `SPORG_UICommon_HeaderBrand`; Items injeta BGD em IDC 107; Weapons não recebeu logo por tabela |
| PAA para Arma e equivalente mission-first/addon | Criados: `addons/ServoPeregrino_Organizador_Items/data/bgd_logo_ca.paa` e cópia na missão; derivado 256px alfa DXT5. Preservar original PNG |
| Teste R2 inicial: Picture `items\data\bgd_logo_ca.paa` not found | Corrigido R2.1 por `getMissionPath` + `ctrlSetText` no runtime |
| R2.1: logo visível, mas `fileExists` com caminho absoluto emitia `Invalid path` e `fileExists=false` enganador | Corrigido R2.2 apenas removendo sonda incompatível; log agora `[BRAND_HEADER] pathAssigned=true` |
| HISTÓRICO roxo ficava cinza após certas atualizações | Root cause `fn_refreshPhysicalTargetUI.sqf` sobrescrevia IDC 5002 com `#81918E`; fix usa `UICommon_fnc_renderFooter`, título roxo `#B9A3E8`, texto `#D1C2F0` |
| R2.2 enviada e testada com print/RPT | **HOMOLOGADA APENAS SP NO ESCOPO LOGO/FOOTER/DIAGNÓSTICO**; missão `SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix.VR`; `UICommon 0.2.0.11-header-brand-slot-r2-candidate`. Não equivale a aprovação MP/PBO de produção |
| Baseline para preservar regressões | `baseline/items-uicommon-r2-2-sp-homologated-20261021` (frozen); fallback mais antigo `baseline/uicommon-0.2-final-homologated` de 07/10 |

A investigação do BGD Watch também encontrou `development/guides/VISUAL_ASSET_PRODUCTION.md` e `development/projects/bgd-environmental-kit/docs/PAA_PRODUCTION_PIPELINE.md` no BGD-HQ, orientando `ImageToPAA`, round-trip/alpha/mips e smoke engine. **Não afirmar que o PNG institucional foi qualificado pelo pipeline oficial completo**: sua renderização foi testada no Arma; o pipeline do derivado do Organizador usou conversor próprio e CI.

## 3. Iconografia, escolhas e decisão de PAUSA (mais recente)

1. O usuário quis ícones originais inspirados só em legibilidade do ACE, não cópias. Produção visual no chat/Work é recomendação de fluxo, não exigência de runtime.
2. Três protótipos vetoriais R0/R1 foram feitos e depois **substituídos por escolhas visuais explícitas do usuário**:
   - Uniforme: `assets/ui/icons/items/approved/uniforme_aprovado_original.png`;
   - Colete: **Colete 1**, `assets/ui/icons/items/approved/colete_1_aprovado_original.png`;
   - Mochila: última **corrigida com corpo central preenchido**, `assets/ui/icons/items/approved/mochila_corrigida_aprovada_original.png`.
3. O usuário enviou os PNGs originais ao Git e eles foram movidos sem alteração de bytes; hashes originais no `assets/ui/icons/items/approved/SELECTION_20261021.json` e `MANIFEST_ORIGINAIS.json`. Os SVGs antigos **não** representam os masters aprovados.
4. UI futura se autorizada: **ícone + texto** para APP_TARGET (2111, 2112, 2113) e EQUIPMENT_VIEW (4110, 4111, 4112), **funções independentes**.
5. **ÚLTIMA DECISÃO VÁLIDA (22/10): NÃO integrar nem criar botões de imagem agora; manter somente TEXTO** para consistência. Sem derivação PAA nem mudança de HPP/SQF em Items/Weapons até novo pedido. PNGs guardados para futuro.
6. Backlog futuro de 18 símbolos em `docs/72_BACKLOG_ICONOGRAFIA_MODULOS.md`: Weapons — Principal, Porte, Lançador, Mira, Apontador, Boca, Bipe, Carregador, Carregador Secundário (cano 2/lançador); secundários — Capacete/Gorro, Facewear, NVG, Binóculo/Telemetro, Mapa, Terminal/UAV, Bússola, Rádio, Relógio.
7. Ícone de carregador secundário **não** resolve a separação funcional de munições de lançador/canos acoplados; isso pertence ao modelo/slots de Weapons e permanece pendente.

## 4. Policy — decisões efetivamente aceitas

**Módulo próprio** `ServoPeregrino_Organizador_Policy` planejado, opcional, dependência prevista somente Nexus. O catálogo Items não pode virar fonte autoritativa de permissão; UICommon não possui semântica Policy. Weapons reutilizará contrato futuro. **BGD/FTAC/Role Kits não são dependências**; não vasculhar outras configurações/mods indiscriminadamente.

### Matriz fechada de política

| Whitelist | Blacklist | Resultado |
|---|---|---|
| vazia | vazia | OPEN; todos os itens elegíveis e instalados permitidos |
| vazia | preenchida | tudo menos blacklist |
| preenchida | vazia | somente whitelist |
| preenchida | preenchida | whitelist menos blacklist — **DENY vence** |

Lista vazia desabilita só a restrição correspondente. Consultas por `className` exato são escopo inicial; regras por addon, baseClass, categoria e tag são possibilidades **não prometidas** no MVP.

### Fontes e autoridade

- **Interna:** configuração fallback do addon Policy com as duas listas vazias; nome de classe/path a escolher e congelar em P0. Na ausência de Policy, o Items atual deve continuar em OPEN; isso precisa ser gate explícito de regressão, não algo já testado.
- **Servidor/missão:** fonte explicitamente nomeada e documentada pelo SP_ORG (ainda **não foi escolhido o mecanismo técnico definitivo**: config, missão, provider etc.); **não é obrigatório** receber configuração externa.
- **Precedência de autoridade aceita:** o cliente normal **não pode ativar** whitelist/blacklist para um servidor; somente o administrador autenticado pelo servidor. Cliente pode criar/editar rascunhos locais para **exportar**. Precedência de fontes sugerida e documentada: snapshot autoritativo ativado no servidor > configuração explícita servidor/missão > fallback interno; o mecanismo efetivo ainda requer prova.
- **Role Kit:** não restringir por função/papel agora; o usuário prefere liberdade do jogador salvo blacklist. Integração BGD/Role Kits é apenas possibilidade futura **não aprovada** para implementação.

### Comportamento runtime acordado, não implementado

- Configurações oficiais geralmente **estáticas durante a partida** e preferencialmente carregadas antes do servidor. Atualização administrativa ao vivo é **extra opcional**, não requisito obrigatório para o primeiro núcleo.
- Catálogo normal Items mostra **apenas classes existentes e autorizadas**, sem mostrar as proibidas. **Editor administrativo** deve mostrar o **catálogo completo não filtrado** (mesmo os proibidos), para permitir edição.
- Construção base de catálogo `CONFIG_ALL` varre mods instalados uma vez por modset/build, se possível aproveitando prefilter; cache base permanece **independente** da projeção permitida, do status dos kits e da policyRevision. Não repetir scanner por scroll/clique ou refresh do Policy.
- Classificação kits pré-computada/cacheada na primeira abertura conforme necessidade; após editar/salvar kit, invalidar só seu diagnóstico. Na revisão Policy futura, invalidar projeção, não scan base.
- **Botão local ATUALIZAR CACHE** ao jogador: obtém versão/revisão do servidor, atualiza projeção/autorização e cores de kits; não publica política nem faz rebuild completo do catálogo. Atualização inicial automática ao entrar/abrir pela primeira vez. Admin poderá publicar nova revisão e **escolher notificar ou não**; o sync efetivo não depende de notificação visual.
- Executor faz lookup barato do índice/revisão antes da aplicação física (segurança e MP) — **não** reavalia milhares de classes ou varre configs por movimento/click.
- Itens proibidos/ausentes **não somem dos kits salvos**, mesmo que o mod tenha sido removido. Classe ambientalmente inexistente é distinta de uma classe presente porém não autorizada.
- Ao abrir kit persistido para edição, **todas as entradas devem continuar no draft**. Ao copiar/combinar para outro rascunho ou aplicar fisicamente, o destino recebe só o subconjunto elegível na operação, com relatório e preservação do original. Importante: copiar para rascunho não é necessariamente equipar fisicamente — não confundir fluxos.
- ADD BEST_EFFORT: aplicação parcial de disponíveis/autorizados, ainda limitada por capacidade. REMOVE voluntário não bloqueado por blacklist. REPLACE/CLEAR: preflight/rollback para evitar perda inesperada.
- Em MP, servidor aplica política na mutação autoritativa; não confiar no cliente. Política obrigatória não recebida ainda **não** pode ser presumida OPEN, em contraste com ausência intencional de Política = OPEN.

### Cores e precedência

- Item presente porém negado (por whitelist/blacklist) = **AMARELO** atenção.
- Classe de mod ausente = **VERMELHO** indisponível/pare.
- Linha de rascunho modificada vs snapshot salvo = **LARANJA** (já implementado sem Policy).
- Nome kit com item restrito e nenhum ausente = amarelo; com **qualquer ausente** = vermelho, mesmo kit misto.
- Para linha com ausência + restrição + alteração, **vermelho prevalece**, mas tooltip/rodapé precisa preservar os outros estados. Para restrito + alterado sem ausente, amarelo como precedência **proposta**, ainda depende de validação UX real; não trocar silenciosamente paleta e estados existentes.
- Verde de feedback e roxo do HISTÓRICO permanecem distintos. Caso cores se aproximem, estudar contraste, sem mudar visual homologado antes da entrega própria.
- O usuário cogitou ícones/símbolos por estado em vez de cores, mas **decidiu manter cores por enquanto**.
- Evidência do usuário: o `n/d` e `peso ?` surgiram **quando ele desativou mods**. Respeitar esse relato, mas a detecção em código deve usar `isClass`/validação ambiental existente; **não** usar `peso ?` como detector técnico único.

### Desempenho

- RPT grande medido ~**73.470 configs visitadas**, **7.092 itens elegíveis**, inicialização **24–27 s** no modset, com `CATALOG_FOCUSED` ~**10–14 ms**.
- Redução de itens autorizados **não implica** necessariamente grande redução do scan base `CONFIG_ALL`. Consultas por HashMap + projeção em memória são baratas; benchmark antes/depois.
- Escolha arquitetural: catálogo base disponível para editor, projeção filtrada para jogador, cache de compatibilidade de kits, lookup mínimo no executor. Não implementar um campo `active` para milhares de linhas visíveis se a lista do jogador deve ser filtrada.

## 5. Editor Policy — projeto documentado, sem interface pronta

Editor para montar lista de itens a partir de classes de todos os mods ativos, busca, adicionar à whitelist/blacklist, remover, limpar, importar/exportar, validar prévia/diff; cliente monta lista **local sem ativação**, admin do servidor pode publicar por canal autorizado no futuro.

Distinguir:
- `ATUALIZAR CACHE` (jogador): refresh de regras/projeções locais, baixo custo.
- `PUBLICAR/ATIVAR POLÍTICA` (admin): altera snapshot autoritativo e revisão; opcional aviso a jogadores.
- `RECONSTRUIR CATÁLOGO` (operação distinta e cara, se houver).
- Na ausência de Policy configurado, exibir catálogo normalmente. O editor não deve ficar indisponível apenas porque blacklist/whitelist vazias.
- Import/export deve ser **dados versionados, sem compilar SQF importado**. Clipboard e filesystem no MP exigem spike Arma, não há implementação validada. Formato, fonte de dados quando Items não está instalado e mecanismo de publicação ainda são decisões técnicas abertas.

## 6. Ownership e sequência de desenvolvimento

- `Policy`: dono único do motor allow/deny, índice, snapshot e contrato `PolicyDecision`.
- `Items`: ItemEntry/ItemKit, catálogo e aplicação; consome Policy opcional.
- `Weapons`: dados de arma, slots e aplicação; consome Policy opcional quando implementado.
- `UICommon`: controles/cores/listagem/refresh genéricos, **sem regras de autorização nem imagens BGD hardcoded**.
- `Nexus`: capability/contratos, sem acoplamento de UI.
- `Adapters`: BGD e integrações externas opcionais sem infiltrar lógica BGD em Policy.
- `Policy Editor`: interface do Policy ou addon separado, **decisão de packaging ainda aberta**, sem dependência obrigatória Items.

**Ordem recomendada** (já documentada): P0 contratos/spikes → P1 motor puro → P2 configuração → P3 integração Items/cores/cache → P4 aplicação parcial/segura → P5 editor/import/export/refresh → P6 admin/autorização/sync MP → P7 adapters/performance. Não chamar P0/P1 de implementados.

## 7. Itens omitidos, imprecisos ou desatualizados identificados nesta auditoria

| Problema encontrado | Ação documental |
|---|---|
| `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md` ainda listava CAPTURAR e destaque como futuros | Adicionar aviso temporal de supersessão com status aprovado |
| `docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md` ainda dizia RPT pendente | Adicionar estado posterior e link ao aceite UX R1/R2.2 |
| `docs/70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md` dizia que a próxima frente obrigatória era ícones | Indicar pausa atual; assets guardados e não integrados |
| `docs/ITEMS_CONTINUIDADE_RETOMADA_20261021.md` dizia que ícones eram próximo passo | Incluir aviso de supersessão e redirecionar ao handoff novo |
| Listas Policy e editor descreviam alterações ao vivo, enquanto usuário disse blacklist estática antes do servidor | Reafirmar **estática por padrão**, hot reload somente capacidade futura opcional |
| Precedência amarelo/laranja apresentada como fechada sem confirmação visual específica | Marcar como proposta UX a validar, mantendo vermelho inequívoco para ausência |
| Causa relatada de `n/d`/`peso ?` ao desativar mods não constava explicitamente em todos os documentos | Registrar observação e preservar `isClass` como fonte verificável no código |
| Config interna vs servidor ainda tem mecanismo/path e serialização incertos | Handoff deve listar **EM ABERTO**, não escolher por suposição |
| Diferença copiar kit para draft vs abrir para editar vs adicionar ao equipamento tinha risco de ambiguidade | Criar regras por fluxo e exigir regressão sem apagar kit |
| Estado P0 do Policy não tinha guia autossuficiente para novo chat sem histórico | Criar handoff abrangente `docs/74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md` |
| Itens mais velhos na `main` e `machine/PROJECT_STATE.json` podem ser confundidos com estado presente | Handoff fixa branch e baseline, com documentos novos priorizados; nenhum merge foi feito |

## 8. Próxima ação proposta — sem código até o próximo chat decidir

Iniciar **P0 — contrato e spike do Policy**, em branch de desenvolvimento **própria a criar quando começar a implementação**, derivada de um ponto estável e sem carregar mudanças de ícones/runtime por acidente. P0 decide e registra contrato de configuração, origem, objeto PolicySnapshot/Decision, serializer seguro, autoridade e catálogo base/projeção. Não misturar P0 com P3 do Items.

**Teste de integridade desta auditoria:** nenhuma alteração em `addons/` ou `missions/`; nenhum teste SP/MP novo executado; nenhum PBO novo; nenhuma branch mergeada.
