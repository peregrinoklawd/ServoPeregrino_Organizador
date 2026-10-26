# 75 — Continuidade Policy P0 (24/10/2026)

**Repo:** `peregrinoklawd/ServoPeregrino_Organizador`  
**Branch atual:** `feature/policy-0.1-p0-contracts`, criada da baseline `67f457414c37784ef0469e7235d39006342edb40` (`baseline/items-uicommon-r2-2-sp-homologated-20261021`).  
**CHECKPOINT MAIS RECENTE 25/10/2026 — P0 CONTRATO/VIABILIDADE SP CONCLUÍDO.** G2 **12/12 PASS** recuperou **532/532 classnames elegíveis**; nova regex `^[A-Za-z0-9_]{1,128}$`; Python revisado **8/8 PASS** (32 fixtures); H SQF **156/156 PASS** (4 missões C/D/E/F com 39 PASS cada). Todas as seções abaixo que indicam P0/G2/H como pendente são **histórico superado**. Próximo marco: **P1 motor Policy**, sem alterar baseline Items/Weapons/UICommon; addon Policy e MP não implementados. Evidências: [G2](projects/policy-editor/evidence/P0_G2_REGEX_COMPARISON_RPT_20261025.md), [H](projects/policy-editor/evidence/P0_H_REVISED_CLASSNAME_SQF_RPT_20261025.md), [Python](projects/policy-editor/evidence/P0_G2_PYTHON_REGRESSION_20261025.md).

## Artefatos nesta branch

- `docs/73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md` e `docs/74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md`: cópias canônicas da branch de auditoria.
- `docs/modules/Policy.md`, `docs/projects/policy-editor/README.md` e `ROADMAP.md`: planejamento canônico, com notas de P0.
- `docs/projects/policy-editor/P0_CONTRACTS_20261024.md`: candidatos PolicySnapshot, PolicyDecision, PolicyExport, config, segurança e open gates. **LER ANTES DE PROGRAMAR.**
- `machine/POLICY_EDITOR_PLANNING_20261022.json`: P0 passou a EM ANDAMENTO, P1–P7 permanecem PLANNED; não existe runtime instalado.
- `machine/policy/p0_contract_fixtures_v1.json`: 28 fixtures de autorização/validação/fail-closed/ambiente, aprovadas pelo oráculo JS independente em 24/10 (28/28).
- `tools/policy/test_p0_contracts.py`: suíte Python unittest do oráculo de referência. **EXECUTADA e APROVADA em Python 3.13.5: 7 métodos/7 PASS (28 fixtures de referência)**. [Evidência](projects/policy-editor/evidence/P0_PYTHON_UNITTEST_20261024.md).
- `spikes/policy-p0/runPolicyP0Smoke.sqf`: experimento **isolado**, deve ser copiado para missão SP; não é função registrada em `CfgFunctions`, nem foi executado no Arma.

## Contrato em avaliação

- Policy módulo **opcional** e único dono das regras; depende só de Nexus. OPEN sem listas; whitelist restringe; blacklist nega; DENY prevalece.
- Classe ambientalmente ausente (`isClass`) independe de restrição Policy; jamais apagar registros salvos.
- Import/export de **JSON apenas dados** com `fromJSON`/`toJSON`, Arma 3 2.18+; rejeitar campos de autoridade, classnames inválidos, entradas duplicadas e versões desconhecidas. Não usar `compile` em input.
- Fontes candidatas: fallback interno `configFile >> "CfgSPORGPolicy"` (**não implementado**) e opt-in explícito `missionConfigFile >> "CfgSPORGPolicy"`, `enabled=1`. Política inválida exigida não vira OPEN. Política estática no MVP.
- Autorização MP validada no servidor, não em cliente/UI. Somente P6 após teste real.
- Capacidades Nexus `policy.evaluate`/`policy.snapshot` v1 são **propostas**, não registradas. Nexus já oferece registro de capability mas não executa dispatch; consumidor chama função pública conhecida depois de validar a presença.
- `copyFromClipboard` é **desabilitado em MP**; projetar campo de entrada editável/colar texto, sem depender da leitura nativa do clipboard. Arquivo externo gravável/carregável não confirmado.
- `Items_fnc_invalidateCatalogCache` invalida base cara: futuro refresh Policy deve invalidar **projeção**, não CONFIG_ALL.
- Ícones text-only, Items R2.2 homologada SP, Items 0.13-A MP pendente, Weapons separado, BGD/Role Kits opcional/diferido.

