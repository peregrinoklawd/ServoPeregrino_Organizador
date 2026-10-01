/*
    Servo Peregrino Organizador - Items
    Entrega 0.13-A — Server Authority Foundation

    Base oficial: 0.12 FINAL — Integration Freeze, aprovada manualmente.

    Objetivo desta entrega:
    - manter a biblioteca pública SESSION-scoped, sem prometer ainda persistência/JIP;
    - tornar o SERVIDOR a única autoridade de mutação da biblioteca pública em multiplayer;
    - clientes publicam snapshots validados por request explícito; o servidor deriva a identidade do remetente e decide a revisão;
    - preservar integralmente Repository privado, Whole-Kit, EXACT, DnD/ghost, Catálogo, Equipment, áudio, carga e authorities de destino.

    Fora do escopo 0.13-A:
    - persistência de biblioteca pública entre missões/restarts;
    - reconciliação JIP completa;
    - ACL/moderação/permissões avançadas;
    - rate limit, retry/timeout e recovery de requests;
    - mudanças no motor físico ou nos contratos Items/Weapons/Equipment/Sets.
*/

/*
    Servo Peregrino Organizador - Items
    Entrega 0.12 FINAL — Integration Freeze

    A 0.12 FINAL congela a baseline funcional aprovada manualmente da 0.12-D.7.4.
    Não adiciona funcionalidades e não altera Whole-Kit, EXACT, DnD/ghost, Application Engine, Repository/Storage,
    biblioteca PRIVADOS/PÚBLICOS, áudio, Catálogo, Equipment ou autoridade applicationTarget/equipmentView.

    Critério de homologação adotado nesta release:
    - testes manuais da 0.12-D.7.4 aprovados;
    - regressão automática histórica executa até o checkpoint C.6 e pode registrar falsos negativos conhecidos nos gates 516/523;
    - esses dois gates permanecem documentados como dívida técnica e não são corrigidos nesta release por decisão explícita de continuidade;
    - nenhum runtime é modificado para satisfazer teste histórico.

    0.12 FINAL:
    - versiona e congela a D.7.4 aprovada como baseline oficial 0.12;
    - preserva integralmente o comportamento runtime da D.7.4;
    - atualiza apenas identidade de release, documentação e compatibilidade do gate de versão D.7.4 com a release FINAL;
    - mantém o contrato histórico de 654 gates sem renumerar nem apagar gates antigos;
    - registra 516/523 como falsos negativos históricos conhecidos, aceitos por homologação manual;
    - prepara a transição controlada para 0.13 — Hardening + Public Integration.
*/

