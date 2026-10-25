# P0 — Auditoria RPT dos smoke tests negativos C–F

**Data de execução:** 24/10/2026 às 22h19–22h21 (horário local da máquina); **RPT recebido em 25/10 no nome do arquivo**.  
**Resultado:** **140/140 PASS, 0 FAIL**, em **4 missões VR single-player** na versão estável **Arma 3 2.22.154089**.  
**Escopo:** `NEGATIVE_SP_SPIKE`, validador SQF **isolado** e não loader/autoridade de addon real. O resultado não demonstra PBO instalado, persistência, servidor MP, administração ou aplicação física Items/Weapons.

## Proveniência

- Arquivo recebido do usuário: `Texto colado(20261025-013526).txt`, RPT Arma 3, 8.940 linhas e 1.126.175 bytes.
- SHA-256 do arquivo integral: `df3fed6cdd85287a346a940d10d286fcaa9f304ef3b555c2b2e25e75e6137583`.
- Foram encontrados **152 registros** com prefixo `[SPORG_POLICY_P0_NEG]`; 4 `START`, 140 `[TEST] PASS`, 4 `CONFIG`, 4 `SUMMARY`, e **0 `[TEST] FAIL`**.
- No RPT integral: **0** `Error in expression`; **0** `Error position:`. Não presumir que os demais avisos de configuração de mods terceiros sejam erros Policy.
- Pacote usado: `SP_ORG_Policy_P0_Testes_Negativos_20261024.zip`; preparação documentada em [P0_NEGATIVE_MISSIONS_PREP_20261024.md](P0_NEGATIVE_MISSIONS_PREP_20261024.md). A versão do ZIP não foi alterada após o teste pelo assistente.

## Quatro provas executadas

| Cenário | Hora local (24/10) | Evidência `[CONFIG]` | `[SUMMARY]` |
|---|---|---|---|
| C — versão inválida | 22:19:56 | `state=INVALID code=INVALID_CFG_VERSION required=true effectiveAllow=false` | `APROVADO pass=35 fail=0 total=35` |
| D — whitelist com tipo string | 22:20:35 | `state=INVALID code=INVALID_CFG_LIST_TYPE required=true effectiveAllow=false` | `APROVADO pass=35 fail=0 total=35` |
| E — duplicação case-insensitive | 22:21:08 | `state=INVALID code=DUPLICATE_CLASSNAME required=true effectiveAllow=false` | `APROVADO pass=35 fail=0 total=35` |
| F — política obrigatória ausente | 22:21:43 | `state=PENDING code=POLICY_REQUIRED_MISSING required=true effectiveAllow=false` | `APROVADO pass=35 fail=0 total=35` |

### Detalhes representativos da matriz 35/35

O teste de payload rejeitou `SCHEMA_INVALID_ROOT_ARRAY`, `INVALID_VERSION_TYPE`, `INVALID_WHITE_LIST_TYPE`, `INVALID_BLACK_LIST_TYPE`, `INVALID_ITEM_TYPE`, `SCHEMA_INVALID_CLASSNAME_SPACE`, `INJECTION`, `DIGIT_START`, `TOO_LONG`, `INVALID_DUPLICATE_CASE`, `INVALID_MISSING_FIELD`, `INVALID_EXTRA_ADMIN_FIELD`, `INVALID_EXTRA_REVISION_FIELD` e `INVALID_LIST_SIZE`. Os casos válidos `SCHEMA_VALID_EMPTY`, `WHITELIST`, `DENY_WINS_CONFLICT` e `VALID_TRIM` foram aceitos pelo mesmo validador. O teste de decisão confirmou `DENY_WINS`, `CLASS_ABSENT_IN_WHITELIST`, `DENIED_INVALID_SNAPSHOT`. A matriz de prontidão confirmou `REQUIRED_ABSENT_FAIL_CLOSED`, `REQUIRED_PENDING_FAIL_CLOSED`, `REQUIRED_INVALID_FAIL_CLOSED`, `OPTIONAL_ABSENT_OPEN`, `ACTIVE_INVALID_FAIL_CLOSED`, `ACTIVE_DENIED_FAIL_CLOSED` e `ENVIRONMENT_MISSING`, além de casos permitidos quando aplicável.

**Significado de PASS:** em teste negativo, PASS significa que a entrada inválida **foi rejeitada**, e não que a política inválida foi ativada. `effectiveAllow=false` no cenário obrigatório é a evidência central de fail-closed.

## Triagem de logs exteriores

O RPT possui múltiplos `Warning Message` de `CfgWeapons/ItemInfo` e avisos de stringtables/configs em mods do ambiente (entre outros), originados fora dos prefixos de teste. Há 220 linhas `Warning Message:` no RPT e muitos erros de configuração de terceiros na carga inicial. **Não há base para imputá-los ao Policy**, e não justificam mexer no módulo Items.

## Estado após o RPT

- Smoke SP positivo A/B anterior: **20/20 PASS**. Evidência: [P0_SP_SMOKE_RPT_20261024.md](P0_SP_SMOKE_RPT_20261024.md).
- Smoke SP negativo C/D/E/F deste RPT: **140/140 PASS**.
- **Acumulado: 160/160 PASS em spikes SP**. Quatro missões repetiram parte da matriz comum: são 160 asserções executadas, não 160 classes distintas.
- **P0:** gates de engine SP **aprovados**. Ainda é necessário revisão final de contrato, execução ou ressalva da suíte Python de referência e amostragem real de classnames de modsets antes de declarar P0 integralmente encerrado. Parser de JSON sintaticamente malformado e duplicação de *chaves JSON* não entraram nesta rodada; tratar como limitações/gates de implementação.
- **P1/P2:** desenvolvimento futuro do motor e loader; os smoke tests não são seu substituto.
- **P6:** segurança servidor/MP, JIP e privilégios de admin permanecem não testados, de forma explícita.
- Preservar baseline `baseline/items-uicommon-r2-2-sp-homologated-20261021`; sem mexer em `addons/`, `missions/`, Weapons, Items, UICommon ou `main`.
