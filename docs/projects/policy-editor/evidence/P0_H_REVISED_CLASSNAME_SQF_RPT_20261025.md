# P0 H — RPT da regressão do contrato de classname revisado — 25/10/2026

**RESULTADO: APROVADO (LABORATÓRIO SQF / SP / VR): 156/156 PASS, 0 FAIL.** O contrato corrigido de classname, após os RPTs G/G2 e os testes Python, está pronto para fechamento do gate P0 de contrato/viabilidade SP. **Não é prova de addon Policy implementado, instalação PBO, integração Items/Weapons, autorizações reais MP ou servidor.**

## Proveniência

- Fonte: RPT completo recebido do operador `Texto colado(20261025-055728).txt`; **1.131.619 bytes, 9.060 linhas**.
- SHA-256 integral: `86ad170a1d5a7445aa7b608cde31afa49c68755569ffb081d8c5ea29d7decbf1`.
- Arma 3 Stable **2.22.154089**, início do processo `2026/10/25 02:50:35`, testes executados às **02:54:26, 02:55:07, 02:55:43, 02:56:23** (horários impressos no RPT), VR single-player.
- Prefixo `[SPORG_POLICY_P0_H]`: **4 START, 156 TEST PASS, 0 TEST FAIL, 4 CONFIG, 4 SUMMARY** = 168 linhas; **39 IDs únicos de teste por missão**, repetidos nas quatro configurações (156 asserções, não 156 cenários independentes).
- RPT completo: `Error in expression` **0**; `Error position:` **0**. Mensagens de config/stringtable de outros mods aparecem na carga, sem correspondência identificada com scripts SPORG_POLICY_P0_H. Não publicar o RPT bruto (caminhos locais de instalação e lista de mods).

## Resumos por cenário

| Missão | Timestamp | CONFIG state | CONFIG code | effectiveAllow | PASS/FAIL |
|---|---|---|---|---|---|
| `H_C_InvalidVersion` | 02:54:26 | INVALID | INVALID_CFG_VERSION | false | 39/0 |
| `H_D_InvalidArray` | 02:55:07 | INVALID | INVALID_CFG_LIST_TYPE | false | 39/0 |
| `H_E_DuplicateClass` | 02:55:43 | INVALID | DUPLICATE_CLASSNAME | false | 39/0 |
| `H_F_RequiredMissing` | 02:56:23 | PENDING | POLICY_REQUIRED_MISSING | false | 39/0 |
| **TOTAL** | | | | | **156/0** |

Todas as quatro SUMMARY: `status=APROVADO pass=39 fail=0 total=39 scope=REVISED_CLASSNAME_CONTRACT_SP_SPIKE`.

Os testes específicos de classname corrigidos passaram em **todas** as quatro missões:
- `SCHEMA_VALID_CLASSNAME_DIGIT_START` (`1bad` → VALID);
- `SCHEMA_VALID_VANILLA_MAG_30RND` (`30Rnd_556x45_Stanag` → VALID);
- `SCHEMA_VALID_BGD_WEAPON_121` (`121_SP10M_18_FDE` → VALID);
- `SCHEMA_VALID_BGD_BACKPACK_1ST` (`1st_pack_1` → VALID);
- `SCHEMA_INVALID_PUNCTUATION_PREFIX` (`-BadStart` → INVALID_CLASSNAME);
- regras de versão, arrays, duplicatas, injection, trim, limite de lista, deny-wins, absent/pending/invalid fail-closed continuam PASS.

## Decisão do P0

1. Regra v1 confirmada nos gates G2 e H: **`^[A-Za-z0-9_]{1,128}$`** após trim; lowercase apenas para comparação/deduplicação.
2. Evidência complementar já aprovada: G2 scanner de **133.399 classnames**, **532 elegíveis recuperados**, zero restantes sob regra candidata ([RPT G2](P0_G2_REGEX_COMPARISON_RPT_20261025.md)); Python referência corrigido **8/8 métodos PASS com 32 fixtures** ([regressão Python](P0_G2_PYTHON_REGRESSION_20261025.md)). Smokes positivos A/B **20/20** e negativos originais C–F **140/140** são históricos; H é a regressão de formato **mais recente**.
3. **P0 contrato e viabilidade em SP concluído** nesta fronteira. P1 (core runtime Policy) e P2 (loader), P3/4 (Items), P5 (editor), P6 (server MP), P7 (adapters) permanecem à frente e têm gates próprios. Não afirmar homologação de addon/MP.
4. **Revisão cruzada Weapons:** o motor de compatibilidade é engine-derived (não aplica esta regex); precisa, futuramente, respeitar o contrato Policy na integração e revisar o seletor `magazines` plano versus `magazinesByMuzzle`, como registrado em `docs/modules/Weapons.md`. Não associar automaticamente o problema multi-muzzle à regex Policy.
