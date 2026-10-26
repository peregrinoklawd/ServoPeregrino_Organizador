# Projeto futuro — Editor de Whitelist / Blacklist e Cache de Sessão

**Proposta registrada:** 22/10/2026  
**CHECKPOINT ATUAL 26/10/2026:** P0 fechado; **P1-A R1 68/68 PASS**, **P1-B Nexus REAL em missão SP 59/59 PASS** ([auditoria](evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md)); **P1-C addon Nexus+Policy em PBO não iniciado**. P2 loader, P3/P4 Items, P5 editor, P6 multiplayer e P7 adapters planejados.
**Módulo proprietário existente no planejamento:** `Policy`, futuro PBO opcional `ServoPeregrino_Organizador_Policy` (Nexus apenas).  
**Plano de execução:** [ROADMAP.md](ROADMAP.md)  
**Contrato base:** [../../modules/Policy.md](../../modules/Policy.md)

## Contexto e limites atuais (auditoria 22/10/2026)

A configuração de whitelist/blacklist do servidor será **estática inicialmente**, normalmente definida antes de iniciar a sessão. O recurso de **ativação de nova revisão pelo administrador em runtime**, com aviso opcional aos jogadores, é uma **evolução futura**; o botão local `ATUALIZAR CACHE` também é funcionalidade planejada, não implementada.

**Não estão tecnicamente fechados**: formato/serialização definitivo do import/export; escolha de API do Arma para clipboard/arquivo; nome e local da configuração interna e da fonte de servidor; forma concreta de sincronização MP e autenticação de admin; desacoplamento do scanner base quando Policy Editor roda sem Items. Esses são entregáveis do P0 e de spikes subsequentes — não fazer promessas de I/O arbitrário.

**Regras fechadas**: ambas listas vazias = OPEN; whitelist preenchida = allowlist; blacklist preenchida = denylist; juntas = whitelist menos blacklist; admin do servidor controla policy ativa; cliente comum pode editar/exportar apenas localmente. Nenhum filtro por Role Kit nesta fase.

## 1. Visão do usuário

Criar uma interface de administração (pode ser um módulo separado da família Organizador) que **exiba todos os itens elegíveis disponíveis dos mods ativos**, com busca/categorias, e permita montar **whitelist** e **blacklist** por clique em botões.

Os botões e capacidades desejados incluem:
- `ADICIONAR À WHITELIST`;
- `ADICIONAR À BLACKLIST`;
- `REMOVER DA LISTA` / limpar entrada selecionada (não apagar a outra lista sem intenção);
- `IMPORTAR` uma lista anteriormente exportada, apresentando prévia/diff e validação;
- `EXPORTAR` lista/snapshot completo para compartilhar com administradores e reutilizar em outra missão/servidor;
- `ATUALIZAR CACHE` da sessão (jogador ou admin);
- `ATIVAR/PUBLICAR POLÍTICA` **somente para administrador autenticado pelo servidor**;
- comando de admin `NOTIFICAR JOGADORES` opcional ao publicar revisão (mas a sincronização do estado é necessária independentemente do popup).

O administrador do servidor define a política autoritativa. O jogador comum pode usar o editor **local** como ferramenta de preparação/exportação; **não** pode publicar listas ativas nem interferir no servidor. Em SP, o operador da instância local pode validar listas.

A visualização administrativa precisa mostrar itens **inclusive atualmente restritos**, pois a finalidade é poder adicioná-los/removê-los das listas. O Catálogo normal de Items fica filtrado; não compartilhar semântica de "catálogo autorizado" com a tela de edição de regras.

### Layout funcional candidato (não visual aprovado)

```text
POLICY — EDITOR DE ITENS
  [Buscar classe ou nome...]  [TODOS] [ITENS] [MUNIÇÃO] [OUTRAS CATEGORIAS]

  CATALOGO COMPLETO DOS MODS      LISTAS DE POLÍTICA
  • Classe X                      [WHITELIST] [BLACKLIST]
  • Classe Y                      • X        • Z
  • Classe Z                      • Y
                                  [Remover]  [Limpar seleção]

  [Adicionar à whitelist] [Adicionar à blacklist] [Remover da lista]
  [Importar] [Exportar] [Validar] [Atualizar cache]
  [Administrador: Ativar política] [Notificar jogadores: SIM/NÃO]

  Rodapé: modo OPEN/COMBINED | revisão 12 | itens elegíveis | aviso de conflito
```

**Observação:** manter os botões da interface atual de Items **apenas texto**. Esta tela administrativa é um futuro módulo independente; não reabrir iconografia antes de nova decisão.

## 2. Fonte de dados e descoberta

- O editor reutiliza, por contrato, a enumeração de classes elegíveis de todos os mods ativos (CfgWeapons/CfgMagazines) sem duplicar o scan caro do Items. Para uso com Items ausente, definir provider/capability opcional de catálogo do servidor ou um provider independente da política; não criar dependência obrigatória Policy → Items.
- Lista interna vazia do Policy addon é fallback explícito; servidor/mission pode definir/fornecer regras em local documentado, **sem vasculhar configurações de terceiros**.
- O editor manipula classnames estáveis, não nomes exibidos. Visualização do classname, nome, categoria e addon ajuda conferência.
- Importar/exportar um objeto de dados versionado. Exemplo ilustrativo:
  ```text
  {
    schemaVersion: 1,
    policyName: "Servidor A",
    whitelist: ["class_a", "class_b"],
    blacklist: ["class_z"],
    scope: "ITEMS"
  }
  ```
  **Não é payload literal prometido para a engine**. Escolher codificação parseável/segura em spike, sem executar SQF arbitrário. Prever classificação de ausente/existente e diagnóstico de classnames duplicados/inválidos.
