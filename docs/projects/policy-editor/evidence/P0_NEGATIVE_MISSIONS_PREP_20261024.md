# Policy P0 — Rodada negativa automatizada (24/10/2026)

**Status:** pacote de missões gerado; estrutura ZIP e delimitadores SQF revisados offline. **Ainda NÃO executado no Arma**. O usuário executará os laboratórios e compartilhará RPT. A baseline Items/UICommon R2.2 não foi alterada.

## Artefato entregue ao operador

- Nome: `SP_ORG_Policy_P0_Testes_Negativos_20261024.zip`
- SHA-256 do ZIP: `4e092a41aae095085a76b9389aa7e291bf5ac0e296ac4eb47b95599aff2be0a1`
- Estrutura: quatro pastas de missão independentes `.VR`, cada uma com `mission.sqm`, `description.ext`, `init.sqf` e `runPolicyP0Negative.sqf`; `LEIA-ME.txt` na raiz. Total: **17 arquivos**; mapas apenas VR, unidade vanilla `B_Soldier_F`, sem novas dependências.
- Instalação: extrair apenas as pastas `.VR` para `Documents/Arma 3/missions` (ou pasta de missões do perfil), iniciar uma de cada vez em `Eden Editor > VR > Preview`. O `init.sqf` executa o smoke automaticamente após player existir. Não usar Debug Console.
- Indicador: hint final no jogo e prefixo RPT `[SPORG_POLICY_P0_NEG]`; cada cenário espera **35 PASS / 0 FAIL**. Esta é uma **expectativa de teste**, não um resultado medido na engine.

| Missão | Entrada concreta em `description.ext` | Estado/código esperados do loader-protótipo |
|---|---|---|
| `SP_ORG_Policy_P0_C_InvalidVersion.VR` | `schemaVersion=2` com política habilitada | `INVALID / INVALID_CFG_VERSION` |
| `SP_ORG_Policy_P0_D_InvalidArray.VR` | `whitelist = "FirstAidKit"` (string, não array) | `INVALID / INVALID_CFG_LIST_TYPE` |
| `SP_ORG_Policy_P0_E_DuplicateClass.VR` | whitelist com `ItemGPS` e `itemgps` | `INVALID / DUPLICATE_CLASSNAME` |
| `SP_ORG_Policy_P0_F_RequiredMissing.VR` | não declara `CfgSPORGPolicy`, mas o teste exige política | `PENDING / POLICY_REQUIRED_MISSING` |

Cada missão também roda a **mesma suíte de 35 asserções** de referência, composta de 20 fixtures de payload/schema (inclui limite de 129 caracteres e 4097 entradas), 4 gates de decisão/índice, 8 de prontidão ambiental/autoridade e 3 de config da missão.

**Ponto de segurança:** a intenção dos testes negativos é obter `PASS` quando a entrada inválida é **rejeitada**. O caminho `ACTIVE` não pode aplicar ADD se o snapshot falhou validação; estado `PENDING` exigido não vira fallback OPEN. Ainda não existe server-authority real ou loader instalado no addon. Texto malicioso é tratado como **dado JSON** através de `fromJSON`/`toJSON`, nunca executado por `compile`.

## QA offline realmente realizado

- ZIP abre e passa `testzip()`; 17 entradas, sem path absoluto ou `../`.
- Cada missão apresenta seus quatro arquivos, classe `B_Soldier_F` e caminho de execução automática.
- `mission.sqm`, `description.ext` e `runPolicyP0Negative.sqf` passaram a conferência estática de equilíbrio de chaves/parênteses/colchetes que desconsidera strings e comentários.
- Cada `description.ext` corresponde ao estado/código esperados e os quatro nomes das missões são distintos.
- Estes são **testes de pacote/estrutura**, não homologação do parser SQF do Arma nem prova de correção de lógica.

## Limites explícitos e sequência

- É um validador **isolado de contrato no ambiente de missão**; **não** é `addons/ServoPeregrino_Organizador_Policy/config.cpp`, integração de Items, PBO ou motor de segurança completo.
- `fromJSON` é alimentado com strings JSON **sintaticamente válidas**, mas com schemas/valores inválidos. Malformed JSON com sintaxe quebrada, chaves JSON repetidas e ataques de carga fora dos limites são gates adicionais, não testados nesta rodada.
- Os testes `mayAdd` são apenas modelo de decisão SP; autoridade MP/JIP e bypass de cliente requerem P6 com host e clientes.
- A regex de classname ASCII/underscore permanece candidata até comparação com classnames reais de mods.
- Após receber RPT, conferir precisamente 4 blocos `[SUMMARY]`, `pass=35`, `fail=0`, `CONFIG` e ausência de `Error in expression` atribuível ao smoke. Se houver erros, corrigir candidato antes de P1. Não confundir warnings externos de CBA/BGD com falha do Policy.

## Refs

- [Contratos P0](../P0_CONTRACTS_20261024.md).
- [Primeiro smoke SP, 20/20 aprovado](P0_SP_SMOKE_RPT_20261024.md).
- Bohemia: https://community.bistudio.com/wiki/fromJSON, https://community.bistudio.com/wiki/toJSON, https://community.bistudio.com/wiki/trim, https://community.bistudio.com/wiki/isArray.

**Git:** apenas documentação e estado de QA desta rodada; os arquivos gerados das missões foram disponibilizados em ZIP na conversa, não adicionados ao código runtime. Branch `feature/policy-0.1-p0-contracts`; sem merge em main. 