## Testes executados na engine (24/10)

- RPT completo do usuário analisado: **Missão A 10/10 PASS (17:35:59); Missão B 10/10 PASS (17:36:41)**, Arma 3 2.22.154089, single-player VR. JSON, oito casos de decisão e leitura da configuração tiveram PASS nas duas missões.
- Evidência e SHA-256 do RPT: [P0_SP_SMOKE_RPT_20261024.md](projects/policy-editor/evidence/P0_SP_SMOKE_RPT_20261024.md).
- Warnings de CBA/FTAC/BGD/outros mods no RPT não foram atribuídos ao Policy; nenhum `[SPORG_POLICY_P0] FAIL`.
- Não equivale a teste de addon: `addonPresent=false` é o esperado; P0 precisa fechar schema inválido, fail-closed e amostragem de classnames.

## Instruções históricas dos testes SP (já executados em 24/10; reexecutar apenas se código mudar)

**1 — Teste offline:** na raiz de um checkout da branch:
~~~bash
python -m unittest discover -s tools/policy -p 'test_*.py' -v
~~~
Registrar total, FAILs e ambiente Python; os 28/28 anteriores são um oráculo JavaScript dos fixtures, **não são este unittest**.

**2 — Smoke no Arma 3 SP (sem mudar a baseline):**
- Criar missão de teste descartável no Eden (VR serve); copiar `spikes/policy-p0/runPolicyP0Smoke.sqf` para a raiz **da nova missão de teste**, como `runPolicyP0Smoke.sqf`.
- Abrir Debug Console em single-player e executar `[] execVM "runPolicyP0Smoke.sqf";`.
- Verificar linhas `[SPORG_POLICY_P0]` no RPT: para as missões empacotadas espera-se **10 PASS, 0 FAIL** (8 decisões + round-trip JSON + configuração). Na primeira execução, `missionPresent=false` é esperado se não houver classe de Policy na missão; `addonPresent=false` é esperado pois o addon não existe.
- Repetir SP com `description.ext` contendo, ao nível raiz:
~~~cpp
class CfgSPORGPolicy {
    enabled = 1;
    schemaVersion = 1;
    whitelist[] = {"FirstAidKit"};
    blacklist[] = {"ItemGPS"};
};
~~~
  Espera-se `missionPresent=true`, `missionEnabled=1`, arrays carregados. **Atenção:** incluir somente em missão de teste, nunca sobrescrever uma `description.ext` homologada.
- O smoke testa comandos básicos/semântica de referência; **não certifica a segurança do loader, de qualquer PBO nem multiplayer**. Enviar RPT para auditoria.

**3 — Portabilidade:** testar colagem em controle de texto de UI quando P5 existir; nenhuma solução de arquivo externo está aprovada ainda. Multiplayer real obrigatório em P6.

## Critério de seguir para P1

1. Smoke SP positivo 20/20 e negativo 140/140 **aprovados** (160/160 total); verificar classnames reais na modlist antes de congelar regex.
2. Consolidar fonte de config testada em `missionConfigFile` e modo inválido (fail-closed).
3. Fixar contratos e ajustar documentação/machine status com evidências, sem fingir homologação MP.
4. Desenvolver motor `Policy 0.1-A` apenas na branch de Policy, com funções/índice e testes engine; **não integrar Items ainda**.

## Integridade

Até aqui: **sem alterações de runtime** em `addons/`, `missions/`, e **sem merge** em `main`. Se o estado global antigo `machine/PROJECT_STATE.json` conflitar, priorizar o handoff 74 + este documento 75 para a frente Policy. O roadmap da branch de Policy passa a ser fonte de verdade da implementação do novo módulo; a branch de ícones permanece intacta.


## Checkpoint adicional — missões negativas prontas em 24/10/2026 (RPT pendente)

Após o smoke SP positivo **20/20 PASS**, foi entregue novo pacote `SP_ORG_Policy_P0_Testes_Negativos_20261024.zip` com quatro missões automáticas `C` a `F` para estados de **versão inválida, whitelist não-array, classname duplicado e política exigida ausente**. Cada missão prevê **35 asserções** de schema, decisão, prontidão e fonte real `description.ext`, total esperado **140 PASS / 0 FAIL** apenas quando comprovado pelo operador em RPT. Há ainda testes de limites (129 caracteres e 4097 entradas) e payload contendo texto malicioso tratado como dado, nunca como SQF.

