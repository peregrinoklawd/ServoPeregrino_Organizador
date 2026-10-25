# P0 G2 — regressão Python após correção da regex (25/10/2026)

**Status: APROVADO na execução Python**, 8/8 métodos `unittest` OK, 0 falhas, 0 erros, com 32 cenários de fixtures. **Não é teste de addon/SQF na engine**.

## Mudança de contrato

A auditoria real [G2](P0_G2_REGEX_COMPARISON_RPT_20261025.md) demonstrou que a regra anterior rejeitava 532 classes elegíveis por começarem com dígito. A validação `CLASSNAME` foi corrigida de `[A-Za-z_][A-Za-z0-9_]{0,127}\Z` para **`[A-Za-z0-9_]{1,128}\Z`**. O teste de boundary que rejeitava `1StartsWithDigit` foi substituído por rejeição a `-StartsWithPunctuation`.

Também entrou `test_numeric_prefix_real_classnames`, cobrindo `30Rnd_556x45_Stanag`, `121_SP10M_18_FDE`, `1st_pack_1`, `1StartsWithDigit` e bloqueio de payload com `;call compile`. Fixtures receberam quatro cenários:
- `P0-VALID-DIGIT-VANILLA-MAG` → true.
- `P0-VALID-DIGIT-BGD-WEAPON` → true.
- `P0-VALID-DIGIT-BGD-BACKPACK` → true.
- `P0-INVALID-PUNCTUATION-PREFIX` → false.

## Proveniência verificável

- Arquivo testado `tools/policy/test_p0_contracts.py`; blob Git da branch **`8080d70c1a5bed07fa4cce1ca988f20c31bcb3bc`**.
- Fixtures testados `machine/policy/p0_contract_fixtures_v1.json`; blob Git **`1a75b9541999c62b818c024026872cf185eec62b`**.
- A cópia local desses arquivos foi conferida com `git hash-object`, ambos retornando **exatamente** os blobs Git apontados.
- Comando realmente executado em cópia fiel da raiz do repositório:

~~~bash
python -m unittest discover -s tools/policy -p 'test_*.py' -v
~~~

- Resultado observado:

~~~text
test_bad_boundaries ... ok
test_decision_matrix ... ok
test_environment_is_independent ... ok
test_fail_closed_readiness ... ok
test_json_semantic_roundtrip ... ok
test_no_extra_authority_fields ... ok
test_numeric_prefix_real_classnames ... ok
test_portable_payload_validation ... ok
----------------------------------------------------------------------
Ran 8 tests in 0.001s
OK
~~~

- Log da execução `policy_p0_g2_python_unittest_20261025.log`, SHA-256 **`c31c5dcba515db32cb9d8767cee1d33468d9700448665daf1e68a5695262adbd`**.
- 32 cenários: 10 decisão, 16 validação payload, 3 prontidão, 3 ambiente. O `unittest` contabiliza 8 métodos; cenários de fixture são `subTest`, não 32 métodos.
- A execução não foi no computador do operador, nem no Arma 3.

## Pendências

O protótipo SQF negativo C–F antigo tratava dígitos iniciais como inválidos e permanece uma **prova histórica do contrato anterior**. A atualização do SQF foi empacotada como **P0 H**, pronto para RPT, não homologado até execução. [Preparação H](P0_H_REVISED_CLASSNAME_SQF_PREP_20261025.md). Após H PASS, revisar consistência documental e então decidir fechamento formal do P0. Loader Policy, Items e MP continuam implementações futuras.
