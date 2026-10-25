# Roadmap — Policy + Policy Editor

**Planejamento:** 22/10/2026 | **Checkpoint 24/10/2026:** **P0 EM REVISÃO FINAL (smoke engine SP A–F 160/160 PASS; revisão de contrato, regex real e teste Python pendentes); P1–P7 PENDENTES**.
**Fonte funcional:** [README do projeto](README.md) | **módulo proprietário:** [Policy](../../modules/Policy.md).

> **CHECKPOINT AUDITORIA 22/10/2026 (histórico):** naquela data todo P0–P7 estava pendente. P0 deve diferenciar claramente fonte interna (fallback vazio) de fonte externa (opt-in) e decidir técnica de configuração **sem presumir** `CfgSPORGPolicy` já implantado. A política é **estática por padrão**; ativação de nova revisão em runtime é capacidade futura opcional. Validar explícito: UI do jogador com blacklist não inclui proibidos, mas o editor mostra catálogo base completo; ausência de mod permanece vermelha; role kit fora; ícones dos botões ficam texto. Detalhes: [auditoria](../../73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md) e [continuidade](../../74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md).

**P0 atual:** [Contratos, fontes, testes e gates](P0_CONTRACTS_20261024.md). Smoke Arma SP A/B 20/20 e C–F 140/140 aprovados via RPT ([evidência A/B](evidence/P0_SP_SMOKE_RPT_20261024.md), [C–F](evidence/P0_NEGATIVE_SP_RPT_20261024.md)); gates de fechamento de contrato/regex e implementação do loader continuam pendentes; nenhum código runtime foi implementado.

## Estratégia geral

Construir um módulo Policy **opcional, genérico, sem dependência do BGD**, e posteriormente um editor administrativo como frontend desse contrato. Items e Weapons são consumidores, não proprietários de regras. Nunca iniciar por alterar o UICommon/Items aprovado sem candidato versionado e smoke SP.

**Sequência recomendada:** contrato → motor puro → políticas configuráveis → integração Items/cache → UX de kits → editor local/import/export → ativação admin e sync MP → integrações externas opcionais.

| Fase | Escopo e entregáveis | Critério de saída | Testável apenas em SP? |
|---|---|---|---|
| **P0 — Contrato e spike (em andamento; SP pendente)** | Esquema `PolicySnapshot`, `PolicyDecision`, nomes de config/caminhos, origem interna vs servidor, roles permitidos, import/export seguro, testes do editor sem CBA/ACE | Documentação canônica, exemplos, regras A/B/C testadas em fixtures; spike de clipboard/file loading Arma; não criar acoplamento | Sim |
| **P1 — Núcleo Policy 0.1-A** | Addon `Policy` opcional, lista vazia OPEN, whitelist, blacklist, COMBINED, prioridade DENY, classnames indexados, validação de arrays, status/revisão | 100% dos modos A/B/C em testes isolados e SP; sem impactar catálogo Items quando Policy ausente | Sim |
| **P2 — Configuração e descoberta 0.1-B** | Fallback interno do addon, fonte de missão/servidor explicitamente nomeada, precedência de configuração, carregamento inicial, detecção de ausência, freeze por sessão, sem busca por configs externas desconhecidas | Servidor com listas vazias e sem Policy mantém comportamento original; configuração conhecida sobrepõe fallback; fonte e hash visíveis no RPT | SP e host; MP autoritativo depois |
| **P3 — Items e caches 0.1-C** | Integração via capability; base de catálogo sem blacklist vs projeção autorizada; invalidation por `policyRevision`; kit awareness ambiental/política; cores vermelho/amarelo/laranja por prioridade; filtro no catálogo normal | Scan `CONFIG_ALL` não reinicia quando muda apenas Policy; kit salvo intacto; destaque correto de mods ausentes e proibidos; focused refresh, benchmark antes/depois | Sim |
| **P4 — Aplicação segura 0.1-D** | Rejeições `POLICY_DENIED` / `CLASS_UNAVAILABLE`, filtro antes de ADD, cópia lógica parcial, REMOVE liberado, preflight SUBSTITUIR/CLEAR, rollback e mensagens | Cenários 20 unidades (permitidas+proibidas+ausentes) produzem resultado parcial fiel sem destruir originais; nenhum caminho físico pula Policy | Sim; autoridade MP em P6 |
| **P5 — Editor local e portabilidade 0.1-E** | Tela de catálogo **completo**, busca/categoria, add/remove whitelist/blacklist, conflito, import, export, preview/diff, salvar rascunho local; botão `ATUALIZAR CACHE` da política sem reconstrução completa | Jogador comum prepara/exporta listas mas não ativa a do servidor; round-trip dados, sem SQF arbitrário; invalid input não corrompe política | Sim; clipboard MP requer experimento |
| **P6 — Administração/sync MP 0.1-F** | Submeter/ativar política somente admin, autenticação no servidor, `revision/hash`, sync de clientes, JIP, botão refresh individual, aviso admin opcional e atualização automática de segurança | Host+2 clientes; cliente não-admin não altera policy; JIP recebe snapshot, stale/replay rejeitados; auto-update sem aviso funciona; execução física validada no servidor; RPTs completos | **Não** — requer MP real |
| **P7 — Adapters e hardening 0.1-G** | BGD blacklist como adapter opcional, integração external config CBA se desejada, Role Kits somente se nova decisão, stress e catálogo de milhares de classes, release PBO/docs | Com e sem BGD; sem Policy instalado; política vazia; blacklist+whitelist; desempenho dentro do orçamento medido; assinatura/publicação separada | Parcial + MP |

