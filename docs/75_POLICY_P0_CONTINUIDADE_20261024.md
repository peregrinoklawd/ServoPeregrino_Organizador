# 75 — Continuidade Policy P0 (24/10/2026)

**Repo:** `peregrinoklawd/ServoPeregrino_Organizador`  
**Branch atual:** `feature/policy-0.1-p0-contracts`, criada da baseline `67f457414c37784ef0469e7235d39006342edb40` (`baseline/items-uicommon-r2-2-sp-homologated-20261021`).  
**Status P0 após dois RPTs de 24/10:** smoke SP positivo A/B **20/20 PASS** e negativo C–F **140/140 PASS**, acumulado **160/160 PASS, 0 FAIL**. P0 **em revisão final dos contratos** (amostragem de classnames e revisão final pendentes; Python 7/7 PASS); **addon runtime e MP NÃO testados**. Evidências: [A/B](projects/policy-editor/evidence/P0_SP_SMOKE_RPT_20261024.md) e [C–F](projects/policy-editor/evidence/P0_NEGATIVE_SP_RPT_20261024.md).

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

**Foi criado e entregue ZIP pronto:** `SP_ORG_Policy_P0_G_Auditoria_Classnames_20261025.zip`, SHA-256 `0bd55b4742ffb2837f2ae26cb33d165cdf284b2f51b8460d9669d816a0f6d7f7`, contendo pasta `SP_ORG_Policy_P0_G_ClassnameAudit.VR`. Instalar a pasta `.VR` em `missions`, executar no Eden → VR → Preview com a modlist normal. A missão roda sem console/debug e registra RPT prefixado `[SPORG_POLICY_P0_G]`. **O RPT não foi recebido, logo nenhum PASS de classname real é alegado.**

Metodologia: percorre `CfgWeapons`, `CfgMagazines`, `CfgGlasses`, `CfgVehicles`, confirma `scope`, `scopeArsenal`, `displayName`, mochila `isBackpack`, e pré-filtro de `Items` para `CfgWeapons` com `ItemInfo` / `CfgMagazines`. Total bruto, elegíveis, anomalias (incluindo exemplos e origem mod) e 10 autotestes de regex separados por bloco `[ROOT_SUMMARY]`, `[SUMMARY]`. Estados PASS, REVIEW e FAIL têm semântica própria; REVIEW pede inspeção humana, não aprovação automática.

**Evidência de preparação e instruções exatas:** [P0_G_CLASSNAME_AUDIT_PREP_20261025.md](projects/policy-editor/evidence/P0_G_CLASSNAME_AUDIT_PREP_20261025.md). Com o RPT real, revisar falsos positivos/negativos do pre-filtro, e apenas então congelar regex/contratos de P0. Sem mudanças em runtime `addons/`, `missions/` do repo nem `main`.
