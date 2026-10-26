# Policy P1-C — preparo do laboratório de runtime de addons (26/10/2026)

**Status: LABORATÓRIO PREPARADO / GATE P1-C ABERTO / SEM HOMOLOGAÇÃO DE PBO.** Este documento acrescenta somente a preparação inicial feita na continuação do chat de 26/10/2026. A fonte de verdade sobre P0, P1-A e P1-B continua [CONTINUIDADE_POLICY_P1B_P1C_20261026.md](CONTINUIDADE_POLICY_P1B_P1C_20261026.md).

## Posição e decisão

- Branch: `feature/policy-0.1-b-nexus-integration`. Sem merge na `main`.
- P1-A: 68/68 PASS em missão SP. P1-B: 59/59 PASS Nexus real e Policy via CfgFunctions da **missão**.
- **P1-C exige dois PBOs reais, Nexus e Policy separados**, e uma missão de diagnóstico que NÃO fornece `CfgFunctions` substitutos.
- Os arquivos `addons/ServoPeregrino_Organizador_Nexus/config.cpp` e `addons/ServoPeregrino_Organizador_Policy/config.cpp` foram lidos, juntamente com `$PBOPREFIX$`, `script_version.hpp`, inicializadores, NexusResult, registry e funções do Policy. Os dois usam tag `ServoPeregrino_Organizador_{Nexus,Policy}`, `preInit=1` e `requiredAddons` orientado Policy → Nexus. Nenhuma correção no core foi justificada apenas pela inspeção.
- Regra mantida: não modificar Items/Weapons/UICommon, não instalar `CfgRemoteExec` global, não avançar para loader P2/UI P5/autoridade MP P6.

## Artefato de missão criado nesta continuação

- ZIP para download no chat: `SP_ORG_Policy_P1_C_AddonRuntime_Lab_20261026.zip`.
- SHA-256 do ZIP: `390968a47817cae66b55dc556938a6f166a6ae471a747d6e4a0fd2c450889554`. Tamanho 7.313 bytes; 4 membros; teste de integridade ZIP passou.
- Pasta: `SP_ORG_Policy_P1_C_AddonRuntime_Lab.VR/`.
- Arquivos: `mission.sqm`, `init.sqf`, `runPolicyP1C.sqf`, `README.md`.
- O laboratório foi criado no ambiente da conversa e **não foi adicionado como arquivo de missão ao Git** nesta etapa; para transportar os bytes para um chat posterior, recuperar o ZIP do chat de entrega. Não assumir que um nome de arquivo equivale a link Git.
- A missão parte de um modelo Eden `mission.sqm` canônico do repositório, com uma unidade vanilla e terreno VR, e não define `CfgFunctions` dos addons nem empacota SQFs originais Nexus/Policy.
- Preflight estático local: ZIP íntegro, quatro membros, delimitadores básicos SQF balanceados. **Não é validação de sintaxe pelo Arma 3 nem execução no jogo**.

## Matriz de cenário

| Cenário detectado via `configFile >> CfgPatches` | Objetivo | Significado de PASS |
|---|---|---|
| `NONE` | Sem Nexus e sem Policy | Apenas controle negativo: não comprova P1-C |
| `NEXUS_ONLY` | Nexus.pbo presente e Policy ausente | Registro e APIs reais Nexus sem Policy |
| `BOTH` | Nexus.pbo + Policy.pbo presentes | Candidato ao gate principal P1-C; precisa revisão do RPT e hashes dos PBOs |
| `POLICY_WITHOUT_NEXUS` | Política presente sem addon requerido | Falha esperada / recolher RPT **desde a inicialização**, pois o jogo pode bloquear antes da missão |

Runner automático 3s após criação do jogador e ação única de scroll para repetição. Logs `[SPORG_POLICY_P1_C] [START]`, `[TEST] PASS/FAIL id=...`, `[SUMMARY]`. Testes em `configFile` de `CfgPatches`, `requiredAddons`, `CfgFunctions`, `preInit`, paths e símbolos compilados no motor; inicialização Nexus, capacidades registradas, provider/metadados Policy, callbacks reais, deny-wins, required fail closed, fingerprint/revision não autoritativos e idempotência. O `SUMMARY` inclui `p1cHomologated=false` **deliberadamente**, mesmo com `status=PASS`: decisão depende de auditoria humana de evidências.

## Limite concreto do empacotamento

O ambiente utilizado para gerar o ZIP **não possui Arma 3 Tools, Addon Builder, armake/HEMTT ou outro empacotador PBO verificado**; não foi possível compilar ou homologar PBOs reais aqui. O repositório possui um Nexus.pbo histórico de outra entrega, mas não há evidência de que corresponda byte a byte à fonte atual para o P1-C. Não reaproveitar PBO histórico como candidato sem verificação.

Arma 3 Tools / Addon Builder no Windows é o caminho oficial para empacotar esses dois diretórios, preservando `$PBOPREFIX$` e os includes do Nexus. Documentar a toolchain e SHA-256 de ambos os PBOs assim que existirem.

## Próximos passos obrigatórios

1. Empacotar os dois addons da fonte canônica com ferramenta Arma conhecida; manifestar versões, paths, hashes.
2. Executar cenário `NONE`, `NEXUS_ONLY` e `BOTH` com os modsets separados, em SP Preview; registrar RPT, contagem por ID e erros globais relevantes.
3. Documentar startup sem Nexus separadamente (pode falhar antes de entrar na missão).
4. Concluir P1-C só com RPT real e revisão. Depois P2, nunca antes.
