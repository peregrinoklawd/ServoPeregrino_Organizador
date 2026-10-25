# Policy P0 G — missão de auditoria de classnames reais (25/10/2026)

**Status:** missão automática **PREPARADA**, QA de pacote aprovado, **RPT real pendente**. Não confundir entrega do ZIP com execução na engine. Fase P0 em revisão de regex.

## Objetivo

Validar a hipótese de que nomes de classe reais encontrados na modlist do usuário respeitam o formato ASCII de Policy export v1:

`^[A-Za-z_][A-Za-z0-9_]{0,127}$`

O formato foi proposto, não homologado. O operador precisa rodar a missão no Arma 3 com sua modlist normal (ACE/RHS/BGD e demais mods carregados), sem desabilitá-los para o teste.

## Pacote pronto para o operador

- Download (anexo da conversa): `SP_ORG_Policy_P0_G_Auditoria_Classnames_20261025.zip`
- SHA-256 exato: `ffc30f29a957eadf2586c5270e3719095f57583456e24db4d077bf28c2c92c79`
- 5 entradas no ZIP: `LEIA-ME.txt`; `SP_ORG_Policy_P0_G_ClassnameAudit.VR/mission.sqm`, `description.ext`, `init.sqf` e `runPolicyP0ClassnameAudit.sqf`.
- Instalar só a pasta `.VR` em `Documents/Arma 3 - Other Profiles/<perfil>/missions` ou pasta equivalente. Eden Editor → VR → abrir missão → Preview. A execução é automática, sem console.
- Independente de Policy, Nexus, Items e BGD; precisa **apenas** do Arma 3. Entretanto, com menos mods os resultados não representam a modlist normal.
- Prefixo RPT: **`[SPORG_POLICY_P0_G]`**. Enviar o RPT completo ao assistente.

## Metodologia SQF (somente leitura)

O laboratório percorre classes **diretas** do `configFile` atual nos roots `CfgWeapons`, `CfgMagazines`, `CfgGlasses` e `CfgVehicles`, via `count`/`select`/`isClass`/`configName`, tal como o `fn_buildCatalog.sqf` homologado do Items. Inclui leitura de `scope`, `scopeArsenal`, `displayName` e presença de `ItemInfo`.

- **raw:** todas as classes diretas em cada raiz, inclusive classes internas e abstratas.
- **eligible:** classes com `displayName` e `scope>=2 || scopeArsenal>=2`; no `CfgVehicles`, só `isBackpack=1`. Este conjunto é amplo, não pretende validar elegibilidade final do catálogo Items.
- **itemsPrefilter:** classes de `CfgWeapons` elegíveis com `ItemInfo`, e `CfgMagazines` elegíveis; este pre-filtro replica o **gate inicial** de `fn_buildCatalog.sqf`, mas não chama `fn_createCatalogItemFromConfig`, e portanto **não é o catálogo final**.
- Verifica cada nome usando `toArray`: primeira posição ASCII A-Z, a-z ou underscore; demais A-Z, a-z, 0-9 ou underscore; tamanho de 1 a 128. Regras independentes do ambiente, com **10 autotestes** antes do scan.
- Limita logs detalhados a 20 anomalias de classes brutas e 40 de elegíveis, com `configSourceModList` para anomalias. Registra até 3 amostras por prefixo `ace_`, `rhs_`, `bgd_` se existirem, além da contagem. **Prefixo não prova addon de origem**, que só a lista de origem confirma.
- Progresso a cada 8.000 classes, e `uiSleep` apenas em script `execVM` agendado, para evitar monopolizar a fila.
- `[ROOT_SUMMARY]`, `[FAMILY_SUMMARY]`, `[BOUNDARY]` e `[SUMMARY]` sintetizam os resultados sem imprimir o catálogo inteiro.
- Resultado final `PASS`: 10 autotestes sem falha, roots presentes, candidatos não vazios, **0 nomes inválidos elegíveis**. `REVIEW`: aparecem classes elegíveis fora da regex; **não mudar regex automaticamente** sem inspecionar. `FAIL`: erro de autoteste/raiz/ausência de candidatos. A classificação não certifica o Policy real.

**Nunca** altera caches, itens, mods, equipamentos físicos, kits, baseline, persistência ou `CfgRemoteExec`.

## QA offline realmente executado nesta entrega

- ZIP pode ser reaberto, `testzip() == None`, 5 entradas, nomes sem path traversal.
- Os quatro arquivos de missão presentes; missão `B_Soldier_F` baseada na missão P0 C previamente executada com sucesso.
- Equilíbrio de `()`, `[]`, `{}` inspecionado por parser estático que ignora comentários SQF e strings; nenhum desequilíbrio.
- Ferramentas de engine usadas confirmadas nas referências da Bohemia: `toArray`, `configName`, `configSourceModList`, `toLowerANSI`, `execVM`. O QA estrutural **não substitui** o parser e a execução Arma.

## Interpretação e continuação

1. Executar P0 G com modlist normal e enviar RPT.
2. Conferir `[SUMMARY]` e quatro `[ROOT_SUMMARY]`; procurar `Error in expression` referente à pasta da missão, `[SELFTEST] FAIL` e casos `[ELIGIBLE_ANOMALY]`.
3. Investigar se eventual anomalia é classe de inventário real ou classe de configuração que entrou no pre-filtro; usar `itemsPrefilterInvalid` para avaliar risco direto ao Items, e amostragem por família para corroborar cobertura.
4. Se necessário, ajustar **contrato proposto e respectivos fixtures** somente após revisão com dados reais. Quando P0 estiver fechado, P1 implementará o **motor** independente; não inferir que Policy já está ativo.
5. Teste MP, autoridade, loader/config e integração de UI continuam etapas futuras P1–P6.

## Referências

- Código canônico de pre-filtro: `addons/ServoPeregrino_Organizador_Items/functions/catalog/fn_buildCatalog.sqf` na baseline homologada.
- P0: [P0_CONTRACTS_20261024.md](../P0_CONTRACTS_20261024.md).
- Evidência positiva SP: [P0_SP_SMOKE_RPT_20261024.md](P0_SP_SMOKE_RPT_20261024.md).
- Evidência negativa SP: [P0_NEGATIVE_SP_RPT_20261024.md](P0_NEGATIVE_SP_RPT_20261024.md).
- Python unittest: [P0_PYTHON_UNITTEST_20261024.md](P0_PYTHON_UNITTEST_20261024.md).
- Bohemia scripting: https://community.bistudio.com/wiki/toArray ; https://community.bistudio.com/wiki/configName ; https://community.bistudio.com/wiki/configSourceModList .
