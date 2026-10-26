# Policy P1-A — incidente no primeiro RPT e correção de laboratório R1 (26/10/2026)

**Conclusão:** P1-A original **REPROVADO/BLOCKED POR INFRAESTRUTURA DE MISSÃO**, não por regra de Policy. O RPT **não validou** os 68 testes prometidos, apesar de o resumo reportar erroneamente `status=READY_FOR_OPERATOR_REVIEW pass=1 fail=0 total=68`.

## Evidência do operador

- Arma 3 Stable **2.22.154089**, modset real ACE/RHS/BGD, execução P1-A em VR às **15:26:50** de 26/10/2026, conforme relógio do RPT.
- Arquivo recebido: `Texto colado(20261026-182742).txt`; tamanho **1.081.057 bytes**, **8.793 linhas**, SHA-256 **`be8cd428684c70d12533f7128cc509c471b22a31f3742effe50ff08e839e7f70`**. Não publicar RPT bruto: contém caminhos pessoais e modlist.
- **5 avisos `Script policy/functions/core/fn_*.sqf not found`**, envolvendo `isValidClassname`, `validateExport`, `createContext`, `evaluate` e `snapshot`. Os cinco fontes estão presentes no ZIP original, mas a engine não os encontrou quando o runner usou `preprocessFileLineNumbers` por caminho de subdiretório.
- **91 ocorrências `Error in expression`**, **91 `Error position:`**, **91 `Error Variável indefinida na expressão:`**: `_ok` **67**; `_ctx` **22**; `_result` **1**; `_v` **1**. São falhas de execução em cascata após ausência de funções, não diagnóstico de erro sintático específico na implementação de domínio.
- Apenas **1 linha `[TEST] PASS`** no RPT (`SNAPSHOT_NO_INDICES`), por condição que independe de carga dos cinco arquivos. **0 linhas de `[TEST] FAIL` não significam sucesso.** O runner antigo não fazia preflight, contava somente asserções executadas e emitia status positivo se `fail=0` mesmo com `pass=1` e `total=68`.
- Erros de config e stringtable de terceiros durante boot aparecem no RPT, mas não devem ser confundidos com o incidente do laboratório P1.

## Causa e reparo executados

1. **Caminhos SQF do laboratório:** os cinco arquivos core foram deslocados **da subpasta `policy/functions/core/` para a raiz da pasta de missão `.VR`**, mesma pasta de `init.sqf` e runner. `preprocessFileLineNumbers` agora usa **nomes relativos à raiz da missão**. Segundo a wiki Bohemia, `fileExists` não aceita paths absolutos; `getMissionPath` não deve alimentar `fileExists` ([fileExists](https://community.bistudio.com/wiki/fileExists), [preprocessFile](https://community.bistudio.com/wiki/preprocessFile)).
2. **Bloqueio fail-closed do harness:** preflight `fileExists` em todos os cinco arquivos, log `[LOAD] MISSING` e resumo `BLOCKED_FILES_MISSING` com `executed=0` se faltar algum. Após compilação, validar tipo Code de cada função; se não carregar todas, `BLOCKED_LOAD_COMPILE`. Registrar `[LOAD] OK` para cada arquivo.
3. **Contagem protegida:** `params` de `_check` recebe `false` por padrão caso um Boolean não seja produzido; status `PASS_CANDIDATE` **somente** se `fail=0`, `count=68` e cinco funções carregadas; caso contrário `FAIL`/ `BLOCKED`. A auditoria externa também deve confirmar **68 logs [TEST] e 0 Error in expression** antes de homologar.
4. **Versão isolada:** prefixo novo `[SPORG_POLICY_P1_A_R1]`, nome de missão novo `SP_ORG_Policy_P1_A_R1_CoreLab.VR` para evitar arquivos antigos confundidos. Sem mudanças no algoritmo de autorização v1.

## Pacote R1 entregue

- `SP_ORG_Policy_P1_A_R1_Fix_Carregamento_20261026.zip`
- SHA-256 final **`018e04a78392410cf9e771771547b409bf124b673eb8f8e863d02737e7dde422`**, tamanho **10.682 bytes**; 10 arquivos: README e missão VR com runner, init, description, sqm e cinco fontes.
- Verificação offline: `ZipFile.testzip() == None`, **68 asserções de topo** (não contar a invocação `_check` dentro de `_judge`), balanceamento `[]{}()` ignorando strings e comentários, runner com fail-fast, cinco arquivos de código **byte a byte iguais ao ZIP anterior e aos blobs Git do P1-A**. Não confundir isso com parser/execução Arma.
- Instalar **a pasta completa** `SP_ORG_Policy_P1_A_R1_CoreLab.VR` em `missions`, abrir **Eden → VR → Preview**, evitar usar Save As sem copiar SQFs. A execução inicia automaticamente via `init.sqf`.
- RPT esperado (NÃO observado ainda): cinco `[LOAD] OK`; 68 linhas `[TEST] PASS`; `[SUMMARY] status=PASS_CANDIDATE pass=68 fail=0 total=68 expected=68 loaded=5 expectedLoaded=5`; nenhum `Error in expression` associado à missão.

## Situação e gates

**P1 = CANDIDATE_R1_SP_RPT_PENDING**, código addon source intocado, nenhuma execução de PBO/Nexus real, nenhum teste MP. O fato de ZIP da candidata original conter os arquivos e os testes estáticos estarem verdes **não validou descoberta de arquivos na engine**; por isso o harness agora efetua preflight real. Corrigir qualquer problema adicional apontado pelo próximo RPT e reexecutar até todo o teste ficar verde. Só então considerar homologação mission-first do núcleo.

- Docs: [P1 original](../P1_CORE_0_1_A_20261025.md); [P0 congelado](../P0_CONTRACTS_20261024.md).
- Preservação: **sem alteração em Items, Weapons, UICommon, Nexus, main ou baseline homologada**. Não confundir reparo de laboratório com implementação de Policy loader P2/PBO.
