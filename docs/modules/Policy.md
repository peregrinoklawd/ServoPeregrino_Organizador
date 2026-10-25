# Policy — módulo opcional de autorização de itens/equipamentos

**Data da consolidação:** 22/10/2026  
**Status (24/10/2026):** P0 contratos/fixtures **EM ANDAMENTO**, smoke SP A–F **160/160 PASS** ([A/B](../projects/policy-editor/evidence/P0_SP_SMOKE_RPT_20261024.md), [C–F](../projects/policy-editor/evidence/P0_NEGATIVE_SP_RPT_20261024.md)), Python 7/7 PASS; auditoria P0 G **REVIEW**, G2 concluída **PASS**, todas 532 elegíveis recuperadas por permitir dígitos iniciais; Python revisado 8/8 PASS, SQF H RPT pendente; módulo Policy **NÃO IMPLEMENTADO**. Ver [P0](../projects/policy-editor/P0_CONTRACTS_20261024.md) e [preparação P0 G](../projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_PREP_20261025.md).  
**Proprietário único:** `ServoPeregrino_Organizador_Policy` (futuro PBO); dependência planejada: Nexus.  
**Projeto do editor:** [../projects/policy-editor/README.md](../projects/policy-editor/README.md) e [ROADMAP](../projects/policy-editor/ROADMAP.md).

## Esclarecimentos da auditoria — 22/10/2026 (prevalecem sobre alternativas anteriores)

- **Blacklist e whitelist são estáticas por padrão na sessão.** O usuário informou que, na realidade do BGD, são definidas antes de abrir o servidor. A possibilidade de um administrador **publicar revisão durante a partida** é uma capacidade opcional futura do Editor/MP, **não** é condição para o primeiro Policy 0.1-A/B nem implica polling contínuo.
- **Origem versus autoridade:** a escolha do arquivo/config exato onde o servidor depositará suas listas **ainda está EM ABERTO para P0**; o usuário apenas determinou que **servidor/admin mandam**, e que cliente comum só pode preparar/exportar listas. A configuração interna nasce vazia e a externa é sempre opt-in explícito. **Não** transformar o exemplo `CfgSPORGPolicy` num contrato implementado.
- **Classes ambientalmente ausentes no print:** o usuário confirmou que o surgimento de `n/d` e `peso ?` coincidiu com a remoção dos mods de sua modlist. Isso é evidência de teste do operador. O código deve usar `isClass`/validação ambiental como confirmação formal, e não inferir ausência apenas do texto.
- **Cor/estados concorrentes:** VERMELHO para ausência, AMARELO para restrição, LARANJA para modificação são decisões explícitas. **Ausência (vermelho) prevalece** em combinações. A sugestão de **amarelo acima do laranja** quando um item *presente* está simultaneamente restrito e alterado **ainda precisa de validação UX**; preservar motivo secundário em tooltip/resultado. Símbolos substituindo cores foram cogitados e **adiados**.
- **Movimentação de kit não é operação única:** (a) *abrir para editar* preserva todas as ItemEntries; (b) *copiar/combinar entre drafts* pode gerar apenas subconjunto autorizado e disponível no destino sem regravar origem; (c) *aplicar fisicamente* filtra restritos/ausentes e ainda verifica capacidade. Confirmar semântica com testes próprios.
- **Catálogo administrativo não filtrado ≠ Catálogo de jogador filtrado:** conservar um catálogo base reutilizável; não destruir os metadados das classes negadas nem executar scan completo dos mods quando só muda uma revisão Policy.
- **Role Kit:** o usuário expressou preferência **contra limitação por papel**; registrar como hipótese opcional e não como feature prometida.
- **Status:** todos estes itens Policy são **projetados**, não testados ou implementados. Ver a [auditoria integral](../73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md) e [continuidade autossuficiente](../74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md).

## 1. Motivo e limites

Policy é o dono único dos critérios de allow/deny. Items, Weapons, Equipment e outros módulos **consultam** Policy; não implementam listas, regras ou renderizadores próprios duplicados de avaliação. UICommon oferece controles genéricos e não conhece autorização, catálogo, classes ou usuário.

