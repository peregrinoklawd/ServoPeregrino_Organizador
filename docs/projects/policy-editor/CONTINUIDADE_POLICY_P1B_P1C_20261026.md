# Continuidade autossuficiente Policy — P1-B → P1-C (26/10/2026)

**Repositório canônico:** `peregrinoklawd/ServoPeregrino_Organizador`.
**Branch de trabalho:** `feature/policy-0.1-b-nexus-integration`, baseada em `feature/policy-0.1-a-core` → `feature/policy-0.1-p0-contracts`.
**Baseline de Items/UICommon preservada:** `baseline/items-uicommon-r2-2-sp-homologated-20261021`, SHA `67f457414c37784ef0469e7235d39006342edb40`.
**Sem merge na main.** GitHub, não o histórico do chat, é a fonte da verdade. Nada em Items, Weapons, UICommon foi alterado nesta rodada.

## Checkpoint exato e escopo dos resultados

| Etapa | Status canônico | Evidência |
|---|---|---|
| P0 — contratos/viabilidade SP | FECHADO | G2 12/12, H 156/156, Python 8/8 com 32 fixtures |
| P1-A R1 — núcleo Policy puro SQF | **HOMOLOGADO EM MISSÃO SP 68/68 PASS** | [RPT](evidence/P1_A_R1_CORE_SP_RPT_PASS_20261026.md) |
| P1-B — Nexus REAL + Policy `CfgFunctions/preInit` de missão | **HOMOLOGADO EM MISSÃO SP 59/59 PASS** | [RPT mais recente](evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md) |
| P1-C — dois addons Nexus + Policy em **PBO** com `CfgPatches` e `requiredAddons` | **PENDENTE, PRÓXIMA ETAPA** | Ainda não construídos/testados no contexto P1 |
| P2–P7 | PLANEJADOS | Não foram iniciados pelo P1-B |

**Regra de interpretação:** P1-B validou *código-fonte verdadeiro e registro real do Nexus no contexto de missão*, e **NÃO** o runtime dos addons como PBO. Um `description.ext` de missão não prova o `config.cpp` de addon. **P1 inteiro permanece aberto até o gate P1-C** ou decisão explícita e documentada de escopo. Não alegar MP/JIP, servidor autoritativo, editor ou loader implementados.

## Último RPT auditado — 26/10/2026

**Arquivo:** `Texto colado(20261026-210613).txt`, 26.525 bytes, 330 linhas, SHA-256 `fe37a41b8fe353615bff55fd5c1441c8d4cf9d44771e4e19d330169e71971bd7`. É **recorte de execução da missão**, sem cabeçalho com build do executável (não inventar build nesse RPT).
**Missão:** `SP_ORG_Policy_P1_B_NexusIntegration.VR`, Preview Eden/VR. Arquivo preparado `SP_ORG_Policy_P1_B_Nexus_Integration_Lab_20261026.zip`, SHA-256 `618faca9a6fd4a23bfb890a29c1d1e59581af423c41cd5074021eb8b90416a32` (23 membros).
**Início da missão:** 18:04:08; init de Nexus e Policy: 18:04:12; testes: 18:04:16. CBA indica `isMultiplayer=false`, `isDedicated=false`, `hasInterface=true`.

Contabilidade **independente do resumo**: **79 logs P1-B = 18 BOOT exists=true + 1 START + 59 TEST PASS + 1 SUMMARY**; IDs únicos 59, grupos CFG=4, NEXUS=25, POLICY=30. **0 TEST FAIL, 0 FATAL, 0 Error in expression, 0 Error position, 0 Undefined variable, 0 scripts não encontrados** no recorte. Alguns **IDs** contêm a palavra `FAIL_CLOSED`, mas são casos que passaram — não contar busca ingênua por substring `FAIL` como falha.

```text
[SPORG_POLICY_P1_B] [SUMMARY] status=PASS pass=59 fail=0 total=59 expected=59 complete=true valid=true scope=MISSION_CFGFUNCTIONS_NEXUS_POLICY addonRuntime=false mp=false
```