**Execução posterior confirmada no RPT, em 24/10/2026 às 22:19–22:21: 140/140 PASS e 0 FAIL;** evidência e SHA-256 do RPT: [P0_NEGATIVE_SP_RPT_20261024.md](projects/policy-editor/evidence/P0_NEGATIVE_SP_RPT_20261024.md). Evidência da preparação e hash do ZIP: [P0_NEGATIVE_MISSIONS_PREP_20261024.md](projects/policy-editor/evidence/P0_NEGATIVE_MISSIONS_PREP_20261024.md). P0 em revisão final (regex de classes reais e teste Python); ainda não há runtime Items/UICommon/Weapons alterado.

**Retomar agora:** as missões C–F já foram executadas e aprovadas e a suíte Python também (7/7 PASS, 28 fixtures). Finalizar amostragem real de classnames para congelar regex e consolidar contratos v1. Iniciar P1 depois do gate documental, mantendo motor e loader reais como fases ainda não homologadas.


## QA Python validado após os smoke SP (24/10/2026)

- **Executado no ambiente do assistente:** Python 3.13.5, `python -m unittest discover -s tools/policy -p 'test_*.py' -v`.
- **Resultado real:** 7 métodos `unittest` OK, 0 falhas, 0 erros, exit code 0. A suíte usa os 28 fixtures e não requer pacotes `pip`.
- Os bytes de código e fixtures foram conferidos contra os respectivos hashes Git blob da branch (test script `7d46f8957da4a1599c5ef538b0173c4bba2371c3`, fixtures `e6fcc4ad3d81a82494ebd6042bbe22c90f0a40c9`).
- Evidência completa: [P0_PYTHON_UNITTEST_20261024.md](projects/policy-editor/evidence/P0_PYTHON_UNITTEST_20261024.md); log SHA-256 `42f2f32c7cfbcfc6f5e4dcfba7b1173be14ea2331f49a0c1e751d4ea2c9db683`.
- **Único gate P0 substantivo pendente:** validar regex classname no modset real e fechar revisão documental dos contratos. Addon/loader e MP continuam fases posteriores.


## Checkpoint 25/10/2026 — missão P0 G pronta, RPT pendente

A execução de 160 asserções SP de P0 A–F e 7 testes Python / 28 fixtures já foi confirmada; **Policy runtime continua NÃO implementado**. O último gate P0 é confrontar a regex ASCII proposta com os classnames realmente presentes no modset do operador.

**Foi criado e entregue ZIP pronto:** `SP_ORG_Policy_P0_G_Auditoria_Classnames_20261025.zip`, SHA-256 `ffc30f29a957eadf2586c5270e3719095f57583456e24db4d077bf28c2c92c79`, contendo pasta `SP_ORG_Policy_P0_G_ClassnameAudit.VR`. Instalar a pasta `.VR` em `missions`, executar no Eden → VR → Preview com a modlist normal. A missão roda sem console/debug e registra RPT prefixado `[SPORG_POLICY_P0_G]`. **O RPT não foi recebido, logo nenhum PASS de classname real é alegado.**

Metodologia: percorre `CfgWeapons`, `CfgMagazines`, `CfgGlasses`, `CfgVehicles`, confirma `scope`, `scopeArsenal`, `displayName`, mochila `isBackpack`, e pré-filtro de `Items` para `CfgWeapons` com `ItemInfo` / `CfgMagazines`. Total bruto, elegíveis, anomalias (incluindo exemplos e origem mod) e 10 autotestes de regex separados por bloco `[ROOT_SUMMARY]`, `[SUMMARY]`. Estados PASS, REVIEW e FAIL têm semântica própria; REVIEW pede inspeção humana, não aprovação automática.

**Evidência de preparação e instruções exatas:** [P0_G_CLASSNAME_AUDIT_PREP_20261025.md](projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_PREP_20261025.md). Com o RPT real, revisar falsos positivos/negativos do pre-filtro, e apenas então congelar regex/contratos de P0. Sem mudanças em runtime `addons/`, `missions/` do repo nem `main`.


## Continuidade crítica 25/10/2026 — P0 G REVIEW e G2 entregue