O SP_ORG opera **com ou sem BGD** e não deve vasculhar os mods instalados tentando descobrir blacklists arbitrárias de terceiros. Integrações para BGD/Role Kits/FTAC poderão existir em *adapters* explícitos e opcionais. **Role Kits fica fora do escopo presente**; não bloquear jogador por papel/função sem nova decisão. Os botões de Items permanecem **somente texto**. PNGs aprovados em `assets/ui/icons/items/approved/` estão preservados e aguardam possível uso futuro.

## 2. Regras aprovadas (escopo classes exatas, v0.1)

| Whitelist | Blacklist | Autorização |
|---|---|---|
| vazia | vazia | OPEN: autorizar classes elegíveis existentes no modset |
| vazia | com classes | todas elegíveis **exceto** as da blacklist |
| com classes | vazia | **somente** as classes da whitelist |
| com classes | com classes | apenas whitelist **menos** blacklist; **DENY prevalece** em conflito |

Uma lista vazia desativa apenas sua própria restrição; não cancela a outra lista. Normalizar classnames, rejeitar entradas malformadas, duplicatas e configurações inválidas (sem executar texto importado como código). Generalizações por baseClass/addon/tag ficam **fora da primeira entrega**, embora constem como possibilidades antigas em `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`.

**Disponibilidade ambiental** é independente de **autorização**. Classe de mod ausente é indisponível (não simplesmente restrita), mesmo que esteja na whitelist. Um kit pode conter simultaneamente entradas válidas, proibidas e indisponíveis.

## 3. Configuração: onde vive e quem manda

### Fonte interna — fallback do próprio addon Policy

O futuro addon Policy possuirá **configuração conhecida e explícita**, definida por ele (nomes/caminhos/versionamento a serem congelados no contrato, por exemplo `CfgSPORGPolicy`). Por padrão, whitelist e blacklist estarão **vazias**: funcionamento irrestrito em SP/servidor sem políticas fornecidas. Não há busca automática por configurações de mods alheios.

### Fonte do servidor / missão — somente opt-in explícito

O operador poderá fornecê-las em um local suportado e declarado pelo SP_ORG (config do servidor, configuração da missão ou arquivo/pacote de política carregado por um mecanismo documentado do módulo). Escolher mecanismo concreto após spike de compatibilidade Arma. A ideia de settings CBA é **opção de adapter**, não dependência obrigatória.

**Precedência de origem proposta** (diferente da precedência allow/deny): política efetiva publicada/ativada pelo servidor > configuração explícita do servidor/da missão carregada na inicialização > fallback interno do addon Policy. **O cliente não tem autoridade sobre a política efetiva de um servidor.**

- Em SP: instância local é a autoridade; sem configuração externa, usa fallback vazio.
- Em MP: o servidor inicia/valida a política autoritativa; comunica `policyRevision`, `policyHash` e snapshot de regras aos clientes; os clientes aplicam visibilidade local **após** confirmação da versão.
- **Não é obrigatório receber configuração externa**; se o servidor não tiver Policy/nenhuma política for configurada, o contrato funciona em OPEN onde a instalação permitir fallback. Se existir política obrigatória ainda não sincronizada, não interpretar atraso como autorização irrestrita de operações protegidas.
- Cliente comum pode montar/editar uma **lista de trabalho local** e exportá-la, mas **não** instalar/alterar as regras ativas do servidor. Admin pode submeter requisição de ativação; servidor identifica e autoriza o remetente **server-side**. Não confiar em flag `isAdmin` informada pelo cliente.

A configuração não precisa mudar durante a partida; edição e sincronização ao vivo são uma **capacidade opcional planejada** do projeto do editor, com revisão publicada e atualização de caches.

## 4. Visibilidade, preservação e UX

- **Catálogo normal dos jogadores:** exibir só itens disponíveis e permitidos. O editor de políticas deve ter visão administrativa **sem filtro** dos itens catalogáveis para possibilitar colocá-los nas listas.
- **Kits existentes:** preservar *todas* as ItemEntries; não apagar nem regravar ao mudar whitelist, blacklist ou modset. O catálogo filtrado não é fonte de verdade para classificar kits persistidos.
- **Rascunho:** exibir classes proibidas/ausentes com mensagens; preservar entradas originais para edição e salvamento. A operação de aplicar/copiá-las em contexto restrito poderá usar apenas o subconjunto elegível e informar rejeições. O kit de origem permanece intacto.
- **Disponibilidade:** usar a validação ambiental de className; `n/d` e `peso ?` são sintomas de metadados não resolvidos, não devem servir como teste único de ausência.