**Logs de inicialização confirmados:**
```text
[SP_ORG] [NEXUS] [INFO] Nexus inicializado.
[SPORG_POLICY_P1] [INIT] evaluate=CAPABILITY_REGISTERED snapshot=CAPABILITY_REGISTERED state=CORE_ONLY_NO_LOADER_NO_AUTHORITY
[SPORG_POLICY_P1] [INIT] evaluate=CAPABILITY_ALREADY_REGISTERED snapshot=CAPABILITY_ALREADY_REGISTERED state=CORE_ONLY_NO_LOADER_NO_AUTHORITY
```

Provas: Nexus real `registerCapability`, `hasCapability`, `getCapability`, `listCapabilities`, `unregisterCapability` funcionaram; registrou-se `nexus.runtime`, `policy.evaluate` v1 e `policy.snapshot` v1; verificados metadados, owner, versão, normalização case-insensitive, idempotência, conflitos provider/version e restrições de remoção. O `Nexus_fnc_createResult`/ `isResult` **verdadeiros** foram usados, sem stub local. Os retornos reais Policy `validateExport/createContext/evaluate/snapshot` passaram, com deny-wins, classnames numéricos e ausência de policy required/optional.

**Avisos no RPT:** há warnings de mods externos como ACE/CBA/RHS/Blastcore/FTAC e watchdog externo `CfgRemoteExec >> Functions >> mode = 2`; isto não significa alteração pelo Policy. Não mudar política global de CfgRemoteExec. RPT foi recortado e não autoriza alegar ausência de avisos de todo o cliente.

**Auditoria Git:** `docs/projects/policy-editor/evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md`.
**Laboratório:** `docs/projects/policy-editor/P1_B_NEXUS_INTEGRATION_LAB_20261026.md`, 11 fontes Nexus adaptadas *apenas na linha de include para layout plano* e 1 header original, 6 funções Policy idênticas aos blobs da árvore Git; missão `CfgFunctions/preInit=1` de ambos.

## Histórico P0/P1-A — não reconstruir de memória

- P0 auditou modset real de 133.399 classes. Regex antigo rejeitava 668 classnames com dígito inicial, 532 dos quais elegíveis; corrigido e homologado `^[A-Za-z0-9_]{1,128}$`, de 1–128 ASCII alnum/_ (começar com dígito é válido). G2 12/12; H 156/156; Python 8/8/32 fixtures. Fonte canônica `docs/projects/policy-editor/P0_CONTRACTS_20261024.md`.
- P1-A primeira missão teve cinco scripts em subpastas não encontrados, 91 `Error in expression` em cascata e resumo falso 1/68. **Não é defeito semântico confirmado do core.** A R1 corrigiu caminhos movendo funções à raiz e endureceu preflight/fail-fast, preservando os cinco fontes; RPT **68/68 PASS e 0 erro SQF**. Evidência `docs/projects/policy-editor/evidence/P1_A_R1_CORE_SP_RPT_PASS_20261026.md`; ZIP `SP_ORG_Policy_P1_A_R1_Correcao_Load_20261026.zip` SHA-256 `9f885450904ed3cf905743e2c2c81c39a93034787b61a6dfebecc836c2766e7d`.
- P1-B adicionou testes de integração reais em missão, 59/59 PASS. **Não repetir as baterias antigas sem mudança relevante**. Avançar fronteira de distribuição e startup real de addon.

## Contratos Policy v1 — preservar

Policy é addon opcional genérico, proprietário de whitelist/blacklist de classes exatas, dependência do **Nexus**, nunca do BGD obrigatório. Itens/armas são consumidores. Separar **classe existente no modset** (`isClass`), **classe autorizada por Policy**, e **compatibilidade física** de armamento/acessório/magazine avaliada pela engine em Weapons.

**Regra:** whitelist vazia = sem restrição de inclusão; blacklist vazia = sem exclusões; ambas vazias = OPEN; com ambas, **whitelist menos blacklist / blacklist vence**. Policy ausente e *opcional* = OPEN; required ausente, PENDING ou INVALID = fail closed. Kits persistidos jamais excluídos pela mudança da política; Items aplica entradas viáveis com motivos claros em P4.

**PolicyExport v1:** JSON com exatamente `schema: SPORG_POLICY_EXPORT`, `schemaVersion: 1`, `whitelist: []`, `blacklist: []`. Até 4096 por lista e 512 KiB serializados; trim, classname `^[A-Za-z0-9_]{1,128}$`, duplicatas dentro de cada lista rejeitadas case-insensitive, conflitos entre listas aceitos com blacklist prevalecendo. Importação futura **nunca executar `compile` em texto externo**.

