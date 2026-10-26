# Policy P1-B — Nexus real com CfgFunctions/preInit em missão: RPT PASS (26/10/2026)

**Gate decidido:** `P1_B_NEXUS_MISSION_FIRST_SP = HOMOLOGATED`. **59/59 verificações PASS, 0 FAIL, 18/18 arquivos presentes, zero erros de expressão/posição SQF no arquivo fornecido.** O P1 completo ainda **NÃO está encerrado**: resta `P1_C_ADDON_REAL_PBO`.

## Identificação da evidência

- Arquivo fornecido: `Texto colado(20261026-210613).txt`, conteúdo da janela do RPT referente ao Preview da missão.
- SHA-256: **`fe37a41b8fe353615bff55fd5c1441c8d4cf9d44771e4e19d330169e71971bd7`**; 26.525 bytes; 330 linhas (leitura UTF-8 com `splitlines`). O recorte **não inclui cabeçalho de versão geral do executável**, portanto não inferir build da engine por ele.
- RPT confirma **SP local**, sem multiplayer: log CBA `isMultiplayer=false, isServer=true, isDedicated=false, hasInterface=true, didJIP=false`.
- Missão `SP_ORG_Policy_P1_B_NexusIntegration.VR`, terreno `VR`, início às **18:04:08** e testes às **18:04:16** no horário do RPT. Uma execução de Preview.
- ZIP de preparação: `SP_ORG_Policy_P1_B_Nexus_Integration_Lab_20261026.zip`, SHA-256 `618faca9a6fd4a23bfb890a29c1d1e59581af423c41cd5074021eb8b90416a32`; fontes originais Nexus e Policy, exceto realocação da linha `#include` das cópias de função Nexus devido ao layout plano de missão. [Especificação e QA offline](../P1_B_NEXUS_INTEGRATION_LAB_20261026.md).

## Auditoria independente dos contadores

- **79 linhas** com prefixo `[SPORG_POLICY_P1_B]` = **18 BOOT + 1 START + 59 TEST + 1 SUMMARY**.
- Os **18 BOOT** possuem `exists=true`: 1 header Nexus, 11 arquivos de funções Nexus, 6 arquivos de funções Policy.
- **59 IDs de teste únicos, sem duplicatas**, todos com `[TEST] PASS`, nenhum com `[TEST] FAIL`. **4 CFG, 25 NEXUS, 30 POLICY**.
- Nenhum `[FATAL]`, `Error in expression`, `Error position:`, `Undefined variable` ou `Script ... not found` no arquivo recebido.
- Só há **um SUMMARY**, e ele concorda com as linhas individuais:

```text
18:04:16 "[SPORG_POLICY_P1_B] [SUMMARY] status=PASS pass=59 fail=0 total=59 expected=59 complete=true valid=true scope=MISSION_CFGFUNCTIONS_NEXUS_POLICY addonRuntime=false mp=false"
```

Observação de parsing: dois IDs contêm a palavra `FAIL_CLOSED` no **nome** de casos de teste, mas suas linhas são `[TEST] PASS`; não interpretar ocorrência bruta da substring `FAIL` como um teste reprovado.

## Resultados técnicos confirmados no RPT

### Inicialização e registry

Nexus inicializou antes do Policy, ambos por CfgFunctions `preInit` **na missão**:

```text
18:04:12 "[SP_ORG] [NEXUS] [INFO] Nexus inicializado. | CONTEXT=[[""build"",""0.1.1-dev-nexus-contract-event-foundation""]]"
18:04:12 "[SPORG_POLICY_P1] [INIT] evaluate=CAPABILITY_REGISTERED snapshot=CAPABILITY_REGISTERED state=CORE_ONLY_NO_LOADER_NO_AUTHORITY"
```

O segundo chamado de `Policy_fnc_initialize` produziu `CAPABILITY_ALREADY_REGISTERED` para ambas as capabilities, e o teste de idempotência passou. Os testes confirmam `nexus.runtime`, `policy.evaluate` e `policy.snapshot`, todos no registry REAL de Nexus, inclusive `hasCapability`, `getCapability`, `listCapabilities`, normalização case-insensitive, versão 1, provedor, metadata e conflito entre provider/version.

