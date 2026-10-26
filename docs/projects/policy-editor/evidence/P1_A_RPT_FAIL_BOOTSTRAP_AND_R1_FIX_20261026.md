# Policy P1-A — RPT falhou em bootstrap; missão R1 corrigida (26/10/2026)

**Status:** primeira execução **INVALID/FAIL (BOOTSTRAP NÃO CARREGOU)**; o pacote de correção **P1-A R1 PREPARADO**, **NÃO TESTADO NA ENGINE**. P1 continua **CANDIDATE**, nunca homologado com esse RPT.

## Evidência: RPT do usuário

- Arquivo integral analisado: `Texto colado(20261026-182742).txt`.
- SHA-256 RPT: `be8cd428684c70d12533f7128cc509c471b22a31f3742effe50ff08e839e7f70`; tamanho **1.081.057 bytes**, **8.793 linhas**; Arma 3 Stable 2.22.154089.
- Missão original `SP_ORG_Policy_P1_A_CoreLab.VR`, prefixo `[SPORG_POLICY_P1_A]`, executada às 15:26:50 do RPT.
- Antes do primeiro teste o Arma imprimiu **cinco** `Warning Message: Script policy/functions/core/fn_*.sqf not found`: `fn_isValidClassname`, `fn_validateExport`, `fn_createContext`, `fn_evaluate`, `fn_snapshot`.
- Ao não carregar as funções a suíte gerou **91 blocos `Error in expression`**: **67** `_ok` indefinidos na linha 9 do runner; **22** `_ctx` indefinidos na linha 126; **1** `_result` (linha 127) e **1** `_v` (linha 63). Essas falhas são **cascatas do bootstrap**, não prova de defeito semântico de qualquer uma das cinco funções.
- O RPT traz **um único** `[TEST] PASS id=SNAPSHOT_NO_INDICES` e nenhum FAIL marcado no padrão de teste, seguido de `[SUMMARY] status=READY_FOR_OPERATOR_REVIEW pass=1 fail=0 total=68`. **Esse SUMMARY é um falso positivo/inconsistente:** o contador `total` planejava 68 testes mas apenas 1 passou; o `_check` original incrementava `_count` antes de tentar ler `_ok` indefinida. Não homologar, nem contabilizar o 1/68 como teste funcional significativo.
- Há muitos avisos de stringtable e sintaxe de `config.cpp` de addons terceiros antes da missão; não atribuí-los ao Policy. Não publicar RPT bruto porque contém caminhos locais e lista de mods.

## Causa confirmada e limite do diagnóstico

O fato **confirmado** é que o motor Arma não encontrou os cinco arquivos nos caminhos de subpasta `policy/functions/core/` durante execução, embora constassem do **ZIP original**. O RPT **não explica se a falha veio da extração/cópia do usuário, da resolução de diretórios durante Eden Preview, ou da estrutura do pacote**. Sem acesso à pasta real copiada no PC, não presumir uma dessas explicações como fato. O runner principal na raiz foi executado, portanto a correção reduz pontos de falha usando todos os cinco `.sqf` diretamente na raiz.

## Correção mission-first P1-A R1 (artefato)

- ZIP: `SP_ORG_Policy_P1_A_R1_Correcao_Load_20261026.zip`.
- SHA-256 ZIP final: **`9f885450904ed3cf905743e2c2c81c39a93034787b61a6dfebecc836c2766e7d`**; tamanho **10.661 bytes**, **10 arquivos**.
- Pasta: `SP_ORG_Policy_P1_A_R1_CoreLab.VR`; nome novo também em `mission.sqm` e `description.ext`, para diferenciar da candidata antiga.
- Substituídos caminhos nested por arquivos no **nível raiz da missão**, `fn_isValidClassname.sqf`, `fn_validateExport.sqf`, `fn_createContext.sqf`, `fn_evaluate.sqf`, `fn_snapshot.sqf`; continuam cópias byte-a-byte idênticas ao addon source GitHub (blobs SHA abaixo).
- Runner usa `fileExists _path` e escreve **cinco** logs `[BOOT]` com caminho/status; caso algum falte, `[FATAL] MISSING_SOURCE` + `[SUMMARY] status=BOOTSTRAP_FAILED pass=0 fail=0 total=0 expected=68 complete=false valid=false` e **encerra antes das asserções**.
- `_check` foi endurecido com `_this param [1,false,[false]]`; nil ou tipo incorreto não é interpretado como aprovação (ao entrar na função).
- Final só produz `status=PASS` e `valid=true` quando `total==68`, `pass+fail==68`, `fail==0`. Caso contrário, `FAIL` e `complete=false` ou `valid=false`.
- Prefixo exclusivo R1: **`[SPORG_POLICY_P1_A_R1]`**.
- **As 68 asserções originais foram preservadas**, apenas bootstrap/contador/diagnósticos corrigidos; addon source não alterado.

### Integridade de código (identidade byte-a-byte Git)

| Arquivo flat na missão | Blob Git SHA-1 do addon |
|---|---|
| `fn_isValidClassname.sqf` | `810494637c463cdd30570fc3fdc8815f7bd4e9b1` |
| `fn_validateExport.sqf` | `b314a4e77d25412363d40b50b5523295635be408` |
| `fn_createContext.sqf` | `68d84124c76014b9887a821d0fe679e52d4ff61d` |
| `fn_evaluate.sqf` | `766d96ac988e95e65629885c0af860293a61278f` |
| `fn_snapshot.sqf` | `598c2ccf38abb4c57218087eefc6240e6bc24427` |

## QA R1 realizado e ainda pendente

**Offline PASS:** ZIP abriu (`ZipFile.testzip()==None`), 10 arquivos, sete arquivos SQF com delimitadores estruturais balanceados sob analisador que ignora comentários e strings, 68 IDs de asserções únicos preservados, todos os hashes de conteúdo core iguais aos blobs existentes do GitHub; mission.sqm e descrição identificam R1.

**Ainda NÃO EXECUTADO** na engine Arma 3. Não confundir validação estática da estrutura com prova de sintaxe/sucesso SQF no runtime.

**Execução solicitada ao operador:** extrair `SP_ORG_Policy_P1_A_R1_CoreLab.VR` para a pasta missions correta do perfil; abrir especificamente **P1 A R1 - Policy Core** no Eden VR e clicar Preview; enviar RPT. Conferir cinco `[BOOT] exists=true`, zero novos `not found`, 68 `[TEST]` conclusivos e `[SUMMARY] status=PASS pass=68 fail=0 total=68 expected=68 complete=true valid=true`. Caso haja `[FATAL]` ou qualquer `Error in expression`, fazer revisão e não declarar PASS.

**Limites de escopo:** missão independente não instala addon/Nexus, não altera Items/Weapons/UICommon, não prova CfgFunctions/preInit, não é teste MP nem libera P2. O código do addon P1 permanece como candidata enquanto aguardamos RPT válido. Fonte de verdade: branch `feature/policy-0.1-a-core`.