**PolicySnapshot v1:** estados `ACTIVE`, `PENDING`, `INVALID`, `ABSENT`; fontes conceituais `ADDON_FALLBACK`, `MISSION_EXPLICIT`, `SERVER_ACTIVE`, `NONE`; índice separado de DTO. **Contexto P1 não autoritativo**: `revision=0`, `fingerprint=P1_NON_AUTHORITATIVE`. **PolicyDecision** códigos `POLICY_ALLOW_OPEN`, `POLICY_ALLOW_WHITELIST`, `POLICY_DENY_BLACKLIST`, `POLICY_DENY_NOT_WHITELIST`, `POLICY_NOT_READY`, `POLICY_INVALID`. `NexusResult.success=true` indica sucesso de consulta, **não** `decision.allowed=true`.

**Nexus real** em `addons/ServoPeregrino_Organizador_Nexus/`; `config.cpp` e `script_version.hpp` (`0.1.1-dev-nexus-contract-event-foundation`), `functions/lifecycle/fn_initialize.sqf` com `preInit`, functions/results/capabilities/diagnostics/contracts. `createResult` retorna `schema/version/success/code/message/data/diagnostics/createdAtUTC`; capability registry em `missionNamespace`; idempotente por provider+version e conflito de owner/version rejeitado.

**Policy source real** em `addons/ServoPeregrino_Organizador_Policy/`: `config.cpp`, `$PBOPREFIX$`, `README.md`, cinco core `functions/core/fn_{isValidClassname,validateExport,createContext,evaluate,snapshot}.sqf`, `functions/lifecycle/fn_initialize.sqf`. `requiredAddons[]={"A3_Functions_F","ServoPeregrino_Organizador_Nexus"}`, `CfgFunctions` com `preInit=1` para initialize. Registra `policy.evaluate` e `policy.snapshot` v1, metadata `phase=P1_CORE_ONLY`, `authority=NONE_P1`, `runtimePolicyLoaded=false`, `entrypoint=STATIC_FUNCTIONS`; não carrega configurações do servidor.

## Próxima entrega EXATA: P1-C — integração de PBO real

**Objetivo:** provar empacotamento e startup de **Nexus.pbo + Policy.pbo separados**, em Arma real, sem mascaramento de `CfgFunctions` no `description.ext`.

1. Ler do **GitHub atual** os diretórios e `config.cpp` de ambos, `$PBOPREFIX$`, includes e funções. Auditar CfgPatches/`requiredAddons`, paths/funções, preprocess e `preInit`; manter fonte idêntica sempre que possível. Nunca adicionar `CfgRemoteExec` global `mode`/`jip`.
2. Escolher empacotamento reprodutível com toolchain Arma 3 Tools/Addon Builder ou equivalente, **documentar comandos, versão, arquivos e hashes**. O usuário prefere receber pacote pronto e evita processos manuais de construção PBO; mission-first foi adotado para ciclos rápidos. Se não houver builder adequado, explicar concretamente o limite e preparar o que for verificável — **não inventar PBO**.
3. Criar missão VR de P1-C que **não declara os CfgFunctions Nexus/Policy** nem inclui seus SQF locais. Ela apenas sonda `configFile >> CfgPatches`, `configFile >> CfgFunctions`, `missionNamespace` funcs, registry/capabilities, logs e decisões (sem reimplementar o código do addon).
4. Testar **Nexus sozinho**, **Nexus + Policy** e ausência de Nexus de forma controlada (verificar recusa de dependência/erro reconhecível); idempotência, `policy.evaluate` e `policy.snapshot` v1, ownership/metadata, valores reais NexusResult, fail-closed, nenhuma política carregada `P1_CORE_ONLY`.
5. Receber RPT real, conferir cada ID e resumo, erros SQF, config e precedência; registrar evidência. **Somente então marcar P1 completo** no escopo de addon SP. MP, JIP e autoridade de servidor permanecem P6. P2 (loader de config estática) inicia apenas após esse gate.

**Restrições:** não editar Items/Weapons/UICommon, não fazer merge na main, não introduzir loader P2, editor P5 ou lógica de servidor P6 durante P1-C. Não usar alterações em outro mod como atalho. Não chamar de “PBO funcional” código apenas compilado por `description.ext`.

