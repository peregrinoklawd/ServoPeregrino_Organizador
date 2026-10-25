# Policy P0 — execução da suíte Python unittest (24/10/2026)

**Resultado: PASS — 7 métodos unittest / 7 OK, 0 FAIL, 0 ERROR**, processo exit code `0`.

## Identidade do teste

- Branch: `feature/policy-0.1-p0-contracts`.
- Executor: Python **3.13.5**, ambiente Linux local ao assistente. **Não** foi execução no computador do operador, no Arma 3 ou em servidor MP.
- Arquivo canônico `tools/policy/test_p0_contracts.py`: Git blob SHA **`7d46f8957da4a1599c5ef538b0173c4bba2371c3`**, conferido com `git hash-object` da cópia local.
- Fixtures canônicos `machine/policy/p0_contract_fixtures_v1.json`: Git blob SHA **`e6fcc4ad3d81a82494ebd6042bbe22c90f0a40c9`**, conferido da cópia local após formatação original.
- Os fixtures têm **28 cenários**: 10 de decisão, 12 de payload, 3 de prontidão e 3 de disponibilidade ambiental. A suíte chama esses casos via `subTest`; o relatório de `unittest` exibe **7 métodos** e não 28 testes de método independentes.
- Bibliotecas: **somente biblioteca padrão Python**; sem dependência pip.

## Comando exato

A partir da raiz do checkout/cópia fiel:

~~~bash
python -m unittest discover -s tools/policy -p 'test_*.py' -v
~~~

## Saída observada

~~~text
Python 3.13.5

test_bad_boundaries (test_p0_contracts.PolicyP0Contracts.test_bad_boundaries) ... ok
test_decision_matrix (test_p0_contracts.PolicyP0Contracts.test_decision_matrix) ... ok
test_environment_is_independent (test_p0_contracts.PolicyP0Contracts.test_environment_is_independent) ... ok
test_fail_closed_readiness (test_p0_contracts.PolicyP0Contracts.test_fail_closed_readiness) ... ok
test_json_semantic_roundtrip (test_p0_contracts.PolicyP0Contracts.test_json_semantic_roundtrip) ... ok
test_no_extra_authority_fields (test_p0_contracts.PolicyP0Contracts.test_no_extra_authority_fields) ... ok
test_portable_payload_validation (test_p0_contracts.PolicyP0Contracts.test_portable_payload_validation) ... ok

----------------------------------------------------------------------
Ran 7 tests in 0.001s

OK
~~~

- Log original gerado: `policy_p0_python_unittest_20261024.log` — 1.080 bytes.
- SHA-256 do log original: **`42f2f32c7cfbcfc6f5e4dcfba7b1173be14ea2331f49a0c1e751d4ea2c9db683`**.
- Copiar exatamente os dois arquivos de GitHub para a mesma árvore de diretórios e repetir o comando permite reprodução.

## Conclusões e fronteiras

**Comprovado:** oráculo independente valida fixtures e invariantes de referência; a bateria Python prevista foi realmente executada (não confundir com 28/28 do antigo oráculo JavaScript).

**Não comprovado aqui:** execução de SQF dentro da engine, comportamento real de addon `config.cpp`, política aplicada a inventário, integração com servidor/MP ou cobertura de classnames reais de todos os mods. As missões SP A–F aprovadas anteriormente (**160/160 PASS**) têm relatórios separados em `P0_SP_SMOKE_RPT_20261024.md` e `P0_NEGATIVE_SP_RPT_20261024.md`.

**Gate restante antes de congelar o contrato de P0:** avaliar regex provisória de classname em uma amostra concreta e suficientemente ampla das classes do modset real, além de revisão final documental. Não alterar a baseline homologada de Items/UICommon e não confundir contrato provado com runtime instalado.
