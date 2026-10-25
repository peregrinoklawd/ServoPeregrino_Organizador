# Policy P0 H — regressão SQF automatizada após G2 (25/10/2026)

**Status:** artefato **PREPARADO**, **NÃO EXECUTADO NA ENGINE**, RPT SP pendente. Preserva evidência histórica dos testes antigos C–F 35/35 cada, que foram corretos para o contrato anterior, mas não provam a correção de formato.

## Pacote ZIP

- `SP_ORG_Policy_P0_H_Regressao_Contrato_G2_20261025.zip`.
- SHA-256: `e7549e7ef6fbe60ada06669efa6af982a7c84b49a691a96aaef2047b2ffab7ec`.
- Tamanho **25.947 bytes**; **17 arquivos**: `LEIA-ME.txt` e quatro pastas `.VR` com `mission.sqm`, `description.ext`, `init.sqf`, `runPolicyP0Negative.sqf`.
- Missões:
  - `SP_ORG_Policy_P0_H_C_InvalidVersion.VR` (INVALID_CFG_VERSION)
  - `SP_ORG_Policy_P0_H_D_InvalidArray.VR` (INVALID_CFG_LIST_TYPE)
  - `SP_ORG_Policy_P0_H_E_DuplicateClass.VR` (DUPLICATE_CLASSNAME)
  - `SP_ORG_Policy_P0_H_F_RequiredMissing.VR` (POLICY_REQUIRED_MISSING)
- Instalar no perfil Arma 3 na pasta `missions`. Iniciar com Eden → VR → abrir missão H → Preview; executar cada missão uma vez com retorno ao Eden. **Nenhuma edição/console manual necessária.**
- Prefixo do novo RPT: `[SPORG_POLICY_P0_H]`.

## Alteração mínima ao protótipo já executado

1. Removido apenas o bloqueio de dígito na posição inicial dentro do verificador de string (`toArray`, 1–128 bytes/caracteres ASCII, letras/dígitos/underscore apenas). Todo o restante da checagem de chaves, schemaVersion, arrays, tipos, 4096 entradas, 512KiB, duplicação case-insensitive, `deny-wins` e prontidão **preservado**.
2. Antigo cenário `INVALID_CLASSNAME_DIGIT_START` atualizado para `VALID_CLASSNAME_DIGIT_START`, mantendo mesmo payload `1bad`.
3. Acrescentadas **4 asserções** por missão: permitir `30Rnd_556x45_Stanag`, permitir `121_SP10M_18_FDE`, permitir `1st_pack_1`, rejeitar `-BadStart`.
4. Prefixo do relatório alterado de `SPORG_POLICY_P0_NEG` para `SPORG_POLICY_P0_H` para não misturar evidências.
5. Configs C–F preservados, testes de fail-closed reais dentro de cada `description.ext` preservados.

Cada missão H espera **39/39 PASS, 0 FAIL**: 24 validações de schema (20 antigas, das quais 1 mudou expectativa, e 4 adicionais), 4 decisão, 8 readiness, 3 config. Total das quatro missões: **156 PASS esperados**, não executados.

## QA offline feito

- ZIP aberto e testado com `ZipFile.testzip()==None`, todas as **17 entradas** identificadas; cada missão tem os 4 arquivos necessários.
- Verificadas presença de nova regra, quatro novas asserções, alteração de nome de cenário, reutilização dos arquivos de missão já testados pelo usuário, e `execVM` automático.
- O QA estrutural **não é** prova de sintaxe nem execução SQF dentro da engine: somente RPT da missão H pode autorizar PASS de engine.

## Limites

SP VR independente de Nexus/Items/Weapons/Policy real. Não mexe em arquivos de runtime do repo, cache, inventário, persistência, multiplayer, servidor ou políticas efetivas. Referências: [RPT G2](P0_G2_REGEX_COMPARISON_RPT_20261025.md), [unittest atualizado](P0_G2_PYTHON_REGRESSION_20261025.md). Enquanto H não executar, o gate de P0 revisado permanece **PENDENTE**.