## Roadmap futuro e backlog separado

- **P2:** loader estático por sessão (candidato `configFile >> CfgSPORGPolicy` e opt-in `missionConfigFile >> CfgSPORGPolicy`), fallback interno, source precedence, explícito inválido → INVALID, nunca fallback OPEN silencioso. Não pressupor `server.cfg` genericamente legível.
- **P3:** catálogo base Items/Weapons; player vê projeção autorizada, admin catálogo completo; policy revision invalida projeção sem novo scan CONFIG_ALL.
- **P4:** diagnóstico de kits, aplicação parcial segura, códigos de rejeição, preservar kits e remoções pertinentes.
- **P5:** editor whitelist/blacklist visual, adicionar/remover, importar/exportar JSON, refresh cache de sessão, rascunho. Clipboard no MP tem restrições a confirmar.
- **P6:** servidor/admin como autoridade MP, login/verificação, ativação revisão, sincronismo JIP, broadcast e aviso opcional; testes MP reais.
- **P7:** adapters opcionais BGD/FTAC e hardening/distribuição.

Diagnósticos/cores: mod ausente vermelho, Policy negado amarelo, item rascunho alterado laranja; precedência visual para conflito requer revisão. Role kit authorization fora do MVP; botões por texto (ícones adiados).

**Weapons backlog fora do P1:** `WEAPONS-COMPAT-MULTIMUZZLE-01` (há `magazinesByMuzzle`, mas UI usa lista agregada `magazines`), `WEAPONS-POLICY-CLASSNAME-01` e `WEAPONS-COMPAT-REGRESSION-01` em `docs/modules/Weapons.md`; nada disso foi mudado. A compatibilidade de Weapons é derivada da engine.

## Documentos de referência no próximo chat

1. **Esta continuidade**: `docs/projects/policy-editor/CONTINUIDADE_POLICY_P1B_P1C_20261026.md`
2. `docs/projects/policy-editor/evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md`
3. `machine/POLICY_EDITOR_PLANNING_20261022.json` (campos `p1.b` e `p1.c`)
4. `docs/projects/policy-editor/P1_B_NEXUS_INTEGRATION_LAB_20261026.md`
5. `docs/projects/policy-editor/P1_CORE_0_1_A_20261025.md` e `docs/projects/policy-editor/evidence/P1_A_R1_CORE_SP_RPT_PASS_20261026.md`
6. `docs/projects/policy-editor/P0_CONTRACTS_20261024.md`
7. `docs/projects/policy-editor/ROADMAP.md`, `docs/modules/Policy.md`, `docs/modules/Weapons.md`
8. `addons/ServoPeregrino_Organizador_Nexus/{config.cpp,script_version.hpp,functions/...}`
9. `addons/ServoPeregrino_Organizador_Policy/{config.cpp,$PBOPREFIX$,functions/...}`

### Prompt de retomada recomendado

> Continuar Arma 3 — Servo Peregrino Organizador, **Policy P1-C**. GitHub oficial `peregrinoklawd/ServoPeregrino_Organizador`, branch `feature/policy-0.1-b-nexus-integration`. Ler integralmente `docs/projects/policy-editor/CONTINUIDADE_POLICY_P1B_P1C_20261026.md`, machine state e evidências, confirmando HEAD. P0 concluído, P1-A R1 68/68 SP PASS, P1-B Nexus REAL em missão 59/59 SP PASS; **P1-C addon/PBO real pendente**. Auditar configs Nexus+Policy, montar/testar PBOs reais ou identificar limite concreto do tooling, criar missão VR que **não redefine CfgFunctions** e validar `CfgPatches`, `requiredAddons`, `preInit`, capabilities e decisões. Preservar Items/Weapons/UICommon e CfgRemoteExec global; sem merge, sem avançar para P2/P6 ou declarar PBO homologado antes de RPT real. Registrar código, QA e continuidade no Git.

**Conclusão:** P1-B mission-first está homologado, 59/59 PASS; próximo trabalho é **P1-C addon real**.

## Atualização de continuidade após execuções de PBO em 30/10/2026

**Esta atualização prevalece sobre o texto anterior que dizia que P1-C não tinha PBOs construídos/testados.** Pipeline construído e aprovado no [GitHub Actions](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/40437476079), entregando Nexus.pbo + Policy.pbo reais, porém não binarizados/não assinados, gerados dos diretórios canônicos sem alterar o core. Documentação: [P1_C_PBO_BUILD_20261027.md](P1_C_PBO_BUILD_20261027.md).

