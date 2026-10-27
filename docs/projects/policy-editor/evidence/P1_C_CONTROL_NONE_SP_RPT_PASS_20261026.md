# Policy P1-C — RPT do cenário NONE (controle negativo) — 26/10/2026

**Decisão:** `P1_C_CONTROL_NO_ADDONS_SP = PASS`; **`P1_C_ADDON_REAL_PBO = PENDENTE`**. NÃO homologar o gate P1-C nem avançar para P2. Esta é a primeira execução real da missão de diagnóstico P1-C sem addons; o resultado **7/7 PASS** comprova somente a detecção correta da ausência de Nexus e Policy.

## Identificação

- Arquivo recebido em 27/10/2026 (nome): `Texto colado(20261027-004334).txt`; timestamp do jogo em 26/10/2026.
- Tamanho: **93.941 bytes**, **1.050 linhas** (`splitlines()` de UTF-8), SHA-256 **`5169e8d1fabf000001fc707b37613a988f59f4fe25b4165616f35228a173be89`**.
- RPT completo desde o cabeçalho de inicialização até o resumo da missão. Arma 3 Stable **2.22.154089**, executable timestamp 2026/09/29.
- Missão: `SP_ORG_Policy_P1_C_AddonRuntime_Lab.VR`, VR, single-player, `isServer=true`, `isMultiplayer=false`, `isDedicated=false`, `hasInterface=true` (CBA).
- Missão iniciou **21:42:20**, runner gerou testes **21:42:25**.
- Modset de execução em `-mod`: **CBA_A3, ace, Dog, K9 Companion**, sem Nexus nem Policy. O inventário `Loaded addons` confirma a ausência de PBOs Servo Peregrino.
- Arquivo da missão entregue previamente via chat; os testes neste RPT pertencem ao código da missão, não aos dois addons.

## Contabilidade independente

Foram localizados exatamente **10 logs** `[SPORG_POLICY_P1_C]`: 1 INFO, 1 START, 7 TEST PASS com IDs únicos e 1 SUMMARY. Nenhum TEST FAIL. IDs:
`BASE_MISSION_CFG_NO_NEXUS`, `BASE_MISSION_CFG_NO_POLICY`, `BASE_SP_ONLY`, `NONE_NO_NEXUS_PATCH`, `NONE_NO_POLICY_PATCH`, `NONE_NO_NEXUS_FN`, `NONE_NO_POLICY_FN`.

```text
21:42:25 "[SPORG_POLICY_P1_C] [START] scenario=NONE nexusPatch=false policyPatch=false isMultiplayer=false isDedicated=false addonRuntime=true missionCfgFunctions=false"
21:42:25 "[SPORG_POLICY_P1_C] [SUMMARY] status=PASS pass=7 fail=0 total=7 uniqueIds=7 scenario=NONE gate=CONTROL_NO_ADDONS addonRuntime=true mp=false p1cHomologated=false"
```

**Interpretação técnica:** `addonRuntime=true` é marcador de escopo do laboratório, **não detecção de PBO instalado**; as evidências conclusivas são `scenario=NONE`, `nexusPatch=false`, `policyPatch=false` e `p1cHomologated=false`. `missionCfgFunctions=false` confirma que o laboratório não mascara funções via CfgFunctions de missão.

## Erros externos visíveis, não atribuídos ao Policy

Nenhuma ocorrência de `Error in expression`, `Error position:`, `Undefined variable` nem arquivos `Script ... not found` do laboratório no RPT. O relatório contém **cinco linhas `Error:` de outro escopo**:
- Quatro `Bad bone name` em `MFRBodyFullReal/MFRUpperBody`, compatíveis com os mods Dog/K9 ativos.
- Uma `Error during SetFace - class CfgFaces.Man_A3.gsocHead_Tick_Paint_A3 not found`. Origem específica não estabelecida; não há evidência ligando ao Policy.
Outros avisos de ACE de addons opcionais ausentes e alertas de afinidade de CPU são independentes do laboratório. **Não usar "zero errors no RPT" sem qualificação.**

## Gates e próximo passo

| Marco | Situação |
|---|---|
| P0 | Fechado |
| P1-A R1 | SP 68/68 PASS |
| P1-B | SP 59/59 PASS, source real via CfgFunctions de missão |
| P1-C NONE | **7/7 PASS, controle negativo apenas** |
| P1-C NEXUS_ONLY | **Não executado** |
| P1-C BOTH | **Não executado** |
| P1-C sem Nexus com Policy presente | **Não executado**; verificar dependência por startup de engine |
| P2–P7 | Não iniciados |

**Não é necessário gerar outra missão para o próximo teste**: usar o mesmo laboratório P1-C já validado. Construir Nexus.pbo e Policy.pbo independentes a partir dos diretórios canônicos, registrar toolchain/hashes, carregar inicialmente somente Nexus, depois ambos, e recolher RPTs. Conduzir ao menos um teste com o modset SP mínimo, sem Dog/K9, para reduzir ruído, mantendo outros cenários opcionais separados. Preservar Items, Weapons, UICommon, CfgRemoteExec e branch sem merge.

Referências: `../P1_C_ADDON_RUNTIME_LAB_PREP_20261026.md`; `../CONTINUIDADE_POLICY_P1B_P1C_20261026.md`.