A missão P0 G foi realmente executada na engine (RPT de 25/10, Arma Stable 2.22.154089), retornando **REVIEW**: SELFTEST **10/10 PASS**, scan **133.399 raw**, **54.003 elegíveis**, **532 elegíveis incompatíveis com a regex estrita** e **529 no pre-filtro inicial Items**; máxima de nome **78**. Regex provisória `^[A-Za-z_][A-Za-z0-9_]{0,127}$` rejeita prefixo numérico de classes reais `121_SP10M_18_FDE`, `121_USASOC_CNVD_ITEM` (origem `@BGD - Tools of the Trade`). Como os detalhes de classe foram truncados em 40 exemplos, não supor que as outras incompatibilidades tenham a mesma causa. [Auditoria RPT G](projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_RPT_20261025.md).

Nova missão automática **P0 G2** entregue: `SP_ORG_Policy_P0_G2_Comparacao_Classnames_20261025.zip`, SHA-256 `d4359363eca916f6a40e4a9d58b7e56fd332c841390d36f01529f105ca8b79a8`, pasta `SP_ORG_Policy_P0_G2_RegexComparison.VR`, prefixo RPT `[SPORG_POLICY_P0_G2]`, 12 autotestes esperados. Ela compara regex original versus candidata `^[A-Za-z0-9_]{1,128}$`; informa valores `fixedByDigit` e `remainingInvalid` por root e amostras do que continuar inválido. **G2 ainda NÃO testada na engine.** [Preparação G2](projects/policy-editor/evidence/P0_G2_REGEX_COMPARISON_PREP_20261025.md).

**Retomar sem repetir perguntas:** operador instala G2 na pasta missions, executa Eden VR Preview com a mesma modlist e envia RPT. Então confirmar regex final, atualizar suite Python, fixtures e smoke negativos que tratavam primeiro dígito como inválido e reexecutar QA afetado; só então fechar P0 e partir para P1. Outros 160 PASS SP e 7 PASS Python são resultados históricos corretos dos contratos antigos, não validação retroativa do contrato revisado. Nenhum código de runtime ou main alterado.


## Continuidade 25/10 — G2 PASS, contrato corrigido, SQF H aguarda RPT

1. Operador executou **G2 no Arma 3 Stable 2.22.154089**, RPT `Texto colado(20261025-050918).txt`, SHA-256 `d3eabefdc7c96e6aabc715d4626f8f32b6f559b520c33ed50fcffb6a9e3497d1`. **PASS**, 12/12 autotestes, 0 erros root/SQF. Mesmas 133.399 raw/54.003 elegíveis/50.727 no pré-filtro Items; a regra `^[A-Za-z0-9_]{1,128}$` recuperou **668/668 raw, 532/532 elegíveis, 529/529 pré-filtro Items; 0 restantes**. Exemplos: `30Rnd_556x45_Stanag` (Arma/ACE), `121_SP10M_18_FDE` (BGD Tools of the Trade), `1st_pack_1` (BGD High Tier Equipment). [Relatório](projects/policy-editor/evidence/P0_G2_REGEX_COMPARISON_RPT_20261025.md).
2. **Python canônico alterado**: `tools/policy/test_p0_contracts.py` blob `8080d70c1a5bed07fa4cce1ca988f20c31bcb3bc`; `machine/policy/p0_contract_fixtures_v1.json` blob `1a75b9541999c62b818c024026872cf185eec62b` (32 fixtures). Arquivos locais confirmados contra os blobs e **8/8 unittest PASS, 0 FAIL**. [Evidência](projects/policy-editor/evidence/P0_G2_PYTHON_REGRESSION_20261025.md).
3. **ZIP pronto para operador**: `SP_ORG_Policy_P0_H_Regressao_Contrato_G2_20261025.zip`, SHA256 `e7549e7ef6fbe60ada06669efa6af982a7c84b49a691a96aaef2047b2ffab7ec`, quatro pastas `SP_ORG_Policy_P0_H_C_InvalidVersion.VR`, `...H_D_InvalidArray.VR`, `...H_E_DuplicateClass.VR`, `...H_F_RequiredMissing.VR`. Cada uma **espera 39 PASS, 0 FAIL (156 total)** e usa prefixo `[SPORG_POLICY_P0_H]`. **Ainda NÃO foi testado em Arma**, apenas ZIP estruturalmente verificado. [Preparação](projects/policy-editor/evidence/P0_H_REVISED_CLASSNAME_SQF_PREP_20261025.md).
4. **Próxima ação direta:** operador extrai as quatro pastas .VR no perfil, abre uma por vez no Eden VR Preview com a modlist normal e envia RPT. Analisar P0 H [TEST], [CONFIG], [SUMMARY] e erros da engine; se 156/156 PASS e contrato consistente, encerrar P0 formalmente e iniciar planejamento P1 Motor Policy isolado.
5. **Limites:** 160/160 SP A–F anteriores e Python 7/7 anteriores foram corretos **para a regex antiga**; não contar como prova retroativa da nova. Nenhum addon Policy real nem integração de servidor/MP foi implementado. Branch `feature/policy-0.1-p0-contracts`, baseline homologada intocada.


