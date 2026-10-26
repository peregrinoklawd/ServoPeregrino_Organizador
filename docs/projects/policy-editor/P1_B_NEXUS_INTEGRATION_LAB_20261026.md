# Policy P1-B — integração com Nexus real em missão (26/10/2026)

**CHECKPOINT ATUAL 26/10/2026: HOMOLOGADO EM MISSÃO SP — RPT real 59/59 PASS, 18 BOOT OK, 0 erros SQF. P1-C addon/PBO AINDA PENDENTE.** [Evidência de execução](evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md). Os textos abaixo sobre execução futura descrevem o plano anterior ao RPT, e estão superados pelos resultados abaixo.

**Branch nova:** `feature/policy-0.1-b-nexus-integration`, derivada de `feature/policy-0.1-a-core`. **P0 fechado; P1-A R1 core SQF SP homologado (68/68 PASS)**; P1-B realiza integração mission-first. No momento **nenhum addon Policy/Nexus PBO novo foi construído/testado**. Items, Weapons, UICommon e sua baseline ficam intactos, sem merge.

## Escopo e escolha consciente de teste

Para preservar fluxo rápido de Eden, a candidata **P1-B** testa o **Nexus de verdade** (source SQF do repositório, não a função substituta/shim de `createResult` do P1-A), junto das seis funções Policy originais (cinco core e `initialize`). O `description.ext` declara **ambos via `CfgFunctions` de missão**, incluindo `preInit=1` de Nexus e Policy. Os logs e testes procuram capabilities no registro REAL criado por `Nexus_fnc_registerCapability`.

**Adaptação única dos fontes Nexus:** dez/onze arquivos Nexus usam `#include "..\..\script_version.hpp"` em seu layout de addon. Como a missão mantém arquivos SQF na raiz para evitar erro de `Script not found` observado no P1-A original, o **único delta** aplicado às cópias Nexus foi mudar esse include para `#include "nexus_script_version.hpp"`, preservando 100% do restante do código. Com essa única linha restaurada, **11/11 SHA de Git blob correspondem aos fontes canônicos**; o próprio header coincide com o SHA do Git. As **seis funções Policy são byte-idênticas aos fontes do addon**, sem adaptação.

A missão **NÃO é um addon em PBO**, e `CfgFunctions` declaradas em `description.ext` não provam a configuração do addon `config.cpp`, `CfgPatches.requiredAddons`, `$PBOPREFIX$`, ordem de inicialização de addons binários ou empacotamento. Isso é um gate **P1-C / P1 ADDON REAL**, a decidir após RPT do P1-B. Não existe loader P2, snapshot autoritativo, MP, JIP, interface ou aplicação de itens nessa entrega.

## Artefato de execução e invariantes

- ZIP: `SP_ORG_Policy_P1_B_Nexus_Integration_Lab_20261026.zip`
- **SHA-256:** `618faca9a6fd4a23bfb890a29c1d1e59581af423c41cd5074021eb8b90416a32`
- **Tamanho:** 19.692 bytes; **23 membros**, `ZipFile.testzip()==None`, sem entradas `..`.
- Pasta instalável: `SP_ORG_Policy_P1_B_NexusIntegration.VR`; mapa VR, `B_Soldier_F` vanilla, `mission.sqm` da candidata P1-A R1 adaptado só em identificadores/título/descrição.
- `description.ext`: `CfgFunctions` com **11 funções Nexus** e **6 funções Policy**, registradas com os mesmos tags proprietários, Nexus e Policy `initialize` com `preInit=1`.
- `init.sqf` chama `runPolicyP1BTests.sqf` automaticamente via `execVM` em jogador local; sem comando manual, addon extra ou dependência de servidor.
- **19 arquivos SQF** incluindo `init.sqf` e runner; parser estrutural leve passou para 19/19 (delimitadores `()[]{` e aspas/comentários). Não afirmar que isso substitui parser Arma.
- `[SPORG_POLICY_P1_B]` é o prefixo de RPT, com **18 logs `BOOT` esperados** (1 header, 11 Nexus, 6 Policy), **59 IDs de testes únicos** e 1 `SUMMARY` obrigatório. Ausência de arquivos ou funções interrompe em `BOOTSTRAP_FAILED` sem contar falsos PASS. O total só dá `status=PASS` se `pass=59 fail=0 total=59 expected=59 complete=true valid=true`, `addonRuntime=false mp=false`.
- **QA pré-engine:** 11/11 Nexus canonical Git blob hashes (após reversão de um include), 1/1 header Nexus Git blob, 6/6 Policy Git blob; 59 IDs sem duplicação; ZIP íntegro; source sem mudanças funcionais.

## O que são as 59 asserções

| Grupo | IDs | Propósito |
|---|---:|---|
| `CFG_` | 4 | missão declara ambos inicializadores e preInit |
| `NEXUS_` | 25 | ciclo de inicialização, capability registry e conflitos, versão, listagem, proprietário, formato NexusResult |
| `POLICY_` | 30 | capabilities, provider/metadados, chamadas Policy sobre Nexus real, deny-wins, classe começada com número, não autoritativo, ausência obrigatória |
| **TOTAL** | **59** | **CANDIDATAS, ainda não executadas dentro do jogo** |