### Gates transversais e testes específicos

**Política:**
- Ambas vazias => OPEN; whitelist vazia+blacklist cheia => blacklist opera; blacklist vazia+whitelist cheia => whitelist opera; ambas => whitelist menos blacklist; conflito => DENY.
- Classe instalada porém negada = AMARELO; classe ausente (qualquer política) = VERMELHO; linha somente alterada = LARANJA; múltiplos estados = vermelho > amarelo > laranja, tooltip com todos.
- Classe ausente não destrói kit e não bloqueia entrada permitida e instalada; kit com qualquer ausente em vermelho.
- Kit com classe restrita preserva entry original e não aplica item; remoção do próprio inventário funciona; snapshot privado e público não são regravados.
- A versão do mod/servidor e a origem autoritativa aparecem em diagnóstico, sem imprimir listas sensíveis desnecessariamente.
- Editor mostra **todos** os itens descobertos para administrar regras; o Catálogo normal Items mostra apenas autorizados.

**Cache:**
- Baseline de medição registrada: CONFIG_ALL visita cerca de **73.470** classes e retorna **7.092** itens, início 24–27 s dependendo da execução; tempos reais precisam ser re-medidos em mesmos modsets.
- Atualização de Policy não deve multiplicar scanners nem superar visivelmente o orçamento de render/focused refresh.
- Botão de refresh do usuário NÃO muda política do servidor e não faz rebuild `CONFIG_ALL` por padrão.
- Revisão publicada por admin invalida cache de autorização/kit; banner de aviso opcional; segurança atualiza obrigatoriamente.

**Segurança:**
- Addon Policy ausente não impede Items/Weapons em OPEN; apenas o recurso de Policy fica indisponível.
- Política obrigatória pendente não vira OPEN silenciosamente.
- Admin autenticado no servidor para activation; bloquear requisição de cliente comum e alterações maliciosas de revision/import.
- Evitar política global em `CfgRemoteExec`: declarar apenas funções específicas sem sobrescrever `mode`/ `jip` globais da missão.
- JIP, disconnect, reconnect e revisão alterada durante pedido de equipar devem ter testes MP.

**Portabilidade:**
- Arquivo importado compatível com schema sem executar código. Export -> Import idempotente.
- Verificar limitações de clipboard no Arma MP (CBA Settings registra possível bloqueio).
- Se import/export de arquivo não for viável via SQF nativo, usar caminho administrativo documentado ou provider opcional; não adicionar extensão obrigatória.

## Critérios de priorização

**Não iniciar P6** enquanto não houver capacidade de testar multiplayer com cliente externo.  
**Não iniciar P5** sem P0/P1 e contrato de serialização.  
O editor pode virar produto independente quando contrato/capabilities estiverem maduros, ou ser interface em Policy; não criar dependência obrigatória entre Items ↔ editor.  
**Não consumir todos os eventos para recalcular Policy**; servidor muda raramente, invalidation é por revisão.  
**Não retomar botões gráficos de Items ou Weapons** nesta frente — ficam no banco de ícones aguardando eventual decisão futura.

## Milestones sugeridos

- **M1 — Pure Policy:** P0–P2; funcionamento OPEN/deny/allow offline e SP.
- **M2 — Player safety:** P3–P4; Items com catálogo filtrado, aviso de kits, aplicação parcial.
- **M3 — Editor portátil:** P5; construir/importar/exportar listas e refresh manual local.
- **M4 — Autoridade e distribuição:** P6–P7; admin, revisões, JIP, adapters, pacote PBO.

Nenhuma dessas milestones foi executada; projetos anteriores de Items (R2.2) permanecem separados.