## Encerramento P0 e handoff P1 — 25/10/2026 (conclusivo)

- **H executado na engine real**, Arma 3 2.22.154089, RPT `Texto colado(20261025-055728).txt` SHA-256 `86ad170a1d5a7445aa7b608cde31afa49c68755569ffb081d8c5ea29d7decbf1`: 4 missões SP VR `[SPORG_POLICY_P0_H]`, 39/39 PASS cada = **156/156 PASS, 0 FAIL, 0 SQF expression error**; estados C/D/E INVALID, F PENDING, todos `effectiveAllow=false`. [Auditoria](projects/policy-editor/evidence/P0_H_REVISED_CLASSNAME_SQF_RPT_20261025.md).
- **Policy P0 contrato e viabilidade SP formalmente FECHADOS**: formato `^[A-Za-z0-9_]{1,128}$`, G2 scanner de mods reais 12 PASS recuperou 532 classnames elegíveis, Python revisado 8 PASS com 32 fixtures. A/B positivo antigo 20/20 PASS; C–F antigo 140/140 PASS como histórico, **H substitui a regressão negativa da regex antiga**.
- **Weapons verificado no código mission-first 0.6-F R6**: não foi identificada regex restritiva na detecção de compatibilidade, que usa engine `compatibleItems/compatibleMagazines` e `baseWeapon` para SECONDARY. Contudo `fn_getWeaponCompatibility.sqf` fornece `magazinesByMuzzle` e o seletor `fn_buildCompatibilitySelectorModel.sqf` ainda usa `magazines` agregada; pendência **WEAPONS-COMPAT-MULTIMUZZLE-01** registrada em [Weapons](modules/Weapons.md), junto de **WEAPONS-POLICY-CLASSNAME-01** para futura integração Policy. Não é correção do P0 nem bug de regex confirmado em Weapons.
- Próxima execução: **P1 implementação isolada Policy**, sem addon real/MP presumidos. Não reexecutar scans G/G2 ou H se contrato não mudar; novo addon e integração demandam QA próprio. Branch `feature/policy-0.1-p0-contracts`, sem merge, baseline Items/Weapons/UICommon preservada.


## Handoff P1 — 25/10/2026

P0 permanece **FECHADO**, regex classname v1 `^[A-Za-z0-9_]{1,128}$` conforme [contrato reparado](projects/policy-editor/P0_CONTRACTS_20261024.md). Nova branch `feature/policy-0.1-a-core` contendo addon source `addons/ServoPeregrino_Organizador_Policy` com validação/índices/decision/snapshot puros e registro de capabilities Nexus (sem loader, sem MP/autoridade, sem política global de CfgRemoteExec). ZIP entregue ao operador: `SP_ORG_Policy_P1_A_CoreLab_20261025.zip`, SHA256 `a67bd800ec70c3bbe972859878ff0436c474968f6b2faf1e32bc5647e1e39a5d`, missão `SP_ORG_Policy_P1_A_CoreLab.VR`, prefixo RPT `[SPORG_POLICY_P1_A]`, **68 assertions esperadas**. QA ZIP/source offline aprovado, engine ainda NÃO executada: **P1 CANDIDATE, não homologado**. [Documento detalhado](projects/policy-editor/P1_CORE_0_1_A_20261025.md). Próximo passo: operador roda VR Preview e envia RPT para auditoria; validar 68/68 ou corrigir, só então considerar P1 core SP homologado. Capabilities do addon real/PBO e MP requerem evidência específica futura.


## 26/10 — P1-A RPT não válido, R1 reteste pronto