- A missão e o servidor só usam o arquivo/importação ativa depois de validação explícita e recebimento por canal autoritativo.
- Import/export pela área de transferência do jogo é um **risco real** em MP e precisa de prova prática. CBA Settings documenta que clipboard pode ser bloqueado no multiplayer; testar estratégias compatíveis (texto selecionável, arquivo de configuração importado no lado do servidor, adapter autorizado). Não garantir gravação/leitura livre no filesystem do cliente via SQF.

## 3. Ciclo de vida das políticas e caches

**Primeira abertura da sessão**:
1. servidor carrega política inicial ou OPEN; valida, indexa classnames e publica `revision/hash`;
2. cliente obtém `revision/hash` e aplica snapshot (ou OPEN se nenhuma política exigida); configura projeção de catálogo;
3. catálogo base é construído *quando necessário*, uma vez por modset/build; kits existentes classificados sob demanda;
4. interface do jogador mostra somente classes autorizadas; kits salvos mantêm todas as entradas e seus avisos.

**Alteração opcional em runtime por administrador**:
1. editar lista de trabalho e validar diff;
2. servidor confirma permissão administrativa, normaliza e valida import, eleva revisão e publica nova política efetiva;
3. clientes recebem invalidação e **atualizam projeção e classificação** sem varrer todos os 70k configs;
4. notificação visual opcional (`as listas foram atualizadas`), independente da atualização real;
5. execução física verifica a revisão autoritativa em momento seguro; item proibido não pode ser introduzido.

**Botão Atualizar Cache do jogador**:
- solicita o snapshot/revisão atual ao servidor, força a recomputação local das projeções relevantes, atualiza cores de kits e catálogo;
- **não** muda política, listas ou permissões do servidor;
- não dispara revarredura completa por padrão; opção explícita de "Reconstruir catálogo" somente se tecnicamente necessária e separada com alerta de custo;
- usuário pode usá-lo a qualquer momento, sem depender de notificação do admin.

O cache de política e o cache de itens disponíveis são distintos. `fn_invalidateCatalogCache.sqf` do Items existe, mas seu uso atual cancela e reconstrói o catálogo base; planejar uma invalidation mais localizada para o editor de políticas.

## 4. Aplicação a kits e estados visuais

- Kit com somente proibidos/pelo menos um proibido e **nenhum ausente** → nome amarelo.
- Kit com **qualquer classe indisponível**, mesmo misturado com proibidos → nome vermelho.
- Linha proibida (mas classe instalada) → amarelo; ausente → vermelho; linha alterada → laranja.
- Se um item tiver vários estados, **vermelho > amarelo > laranja**, e os demais estados permanecem detalhados no tooltip/rodapé.
- Não usar a cor do indicador SALVO/ALTERADO para expressar autorização.
- No catálogo normal, itens proibidos não aparecem. No editor administrativo, aparecem com indicação de status.
- Kits persistidos nunca são apagados/regravados automaticamente. Operações parciais com rejeições por motivo; remoção de equipamento proibido deve continuar permitida; substituições destrutivas precisam de preflight/rollback.
- Classes ausentes não são "simplesmente peso ?": usar validação `isClass` já existente e informar `ITEMS_CLASS_UNAVAILABLE`.

## 5. Acesso e administração

- Exibir botões de montagem/import/export para jogadores somente como **editor local de proposta**, com rótulo claro `NÃO ATIVA NO SERVIDOR`.
- Somente admin verificado **no servidor** pode ativar política ou ordenar notificação geral. Administradores de missão/mod poderão ter canal de configuração sem UI, a definir.
- Não confiar em dados de cliente quanto a UID/admin, classificação, revision ou autorização. Testar contra replay/stale requests, invalid imports, conflitos e mensagens JIP.
- Preservar política inicial padrão sem restrições, caso nenhum servidor defina lista; distinguir policy obrigatória ainda não sincronizada de política OPEN intencional.

## 6. Fora de escopo atual

- Não implementar Role Kits ou autorização automática por função. **Pendência opcional**, mesmo na comunidade BGD: decisão do usuário é não restringir papel neste momento.
- Não exigir BGD/FTAC; adaptar regras externas apenas futuramente e de forma explícita.
- Não desenvolver ícones gráficos de botões agora; manter a interface Items atual.
- Não disponibilizar funções de policy diretamente a clientes que contornem autenticação do servidor.
- Não alterar addon / missão Items / UICommon / Weapons neste planejamento.

## 7. Pesquisa e referências do repositório

- `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md` já designa Policy como dono único de whitelist/blacklist.
- `machine/MODULE_MATRIX.json` já registra Policy como `NEW_PLANNED_OPTIONAL_LAYER`.
- `addons/ServoPeregrino_Organizador_Items/functions/catalog/fn_buildCatalog.sqf`: catálogo base.
- `addons/ServoPeregrino_Organizador_Items/functions/catalog/fn_invalidateCatalogCache.sqf`: invalidação base já implementada.
- `addons/ServoPeregrino_Organizador_Items/functions/domain/fn_validateItemEntryEnvironmental.sqf`: existência de classe (não autorização).
- `addons/ServoPeregrino_Organizador_Items/functions/application/fn_createApplicationPlan.sqf`: planner e motivos de rejeição (sem Policy).
- `addons/ServoPeregrino_Organizador_Items/functions/library/fn_commitPublicKitSnapshotServer.sqf`: autoridade de snapshots públicos, distinta de Policy.

**Estado deste documento:** especificação para desenvolvimento futuro; **nenhum código de editor, botão, sync ou autenticação criado**.