/*
    Servo Peregrino Organizador - Items
    Entrega 0.12-D.7.4 — Player Load Semantics & Historical Gate Hardening

    Base funcional: 0.12-C.7 fechou em 530/530 e teve DnD real aprovado manualmente.
    A 0.12-C.8 manteve o DnD funcional, mas o proxy visual estático não apareceu no gesto humano.
    A 0.12-C.8.1 corrige apenas a camada visual: o ghost nasce em runtime, acima dos painéis, e é destruído no fim do gesto.
    A 0.12-D.1 iniciou o polish final sem alterar DnD/Application/Storage.
    A 0.12-D.2 reorganiza o header em duas linhas compactas, centraliza linguagem player-facing e endurece os gates históricos contra drift ambiental sem mascarar mutação física do SP_ORG.
    A 0.12-D.3 restaura os tooltips dos itens após a autoridade de ponteiro do DnD, clarifica a hierarquia das ações físicas e fecha o registro dos runners D.2/D.3.
    A 0.12-D.4 corrige o hotfix anterior: o runner D.3 deixa de gerar erro de sintaxe no RPT e o tooltip passa a ter fundo translúcido, preservando leitura sem bloquear a inspeção visual do que está abaixo.

    A 0.12-D.7.4 fecha a semântica da carga global do jogador e endurece gates históricos que congelavam implementações antigas.
    A carga do header continua baseada nos comandos nativos loadAbs/load e em maxSoldierLoad, portanto inclui armas, itens vinculados
    e o conteúdo de Uniforme/Colete/Mochila. Quando scripts/mods colocam o jogador acima do limite global, a UI não mascara o estado:
    a barra visual permanece limitada ao trilho, o texto mostra 100%+ e SOBRECARGA, e o tooltip explica o excesso real.
    A capacidade de U/C/M permanece um domínio separado, baseada em loadAbs do container + maximumLoad, sem alteração do motor físico.

    0.12-D.7.4:
    - preserva loadAbs player / maxSoldierLoad como semântica nativa da carga global do jogador;
    - diferencia percentual semântico bruto da fração visual da barra, evitando que o clamp visual esconda sobrecarga real;
    - normal: mantém "Carga: usado / limite kg - N%"; acima do limite: mostra "100%+ · SOBRECARGA" sem fingir que o estado é 100%;
    - tooltip explica explicitamente que armas, itens vinculados e conteúdos U/C/M participam da carga total e informa o excesso;
    - não altera capacidade por container, Application Engine, Whole-Kit, EXACT, DnD, Repository, biblioteca, áudio ou autoridade equipmentView/applicationTarget;
    - endurece o gate histórico 502/505 para a navegação atual do Catálogo: wheel + slider único visível, botões ▲/▼ legados fora da tela;
    - torna gates D.7.1/D.7.2/D.7.3 compatíveis com novas entregas D.7.x sem congelar uma displayVersion intermediária;
    - adiciona gates 647..654 e contrato cumulativo 654/654.


    A 0.12-D.7.3 fecha a autoridade de destino do botão direito do Catálogo e melhora a leitura/descoberta do catálogo.
    O botão de adicionar ao equipamento passa a obedecer exclusivamente ao equipamento exibido em "Mostrar", assim como o DnD;
    PUBLICAR recebe o mesmo cue sonoro da cópia; badges de ação passam a ser transitórios; e a ordenação do catálogo deixa de
    depender da ordem bruta dos configs, tornando filtros como MÉDICO previsíveis e navegáveis.

    0.12-D.7.3:
    - botão direito/amarelo do Catálogo -> Conteúdo do Equipamento usa equipmentView ("Mostrar"), nunca applicationTarget;
    - PUBLICAR toca o cue SUCCESS após persistência bem-sucedida;
    - COPIADO/PUBLICADO permanecem até a próxima interação real e então são limpos, inclusive ao iniciar DnD;
    - textos explicativos deixam de usar setas como caracteres e passam a explicar "botão da esquerda/direita";
    - contador do Catálogo vira "Mostrando X a Y de Z itens" / "Nenhum item encontrado";
    - Catálogo é ordenado alfabeticamente por displayName/className após o scan, antes de publicar o cache;
    - "Onde aplicar o kit?" fica explicitamente reservado às ações de kit; "Mostrar" governa adições diretas ao equipamento;
    - adiciona gates 639..646 e contrato cumulativo 646/646.

    A 0.12-D.7.2 fecha três inconsistências de estado observadas no primeiro smoke da biblioteca privada/pública.
    O botão PUBLICAR não depende do Catálogo: o problema era um refresh focado de troca de kit que atualizava o Draft,
    mas não reavaliava o botão no painel Meus Kits. A entrega também torna audível a cópia Público → Privado e
    sincroniza a seleção visual após excluir um kit, evitando o falso estado “selecionado na tela, vazio no estado”.

    0.12-D.7.2:
    - PUBLICAR é habilitado imediatamente após selecionar/carregar um kit privado, sem aguardar full refresh ou Catálogo;
    - SALVAR NO PRIVADO toca o cue de confirmação SUCCESS após persistência bem-sucedida;
    - após excluir um kit, o próximo kit visível é promovido para a seleção lógica sem trocar/destruir o Rascunho preservado;
    - o botão PUBLICAR acompanha a nova seleção reconciliada;
    - adiciona gates 634..638 e contrato cumulativo 638/638.

    A 0.12-D.7.1 fecha o primeiro ciclo visual/operacional da biblioteca PRIVADOS/PÚBLICOS sem ampliar escopo de rede.
    O header de carga fica mais limpo em kg; cópias públicas ganham nome explícito; o fluxo de cópia permanece na aba
    PÚBLICOS para operações em sequência; e MEUS KITS ganha feedback de ação no cabeçalho do painel.

    0.12-D.7.1:
    - header: "Carga" passa a exibir apenas usado/total em kg + percentual, removendo lb dessa linha;
    - SALVAR NO PRIVADO cria o nome "Cópia <nome público>" e preserva novo ItemKit ID/origem PUBLIC_COPY;
    - após copiar um kit público, a interface permanece em PÚBLICOS, preservando busca e seleção para nova cópia;
    - MEUS KITS exibe COPIADO após cópia bem-sucedida e PUBLICADO após publicação/atualização bem-sucedida;
    - adiciona gates 628..633 e contrato cumulativo 633/633.

    A 0.12-D.7.0 abre a fundação da biblioteca PRIVADOS/PÚBLICOS sem reabrir o motor físico já homologado.
    A prioridade é separar com clareza o que pertence ao perfil do jogador do que está compartilhado na sessão,
    mantendo os kits públicos como snapshots independentes e somente leitura na aba pública. O fluxo de publicação
    e cópia para o privado é explícito; nenhuma edição do Rascunho altera automaticamente uma publicação existente.

    0.12-D.7.0:
    - adiciona abas PRIVADOS / PÚBLICOS abaixo da busca de Meus Kits de Itens, preservando a simetria dos painéis;
    - PRIVADOS continua usando o Repository persistente atual e mantém clique para editar + DnD nativo;
    - PÚBLICOS usa uma biblioteca de sessão separada, capaz de receber snapshots publicados por jogador/servidor;
    - PUBLICAR cria/atualiza um snapshot independente do kit privado sem criar vínculo vivo com o Rascunho;
    - SALVAR NO PRIVADO clona o snapshot público com novo ItemKit ID e persiste a cópia no Repository do jogador;
    - a aba pública é seleção/leitura: clique não substitui o Rascunho e o DnD de Meus Kits é bloqueado nessa aba;
    - exibe origem/autor na lista pública e mantém busca local sobre nome, autor e origem;
    - a biblioteca pública é intencionalmente SESSION-scoped nesta fundação; autoridade/persistência de servidor ficam para o próximo marco de governança;
    - adiciona gates 618..627 e contrato cumulativo 627/627.

    A 0.12-D.6.4 fecha a paridade entre os dois gestos explícitos de adicionar conteúdo ao Kit Selecionado:
    arrastar/soltar e clicar na seta ←. Se não houver Rascunho aberto, ambos agora criam um novo Rascunho
    em memória e concluem a cópia no mesmo gesto. O escopo continua restrito a ações explícitas de adição;
    seleção, busca e cliques neutros não criam estado. Também corrige o gate histórico 510, que ainda esperava
    a palavra antiga "Draft" depois da padronização player-facing para "Rascunho".

    0.12-D.6.4:
    - seta ← do Catálogo cria Rascunho automaticamente quando o Kit Selecionado está vazio;
    - seta ← do Conteúdo do Equipamento possui a mesma paridade e continua sendo cópia lógica, sem remover o item físico;
    - DnD mantém o comportamento aprovado da D.6.3;
    - auto-criação é opt-in explícito no dispatcher para gestos de adição e conserva rollback transacional;
    - chamadas lógicas internas sem opt-in continuam retornando ITEMS_UI_DRAFT_REQUIRED, evitando criação acidental;
    - gate histórico 510 passa a validar a copy atual "Rascunho" e deixa de causar FAIL-FAST em toda a cadeia;
    - adiciona gates 611..617 e contrato cumulativo 617/617.

    A 0.12-D.6.3 elimina um atrito de fluxo do Kit Selecionado e fecha um falso negativo histórico dos testes:
    ao soltar Catálogo, Equipment ou um kit salvo sobre o painel vazio de Kit Selecionado, a interface cria automaticamente
    um novo Rascunho em memória e conclui a cópia lógica. O comportamento automático é exclusivo do DnD; ações por botão
    continuam exigindo um Rascunho já aberto. O header também passa a ser calculado visualmente a partir do botão Fechar,
    formando um único bloco compacto Carga -> Operador/Unidade -> slot futuro -> Fechar.

    0.12-D.6.3:
    - DnD para Kit Selecionado cria Rascunho automaticamente quando nenhum estiver aberto;
    - Catálogo, Conteúdo do Equipamento e Meus Kits compartilham o mesmo contrato de auto-criação;
    - falha na transferência após auto-criação restaura o estado anterior, evitando Rascunho vazio fantasma;
    - botões/rails não passam a criar Rascunho implicitamente: a conveniência é restrita ao gesto de arrastar e soltar;
    - área de drop informa visualmente que soltá-la criará um Rascunho quando necessário;
    - header usa âncoras derivadas do Fechar, barra de carga alinhada ao próprio texto e bloco direito mais compacto;
    - gate histórico 484 aceita a copy player-facing atual “equipamento escolhido”, sem exigir o rótulo antigo “Destino de Aplicação”;
    - adiciona gates 603..610 e contrato cumulativo 610/610.


    A 0.12-D.6.2 corrige a autoridade de destino do DnD físico e fecha o polish visual inspirado no APM:
    o painel Conteúdo do Equipamento passa a ser soberano sobre o destino de drops, usando sempre o equipamento
    atualmente selecionado em "Mostrar", independentemente do alvo de "Onde aplicar o kit?". Também compacta o
    header, remove o status "Adicionar em" da faixa superior, mantém ANY apenas como compatibilidade interna,
    converte textos player-facing de Draft para Rascunho e coloca Capacidade + barra + peso em uma única linha.

    0.12-D.6.2:
    - DnD Catálogo/Kit/Entry -> Conteúdo do Equipamento usa equipmentView (U/C/M), nunca applicationTarget;
    - readiness visual e drop-zone do Equipment são calculados pelo equipamento mostrado, não pelo alvo do kit;
    - header converge ao padrão APM: Carga + barra, Operador/Unidade, slot futuro e Fechar em bloco compacto;
    - HeaderStatus "Adicionar em" permanece apenas como stub invisível de compatibilidade e não é mostrado ao jogador;
    - "Qualquer" deixa de ser exibido em Onde aplicar o kit?, mas ANY continua suportado internamente;
    - "Draft" player-facing em Meus Kits vira "Rascunho";
    - Capacidade passa para linha única: rótulo + barra + usado/máximo em kg;
    - hardening dos gates históricos CP-D/D.1/D.2/A para refletir contratos atuais sem relaxar invariância física;
    - adiciona gates 595..602 e contrato cumulativo 602/602.

    A 0.12-D.6.1 é um hotfix de fechamento, sem expansão funcional: aumenta discretamente a legibilidade do texto de capacidade do equipamento e corrige dois gates históricos do CP-B que ainda validavam frases técnicas removidas pela linguagem player-facing. Os gates passam a validar semântica/metadata do resultado, não uma copy obsoleta.

    0.12-D.6.1:
    - aumenta EquipmentCapacityText de 0.013 para 0.015 safeZoneH, preservando o bloco e o espaçamento dos botões;
    - alinha ITEMS-0.11-408 ao contrato atual de SUCCESS (outcome/qty/actions/op/target/commandId + mensagem amigável);
    - alinha ITEMS-0.11-411 ao contrato atual de rollback (estado, cue, severidade, commandId), sem depender de frase antiga;
    - torna o gate 581/D.6 compatível com versões futuras do mesmo marco;
    - adiciona gates 591..594 e contrato cumulativo 594/594.

    A 0.12-D.6 consolida a interface após o ciclo de hotfixes D.1..D.5: elimina a navegação visual redundante do Catálogo, reorganiza as ações do Kit Selecionado, ancora o bloco de status do header ao Fechar, suaviza o ghost de arraste e troca a unidade técnica `u` por kg/lb na apresentação ao jogador. Também endurece os runners históricos D.2/D.4/D.5 e reduz a janela ambiental do gate 314 sem relaxar a invariância física.

    0.12-D.6:
    - mantém apenas a barra vertical nativa/slider como navegação visível do Catálogo; os antigos botões quadrados ▲/▼ ficam somente como stubs off-screen para compatibilidade dos gates históricos;
    - amplia a barra contínua para toda a altura útil do Catálogo e preserva wheel/drag do thumb;
    - aumenta a transparência do ghost de DnD sem alterar o tooltip normal dos itens;
    - separa verticalmente "Onde aplicar o kit?" e "O que fazer no destino?", eliminando sobreposição com os botões físicos;
    - compacta Operador/Unidade/Carga à direita, usando o Fechar como âncora visual;
    - adiciona formatUIMass: apresentação em kg e lb no padrão do inventário, mantendo mass units internamente;
    - corrige a sintaxe frágil do gate 574/D.5 e torna os gates D.2/D.4/D.5 compatíveis com entregas futuras;
    - reduz o gate 314 ao intervalo estrito do teste de Enter/Numpad Enter, evitando drift ambiental anterior ao gesto sem aceitar mutação física dentro do segmento;
    - adiciona gates 581..590 e contrato cumulativo 590/590.

    A 0.12-D.5 fecha o polimento dessa área: o tooltip não reaparece durante arraste ativo, a legenda de ação física volta a ficar legível/padronizada e o header recebe mais respiro/alinhamento no ultrawide.

    0.12-D.5:
    - bloqueia SHOW/SYNC do tooltip enquanto existir dragState ativo, impedindo que o hover reapareça por baixo do ghost durante o gesto;
    - endurece o gate histórico 392 para aceitar feedback player-facing via lastOutcomeCode, eliminando falso negativo do runner legado sem mascarar o contrato de bloqueio físico;
    - padroniza a legenda "O que deseja fazer?" com a mesma hierarquia visual de "Onde aplicar o kit?";
    - ajusta geometria do header (Operador/Unidade/Carga/barra) para melhor leitura no topo;
    - atualiza textos/versionamento/ações de teste para D.5 e adiciona gates 573..580;

    0.12-D.4:
    - corrige a expressão do gate 562 em fn_runDelivery0_12CheckpointD3Tests.sqf, eliminando o erro de sintaxe `Faltante )` no RPT;
    - tooltip mantém a superfície runtime/pass-through, mas com fundo translúcido (glass) em vez de bloco quase opaco;
    - mantém DnD, ghost, hit-test por display e hierarquia visual das ações;
    - adiciona gates 567..572 para validar registro do runner D.4, hotfix do runner D.3, contrato visual do tooltip glass e invariância do runtime;

    A 0.12-C.6 permanece apenas como checkpoint histórico reprovado por regressão do DnD.

    0.12-D.3:
    - restaura tooltip visível de Catálogo, Kit Selecionado e Conteúdo do Equipamento sem remover o DnD por display;
    - tooltip passa a ser runtime/pass-through, independente do tooltip nativo que deixou de aparecer após C.7;
    - hover usa MouseEnter/MouseExit apenas em ícone/nome e MOVE reaproveita o onMouseMoving já existente, sem fazer varredura de tabelas a cada frame;
    - drag ativo força o tooltip a sumir antes do ghost e unload também limpa a superfície transitória;
    - "Destino de aplicação" vira "Onde aplicar o kit?" e as operações recebem a legenda "O que deseja fazer?" sem deslocar as duas linhas de botões;
    - tooltips dos sete botões de destino/operação são reescritos em linguagem de jogador;
    - corrige o defeito de registro que deixava runDelivery0_12CheckpointD2Tests fora de CfgFunctions e registra também D.3;
    - gates 559..566 validam tooltip runtime, hierarquia visual, runner registration, cleanup e invariância;

    0.12-D.2:
    - header em duas linhas compactas: identidade na primeira; operação/carga na segunda;
    - textos de destino, visualização, DnD, confirmações e resultados reescritos em português natural;
    - códigos técnicos/commandId permanecem no RPT/estado, não na mensagem normal do jogador;
    - gates históricos 234/304/310 acompanham a semântica atual em vez de strings antigas;
    - gates 213/347 passam a diagnosticar fingerprint e só toleram drift ambiental restrito a slots de armas quando o contrato Draft/Storage permanece estaticamente não físico;
    - gates 543..550 são modernizados para o header de duas linhas sem renumerar IDs;
    - gates 551..558 validam layout D.2, linguagem amigável, runner hardening e invariância;

    0.12-D.1:
    - separa Operador, Unidade e Carga em zonas próprias no header, com geometria não sobreposta;
    - centraliza o status operacional e traduz target/view para rótulos player-facing;
    - mantém slot futuro imediatamente antes do Fechar sem ocupar o espaço da barra de carga;
    - adiciona divisor inferior discreto no header para hierarquia visual;
    - limpa tooltips/textos de Draft/VIEW/PHYSICAL quando o jogador não precisa conhecer termos internos;
    - preserva os quatro painéis, buscas, DnD, ghost, Catálogo virtual, EXACT e motor físico;
    - gates 543..550 validam layout, tradução, player-facing cleanup, runtime smoke e invariância;

    0.12-C.8.1:
    - remove os três controles estáticos de ghost do diálogo;
    - cria um único RscStructuredText em runtime quando o drag realmente entra em ACTIVE;
    - criação tardia garante z-order superior às CT_CONTROLS_TABLE já materializadas;
    - o controle runtime é disabled/pass-through e não participa de hit-test/dispatcher;
    - START chama SHOW explicitamente; POINTER_MOVE ativo chama MOVE usando getMousePosition;
    - DROP/CANCEL/UNLOAD executam ctrlDelete e limpam o handle em uiNamespace;
    - telemetria GHOST CREATE/MOVE_FIRST/HIDE prova o lifecycle no RPT sem flood;
    - gates 537..542 validam o caminho real do handler, não somente chamadas diretas ao helper visual;

    0.12-C.8:
    - preserva integralmente a autoridade de ponteiro/hit-test da C.7;
    - restaura feedback visual de "item na mão" por proxy não interativo que acompanha getMousePosition;
    - proxy exibe ícone + nome congelados no START, sem participar do hit-test e sem consumir MouseUp;
    - Meus Kits (drag nativo) também recebe o mesmo proxy visual quando o START é observado;
    - cancel/drop/unload escondem o proxy de forma determinística;
    - adiciona gates 531..536 para presença, payload visual, movimento, pass-through, cleanup e invariância;

    0.12-C.7:
    - torna o display a autoridade do gesto de ponteiro para Catálogo, Equipment e Draft;
    - usa MouseButtonDown do display para armar uma origem e MouseMoving apenas como DELTA de viagem;
    - só inicia DnD após limiar mínimo, preservando clique/seleção e impedindo botões de virarem alças;
    - resolve a origem em linhas reais CT_CONTROLS_TABLE por hit-test de Picture/Name materializados;
    - resolve destinos de painel em coordenadas UI autoritativas com getMousePosition no runtime;
    - centraliza bounds de Kit Selecionado e Equipment em macros compartilhadas com o layout;
    - mantém Meus Kits no drag nativo, mas usa o mesmo finalizador de drop e os mesmos bounds;
    - corrige os gates 516/520/522/523 da C.6 sem renumerar IDs;
    - adiciona gates 525..530 para a cadeia real pointer->source->threshold->target->drop;
    - preserva Catálogo virtualizado, botões reais, EXACT, X/Delete imediato, Storage Guard e refreshes focais.
*/

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION "0.13-A"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION "0.13.0.1"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD "0.13.0.1-a-server-authority-foundation"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER "ServoPeregrino_Organizador_Items"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR "ServoPeregrino_Organizador_Items_initialized"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR "ServoPeregrino_Organizador_Items_runtime"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR "ServoPeregrino_Organizador_Items_repository"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR "ServoPeregrino_Organizador_Items_storageTestSuffix"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ACTIONS_VAR "ServoPeregrino_Organizador_Items_testActions"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR "ServoPeregrino_Organizador_Items_lastTestResult"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR "ServoPeregrino_Organizador_Items_testRunning"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR "ServoPeregrino_Organizador_Items_testOrchestrator"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ITEMKIT_COUNTER_VAR "ServoPeregrino_Organizador_Items_itemKitIdCounter"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR "ServoPeregrino_Organizador_Items_catalogCache"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR "ServoPeregrino_Organizador_Items_catalogMetrics"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR "ServoPeregrino_Organizador_Items_catalogBuildState"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR "ServoPeregrino_Organizador_Items_draftState"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR "ServoPeregrino_Organizador_Items_uiState"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR "ServoPeregrino_Organizador_Items_uiCatalogProjection"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR "ServoPeregrino_Organizador_Items_publicLibrary"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC "SP_ORG_ITEMS_PUBLIC_LIBRARY"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR "ServoPeregrino_Organizador_Items_publicAuthority"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_MAGIC "SP_ORG_ITEMS_PUBLIC_AUTHORITY"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_REQUEST_COUNTER_VAR "ServoPeregrino_Organizador_Items_publicRequestCounter"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_PENDING_VAR "ServoPeregrino_Organizador_Items_publicPending"

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR "ServoPeregrino_Organizador_Items_applicationState"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_LOCK_TIMEOUT 30
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR "ServoPeregrino_Organizador_Items_uiDisplay"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_COMMAND_COUNTER_VAR "ServoPeregrino_Organizador_Items_uiCommandCounter"

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD 0
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_CAPABILITY "nexus.runtime"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY "items.runtime"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY "items.ui"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INTERFACE_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_EVENT "items.runtime.ready"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC "SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC "SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CAPTURE_DRAFT_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD 7700
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE 32
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER "PLAYER_CONTAINERS"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER "CONFIG_ALL"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION 1
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_NAME_MAX_LENGTH 80

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT 363
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_NEW_GATE_COUNT 27
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_FINAL_GATE_COUNT 390
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_0_7_HOTFIX_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_0_7_GATE_COUNT 398
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_A_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_A_CUMULATIVE_GATE_COUNT 406
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_CUMULATIVE_GATE_COUNT 414
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_1_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_1_CUMULATIVE_GATE_COUNT 420
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_2_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_2_CUMULATIVE_GATE_COUNT 422
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_3_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_3_CUMULATIVE_GATE_COUNT 424
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_5_GATE_COUNT 14
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_5_CUMULATIVE_GATE_COUNT 428
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_6_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_6_CUMULATIVE_GATE_COUNT 436
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_6_1_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_6_1_CUMULATIVE_GATE_COUNT 436
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_7_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_B_7_CUMULATIVE_GATE_COUNT 442
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_C_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_C_CUMULATIVE_GATE_COUNT 450
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_D_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_11_CP_D_CUMULATIVE_GATE_COUNT 460
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_A_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_A_CUMULATIVE_GATE_COUNT 468
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_B_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_B_CUMULATIVE_GATE_COUNT 478
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_CUMULATIVE_GATE_COUNT 488
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_2_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_2_CUMULATIVE_GATE_COUNT 494
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_3_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_3_CUMULATIVE_GATE_COUNT 500
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_4_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_4_CUMULATIVE_GATE_COUNT 506
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_5_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_5_CUMULATIVE_GATE_COUNT 514
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_6_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_6_CUMULATIVE_GATE_COUNT 524
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_7_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_7_CUMULATIVE_GATE_COUNT 530
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_CUMULATIVE_GATE_COUNT 536
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_1_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_1_CUMULATIVE_GATE_COUNT 542
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_1_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_1_CUMULATIVE_GATE_COUNT 550
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_2_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_2_CUMULATIVE_GATE_COUNT 558
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_3_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_3_CUMULATIVE_GATE_COUNT 566
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_4_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_4_CUMULATIVE_GATE_COUNT 572
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_5_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_5_CUMULATIVE_GATE_COUNT 580
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_CUMULATIVE_GATE_COUNT 590
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_1_GATE_COUNT 4
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_1_CUMULATIVE_GATE_COUNT 594
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_2_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_2_CUMULATIVE_GATE_COUNT 602
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_3_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_3_CUMULATIVE_GATE_COUNT 610
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_4_GATE_COUNT 7
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_4_CUMULATIVE_GATE_COUNT 617
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_0_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_0_CUMULATIVE_GATE_COUNT 627
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_1_GATE_COUNT 6
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_1_CUMULATIVE_GATE_COUNT 633
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_2_GATE_COUNT 5
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_2_CUMULATIVE_GATE_COUNT 638
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_3_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_3_CUMULATIVE_GATE_COUNT 646
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_4_GATE_COUNT 8
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_4_CUMULATIVE_GATE_COUNT 654
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_13_A_GATE_COUNT 10
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_13_A_FIRST_GATE 655
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_13_A_LAST_GATE 664

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_IDC 2088
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_IDC 4088

