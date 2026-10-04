# Weapons 0.6-F R3 — Search Isolation / Name Editing

Data: 2026-10-04.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Display:
`0.6-F R3`

Semantic:
`0.6.5.3`

Build:
`0.6.5.3-search-isolation-global-catalog-query-name-edit-hotfix-uicommon-mission-first`

## Origem

Após validação manual da 0.6-F R2 foram identificados três bugs/requisitos:

1. apagar completamente o nome em ARMAS DO KIT fazia o nome salvo reaparecer imediatamente;
2. P2/P3/P4 compartilhavam a mesma `catalogQuery`;
3. busca textual no Catálogo continuava combinada com Tipo/Acessório.

## Correções

### Nome inline

Novo estado:
- `draftNameInput`;
- `draftNameEditing`.

Regra:
- campo pode ficar temporariamente vazio enquanto o usuário digita;
- refresh focal não repinta o nome salvo só porque o campo ficou vazio;
- SALVAR valida o valor final;
- nome realmente vazio é rejeitado explicitamente;
- edição do nome mantém o estado global ALTERADO até salvar/descartar.

### Buscas independentes

Estados:
- P2: `draftQuery`;
- P3: `catalogQuery`;
- P4: `equipmentQuery`.

P2 e P4 nunca escrevem em `catalogQuery`.

Semântica:
- ARMAS DO KIT filtra apenas as linhas/valores atuais de P2;
- CATÁLOGO DE ARMAS filtra somente o catálogo;
- CONTEÚDO DO EQUIPAMENTO filtra apenas as linhas/valores atuais de P4.

### Busca global do Catálogo

Quando `catalogQuery != ""`:
- filtros armazenados de Tipo e Acessório permanecem preservados;
- filtros efetivos tornam-se `ALL / ALL`;
- botões de filtro deixam de aparecer ativos enquanto a busca está em uso;
- contador indica `busca global`.

Quando a barra é limpa:
- os filtros armazenados voltam a valer automaticamente.

A compatibilidade do catálogo continua usando a projeção do Draft atual; esta mudança não libera aplicação incompatível.

## Preservação

- Items: byte-idêntico à F R2;
- UICommon: byte-idêntico;
- Nexus: byte-idêntico;
- changed-row highlight R2 preservado;
- P2/P4 preview-ready preservado;
- focused refresh preservado;
- aplicação física continua 0.7;
- MP/JIP continua 0.8.

## Testes

Static:
- **36/36 PASS**.

Runner:
`fn_runDelivery0_6_FR3Tests.sqf`

Assertion sites:
- **555**.

Novas regressões:
- P2 search é local;
- P4 search é local;
- Catalog search não sobrescreve P2/P4;
- Catalog query ativa ignora filtros armazenados;
- limpar query restaura filtros;
- nome inline pode permanecer vazio durante edição;
- estado de edição vazio permanece explícito;
- runtime markers de Search/Name R3.

## Gate manual

1. apagar todo o nome e digitar outro sem o anterior reaparecer;
2. tentar SALVAR vazio -> erro explícito;
3. pesquisar em P2 -> P3/P4 não mudam;
4. pesquisar em P4 -> P2/P3 não mudam;
5. selecionar filtros no Catálogo, digitar busca -> filtros ignorados;
6. limpar busca -> filtros anteriores voltam;
7. validar P2/P4 local filtering;
8. AUTO 0.6-F R3 com 0 FAIL;
9. wheel/slider continuam sem full refresh;
10. enviar RPT + prints.

## Artefato

`SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R3_UICommon.zip`

SHA-256:
`7cde5a3f896d6f819edc4a248f6e6a9857c4935da2f9e24232b4c0c9fe713eb8`
