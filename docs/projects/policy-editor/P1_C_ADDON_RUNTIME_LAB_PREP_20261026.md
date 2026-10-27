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
- SHA-256 do ZIP: `f6aee10442a13b0c9abd86b328168e7b2bf8be33e7335d3533df6e5e0c6a3153`. Tamanho 7.314 bytes; 4 membros; teste de integridade ZIP passou.
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

## Primeiro RPT executado — checkpoint de 26/10/2026

**Controle sem addons (`NONE`) executado e aprovado 7/7 em SP, sem falhas do laboratório.** O comando de lançamento continha somente `@CBA_A3;@ace;@Dog;@K9 Companion`; portanto nenhum PBO Nexus/Policy estava instalado nesta sessão. O runner detectou `nexusPatch=false`, `policyPatch=false` e `missionCfgFunctions=false`; `gate=CONTROL_NO_ADDONS`, `p1cHomologated=false`. **Isto não fecha P1-C**. Evidência e hash do RPT: [P1_C_CONTROL_NONE_SP_RPT_PASS_20261026.md](evidence/P1_C_CONTROL_NONE_SP_RPT_PASS_20261026.md).

**Próximo passo:** usar a **mesma missão** para `NEXUS_ONLY` e `BOTH` depois de empacotar os dois PBOs reais, com build/toolchain e SHA-256 registrados. Não repetir `NONE` sem alteração pertinente; não confundir os erros de animação MFR Dog/K9 e SetFace observados no RPT com erro Policy.

## Segundo RPT — controle NONE em modset BGD (27/10/2026)

A missão foi novamente executada em SP com o ambiente BGD carregado, **duas baterias consecutivas de 7/7 PASS, 0 falhas**. O modo continua `scenario=NONE`, `nexusPatch=false`, `policyPatch=false`, `p1cHomologated=false`; portanto ainda **nenhum PBO Nexus/Policy foi testado**. O RPT é recorte, sem cabeçalho de build nem lista completa de mods. Registrados separadamente: 117 mensagens de tentativa de sobrescrever funções ACE finalizadas (30 nomes), CBA XEH fallback, macro antiga LAxemann, FTAC setting errado, Blastcore sem userconfig legível, `CfgRemoteExec mode=2` externo e BGD Garage com 42485 entradas virtuais autorizadas/41764 estocadas. Esses avisos **não são erros Policy comprovados**. Evidência: [P1_C_CONTROL_NONE_BGD_SP_RPT_PASS_20261027.md](evidence/P1_C_CONTROL_NONE_BGD_SP_RPT_PASS_20261027.md).

**Gate inalterado:** construir PBOs reais e provar `NEXUS_ONLY` e `BOTH`; reutilizar missão existente, sem gerar nova. Comparar posteriormente no BGD completo quando os addons estiverem disponíveis.


## Artefatos PBO produzidos no GitHub Actions — 27/10/2026

**Atualização posterior ao preparo inicial:** foram construídos dois PBOs reais **não binarizados/não assinados** a partir dos diretórios canônicos, por pipeline GitHub Actions, com parser independente, roundtrip de arquivos, integridade SHA-1 e hashes SHA-256. O GitHub Actions concluiu o job com `success`; **não há ainda execução/homologação in-game**. Este resultado substitui o bloqueio de empacotamento mencionado no preparo original, mas **NÃO fecha P1-C**.

[Documento de build, hashes, artefato e roteiro](P1_C_PBO_BUILD_20261027.md). [Workflow executado com sucesso](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/40437476079). Próxima evidência obrigatória: RPT de **NEXUS_ONLY**, seguido de **BOTH**, ambos com os dois PBOs reais; posteriormente **BOTH com modset BGD**. Não alterar núcleo Policy nem marcar P1 homologado antes dessas execuções.