### Cores acordadas

| Elemento / estado | Apresentação |
|---|---|
| Classe elegível/autorizada | Normal |
| Classe proibida por whitelist/blacklist | **Amarelo** (ATENÇÃO) |
| Classe de mod ausente | **Vermelho** (INDISPONÍVEL) |
| Linha de rascunho diferente do kit salvo | **Laranja** (ALTERADA) |
| Kit contém só entradas restritas, todas classes presentes | Nome em amarelo |
| Kit contém qualquer classe ausente, inclusive misturado com proibidos | Nome em vermelho |
| Linha simultaneamente ausente/restrita/alterada | **Vermelho** prevalece; tooltip/mensagem preservam todos os motivos |
| Linha simultaneamente restrita e alterada, sem classe ausente | Amarelo prevalece na cor principal; tooltip preserva `ALTERADA` |
| HISTÓRICO do footer | Roxo constante; não reabrir R2.2 |

Paleta exata e contraste necessitam validação na UI real. Em futuro UI design, ícones adicionais de estado podem ser avaliados; **não adicionar nesta entrega**.

## 5. Aplicação parcial e segurança

Itens marcados como proibidos/indisponíveis **não** devem ser introduzidos fisicamente no inventário por aplicação de kit. O motor de planejamento e rejeições `BEST_EFFORT`/rollback do Items é ponto de extensão, **mas atualmente não aplica a política Policy**.

- ADD / aplicação parcial: planejar somente as entradas elegíveis; devolver quantidades aplicadas e motivos por item (restrito, ausente, capacidade etc.).
- REMOVE de item já presente: não bloquear remoção por blacklist.
- REPLACE / CLEAR e outras mutações destrutivas: preflight explícito/seguro antes de apagar conteúdo existente; preservar rollback; **não** interpretar blacklist como licença para apagar o loadout.
- Validação executora: consultar **índice/revisão de política** antes de ações protegidas (lookup barato), sem revarrer o catálogo; em MP, decisão do lado autoritativo do servidor. UI não é medida de segurança.
- Ações lógico/persistentes e cópia parcial devem preservar o original e explicar o subconjunto transferido; precisarão de gates próprios.

## 6. Cache e atualização sob demanda

Separar três caches/representações:
1. **Catálogo base** de classes realmente existentes (`CfgWeapons/CfgMagazines`), cujo scan caro só deve ocorrer uma vez por modset/build, salvo pedido explícito de reconstrução.
2. **Projeção de autorização** (classes permitidas/restritas), derivada da revisão atual da política por lookup indexado; em alteração das listas, invalidar **apenas esta projeção**, não o scan completo.
3. **Diagnóstico de kits** por kitId e versão/snapshot + política + modset; invalidar somente os alterados ou após nova política; não recarregar itens de mods ausentes tentando resolvê-los a cada frame.

A função Items `fn_invalidateCatalogCache.sqf` **já existe**, porém invalida o catálogo base e força novo scan. O futuro botão `ATUALIZAR CACHE` de Policy não deve usá-la indiscriminadamente.

- Entrada inicial da sessão / primeira interface: sync da política e construção de caches sob demanda; não executar revarredura de configs em toda abertura.
- Botão do jogador **Atualizar cache**: requisitar a revisão autoritativa mais recente, recomputar autorização/estado dos kits localmente e atualizar a UI; **sem necessidade** de rebuild do catálogo base se o modset é o mesmo.
- Admin publica revisão nova: servidor valida, incrementa revisão, atualiza snapshot e pode opcionalmente notificar jogadores; clientes recebem evento/invalidação e atualizam views. Mesmo com botão manual, uma política aplicada no servidor deve deixar a execução segura imediatamente.
- Administrador pode ter opção avançada **Reconstruir catálogo de mods**, explicitamente separada e custosa, quando justificável.
- Não usar polling por frame; usar refresh ao evento e ao clique.

## 7. Administração, import/export e limitações técnicas

O futuro editor Policy oferecerá catálogo **sem filtros de autorização**, busca/categorias, seleção, botões `ADICIONAR À WHITELIST`, `ADICIONAR À BLACKLIST`, `REMOVER`, `IMPORTAR`, `EXPORTAR`, `ATUALIZAR CACHE`; painel de listas, contagens, validação, diferenças e conflito de classes.