#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC 2104
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC 4140
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC 3140
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_NONE "NONE"

// Authoritative full-panel bounds. Shared by the dialog and DnD hit-test so layout and logic cannot drift.
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_X (safeZoneX + 0.196 * safeZoneW)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_Y (safeZoneY + 0.052 * safeZoneH)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_W (0.252 * safeZoneW)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_H (0.815 * safeZoneH)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_X (safeZoneX + 0.794 * safeZoneW)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_Y (safeZoneY + 0.052 * safeZoneH)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_W (0.194 * safeZoneW)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_H (0.815 * safeZoneH)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DND_POINTER_THRESHOLD (8 * pixelH)
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_RUNTIME_IDC 7704
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC 7705
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR "ServoPeregrino_Organizador_Items_uiItemTooltipCtrl"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_SOURCE_IDC_VAR "ServoPeregrino_Organizador_Items_uiItemTooltipSourceIDC"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR "ServoPeregrino_Organizador_Items_uiDragGhostCtrl"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR "ServoPeregrino_Organizador_Items_uiDragGhostMoveCount"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_LOGGED_VAR "ServoPeregrino_Organizador_Items_uiDragGhostMoveLogged"
#define SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_SOURCE_KEY_VAR "ServoPeregrino_Organizador_Items_uiDragGhostSourceKey"