As 59 asserções são **novas de integração e não recontagem dos 68 testes P1-A**. O foco é sequenciamento, APIs reais, metadata e resistência a colisões. O P1-A permanece homologado para funções puras em SP.

### Principais testes/expectativas

- Nexus `initialize` terá executado antes de `init.sqf`, com `nexus.runtime` disponível. `getBuildInfo.semanticVersion=0.1.1` e nova tentativa de inicializar será idempotente.
- Policy `initialize` terá registrado `policy.evaluate` e `policy.snapshot` com versão 1 e proprietário `ServoPeregrino_Organizador_Policy`; `hasCapability` deve ser case-insensitive; consulta versão 2 ausente.
- Metadata de capabilities: `phase=P1_CORE_ONLY`, `authority=NONE_P1`, `runtimePolicyLoaded=false`, `entrypoint=STATIC_FUNCTIONS`.
- Duplicatas com mesmo owner/version são idempotentes; owner adversário/version conflitante retorna `CAPABILITY_CONFLICT`. Registro temporário é desfeito; owner errado não pode remover.
- Policy `validateExport`, `createContext`, `evaluate`, `snapshot` retornam **`NexusResult` real**; lista negra vence a branca; `30Rnd_556x45_Stanag` é permitido se listado; `revision=0` e `P1_NON_AUTHORITATIVE` não são autoridade de servidor.
- Policy ABSENT/optional abre e ABSENT/required nega.

## Como executar

1. Extraia a pasta `SP_ORG_Policy_P1_B_NexusIntegration.VR` em `missions` do perfil Arma 3; **não** mova só os arquivos soltos. **Não habilite addons SPORG Nexus/Policy PBO preexistentes durante este laboratório**, para evitar `CfgFunctions` duplicadas, caso tenha-os instalado futuramente. Seus mods de terceiros podem permanecer.
2. Abra Eden Editor → mapa VR → `P1 B - Nexus Integration` → **Preview**.
3. Envie o **RPT completo**. Procurar `[SPORG_POLICY_P1_B]`, `[SPORG_POLICY_P1] [INIT]`, `Error in expression`, `Error position`, `Script ... not found` e `[SUMMARY]`.
4. Para PASS, exigir **18 `[BOOT]` exists=true**, único `[START]`, 59/59 `[TEST] PASS` sem duplicados, 0 FAIL/FATAL, único `[SUMMARY]` com `complete=true valid=true` e **nenhum erro de expressão SQF da missão**. Não aceitar sucesso apenas pelo resumo.

## Próximo gate após RPT P1-B

Se RPT passar, **homologar somente P1-B Nexus/Policy mission-first** e construir um gate específico para **P1-C addon binário** (Nexus + Policy como PBO, `CfgPatches.requiredAddons`, `CfgFunctions`, `preInit`, capabilities e dependência ausente/duplicada). O primeiro passo P2 será só após essa validação ou uma decisão explícita de escopo. Evitar tocar em Items, Weapons, UICommon ou `CfgRemoteExec` global.

### Fontes Git específicas (sem alteração nesta rodada)

- Nexus `config.cpp`, `script_version.hpp`, `functions/{lifecycle,results,capabilities,contracts,diagnostics}` na árvore `addons/ServoPeregrino_Organizador_Nexus`.
- Policy `config.cpp`, `functions/core/*.sqf`, `functions/lifecycle/fn_initialize.sqf` na árvore `addons/ServoPeregrino_Organizador_Policy`.
- Prova anterior: [P1-A R1 68 PASS](evidence/P1_A_R1_CORE_SP_RPT_PASS_20261026.md).


## Homologação pós-RPT — 26/10/2026 (seção canônica mais recente)

O usuário executou `SP_ORG_Policy_P1_B_NexusIntegration.VR` e enviou `Texto colado(20261026-210613).txt` (SHA-256 `fe37a41b8fe353615bff55fd5c1441c8d4cf9d44771e4e19d330169e71971bd7`, 26.525 bytes / 330 linhas, recorte de missão sem cabeçalho geral do executável). **18 BOOT exists=true**, **1 START**, **59 [TEST] PASS distintos** (CFG 4, NEXUS 25, POLICY 30), **1 SUMMARY PASS**, zero `[TEST] FAIL`, `FATAL`, `Error in expression`, `Error position:`, `Script ... not found`. A linha `status=PASS pass=59 fail=0 total=59 expected=59 complete=true valid=true scope=MISSION_CFGFUNCTIONS_NEXUS_POLICY addonRuntime=false mp=false` é coerente.

Foi confirmada a inicialização Nexus antes do Policy (`nexus.runtime`, `policy.evaluate` e `policy.snapshot` v1), registro real `CAPABILITY_REGISTERED`, segundo registro `CAPABILITY_ALREADY_REGISTERED`, metadata e comportamento com resultados Nexus reais. Tests de colisão owner/versão, ownership de remoção, deny-wins, nomes numéricos e ausência required/optional passaram. **P1-B mission-first homologado.** O P1 completo permanece **INCOMPLETO**: falta **P1-C — addons reais em PBO com `CfgPatches.requiredAddons`, `CfgFunctions`/`preInit` de addon e capabilities reais, sem máscara de missão**. [Auditoria completa](evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md). Não iniciar P2 sem resolver formalmente P1-C.