**Lista local de trabalho ≠ política ativa no servidor**. Jogador pode criar/editar/exportar localmente, mas não clicar em `PUBLICAR NO SERVIDOR` com efeito real. Só administrador autorizado pode ativar revisão no servidor.

Definir payload **somente dados**, versionado e validado (nunca `compile` de texto arbitrário). Testar viabilidade real de import/export no Arma 3: suporte de clipboard pode ser limitado em multiplayer; import/export de arquivo externo não pode ser prometido sem adapter/extensão ou mecanismo suportado. Um editor deve ser útil mesmo onde for possível apenas copiar/colar texto manualmente.

## 8. Roadmap e testes

Ver [projeto](../projects/policy-editor/README.md) e [roadmap](../projects/policy-editor/ROADMAP.md).

**Não implementado**: Policy addon, servidor de política, editor, integração Items/Weapons, cache de autorização, atualização distribuída, recoloração por política ou import/export funcional.

**Já existente para reaproveitar**: catálogo Items (7.092 itens no último modset testado), listagem e busca, cache de catálogo, invalidação explícita, validação de classe existente, planner `BEST_EFFORT` com rejeições, UICommon, contratos previstos no Nexus e server-authority como precedente na biblioteca pública (esta última ainda não homologada MP).

**Gate MP futuro obrigatório**: sincronismo de revisão, cliente malicioso não publica regras, consulta autoritativa server-side, JIP e possível atualização a quente; deixar fora das entregas SP iniciais.


## Checkpoint classname real 25/10/2026

