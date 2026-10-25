# P0 G2 — missão pronta de comparação de validadores de classname (25/10/2026)

**Status:** laboratório **PREPARADO**, **NÃO EXECUTADO na engine**, aguardando RPT do operador. Motivação: [RPT G](P0_G_CLASSNAME_AUDIT_RPT_20261025.md) trouxe `REVIEW` com 532 elegíveis fora da regra atual, sobretudo 49 em CfgWeapons, 480 em CfgMagazines e 3 mochilas.

## Artefato

- ZIP: `SP_ORG_Policy_P0_G2_Comparacao_Classnames_20261025.zip`
- SHA-256 do ZIP final: `d4359363eca916f6a40e4a9d58b7e56fd332c841390d36f01529f105ca8b79a8`
- 5 entradas, pacote validado offline: `LEIA-ME.txt` e pasta `SP_ORG_Policy_P0_G2_RegexComparison.VR` contendo `mission.sqm`, `description.ext`, `init.sqf` e `runPolicyP0RegexComparison.sqf`.
- Instalação: copiar a pasta `.VR` para `missions` do perfil Arma, abrir Eden → VR → Preview com a **mesma modlist do primeiro RPT G**. O `init.sqf` executa script via `execVM` automaticamente; console/debug e addon Policy não necessários.
- Prefixo RPT: **`[SPORG_POLICY_P0_G2]`**. Teste *read-only* sem modificar inventário, cache, kits ou perfis.

## Comparação

- STRICT (antigo): `^[A-Za-z_][A-Za-z0-9_]{0,127}$`
- RELAXED (novo **candidato**): `^[A-Za-z0-9_]{1,128}$`
- Ambos continuam rejeitando strings vazias, caracteres de espaço, ponto, hífen, ponto-e-vírgula, controles e identificadores de 129+ caracteres; RELAXED permite apenas **dígitos iniciais** como extensão.
- 12 SELFTESTs comparativos esperados (fixture de classname com primeiro dígito falha no STRICT e passa no RELAXED). **Ainda não há PASS de engine**.
- O scanner percorre as mesmas 4 roots `CfgWeapons`, `CfgMagazines`, `CfgGlasses`, `CfgVehicles` (mochilas) e contabiliza por root **classes raw / eligible / itemsPrefilter** nos grupos `strictInvalid`, `fixedByDigit`, `remainInvalid`.
- `REMAINING_REASONS` registra as contagens de `BAD_START`, `BAD_CHAR`, `TOO_LONG` e `OTHER` por root, sem truncar contagem; `REMAINING_ANOMALY` e `DIGIT_RECOVERED_SAMPLE` mostram exemplos limitados e `configSourceModList`.
- `PASS` demanda 0 remanescentes em elegíveis e pré-filtro, SELFTEST 12/12 e roots presentes; `REVIEW` significa exceções remanescentes; `FAIL` refere-se a autotestes, raiz ausente ou scan não executado.

## QA realizado nesta entrega

- ZIP criado e aberto com êxito, `ZipFile.testzip()==None`, 5 entradas sem `../`.
- Mission `mission.sqm` derivada da missão P0 G que concluiu `REVIEW` sem erros de expressão; `B_Soldier_F` vanilla, terreno VR.
- Script SQF tem delimitadores de `() [] {}` balanceados segundo verificador offline que ignora comentários e strings, referências aos dois validadores e segmentos de relatório conferidos.
- Validação equivalente em Python dos 12 autotestes comparativos: **12/12 PASS**. Isso **não** é uma execução SQF na engine.
- No Arma e no modset real o resultado **ainda não é conhecido**. Se diferenças de contagem raw/eligible em relação a G surgirem, registrar possível variação de modlist/config e não comparar conclusões cegamente.

## Critério de saída

Após RPT G2, avaliar se aceitar dígitos iniciais cobre as 532 anomalias de elegíveis, inclusive CfgMagazines. Se não, investigar motivos por root. Se sim, revisar o **contrato PolicyExport v1**, `tools/policy/test_p0_contracts.py`, fixtures relevantes (ex.: `1StartsWithDigit`) e negativas SQF; executar novamente QA após alterar a regra. **Não** declarar P0 homologado antes dessas revisões. P1/P2 runtime e P6 MP são fases posteriores. Sem modificações em Items, UICommon, Weapons e branch main.
