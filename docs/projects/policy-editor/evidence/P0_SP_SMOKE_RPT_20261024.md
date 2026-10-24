# Policy P0 — Evidência do smoke Arma SP (RPT 24/10/2026)

**Classificação:** PASS — **as duas missões P0** foram executadas na engine; **20/20 verificações PASS, 0 FAIL**. Este resultado aprova o **gate de smoke SP** e NÃO comprova que o addon Policy esteja implementado/homologado. P0 permanece com testes negativos e contratos a fechar.

## Proveniência verificável

- Arquivo original fornecido pelo operador: `Texto colado(20261024-203733).txt` (RPT completo, **não** incorporado ao Git por seu tamanho e por conter caminhos locais e modlist).
- SHA-256 do arquivo recebido: `d4bb57129e89914174dc550a718602f41f91d33611092c6ab0717a2b7b295979`.
- Data/hora local nos logs: 24/10/2026 às 17:35:59 e 17:36:41. Arma 3 Stable 2.22.154089; world `VR`.
- CBA `MISSIONINIT`: ambas `isMultiplayer=false`, `isServer=true`, `isDedicated=false`, `hasInterface=true`, `didJIP=false`. **Somente SP**.
- `SP_ORG_Policy_P0_A_Fallback.VR` e `SP_ORG_Policy_P0_B_MissionConfig.VR`, distribuídas em `SP_ORG_Policy_P0_Missoes_Prontas_20261024.zip` na conversa. **A revisão do conteúdo do ZIP não substitui os resultados observados no RPT.**

## Evidência literal pertinente (sem caminhos pessoais)

~~~text
17:35:59 "[SPORG_POLICY_P0] [START] case=P0 A - Fallback / Sem politica de missao world=VR"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=OPEN expected=true actual=true"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=BLACKLIST_DENY expected=false actual=false"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=BLACKLIST_ALLOW_OTHER expected=true actual=true"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=WHITELIST_ALLOW expected=true actual=true"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=WHITELIST_DENY expected=false actual=false"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=COMBINED_BLACK_WINS expected=false actual=false"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=COMBINED_ALLOW expected=true actual=true"
17:35:59 "[SPORG_POLICY_P0] [DECISION] PASS id=CASE_INSENSITIVE expected=true actual=true"
17:35:59 "[SPORG_POLICY_P0] [JSON] PASS textLength=112"
17:35:59 "[SPORG_POLICY_P0] [CONFIG] PASS expected=0 missionPresent=false enabled=0 version=0 addonPresent=false whitelist=[] blacklist=[]"
17:35:59 "[SPORG_POLICY_P0] [SUMMARY] case=P0 A - Fallback / Sem politica de missao status=APROVADO pass=10 fail=0 total=10 scope=ENGINE_SMOKE_ONLY"

17:36:41 "[SPORG_POLICY_P0] [START] case=P0 B - Config explicita em description.ext world=VR"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=OPEN expected=true actual=true"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=BLACKLIST_DENY expected=false actual=false"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=BLACKLIST_ALLOW_OTHER expected=true actual=true"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=WHITELIST_ALLOW expected=true actual=true"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=WHITELIST_DENY expected=false actual=false"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=COMBINED_BLACK_WINS expected=false actual=false"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=COMBINED_ALLOW expected=true actual=true"
17:36:41 "[SPORG_POLICY_P0] [DECISION] PASS id=CASE_INSENSITIVE expected=true actual=true"
17:36:41 "[SPORG_POLICY_P0] [JSON] PASS textLength=112"
17:36:41 "[SPORG_POLICY_P0] [CONFIG] PASS expected=1 missionPresent=true enabled=1 version=1 addonPresent=false whitelist=[""FirstAidKit""] blacklist=[""ItemGPS""]"
17:36:41 "[SPORG_POLICY_P0] [SUMMARY] case=P0 B - Config explicita em description.ext status=APROVADO pass=10 fail=0 total=10 scope=ENGINE_SMOKE_ONLY"
~~~

**Contagem:** 2 × (8 decisões + 1 round-trip JSON + 1 configuração) = 20 PASS; zero FAIL. O `missionPresent=false` e `addonPresent=false` da A eram esperados, **não** erros. O addon Policy ainda não existe, logo o RPT não prova fallback interno real.

## Análise de warnings circundantes

Foram observados, em ambas as entradas da missão, avisos externos de CBA XEH (`CAManBase`), CBA Settings (`FTAC_dui_radar_pointer_style`), `STR_RHS_FAC_VDV_45 not found`, CBA event handler deprecated e mensagens de BGD MOG. O início do RPT também tem numerosas inconsistências de stringtables e configs de mods instalados. **Não atribuir essas mensagens ao Policy sem evidência**. Na análise do arquivo completo **não foram encontradas** linhas `Error in expression`, `Error position` ou `[SPORG_POLICY_P0] FAIL`.

## Escopo comprovado vs. pendente

**Comprovado pela engine SP:**
1. Referência de decisão OPEN/blacklist/whitelist/combinada, caso-insensitive e DENY prevalecendo.
2. `toJSON` / `fromJSON` em payload válido.
3. Detectar ausência de `CfgSPORGPolicy` em `missionConfigFile` sem confundir com erro.
4. Ler `CfgSPORGPolicy` explicitamente declarado em `description.ext`, com `enabled=1`, versão e arrays.
5. Não exigir addon Policy instalado para rodar o experimento isolado.

**NÃO comprovado ainda:**
- Runtime/loader do addon com fonte interna em `configFile` e precedência real: addon ainda não implementado.
- Rejeição em engine de JSON malicioso, schema inválido, array de tipo errado, duplicate classnames, excesso de tamanho; oráculo offline e fixtures existem, **mas não substituem testes do motor SQF**.
- Regra fail-closed quando uma configuração explícita for inválida, ausente ou `PENDING`; requer teste específico na implementação.
- Viabilidade de clipboard em MP, file I/O externo, autenticação servidor/admin, JIP, resync, Items UI, aplicação física e performance; fases futuras.
- Auditoria de classnames reais do modset e execução Python unittest ainda não formalmente evidenciadas.

**Conclusão operacional:** `P0_ENGINE_SP_SMOKE_PASS`; **P0_IN_PROGRESS_NEGATIVE_TESTS_PENDING**. Avançar com finalização de contratos / teste negativo e depois P1 motor puro. Nenhuma alteração de Items/Weapons/UICommon ou merge na main decorre deste RPT.