**P0 permanece concluído; P1 não foi homologado.** RPT 26/10/2026 `Texto colado(20261026-182742).txt`, SHA256 `be8cd428684c70d12533f7128cc509c471b22a31f3742effe50ff08e839e7f70`: cinco scripts core não encontrados, 91 `Error in expression` (67 `_ok`, 22 `_ctx`, 1 `_result`, 1 `_v`) e apenas 1 `[TEST] PASS`. `READY_FOR_OPERATOR_REVIEW` antigo é falsa aprovação. Novo pacote `SP_ORG_Policy_P1_A_R1_Fix_Carregamento_20261026.zip`, SHA `018e04a78392410cf9e771771547b409bf124b673eb8f8e863d02737e7dde422`, pasta `SP_ORG_Policy_P1_A_R1_CoreLab.VR`, prefixo `[SPORG_POLICY_P1_A_R1]`, espera cinco `[LOAD] OK`, 68 `[TEST] PASS` e `SUMMARY PASS_CANDIDATE`; **não foi executado ainda em Arma**. Os cinco cores são bytes idênticos à fonte da branch `feature/policy-0.1-a-core`. Próximo operador: instalar pasta completa .VR no perfil, Eden VR Preview, enviar RPT. [Evidência incidente](projects/policy-editor/evidence/P1_A_RPT_20261026_LOADER_FAILURE.md). Nenhum addon PBO, loader P2, MP nem alteração Items/Weapons/UICommon.


## Checkpoint P1 em 26/10/2026 (prioridade sobre notas P1 anteriores)

A primeira missão `SP_ORG_Policy_P1_A_CoreLab.VR` foi executada, porém RPT `Texto colado(20261026-182742).txt` deu **5 `Script ... fn_*.sqf not found`**, **91 erros** principalmente `_ok` 67 e `_ctx` 22, mais `_result` e `_v` 1 cada. O resumo `status=READY_FOR_OPERATOR_REVIEW pass=1 fail=0 total=68` é **falso positivo de harness**; **P1 A NÃO HOMOLOGADO**. Evidência [RPT P1A](projects/policy-editor/evidence/P1_A_RPT_FAIL_BOOTSTRAP_AND_R1_FIX_20261026.md).

**R1 corretiva entregue**: `SP_ORG_Policy_P1_A_R1_Correcao_Load_20261026.zip`, SHA-256 **`9f885450904ed3cf905743e2c2c81c39a93034787b61a6dfebecc836c2766e7d`**, missão `SP_ORG_Policy_P1_A_R1_CoreLab.VR`, prefixo **`[SPORG_POLICY_P1_A_R1]`**. Cinco fontes core byte-idênticas aos blobs do addon foram movidas para raiz da missão, `fileExists` validará boot, abortando com `BOOTSTRAP_FAILED` se faltar; checker e SUMMARY exigem 68 asserções executadas, 68 PASS e 0 FAIL. **Correção testada apenas offline: reteste Arma RPT PENDENTE**. Sem merge, P0 fechado e runtime de Items/Weapons/UICommon preservado. Próximo passo: operador executa a missão R1 no Eden VR Preview e envia RPT; só então avaliar regras core e eventual gate addon/PBO.


## CHECKPOINT MAIS RECENTE — 26/10/2026, Policy P1-A R1 core SP APROVADO

O RPT real `Texto colado(20261026-195652).txt` (SHA-256 **`37d019a9800b679a5b1489e4d046c090fec6dcfdf0aec3c5a306288d4ff3c898`**, 1.061.311 bytes, 8.226 linhas) confirmou no Arma Stable 2.22.154089 a missão `SP_ORG_Policy_P1_A_R1_CoreLab.VR`. Prefixo `[SPORG_POLICY_P1_A_R1]`; **5 BOOT exists=true, 1 START, 68 TEST PASS com 68 IDs únicos, 0 TEST FAIL, 1 SUMMARY pass=68 fail=0 total=68 expected=68 complete=true valid=true, nenhum erro SQF**. [Evidência canônica R1](projects/policy-editor/evidence/P1_A_R1_CORE_SP_RPT_PASS_20261026.md). Referências anteriores de R1 `RPT pendente` são históricas/superadas; o erro de cinco fontes da primeira candidata foi corrigido no pacote R1.

