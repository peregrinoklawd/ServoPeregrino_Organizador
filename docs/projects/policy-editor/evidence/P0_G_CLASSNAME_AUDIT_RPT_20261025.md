# P0 G — Auditoria de classnames reais, RPT de 25/10/2026

**Resultado da missão:** `REVIEW`, **10/10 SELFTEST PASS**, 0 FAIL de autoteste. O scan real foi **concluído**, mas a regex provisória de Policy **não passou no gate de compatibilidade**. **NÃO fechar P0** até determinar por que existem classes elegíveis rejeitadas.

## Proveniência

- RPT entregue pelo operador: `Texto colado(20261025-035910).txt` (conteúdo completo analisado, não apenas preview), **1.067.730 bytes**; 8.265 linhas segundo `wc -l`; SHA-256 `1786ec1c31921e67991df46212b2d561d41ba1d8a1d5fb6732546f69d61e4cb1`.
- Execução: Arma 3 Stable **2.22.154089**, 25/10/2026, **00:57:37–00:58:12** hora do RPT, single-player no VR, modset real com ACE/RHS/BGD e outros addons. RPT inclui caminhos locais e lista de mods; **não publicar o arquivo bruto**.
- Prefixo: `[SPORG_POLICY_P0_G]`; **1 SUMMARY, 4 ROOT_SUMMARY, 10 SELFTEST PASS, 0 SELFTEST FAIL**, `Error in expression` **0**, `Error position` **0** no arquivo.
- `[SUMMARY]`: `status=REVIEW selftestPass=10 selftestFail=0 raw=133399 rawInvalid=668 eligible=54003 eligibleInvalid=532 itemsPrefilter=50727 itemsPrefilterInvalid=529 elapsedMs=34930 scope=SP_CONFIG_CLASSNAME_AUDIT_ONLY`.

## Contagem por fonte do configFile

| Root | Classes brutas | Brutas fora da regex | Elegíveis amplas | Elegíveis fora da regex | Pré-filtro Items | Pré-filtro fora da regex |
|---|---:|---:|---:|---:|---:|---:|
| CfgWeapons | 69.763 | 62 | 49.502 | 49 | 47.760 | 49 |
| CfgMagazines | 3.697 | 536 | 2.967 | 480 | 2.967 | 480 |
| CfgGlasses | 1.000 | 0 | 904 | 0 | 0 | 0 |
| CfgVehicles, filtro mochilas | 58.939 | 70 | 630 | 3 | 0 | 0 |
| **TOTAL** | **133.399** | **668** | **54.003** | **532** | **50.727** | **529** |

Os campos `eligible` e `itemsPrefilter` **NÃO representam o catálogo final Items**: este ainda avalia `fn_createCatalogItemFromConfig` e `eligible` específico. O G percorreu todas as classes diretas em cada root; o pré-filtro de `CfgWeapons` exige `ItemInfo`; o de `CfgMagazines` usa `displayName + scope`. Amostra suficiente para provar o conflito do contrato, não para afirmar que todas 529 classes estarão visíveis na UI.

### Evidência positiva de incompatibilidade

A regex provisória, `^[A-Za-z_][A-Za-z0-9_]{0,127}$`, rejeita **qualquer identificador iniciado por dígitos**. A engine efetivamente carregou, e a missão classificou como elegíveis, por exemplo:
- `CfgWeapons/121_SP10M_18_FDE`
- `CfgWeapons/121_USASOC_CNVD_ITEM`
- `CfgWeapons/121_USASOC_STORM_SLX_Laser`
- `CfgWeapons/121_USASOC_PVPS_ANPVS30_PAINT`

Para esses exemplos, o motivo foi **`BAD_START`** e `configSourceModList` retornou **`@BGD - Tools of the Trade`**. Isso é incompatibilidade real do **contrato proposto**, não erro do jogo nem prova de falha do Items.

Limitação do primeiro scanner: após **20 logs RAW_ANOMALY e 40 logs ELIGIBLE_ANOMALY**, o detalhe individual é truncado. As primeiras amostras são de `CfgWeapons`, então **não há evidência suficiente para declarar que as demais 532 ocorrências são exclusivamente dígitos iniciais**. `CfgMagazines` sozinho tem **480 elegíveis rejeitados**, cujo motivo não aparece individualizado neste RPT. Requer scanner diferencial.

### Informações complementares

- Maior classname observado: **78 caracteres** (`CfgWeapons/TACDEV_Headgear_Maritime_VliteOff_Off_Cover_AOR1_HelstarT_ChargePro_PatchUSIrR`). O limite provisório de **128** não foi atingido por qualquer classe percorrida nesta execução.
- Cobertura por prefixo entre elegíveis: `ace_` **509**, `rhs_` **2.036**, `bgd_` **0**. **Zero prefixos bgd_ NÃO significa ausência do BGD**; o mod aparece confirmado em `configSourceModList` das anomalias.
- Há numerosos avisos de stringtable e configs de outros mods na carga inicial. Nenhum erro de script específico P0 G encontrado. Não confundir avisos externos com falha do scanner.

## Decisão técnica e gate seguinte

1. **NÃO congelar a regex atual nem encerrar P0**. O P0 A–F (160/160 engine) e Python (7/7 métodos) permanecem aprovados para os **contratos que efetivamente testaram**, mas o critério de classname estrito provou-se inadequado no modset real.
2. **Candidata G2 ainda não aprovada:** `^[A-Za-z0-9_]{1,128}$` (permite número inicial, ainda veta espaços, separadores e caracteres de controle; length max 128). Alterar somente depois do resultado da auditoria diferencial G2.
3. Rodar o laboratório **P0 G2** na mesma modlist, medir por root: `strictInvalid`, `fixedByDigit`, `remainInvalid`, por `eligible` e `itemsPrefilter`, motivos e amostras por root. Ver [preparação G2](P0_G2_REGEX_COMPARISON_PREP_20261025.md).
4. Se G2 justificar alterar o contrato, atualizar **Python validator + fixtures + SQF negative suite** (o fixture `1StartsWithDigit` antes era inválido e precisa mudar) e reexecutar QA relevante; evitar declarar QA antigo como prova do novo contrato.
5. **Policy runtime não foi implementado**. MP, loader do addon e integração Items/Weapons continuam fases futuras. Branch `feature/policy-0.1-p0-contracts`, sem merge, baseline homologada preservada.
