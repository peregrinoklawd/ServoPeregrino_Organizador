# Policy P1-A R1 — RPT single-player VR: motor SQF aprovado (26/10/2026)

**Resultado auditado: PASS — 68/68 asserções únicas PASS, 0 FAIL, 5/5 carregamentos OK e 0 erros de expressão SQF no RPT.**

## Proveniência da execução

- RPT recebido: `Texto colado(20261026-195652).txt`; **1.061.311 bytes, 8.226 linhas**; SHA-256 **`37d019a9800b679a5b1489e4d046c090fec6dcfdf0aec3c5a306288d4ff3c898`**. Não armazenar o RPT bruto no repositório (contém caminhos de usuário e modlist).
- Arma 3 **Stable 2.22.154089**, processo iniciado às `2026/10/26 16:53:01`; execução específica do laboratório às **16:56:08**, horário impresso no RPT.
- Missão `SP_ORG_Policy_P1_A_R1_CoreLab.VR`, zip entregue `SP_ORG_Policy_P1_A_R1_Correcao_Load_20261026.zip`; SHA-256 ZIP **`9f885450904ed3cf905743e2c2c81c39a93034787b61a6dfebecc836c2766e7d`**, 10.661 bytes e integridade ZIP PASS (`testzip()==None`), 10 membros.
- Prefixo `[SPORG_POLICY_P1_A_R1]`; **75 linhas exatamente**: 5 BOOT, 1 START, 68 TEST, 1 SUMMARY. **68 IDs de testes distintos**, sem repetidos, todos `PASS`; **0 FAIL**, **0 FATAL**, **0 `Error in expression`**, **0 `Error position:`** em todo o RPT. Nenhum aviso de `Script fn_*.sqf not found` relacionado ao Policy.
- Há dezenas de `not found` e diversos avisos de `Missing ';'` de *outros* mods (strings, assets, config.cpp) fora da seção Policy; não alegar que o RPT completo está sem avisos nem imputar esses avisos ao Policy.

## Bootstrap corrigido

Cinco logs `[BOOT]`, **todos `exists=true`**, provam que a nova estrutura plana carregou os fontes `fn_isValidClassname.sqf`, `fn_validateExport.sqf`, `fn_createContext.sqf`, `fn_evaluate.sqf`, `fn_snapshot.sqf`. Os fontes são os mesmos bytes dos arquivos em `addons/ServoPeregrino_Organizador_Policy/functions/core/` conforme QA estático prévio e SHA dos blobs Git documentados em [P1](../P1_CORE_0_1_A_20261025.md). **Não é prova de CfgFunctions, preInit ou registro de capabilities em addon PBO.**

O RPT original P1-A, antes da correção R1, falhou porque cinco arquivos não foram encontrados e reportou falso positivo `pass=1 fail=0 total=68`. A execução R1 elimina esse defeito e dispõe de resumo consistente. [Erro original e preparo da R1](P1_A_RPT_FAIL_BOOTSTRAP_AND_R1_FIX_20261026.md).

## Distribuição das 68 asserções

| Prefixo de ID | PASS | Escopo |
|---|---:|---|
| `CLASSNAME` | 9 | sintaxe, números iniciais, caracteres inválidos, entrada não string |
| `EXPORT` | 22 | schema, versão, listas, normalização, duplicatas, injection, conflitos |
| `CTX` | 10 | construção e falhas/estados de contexto |
| `OPEN` | 2 | permissão aberta, classname numérico |
| `WHITELIST` | 4 | permissão e negação em lista inclusiva |
| `BLACKLIST` | 4 | negação e permissões para outros |
| `COMBINED` | 3 | whitelist + blacklist, deny-wins |
| `INVALID` | 3 | validação de consulta e recusa por estado inválido |
| `ABSENT` | 2 | ausência opcional/obrigatória |
| `PENDING` | 2 | fail-closed durante configuração pendente |
| `SNAPSHOT` | 7 | DTO, isolamento dos índices, cópia de array, ausência de autoridade |
| **TOTAL** | **68** | **68 IDs únicos, todos PASS** |

## Resumo canônico impresso pela engine

```text
16:56:08 "[SPORG_POLICY_P1_A_R1] [SUMMARY] status=PASS pass=68 fail=0 total=68 expected=68 complete=true valid=true scope=MISSION_FIRST_P1_CORE_ONLY addonRuntime=false mp=false"
```

**Os contadores conferem**: exatamente 68 linhas individuais `[TEST] PASS` mais `5 BOOT` válidos; `total=68 expected=68 complete=true valid=true`. O resultado é adequado para **homologação do núcleo P1-A SQF no laboratório single-player mission-first**.

## Decisão de gate — NÃO ampliar indevidamente o escopo

- **P1-A CORE SP / R1: HOMOLOGADO (2026-10-26)**. A lógica pura do motor de regras Policy funciona nos cenários cobertos pela suíte.
- **P1 addon real/PBO + CfgFunctions + preInit + `policy.evaluate`/`policy.snapshot` registrados no Nexus: PENDENTE**. Missão roda sem o addon Policy e usa adapter local para resultados Nexus. A fonte do addon já existe em `addons/ServoPeregrino_Organizador_Policy`, mas não foi empacotada nem testada.
- **P2 loader CfgSPORGPolicy / origem missão-servidor**, **P3–P4 Items**, **P5 editor**, **P6 autoridade e JIP multiplayer**, **P7 adapters**: não testados/implementados por este laboratório.
- Não houve modificações em Items/Weapons/UICommon, não houve merge na `main`, nem necessidade de nova correção core a partir do RPT R1.

**Próximo gate recomendado:** executar **integração real addon Policy + Nexus** (pode ser como laboratório de addon/PBO, validando dependência e capabilities) antes de fechar **P1 como um todo** e iniciar P2. Não repetir 68 testes mission-first sem mudança de lógica; focar cobertura nova do packaging/config/registro.
