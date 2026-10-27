# Policy P1-C — RPT do controle NONE com modset BGD (27/10/2026)

**Decisão:** cenário `P1_C_CONTROL_NO_ADDONS_BGD_SP = PASS` **7/7 em duas execuções independentes**, total de **14 TEST PASS**, **0 TEST FAIL**; **não homologar o P1-C addon real**. O modset BGD foi carregado, mas os addons `ServoPeregrino_Organizador_Nexus` e `ServoPeregrino_Organizador_Policy` **não estavam presentes**.

## Proveniência da evidência

- Arquivo enviado no chat: `Texto colado(20261027-014858).txt`.
- **SHA-256 dos bytes:** `0d722fc36df51b98e1217b96fa5634828098165d409349a5acc9ebbdc53fff15`; **28.309 bytes**, **355 linhas** pelo `splitlines()`.
- **Importante:** é um **recorte do RPT**, iniciado em `22:47:07` e encerrado em `22:48:26`. Não inclui cabeçalho com versão geral nem lista integral de `-mod`. Não inferir todo o modset instalado nem ausência de erros fora desse intervalo.
- Missão: `SP_ORG_Policy_P1_C_AddonRuntime_Lab.VR`; VR; CBA atesta `isMultiplayer=false`, `isServer=true`, `isDedicated=false`, `hasInterface=true` na linha de `MISSIONINIT` do trecho.

## Verificação independente dos resultados

- Exatamente **19 logs** com prefixo `[SPORG_POLICY_P1_C]`: 1 INFO, 2 START, 14 TEST PASS, 2 SUMMARY.
- **Primeira execução às 22:47:59**: 7/7 PASS; **segunda às 22:48:10**: 7/7 PASS. Os **sete IDs são repetidos** na segunda execução, portanto o conjunto tem **7 IDs únicos**, não 14 testes distintos.
- Todos os casos são de controle negativo ou isolamento de missão:
  - `BASE_MISSION_CFG_NO_NEXUS`
  - `BASE_MISSION_CFG_NO_POLICY`
  - `BASE_SP_ONLY`
  - `NONE_NO_NEXUS_PATCH`
  - `NONE_NO_POLICY_PATCH`
  - `NONE_NO_NEXUS_FN`
  - `NONE_NO_POLICY_FN`
- Dois START idênticos: `scenario=NONE nexusPatch=false policyPatch=false isMultiplayer=false isDedicated=false addonRuntime=true missionCfgFunctions=false`.
- Dois SUMMARY idênticos: `status=PASS pass=7 fail=0 total=7 uniqueIds=7 scenario=NONE gate=CONTROL_NO_ADDONS addonRuntime=true mp=false p1cHomologated=false`.
- **`addonRuntime=true` descreve escopo esperado do laboratório, não prova carregamento de addons.** A negativa explícita está em `scenario=NONE` e `nexusPatch=false`/`policyPatch=false`.
- Não há `Error in expression`, `Error position:`, `Undefined variable`, `[TEST] FAIL`, `[FATAL]` no **recorte**. Não há nem ocorrência literal `Error:` no recorte. O resultado anterior com modset reduzido já havia aprovado o mesmo controle: [evidência NONE anterior](P1_C_CONTROL_NONE_SP_RPT_PASS_20261026.md).

## Avisos externos em modset BGD — classificados, não atribuídos ao Policy

1. **Tentativas de substituir funções finais ACE:** `Attempt to override final function` aparece **117 vezes**, relativas a **30 nomes de funções** (29 nomes em quatro ciclos e um nome uma vez). Inclui funções de ACE medical, gestures, dogtags, dragging e UI. Não prova a identidade do mod que tentou o override; merece auditoria separada de compatibilidade ACE, não correção do Policy P1-C.
2. **CBA XEH:** quatro avisos `CAManBase ... do not support Extended Event Handlers. Fall back to loop` no trecho. Macro antiga `SLX_XEH_COMPILE` aparece oito vezes em dois scripts de `LAxemann/L_Align`. Indicam compatibilidade externa e possível fallback, sem prova de defeito Policy.
3. **FTAC setting:** quatro vezes `Wrong type for setting FTAC_dui_radar_pointer_style (couldn't find default value)`. Registrar no backlog de configuração FTAC/BGD, não modificar Policy.
4. **Blastcore CoB:** informa que `userconfig\cob_blastcore\cob_blastcore.sqf` não é legível sem `-filePatching` ou PBO de userconfig. Isso é aviso de configuração do Blastcore; **não é recomendação para ativar indiscriminadamente filePatching**.
5. **CfgRemoteExec:** watchdog externo informa `CfgRemoteExec >> Functions >> mode = 2 (origem: mod/jogo)`. Não prova que Policy alterou a política. Manter proibição de instalar `CfgRemoteExec` global dentro de Nexus/Policy. Em P6, auditar allowlist server/mission para chamadas remotas reais, se necessárias.
6. **BGD Garage / Arsenal Redux:** loga `42485 allowed virtual items, 41764 stocked entries`. Confirma inicialização do vault BGD, **não** prova integração, filtro ou catalogação pelo Policy. Contagem é do sistema BGD e não deve ser confundida com catálogo Items/Policy.
7. Logs `String STR_NMG_... not found` e `STR_RHS_FAC_VDV_45 not found`: strings de localização em mods externos. `VCOM` detecta ACE Medical e LAMBS, com auto-tune, independente de Policy.

## Interpretação / próximos gates

O BGD coexiste com **a missão de diagnóstico sem os PBOs** e esta consegue detectar corretamente ausência e ausência de shadow CfgFunctions. O resultado é **controle de não regressão do harness**, não aprovação do comportamento de Nexus ou Policy em BGD.

- **P1-C NEXUS_ONLY:** pendente; construir `Nexus.pbo` da árvore fonte canônica e rodar a MESMA missão.
- **P1-C BOTH:** pendente; construir `Policy.pbo`, instalar ambos, coletar RPT. Só após esse gate discutir homologação.
- Política sem Nexus: teste controlado de dependência de config após build, pois falha pode ocorrer antes do carregamento da missão.
- Repetir cenário BOTH também no modset BGD completo após homologação em modset mínimo, para medir interoperabilidade concreta.
- Não avançar para P2, não alterar Items/Weapons/UICommon, sem merge na main.

Referência do laboratório: [P1_C_ADDON_RUNTIME_LAB_PREP_20261026.md](../P1_C_ADDON_RUNTIME_LAB_PREP_20261026.md).
