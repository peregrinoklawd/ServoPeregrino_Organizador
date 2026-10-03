# Weapons 0.6-E R2 Hotfix 1 — Runtime Fix Candidate

Data: 2026-10-03.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Build:
`0.6.4.2-ux-convergence-direct-draft-equip-uicommon-mission-first-hotfix1`

A R2 original foi testada no Arma e fechou:
- **534 PASS**
- **20 FAIL**
- **554 total**

Ela não libera 0.6-F.

## Diagnóstico consolidado

### 1. NOVO / Draft / Repository

`NEW_KIT` preparava corretamente `pendingNewKit=true` e `selectedKitId=""`, mas o fallback legado de `buildUIViewModel` selecionava automaticamente o primeiro kit existente no refresh seguinte.

Consequência:
- o Draft pendente perdia isolamento;
- o P2 passava a representar um kit existente;
- ações posteriores do authoring atingiam o kit errado;
- vários FAILs de Recipe/Save/Save As/cleanup eram cascata.

### 2. Catálogo ÓTICAS x dropdown Mira

O dropdown reconstruía compatibilidade usando a arma atual do Draft.

A projeção cacheada do Catálogo podia reutilizar `sourceWeaponClass` antigo para o mesmo `kitId`, porque o fast path da R3 assumia que a arma-base não mudava. Essa suposição deixou de ser válida na 0.6-E.

Consequência observada:
- Mira tinha opções;
- Catálogo filtrado em ÓTICAS podia retornar 0 ou refletir a arma anterior.

### 3. Test drift

A R2 compactou `Visualizar` para `PRINC. / PORTE / SEC.`, mas o runner ainda exigia `PRINCIPAL / PORTE / SECUNDÁRIA`.

### 4. Items 0.13-A mission-first

Os gates 655/656/662/663 tentavam preprocessar caminhos do addon `ServoPeregrino_Organizador_Items\...` dentro da missão self-contained.

Os FAILs eram do test harness/path, não evidência de regressão funcional de Items.

## Correções HF1

- pending NOVO bloqueia auto-seleção do primeiro kit;
- projeção vazia de Meus Kits resolve `selectedKitId=""` antes de renderizar P2;
- NOVO limpa busca/seleção anterior e abre categoria WEAPON;
- mudança da arma-base invalida `SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR`;
- DESCARTAR invalida a projeção e atualiza os painéis dependentes;
- runner testa ótica engine-derived do seletor contra a projeção do Catálogo;
- runner testa rebuild da projeção depois de trocar arma-base;
- runner aceita a gramática compacta deliberada da R2;
- runner Items 0.13-A detecta mission-first e usa paths relativos `items\...`.

## Preservação

- Nexus: sem alteração funcional;
- UICommon: sem alteração;
- Items: somente runner 0.13-A mission-first;
- aplicação física Weapons: **DEFERRED_0_7**;
- MP/JIP/reconciliação: **DEFERRED_0_8**;
- PUBLICAR Weapons: reservado;
- 0.6-F: bloqueada.

## Static

- **69/69 PASS**
- runner R2 HF1: **531 assertion sites**
- não substitui runtime no Arma.

## Gate humano

1. sem PBO SP_ORG;
2. UICommon 12/12;
3. Items+UICommon 12/12;
4. NOVO sem repository object;
5. arma -> EQUIPAR NO RASCUNHO;
6. Mira x ÓTICAS para a mesma arma;
7. troca de arma-base e nova compatibilidade;
8. LIMPAR/DESCARTAR/SALVAR/SALVAR COMO NOVO;
9. AUTO R2 HF1 com 0 FAIL;
10. wheel/slider sem stutter;
11. RPT completo + prints.

## BGD Development

Issue #9 continua importante. O timing está em avaliação e a auditoria não é gate deste hotfix; pode ser executada na revisão final antes do packaging/PBO definitivo.
