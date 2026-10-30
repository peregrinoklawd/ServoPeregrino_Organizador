# Policy P1-C — 3 RPTs reais de PBO em Arma 3: Nexus, BOTH, BOTH+BGD (30/10/2026)

**Decisão técnica:** **GATES POSITIVOS DE RUNTIME APROVADOS**: \`NEXUS_ONLY = 2 × 25/25 PASS\`; \`BOTH = 2 × 50/50 PASS\`; \`BOTH + BGD = 1 × 50/50 PASS\`. **Total: 200 TEST PASS, 0 TEST FAIL em 5 execuções; mas apenas 25 e 50 IDs únicos por bateria — não 200 requisitos distintos.** PBOs são reais (não binarizados/não assinados), com \`configFile\`, \`CfgFunctions\`, \`preInit\` e callbacks reais do addon em SP. **Gate formal P1-C ainda em revisão**: controle negativo de startup **Policy sem Nexus** não consta dos RPTs, e a tag \`p1cHomologated=false\` é deliberada no harness. Não presumir MP, P2 loader ou autoridade.

## Proveniência e contabilidade

| Origem enviada | SHA-256 do RPT | Bytes / linhas | Modset | Cenário e execução |
|---|---|---|---|---|
| \`Texto colado(20261030-181057).txt\` | \`998b8978630d3fac850cba2ed0ff0f21d8c8ebcba244bc290bf637dd790577a9\` | 64.222 / 779 | CBA_A3 + Cachorros_Recursos_DEV + SPC_CANIL_R13_D3D_IDLE + SPC_CANIL_R13_D3I_MATRIX + Nexus P1C; **Policy AUSENTE** | \`15:10:01\` 25/25 PASS, \`15:10:19\` 25/25 PASS; \`NEXUS_ONLY\`, \`CONTROL_NEXUS_ONLY\` |
| \`Texto colado (2)(1).txt\` | \`0b68e58c20b01076d2a21aee5410408269e916ee26880831ac4e5d5a24c37ead\` | 75.244 / 931 | Mesmo modset acima **com Nexus e Policy P1C** | \`15:13:15\` 50/50 PASS, \`15:13:17\` 50/50 PASS; \`BOTH\`, \`GATE_BOTH_PBOS\` |
| \`Texto colado (3).txt\` | \`56a1bb3e4052eeacbb7f927e1d1f31d6d4596bd1fdd31504e4e651e6f5d08e94\` | 1.058.981 / 8.194 | **Modset BGD completo** (CBA, RHS, ACE, 7+ BGD, CUP, TFAR, JSRS etc.) **com Nexus e Policy P1C**, **sem mods Canil nessa inicialização** | \`15:25:30\` 50/50 PASS; \`BOTH\`, \`GATE_BOTH_PBOS\` |

**Data dos três RPTs: 2026-10-30, horário local no log; jogo Stable 2.22.154089.** Ambiente SP Eden Preview em VR, \`isMultiplayer=false\`, \`isDedicated=false\`, \`missionCfgFunctions=false\` nos três. A presença dos PBOs foi verificada pelo startup \`Loaded addons\`: \`...\@SPORG_Nexus_P1C\addons\servoperegrino_organizador_nexus.pbo\`; nas outras duas sessões há também \`...\@SPORG_Policy_P1C\addons\servoperegrino_organizador_policy.pbo\`.

## Validação funcional diretamente evidenciada

### NEXUS_ONLY — 2 execuções, 25 IDs PASS cada

- \`scenario=NEXUS_ONLY nexusPatch=true policyPatch=false\`;
- Nexus de fato inicializa: \`[SP_ORG] [NEXUS] [INFO] Nexus inicializado.\` com build \`0.1.1-dev-nexus-contract-event-foundation\`;
- \`CfgPatches\`, \`requiredAddons A3_Functions_F\`, \`CfgFunctions\`, tag, paths, \`preInit\`, funções reais \`createResult/isResult\` e APIs de capability, flag de inicialização, registro \`nexus.runtime\`, provider e versão sem shadow via missão;
- resumo das duas execuções: \`status=PASS pass=25 fail=0 total=25 uniqueIds=25 scenario=NEXUS_ONLY gate=CONTROL_NEXUS_ONLY addonRuntime=true mp=false p1cHomologated=false\`.

### BOTH — 2 execuções, 50 IDs PASS cada, modset com Canil

- \`scenario=BOTH nexusPatch=true policyPatch=true missionCfgFunctions=false\`;
- Inicialização Policy no preInit: \`evaluate=CAPABILITY_REGISTERED snapshot=CAPABILITY_REGISTERED state=CORE_ONLY_NO_LOADER_NO_AUTHORITY\`;
- Reinvocação do inicializador: \`CAPABILITY_ALREADY_REGISTERED\`, prova de idempotência de capabilities, não erro;
- \`CfgPatches\` real de Policy, requiredAddons Nexus + A3, CfgFunctions reais, path, tag, preInit, cinco funções core + initialize; \`policy.evaluate\` e \`policy.snapshot\` provider/metadados;
- Casos funcionais reais: whitelist permite, blacklist prevalece (\`PO_DENY_WINS\`), item fora whitelist negado, snapshot NexusResult, optional absent OPEN, required absent DENY e ausência de autoridade P1;
- resumo duplicado: \`status=PASS pass=50 fail=0 total=50 uniqueIds=50 scenario=BOTH gate=GATE_BOTH_PBOS addonRuntime=true mp=false p1cHomologated=false\`.

### BOTH + BGD — 1 execução, 50 IDs PASS

- Ambos PBOs aparecem em \`Loaded addons\`, Nexus e Policy inicializam/registram capacidades e são validados pelas mesmas 50 asserções, sem erros de expressão SQF identificados.
- BGD Garage registra \`42485 allowed virtual items, 41764 stocked entries\`. Isso é **dado do BGD**; NÃO demonstra que Policy já filtra catálogo ou integra inventário.
- Watchdog externo reporta \`CfgRemoteExec >> Functions >> mode = 2\`, **não criado pelo Policy**. Não inserir modo global em addon.

## Erros externos: segregação obrigatória

**Primeiros dois RPTs com Canil:** cada um contém 4 \`Error: Bad bone name mfrrightarm/mfrrightarmroll\` nos skeletons MFR e 1 \`Error during SetFace - class CfgFaces.Man_A3.gsocHead_Tick_Paint_A3 not found\`. Sem evidência de nexo causal com Nexus/Policy. Manter em backlog Canil, não corrigir dentro de Policy.

**Terceiro RPT com BGD:** é um log **ruidoso** e não deve ser declarado limpo. Ocorrências contabilizadas:
- **1.772 linhas \`Error: Bone ... doesn't exist in skeleton OFP2_ManSkeleton\`**, agrupadas em múltiplos bones, incluindo face/tongue/slots; **2 \`Error: Bad bone name\` adicionais**. O registro identifica skeleton, mas **não prova qual addon é responsável pela origem de cada classe/modelo**; investigações devem isolar o modset.
- **220 \`Warning Message:\`** de engine/config, incluindo **105 entradas \`No entry\`** e classes \`CfgWeapons/ItemInfo\`, \`CfgWeapons/medium\`, \`CfgWeapons/far\`, com \`'/' is not a value\` e \`Size: '/' not an array\`. Contextos de configuração incluem alterações prévias por fontes vanilla, ACE, RHS e outras; não atribuir causa à extensão Policy.
- **48 avisos \`[CBA] (xeh) WARNING\`**, muitos identificam addons BGD (W.A.R. Bundle, Supplementals Pack, Field Trip, Hardcore Sim, PMC, Immersion Plus) com classes sem XEH.
- **137 ocorrências \`Unsupported language Portuguese in stringtable\`**; várias tabelas de tradução terceirizadas.
- Em todos os três relatórios, **zero ocorrências** de \`Error in expression\`, \`Error position:\`, \`Undefined variable\` no log, **zero falhas do runner P1-C**. Ausência de erro SQF **não** equivale a ausência de erros gerais do jogo.

Não modificar Policy por causa dos erros de skeleton/config de modset terceiro. Se os problemas persistirem fora do contexto de P1-C, abrir investigação de compatibilidade BGD separada, isolando mods e comparando base sem Nexus/Policy. Não considerar 1.772 linhas como 1.772 bugs independentes.

## Estado do gate / decisão estratégica

| Etapa | Status após 30/10 |
|---|---|
| P0 | fechado (legado) |
| P1-A | SP 68/68 PASS (legado) |
| P1-B | SP 59/59 PASS (mission CfgFunctions) |
| P1-C controle NONE | SP 7/7 PASS com e sem BGD |
| P1-C NEXUS_ONLY (PBO real) | **2 × 25/25 PASS** |
| P1-C BOTH (PBOs reais, sem BGD completo) | **2 × 50/50 PASS** |
| P1-C BOTH (PBOs reais, modset BGD completo) | **1 × 50/50 PASS** |
| P1-C POLICY sem Nexus | **não testado**; requiredAddons declarado/checado em BOTH, startup negativo não executado |
| Homologação formal P1-C | **revisão final pendente**, sem alteração da constante de harness |
| P2+ | não iniciados |

**Recomendação:** não criar novo runner nem rebuild dos PBOs só para repetir o que já passou. Há prova suficiente para considerar **o gate positivo funcional P1-C fechado**. Antes de marcar P1-C integralmente homologado, capturar um **teste negativo de startup com Policy habilitado e Nexus desabilitado**, se a equipe ainda o exigir no critério original, com RPT desde o lançamento (motor pode bloquear antes da missão). Registrar também ciência de que estes PBOs são unsigned/unbinarized. Caso se decida aceitar o \`requiredAddons\` estático como suficiente, documentar a exceção explicitamente, sem inventar teste. Avançar para P2 loader só após esta decisão.

**Escopo preservado:** GitHub é fonte de verdade; sem merge na main, sem tocar em Items/Weapons/UICommon, sem \`CfgRemoteExec mode/jip\` global, sem P6 autoridade falsa.

Referências: [build dos PBOs](../P1_C_PBO_BUILD_20261027.md), [laboratório](../P1_C_ADDON_RUNTIME_LAB_PREP_20261026.md), [continuidade P1-B/P1-C](../CONTINUIDADE_POLICY_P1B_P1C_20261026.md).