**Três RPTs in-game em 30/10, 5 execuções:** Nexus sozinho com CBA+Canil 25/25 PASS duas vezes; Nexus+Policy com CBA+Canil 50/50 PASS duas vezes; Nexus+Policy com modset BGD completo 50/50 PASS. Total **200 PASS e 0 falhas de testes**. Nenhum erro `Error in expression`/undefined variable; preInit/registro/paths/capabilities reais. Evidência com SHA-256 de cada RPT e achados de outros mods: [P1_C_PBO_RUNTIME_3_RPTS_SP_PASS_20261030.md](evidence/P1_C_PBO_RUNTIME_3_RPTS_SP_PASS_20261030.md). **Erro de skeleton e 220 avisos de configuração BGD existem**, mas não há evidência de vínculo com Policy.

**Status agora:** gate positivo de runtime P1-C **PASS**. Gate formal P1-C **AGUARDANDO revisão explícita** sobre a necessidade do teste negativo de startup Policy sem Nexus (declarado requiredAddons e validado em `BOTH`, mas a recusa do engine sem Nexus não foi testada). O `p1cHomologated=false` fixo na missão significa que a homologação é auditada externamente, não que o teste falhou. **Não iniciar P2 antes de decidir e registrar esse único fechamento**; não voltar a reconstruir P1-A/P1-B/PBOs sem razão. Sem alterações em Items/Weapons/UICommon, sem merge na main.


## ENCERRAMENTO FORMAL DO P1 NO ESCOPO SP — 30/10/2026 (checkpoint canônico mais recente)

**ESTADO ATUAL: P0 + P1-A + P1-B + P1-C HOMOLOGADOS EM SINGLE-PLAYER. P2 NÃO INICIADO.** Esta conclusão **substitui** todos os checkpoints históricos anteriores deste arquivo que indicavam 'P1-C pendente'. A versão de estado para automação em `machine/POLICY_EDITOR_PLANNING_20261022.json` foi atualizada em conjunto.

- **P1-C PBO real**: Nexus sem Policy = 2×25/25 PASS; Nexus + Policy com CBA/Canil = 2×50/50 PASS; Nexus + Policy com modset BGD = 1×50/50 PASS. Total 200 verificações aprovadas em 5 execuções, sem falhas no harness. RPTs e hashes: [auditoria dos três RPTs](evidence/P1_C_PBO_RUNTIME_3_RPTS_SP_PASS_20261030.md).
- **Policy sem Nexus**: captura de tela do Arma 3 confirmou o aviso textual `Addon 'ServoPeregrino_Organizador_Policy' requires addon 'ServoPeregrino_Organizador_Nexus'`. O jogo continua abrindo após o usuário confirmar. O gate exigia **dependência detectada/erro reconhecível** e está **PASS**; **não foi comprovado bloqueio do executável nem que Policy tenha sido totalmente descartado**. Nenhum RPT foi fornecido para esta variante. [Evidência e decisão](evidence/P1_C_POLICY_WITHOUT_NEXUS_WARNING_AND_SP_GATE_20261030.md).
- PBOs gerados de fontes Git canônicas, reais, mas **não binarizados/não assinados**: adequados para validação SP, não para liberar servidor público. Não mudar código nem refazer build sem necessidade.
- O valor fixo `p1cHomologated=false` no runner anterior solicita revisão humana; não é um status externo de homologação. A **decisão formal documentada agora é PASS no escopo SP**.
- **Pendências fora do P1**: loader P2, integração Items/Weapons P3/P4, editor P5, autoridade MP/JIP P6, assinatura/distribuição/adapters P7. Os avisos de bone/skeleton/arma/strings do BGD não foram atribuídos ao Policy e merecem investigação separada.
- **Próximo passo:** desenhar e implementar P2 — loader estático de Policy, com fallback interno, precedência de fontes, estados ACTIVE/PENDING/INVALID/ABSENT, required fail closed, sem compile de importação e sem mudanças prematuras em Items/Weapons/UICommon. Preferir missão de laboratório para desenvolvimento e PBO apenas quando necessário. **Sem merge na main.**