**Status correto:** P0 CONTRATOS FECHADOS; **P1 SUBGATE CORE MISSION-FIRST SQF HOMOLOGADO**; P1 addon/PBO real e capacidades registradas no Nexus **ainda PENDENTES**; P2+ ainda não autorizados como implementados. Próximo marco recomendado: testar addon Policy com Nexus de verdade, `CfgFunctions`/`preInit` e as duas capabilities v1; missão R1 usou shim local `Nexus_fnc_createResult` e `addonRuntime=false`. Branch `feature/policy-0.1-a-core`. Sem alterações de Items/Weapons/UICommon, sem merge. Os cinco fontes core não foram modificados nesta homologação.


## CHECKPOINT 26/10/2026 — P1-B Nexus Integration MISSÃO ENTREGUE, RPT PENDENTE

Nova branch `feature/policy-0.1-b-nexus-integration`, da `feature/policy-0.1-a-core`. **P1-A R1 68/68 PASS permanece homologado**. O P1-B agora testa integração do Nexus *real*, não shim: 11 funções Nexus + 1 header (apenas linha de include adaptada ao layout raiz), cinco funções core Policy + initialize sem alterações, `CfgFunctions` de missão e `preInit=1` para Nexus/Policy. ZIP **`SP_ORG_Policy_P1_B_Nexus_Integration_Lab_20261026.zip`**, SHA256 **`618faca9a6fd4a23bfb890a29c1d1e59581af423c41cd5074021eb8b90416a32`**, pasta `SP_ORG_Policy_P1_B_NexusIntegration.VR`. QA estático: hashes Git originais Nexus/Policy verificados **18/18**, ZIP 23 membros, 19 SQF delimitadores balanceados, 59 IDs únicos. [Especificação P1-B](projects/policy-editor/P1_B_NEXUS_INTEGRATION_LAB_20261026.md).

**O que falta:** rodar Eden VR → Preview e enviar RPT com prefixo `[SPORG_POLICY_P1_B]`. Exigir **18 BOOT exists=true, 59 TEST PASS/0 FAIL, SUMMARY complete=true valid=true, sem erro SQF**. **Missão ainda NÃO executada na engine** e não implementa addon binário. P1-C deve testar PBO real Nexus+Policy, dependência `CfgPatches.requiredAddons`, `CfgFunctions`/`preInit` e capacidades v1; depois avaliar P2. Nenhuma alteração em Items/Weapons/UICommon, nenhuma merge `main`. Todo parágrafo mais antigo que afirme P1-B já homologado ou RPT P1-A pendente é histórico.


## CHECKPOINT MAIS RECENTE 26/10/2026 — P1-B SP HOMOLOGADO 59/59, P1-C PBO A SEGUIR

Novo RPT `Texto colado(20261026-210613).txt`, SHA256 `fe37a41b8fe353615bff55fd5c1441c8d4cf9d44771e4e19d330169e71971bd7`, missão `SP_ORG_Policy_P1_B_NexusIntegration.VR`, prefixo `[SPORG_POLICY_P1_B]`. Verificou-se **18 BOOT true, 59 testes PASS únicos (CFG=4,NEXUS=25,POLICY=30), 0 FAIL, 0 `Error in expression`/`Error position`, resumo `status=PASS pass=59 fail=0 total=59 expected=59 complete=true valid=true scope=MISSION_CFGFUNCTIONS_NEXUS_POLICY addonRuntime=false mp=false`**. Nexus initialize e Policy initialize foram executados por preInit **de missão**, capabilities `policy.evaluate` e `policy.snapshot` registradas com Nexus REAL, reinit idempotente. [Evidência canônica](projects/policy-editor/evidence/P1_B_NEXUS_REAL_CFGFUNCTIONS_SP_RPT_PASS_20261026.md). Notas anteriores indicando `P1-B RPT pendente` são históricas.

**Estado:** P0 fechado; P1-A R1 core SP 68 PASS; **P1-B real Nexus mission-first SP 59 PASS HOMOLOGADO**. Próximo **P1-C addon/PBO Nexus + Policy não iniciado**, incluir CfgPatches requiredAddons, CfgFunctions/preInit do addon, paths e registry com mission tester SEM funções duplicadas. P1 todo NÃO fechado até P1-C. P2+ planejados; MP/JIP P6; não tocar Items/Weapons/UICommon e sem merge. Continuidade completa deve ser criada em `docs/projects/policy-editor/CONTINUIDADE_POLICY_P1B_P1C_20261026.md` na branch `feature/policy-0.1-b-nexus-integration`.