### Interoperabilidade real NexusResult / Policy

- `Nexus_fnc_createResult` e `Nexus_fnc_isResult` reais passaram, com magic, version, diagnostics e `createdAtUTC`.
- `Policy_fnc_validateExport`, `createContext`, `evaluate` e `snapshot` retornaram resultados compatíveis com o Nexus real (não havia `result shim` local).
- `POLICY_DENY_WINS_WITH_REAL_NEXUS`, `POLICY_NUMERIC_CLASS_WITH_REAL_NEXUS`, `POLICY_MISSING_POLICY_OPTIONAL_OPEN` e `POLICY_MISSING_POLICY_REQUIRED_DENY` passaram.
- Os testes de idempotência, conflito provider/version, remoção por owner correto e recusa por proprietário incorreto passaram.
- Metadata reportou `phase=P1_CORE_ONLY`, `authority=NONE_P1`, `runtimePolicyLoaded=false`: corretamente **não autoritativo**, não é sincronização de servidor.

### Avisos externos

O recorte contém avisos **de outros mods**, tais como CBA/ACE, strings RHS, compatibilidade, `[BGD MOG]` e `[Blastcore CoB]`, e linha externa `CfgRemoteExec >> Functions >> mode=2`. **Não há evidência de alteração global de CfgRemoteExec pelo Policy**. Não confundir silêncio de erros SQF do laboratório com ausência de avisos no modset global.

## Decisão precisa sobre gates

| Etapa | Decisão |
|---|---|
| P0 contratos/regressão | Fechado, conforme evidências anteriores |
| P1-A R1 core puro SQF em missão | **HOMOLOGADO 68/68 PASS** |
| **P1-B Nexus real + Policy via CfgFunctions/preInit em missão** | **HOMOLOGADO 59/59 PASS** |
| **P1-C addon/PBO real Nexus + Policy** | **PENDENTE / NÃO EXECUTADO** |
| P2 loader config/fallback/mission | Planejado; não implementado |
| P3–P7 integrações, editor, multiplayer | Planejados; não testados por esse RPT |

**Limite fundamental:** `description.ext` carrega CfgFunctions apenas no contexto da missão. Isto **não verifica** `addons/ServoPeregrino_Organizador_Policy/config.cpp` nem `CfgPatches.requiredAddons`, `$PBOPREFIX$`, pack/pbo/signatures, `preInit` real de dois addons, ausência de Nexus, instalação separada ou MP/JIP.

## Próxima entrega recomendada — P1-C

Provar **os dois addons reais em PBO**, priorizando o caminho mínimo reprodutível e sem carregar políticas (P2) ou UI/editor/MP (P5–P6):
1. Auditar `addons/ServoPeregrino_Organizador_Nexus/` e `addons/ServoPeregrino_Organizador_Policy/`, prefixos PBO, `config.cpp`, dependência `requiredAddons`, inicializadores `preInit`, includes e `CfgFunctions`; não alterar baseline aprovada sem necessidade.
2. Empacotar **Nexus + Policy** com toolchain compatível, registrar comandos/hashes em GitHub; criar missão VR de **verificação em runtime dos PBOs** (sem redefinir CfgFunctions de missão, para não mascarar erros do addon).
3. Verificar Nexus inicializar primeiro, registrar `nexus.runtime`, Policy registrar capabilities v1, chamadas reais de core e metadata não autoritativa. Testar sem Policy (Nexus isolado), com ambos, e cenário sem Nexus para validar sinalização/ordem de dependência; definir segurança dos testes sem provocar estados conflitantes no modset habitual.
4. Preservar **Items, Weapons, UICommon, `CfgRemoteExec` global e baseline**; não fazer merge `main`. **P1 inteiro só será fechado com gate de addon documentado**, salvo decisão explícita e rastreada alterando o escopo.

**GitHub source of truth:** branch `feature/policy-0.1-b-nexus-integration`. A documentação de continuidade mais recente deve prevalecer sobre notas históricas 'RPT P1-B pendente'.
