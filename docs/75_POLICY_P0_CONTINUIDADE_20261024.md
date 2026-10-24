# 75 — Continuidade Policy P0 (24/10/2026)

**Repo:** `peregrinoklawd/ServoPeregrino_Organizador`  
**Branch atual:** `feature/policy-0.1-p0-contracts`, criada da baseline `67f457414c37784ef0469e7235d39006342edb40` (`baseline/items-uicommon-r2-2-sp-homologated-20261021`).  
**Status P0 após RPT de 24/10:** smoke SP das missões A/B **APROVADO 20/20 PASS (0 FAIL)**; P0 **ainda EM ANDAMENTO**, aguardando testes negativos/contratos. MP não testado. Ver [evidência](projects/policy-editor/evidence/P0_SP_SMOKE_RPT_20261024.md).

## Artefatos nesta branch

- `docs/73_AUDITORIA_COMPLETA_ITEMS_POLICY_DECISOES_20261022.md` e `docs/74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md`: cópias canônicas da branch de auditoria.
- `docs/modules/Policy.md`, `docs/projects/policy-editor/README.md` e `ROADMAP.md`: planejamento canônico, com notas de P0.
- `docs/projects/policy-editor/P0_CONTRACTS_20261024.md`: candidatos PolicySnapshot, PolicyDecision, PolicyExport, config, segurança e open gates. **LER ANTES DE PROGRAMAR.**
- `machine/POLICY_EDITOR_PLANNING_20261022.json`: P0 passou a EM ANDAMENTO, P1–P7 permanecem PLANNED; não existe runtime instalado.
- `machine/policy/p0_contract_fixtures_v1.json`: 28 fixtures de autorização/validação/fail-closed/ambiente, aprovadas pelo oráculo JS independente em 24/10 (28/28).
- `tools/policy/test_p0_contracts.py`: suíte Python unittest do oráculo de referência. **Ainda não executada neste ambiente**; não marcar PASS sem rodar.
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

1. Smoke SP já aprovado (20/20); executar testes negativos SQF e verificar classnames reais na modlist antes de congelar regex.
2. Consolidar fonte de config testada em `missionConfigFile` e modo inválido (fail-closed).
3. Fixar contratos e ajustar documentação/machine status com evidências, sem fingir homologação MP.
4. Desenvolver motor `Policy 0.1-A` apenas na branch de Policy, com funções/índice e testes engine; **não integrar Items ainda**.

## Integridade

Até aqui: **sem alterações de runtime** em `addons/`, `missions/`, e **sem merge** em `main`. Se o estado global antigo `machine/PROJECT_STATE.json` conflitar, priorizar o handoff 74 + este documento 75 para a frente Policy. O roadmap da branch de Policy passa a ser fonte de verdade da implementação do novo módulo; a branch de ícones permanece intacta.


## Checkpoint adicional — missões negativas prontas em 24/10/2026 (RPT pendente)

Após o smoke SP positivo **20/20 PASS**, foi entregue novo pacote `SP_ORG_Policy_P0_Testes_Negativos_20261024.zip` com quatro missões automáticas `C` a `F` para estados de **versão inválida, whitelist não-array, classname duplicado e política exigida ausente**. Cada missão prevê **35 asserções** de schema, decisão, prontidão e fonte real `description.ext`, total esperado **140 PASS / 0 FAIL** apenas quando comprovado pelo operador em RPT. Há ainda testes de limites (129 caracteres e 4097 entradas) e payload contendo texto malicioso tratado como dado, nunca como SQF.

**O pacote foi verificado somente estruturalmente, NÃO executado na engine**. Evidência de preparação e hash do ZIP: [P0_NEGATIVE_MISSIONS_PREP_20261024.md](projects/policy-editor/evidence/P0_NEGATIVE_MISSIONS_PREP_20261024.md). Registrar RPT quando recebido; não fechar P0 ainda nem iniciar P1 como homologado. Código de runtime Items/UICommon/Weapons não alterado.

**Retomar:** executar as quatro missões C–F no Eden VR usando `Preview`; cada uma dispara sozinha e exibe hint. Filtrar RPT por `[SPORG_POLICY_P0_NEG]`. Se houver FAIL ou `Error in expression`, corrigir protótipo e gerar ZIP revisado; manter teste reprodutível, sem manipulação manual de scripts.