P0 G avaliou 133.399 classnames na modlist real; 532 dos 54.003 elegíveis ficaram fora de `^[A-Za-z_][A-Za-z0-9_]{0,127}$` (529 também no pré-filtro Items). Identificadas classes válidas iniciadas por dígito em `@BGD - Tools of the Trade`; **não usar a regex antiga**. G2 comprovou que `^[A-Za-z0-9_]{1,128}# Policy — módulo opcional de autorização de itens/equipamentos

**Data da consolidação:** 22/10/2026  
**Status (24/10/2026):** P0 contratos/fixtures **EM ANDAMENTO**, smoke SP A–F **160/160 PASS** ([A/B](../projects/policy-editor/evidence/P0_SP_SMOKE_RPT_20261024.md), [C–F](../projects/policy-editor/evidence/P0_NEGATIVE_SP_RPT_20261024.md)), Python 7/7 PASS; auditoria P0 G **REVIEW**, G2 concluída **PASS**, todas 532 elegíveis recuperadas por permitir dígitos iniciais; Python revisado 8/8 PASS, SQF H RPT pendente; módulo Policy **NÃO IMPLEMENTADO**. Ver [P0](../projects/policy-editor/P0_CONTRACTS_20261024.md) e [preparação P0 G](../projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_PREP_20261025.md).  
**Proprietário único:** `ServoPeregrino_Organizador_Policy` (futuro PBO); dependência planejada: Nexus.  
**Projeto do editor:** [../projects/policy-editor/README.md](../projects/policy-editor/README.md) e [ROADMAP](../projects/policy-editor/ROADMAP.md).

## Esclarecimentos da auditoria — 22/10/2026 (prevalecem sobre alternativas anteriores)

- **Blacklist e whitelist são estáticas por padrão na sessão.** O usuário informou que, na realidade do BGD, são definidas antes de abrir o servidor. A possibilidade de um administrador **publicar revisão durante a partida** é uma capacidade opcional futura do Editor/MP, **não** é condição para o primeiro Policy 0.1-A/B nem implica polling contínuo.
- **Origem versus autoridade:** a escolha do arquivo/config exato onde o servidor depositará suas listas **ainda está EM ABERTO para P0**; o usuário apenas determinou que **servidor/admin mandam**, e que cliente comum só pode preparar/exportar listas. A configuração interna nasce vazia e a externa é sempre opt-in explícito. **Não** transformar o exemplo `CfgSPORGPolicy` num contrato implementado.
- **Classes ambientalmente ausentes no print:** o usuário confirmou que o surgimento de `n/d` e `peso ?` coincidiu com a remoção dos mods de sua modlist. Isso é evidência de teste do operador. O código deve usar `isClass`/validação ambiental como confirmação formal, e não inferir ausência apenas do texto.
- **Cor/estados concorrentes:** VERMELHO para ausência, AMARELO para restrição, LARANJA para modificação são decisões explícitas. **Ausência (vermelho) prevalece** em combinações. A sugestão de **amarelo acima do laranja** quando um item *presente* está simultaneamente restrito e alterado **ainda precisa de validação UX**; preservar motivo secundário em tooltip/resultado. Símbolos substituindo cores foram cogitados e **adiados**.
- **Movimentação de kit não é operação única:** (a) *abrir para editar* preserva todas as ItemEntries; (b) *copiar/combinar entre drafts* pode gerar apenas subconjunto autorizado e disponível no destino sem regravar origem; (c) *aplicar fisicamente* filtra restritos/ausentes e ainda verifica capacidade. Confirmar semântica com testes próprios.
- **Catálogo administrativo não filtrado ≠ Catálogo de jogador filtrado:** conservar um catálogo base reutilizável; não destruir os metadados das classes negadas nem executar scan completo dos mods quando só muda uma revisão Policy.
- **Role Kit:** o usuário expressou preferência **contra limitação por papel**; registrar como hipótese opcional e não como feature prometida.
- **Status:** todos estes itens Policy são **projetados**, não testados ou implementados. Ver a [auditoria integral](../73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md) e [continuidade autossuficiente](../74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md).

## 1. Motivo e limites

Policy é o dono único dos critérios de allow/deny. Items, Weapons, Equipment e outros módulos **consultam** Policy; não implementam listas, regras ou renderizadores próprios duplicados de avaliação. UICommon oferece controles genéricos e não conhece autorização, catálogo, classes ou usuário.

O SP_ORG opera **com ou sem BGD** e não deve vasculhar os mods instalados tentando descobrir blacklists arbitrárias de terceiros. Integrações para BGD/Role Kits/FTAC poderão existir em *adapters* explícitos e opcionais. **Role Kits fica fora do escopo presente**; não bloquear jogador por papel/função sem nova decisão. Os botões de Items permanecem **somente texto**. PNGs aprovados em `assets/ui/icons/items/approved/` estão preservados e aguardam possível uso futuro.

## 2. Regras aprovadas (escopo classes exatas, v0.1)

| Whitelist | Blacklist | Autorização |
|---|---|---|
| vazia | vazia | OPEN: autorizar classes elegíveis existentes no modset |
| vazia | com classes | todas elegíveis **exceto** as da blacklist |
| com classes | vazia | **somente** as classes da whitelist |
| com classes | com classes | apenas whitelist **menos** blacklist; **DENY prevalece** em conflito |

Uma lista vazia desativa apenas sua própria restrição; não cancela a outra lista. Normalizar classnames, rejeitar entradas malformadas, duplicatas e configurações inválidas (sem executar texto importado como código). Generalizações por baseClass/addon/tag ficam **fora da primeira entrega**, embora constem como possibilidades antigas em `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`.

**Disponibilidade ambiental** é independente de **autorização**. Classe de mod ausente é indisponível (não simplesmente restrita), mesmo que esteja na whitelist. Um kit pode conter simultaneamente entradas válidas, proibidas e indisponíveis.

## 3. Configuração: onde vive e quem manda

### Fonte interna — fallback do próprio addon Policy

O futuro addon Policy possuirá **configuração conhecida e explícita**, definida por ele (nomes/caminhos/versionamento a serem congelados no contrato, por exemplo `CfgSPORGPolicy`). Por padrão, whitelist e blacklist estarão **vazias**: funcionamento irrestrito em SP/servidor sem políticas fornecidas. Não há busca automática por configurações de mods alheios.

### Fonte do servidor / missão — somente opt-in explícito

O operador poderá fornecê-las em um local suportado e declarado pelo SP_ORG (config do servidor, configuração da missão ou arquivo/pacote de política carregado por um mecanismo documentado do módulo). Escolher mecanismo concreto após spike de compatibilidade Arma. A ideia de settings CBA é **opção de adapter**, não dependência obrigatória.

**Precedência de origem proposta** (diferente da precedência allow/deny): política efetiva publicada/ativada pelo servidor > configuração explícita do servidor/da missão carregada na inicialização > fallback interno do addon Policy. **O cliente não tem autoridade sobre a política efetiva de um servidor.**

- Em SP: instância local é a autoridade; sem configuração externa, usa fallback vazio.
- Em MP: o servidor inicia/valida a política autoritativa; comunica `policyRevision`, `policyHash` e snapshot de regras aos clientes; os clientes aplicam visibilidade local **após** confirmação da versão.
- **Não é obrigatório receber configuração externa**; se o servidor não tiver Policy/nenhuma política for configurada, o contrato funciona em OPEN onde a instalação permitir fallback. Se existir política obrigatória ainda não sincronizada, não interpretar atraso como autorização irrestrita de operações protegidas.
- Cliente comum pode montar/editar uma **lista de trabalho local** e exportá-la, mas **não** instalar/alterar as regras ativas do servidor. Admin pode submeter requisição de ativação; servidor identifica e autoriza o remetente **server-side**. Não confiar em flag `isAdmin` informada pelo cliente.

A configuração não precisa mudar durante a partida; edição e sincronização ao vivo são uma **capacidade opcional planejada** do projeto do editor, com revisão publicada e atualização de caches.

## 4. Visibilidade, preservação e UX

- **Catálogo normal dos jogadores:** exibir só itens disponíveis e permitidos. O editor de políticas deve ter visão administrativa **sem filtro** dos itens catalogáveis para possibilitar colocá-los nas listas.
- **Kits existentes:** preservar *todas* as ItemEntries; não apagar nem regravar ao mudar whitelist, blacklist ou modset. O catálogo filtrado não é fonte de verdade para classificar kits persistidos.
- **Rascunho:** exibir classes proibidas/ausentes com mensagens; preservar entradas originais para edição e salvamento. A operação de aplicar/copiá-las em contexto restrito poderá usar apenas o subconjunto elegível e informar rejeições. O kit de origem permanece intacto.
- **Disponibilidade:** usar a validação ambiental de className; `n/d` e `peso ?` são sintomas de metadados não resolvidos, não devem servir como teste único de ausência.

### Cores acordadas

| Elemento / estado | Apresentação |
|---|---|
| Classe elegível/autorizada | Normal |
| Classe proibida por whitelist/blacklist | **Amarelo** (ATENÇÃO) |
| Classe de mod ausente | **Vermelho** (INDISPONÍVEL) |
| Linha de rascunho diferente do kit salvo | **Laranja** (ALTERADA) |
| Kit contém só entradas restritas, todas classes presentes | Nome em amarelo |
| Kit contém qualquer classe ausente, inclusive misturado com proibidos | Nome em vermelho |
| Linha simultaneamente ausente/restrita/alterada | **Vermelho** prevalece; tooltip/mensagem preservam todos os motivos |
| Linha simultaneamente restrita e alterada, sem classe ausente | Amarelo prevalece na cor principal; tooltip preserva `ALTERADA` |
| HISTÓRICO do footer | Roxo constante; não reabrir R2.2 |

Paleta exata e contraste necessitam validação na UI real. Em futuro UI design, ícones adicionais de estado podem ser avaliados; **não adicionar nesta entrega**.

## 5. Aplicação parcial e segurança

Itens marcados como proibidos/indisponíveis **não** devem ser introduzidos fisicamente no inventário por aplicação de kit. O motor de planejamento e rejeições `BEST_EFFORT`/rollback do Items é ponto de extensão, **mas atualmente não aplica a política Policy**.

- ADD / aplicação parcial: planejar somente as entradas elegíveis; devolver quantidades aplicadas e motivos por item (restrito, ausente, capacidade etc.).
- REMOVE de item já presente: não bloquear remoção por blacklist.
- REPLACE / CLEAR e outras mutações destrutivas: preflight explícito/seguro antes de apagar conteúdo existente; preservar rollback; **não** interpretar blacklist como licença para apagar o loadout.
- Validação executora: consultar **índice/revisão de política** antes de ações protegidas (lookup barato), sem revarrer o catálogo; em MP, decisão do lado autoritativo do servidor. UI não é medida de segurança.
- Ações lógico/persistentes e cópia parcial devem preservar o original e explicar o subconjunto transferido; precisarão de gates próprios.

## 6. Cache e atualização sob demanda

Separar três caches/representações:
1. **Catálogo base** de classes realmente existentes (`CfgWeapons/CfgMagazines`), cujo scan caro só deve ocorrer uma vez por modset/build, salvo pedido explícito de reconstrução.
2. **Projeção de autorização** (classes permitidas/restritas), derivada da revisão atual da política por lookup indexado; em alteração das listas, invalidar **apenas esta projeção**, não o scan completo.
3. **Diagnóstico de kits** por kitId e versão/snapshot + política + modset; invalidar somente os alterados ou após nova política; não recarregar itens de mods ausentes tentando resolvê-los a cada frame.

A função Items `fn_invalidateCatalogCache.sqf` **já existe**, porém invalida o catálogo base e força novo scan. O futuro botão `ATUALIZAR CACHE` de Policy não deve usá-la indiscriminadamente.

- Entrada inicial da sessão / primeira interface: sync da política e construção de caches sob demanda; não executar revarredura de configs em toda abertura.
- Botão do jogador **Atualizar cache**: requisitar a revisão autoritativa mais recente, recomputar autorização/estado dos kits localmente e atualizar a UI; **sem necessidade** de rebuild do catálogo base se o modset é o mesmo.
- Admin publica revisão nova: servidor valida, incrementa revisão, atualiza snapshot e pode opcionalmente notificar jogadores; clientes recebem evento/invalidação e atualizam views. Mesmo com botão manual, uma política aplicada no servidor deve deixar a execução segura imediatamente.
- Administrador pode ter opção avançada **Reconstruir catálogo de mods**, explicitamente separada e custosa, quando justificável.
- Não usar polling por frame; usar refresh ao evento e ao clique.

## 7. Administração, import/export e limitações técnicas

O futuro editor Policy oferecerá catálogo **sem filtros de autorização**, busca/categorias, seleção, botões `ADICIONAR À WHITELIST`, `ADICIONAR À BLACKLIST`, `REMOVER`, `IMPORTAR`, `EXPORTAR`, `ATUALIZAR CACHE`; painel de listas, contagens, validação, diferenças e conflito de classes.

**Lista local de trabalho ≠ política ativa no servidor**. Jogador pode criar/editar/exportar localmente, mas não clicar em `PUBLICAR NO SERVIDOR` com efeito real. Só administrador autorizado pode ativar revisão no servidor.

Definir payload **somente dados**, versionado e validado (nunca `compile` de texto arbitrário). Testar viabilidade real de import/export no Arma 3: suporte de clipboard pode ser limitado em multiplayer; import/export de arquivo externo não pode ser prometido sem adapter/extensão ou mecanismo suportado. Um editor deve ser útil mesmo onde for possível apenas copiar/colar texto manualmente.

## 8. Roadmap e testes

Ver [projeto](../projects/policy-editor/README.md) e [roadmap](../projects/policy-editor/ROADMAP.md).

**Não implementado**: Policy addon, servidor de política, editor, integração Items/Weapons, cache de autorização, atualização distribuída, recoloração por política ou import/export funcional.

**Já existente para reaproveitar**: catálogo Items (7.092 itens no último modset testado), listagem e busca, cache de catálogo, invalidação explícita, validação de classe existente, planner `BEST_EFFORT` com rejeições, UICommon, contratos previstos no Nexus e server-authority como precedente na biblioteca pública (esta última ainda não homologada MP).

**Gate MP futuro obrigatório**: sincronismo de revisão, cliente malicioso não publica regras, consulta autoritativa server-side, JIP e possível atualização a quente; deixar fora das entregas SP iniciais.


## Checkpoint classname real 25/10/2026

P0 G avaliou 133.399 classnames na modlist real; 532 dos 54.003 elegíveis ficaram fora de `^[A-Za-z_][A-Za-z0-9_]{0,127}$` (529 também no pré-filtro Items). Identificadas classes válidas iniciadas por dígito em `@BGD - Tools of the Trade`;  recupera as 532 elegíveis sem permitir caracteres especiais; validador Python e fixtures atualizados/8 PASS, protótipo SQF corrigido H pendente de execução na engine. [RPT G](../projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_RPT_20261025.md) / [preparação G2](../projects/policy-editor/evidence/P0_G2_REGEX_COMPARISON_PREP_20261025.md).


**Evidência G2 25/10:** [auditoria diferencial PASS](../projects/policy-editor/evidence/P0_G2_REGEX_COMPARISON_RPT_20261025.md), [regressão Python 8 PASS](../projects/policy-editor/evidence/P0_G2_PYTHON_REGRESSION_20261025.md), [H SQF pendente](../projects/policy-editor/evidence/P0_H_REVISED_CLASSNAME_SQF_PREP_20261025.md). P0 ainda em validação final, Policy runtime não implementado.
