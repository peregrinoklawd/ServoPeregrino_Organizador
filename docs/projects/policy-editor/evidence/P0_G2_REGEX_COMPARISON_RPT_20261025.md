# P0 G2 — RPT diferencial de classnames reais (25/10/2026)

**Resultado:** `PASS` da missão de auditoria diferencial **G2**; **12/12 SELFTEST PASS**, **0 restantes inválidos sob a regra candidata**, **0 erros de root**; sem erros SQF de expressão localizados no RPT. **Escopo:** scanner de classe real SP VR, não runtime Policy addon nem homologação MP.

## Proveniência e reprodução

- RPT recebido do operador: `Texto colado(20261025-050918).txt`, total ~1.1 MB.
- SHA-256 do RPT integral: `d3eabefdc7c96e6aabc715d4626f8f32b6f559b520c33ed50fcffb6a9e3497d1`.
- Arma 3 **Stable 2.22.154089**, sessão 25/10/2026, prefixo RPT `[SPORG_POLICY_P0_G2]`.
- Missão `SP_ORG_Policy_P0_G2_RegexComparison.VR` (pacote preparado em [P0_G2_REGEX_COMPARISON_PREP_20261025.md](P0_G2_REGEX_COMPARISON_PREP_20261025.md)).
- Execução de scanner aprox. **02:07:26–02:08:27** no RPT, `elapsedMs=60481`. 1 START / 4 ROOT_SUMMARY / 4 REMAINING_REASONS / 12 SELFTEST PASS / 0 SELFTEST FAIL / 1 SUMMARY. Nenhum `Error in expression` ou `Error position` encontrado. O jogo registrou mensagens sobre **stringtables de terceiros ausentes** em CfgVehicles; não afetam a contagem de classes e não são erro SQF atribuído ao scanner.
- Não armazenar o RPT bruto no GitHub: carrega caminhos pessoais do operador e a modlist inteira.

## Resultado por raiz — valor medido

| Root | Raw | Raw incompatíveis com strict | Raw recuperados | Raw restantes com relaxed | Elegíveis | Elegíveis strict inválidos | Elegíveis recuperados | Elegíveis restantes | Pré-filtro Items | Pré-filtro recuperados | Pré-filtro restantes |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| CfgWeapons | 69.763 | 62 | 62 | 0 | 49.502 | 49 | 49 | 0 | 47.760 | 49 | 0 |
| CfgMagazines | 3.697 | 536 | 536 | 0 | 2.967 | 480 | 480 | 0 | 2.967 | 480 | 0 |
| CfgGlasses | 1.000 | 0 | 0 | 0 | 904 | 0 | 0 | 0 | 0 | 0 | 0 |
| CfgVehicles (mochilas) | 58.939 | 70 | 70 | 0 | 630 | 3 | 3 | 0 | 0 | 0 | 0 |
| **TOTAL** | **133.399** | **668** | **668** | **0** | **54.003** | **532** | **532** | **0** | **50.727** | **529** | **0** |

`[SUMMARY]` copiado: `status=PASS selftestPass=12 selftestFail=0 rootsErrors=0 raw=133399 strictInvalid=668 fixedByDigit=668 remainingInvalid=0 eligible=54003 eligibleStrictInvalid=532 eligibleFixedByDigit=532 eligibleRemainingInvalid=0 itemsPrefilter=50727 itemsStrictInvalid=529 itemsFixedByDigit=529 itemsRemainingInvalid=0 elapsedMs=60481 scope=SP_CONFIG_DIFFERENTIAL_ONLY`.

**Motivos restantes:** cada root retornou `[REMAINING_REASONS] BAD_START=0 BAD_CHAR=0 TOO_LONG=0 OTHER=0` sob a candidata relaxed. As contagens brutas/elegíveis/pré-filtro conferem com P0 G, indicando mesmo conjunto de classes examinadas.

## Exemplos reais recuperados e implicações

- CfgWeapons `121_SP10M_18_FDE`, `121_SP10M_ATC_Steel` — `configSourceModList` inclui `@BGD - Tools of the Trade`.
- CfgMagazines `30Rnd_556x45_Stanag`, `30Rnd_45ACP_Mag_SMG_01` — nomes com dígito inicial são comuns também no ecossistema base/DLC/ACE, não só BGD.
- CfgVehicles mochilas `1st_pack_1`, `1st_pack_2`, `1st_pack_3` — `configSourceModList` inclui `@BGD - High Tier Equipment`.

**Conclusão bem delimitada:** no modset analisado, trocar a validação sintática de `^[A-Za-z_][A-Za-z0-9_]{0,127}$` para **`^[A-Za-z0-9_]{1,128}$`** resolve **100% das 668/532/529 rejeições sintáticas**, sem relaxar critérios sobre espaço, pontuação ou limite de comprimento. **Não é uma prova universal para todo mod existente**, nem prova de elegibilidade final do catálogo Items, nem teste contra payloads JSON malformados de terceiros ou privilégio MP.

## Decisão e consequências de QA

- **Aceitar a regra sintática candidata para revisão dos contratos P0 v1:** ASCII letras, dígitos ou underscore; 1–128 caracteres; dígito inicial permitido.
- Regra é de **formato**, não de existência. Disponibilidade de classe continua decisão separada do consumidor (isClass/configFile).
- **Atenção:** `tools/policy/test_p0_contracts.py` antes rejeitava `1StartsWithDigit`; o spike SQF negativo C–F também rejeitava `1bad`. Esses casos foram **corretos para o protótipo anterior**; não usar 160/160 SP e 7/7 Python antigos como aprovação retroativa de contrato atualizado.
- Atualizar Python e fixtures, criar asserções positivas para números no início e reexecutar teste de regressão. Corrigir e executar smoke SQF afetado na engine ou registrar explicitamente a exceção antes de declarar P0 plenamente homologado.
- A proposta de nomear P0 como “concluído” depende de QA dos contratos *corrigidos* e revisão documental final. Runtime Policy addon, servidor/admin MP, integração Items/Weapons continuam não implementados e são fases posteriores.
