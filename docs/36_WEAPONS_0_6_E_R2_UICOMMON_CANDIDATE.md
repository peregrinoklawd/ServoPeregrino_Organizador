# Weapons 0.6-E R2 + UICommon — Candidate Delivery

Data: 2026-10-03.

## Estado

**CANDIDATA MISSION-FIRST — RUNTIME/MANUAL/PERFORMANCE PENDENTES.**

Build:
`0.6.4.2-ux-convergence-direct-draft-equip-uicommon-mission-first`

Base:
- Items + UICommon Equivalence R1 aprovada para Items;
- Weapons 0.6-E R1 histórica preservada;
- 0.6-D R3 focused refresh permanece baseline de performance;
- aplicação física continua 0.7;
- MP/JIP/reconnect continua 0.8.

## Objetivo

Implementar os requisitos congelados da 0.6-E R2 sobre UICommon sem alterar a baseline funcional de Items.

## Dependência UICommon

Weapons passa a consumir a fundação compartilhada:
- `UICommon_fnc_escapeStructuredText`;
- `UICommon_fnc_clampVirtualOffset`.

Lifecycle exige UICommon 0.1.1 e publica a dependência no runtime.

Não existe dependência Weapons -> Items.

## P1 — MEUS KITS DE ARMAS

Ordem player-facing:
1. NOVO;
2. DUPLICAR;
3. EXCLUIR;
4. PUBLICAR.

RENOMEAR não existe mais como ação visível de P1.

PUBLICAR permanece reservado/no-op nesta candidata.

## P2 — ARMAS DO KIT

Título player-facing:
**ARMAS DO KIT**

Controles:
- nome inline;
- SALVO / ALTERADO / NOVO;
- busca abaixo do título;
- SALVAR;
- SALVAR COMO NOVO;
- DESCARTAR;
- LIMPAR.

SALVAR confirma:
- nome inline;
- Recipe do Draft.

Focused refresh deve preservar texto digitado.

## Fluxo NOVO

```
NOVO
 -> pendingNewKit=true
 -> nenhum WeaponKit inválido é criado
 -> escolher ARMA no Catálogo
 -> ← / EQUIPAR NO RASCUNHO
 -> WeaponKit mínimo válido é criado
 -> estado NOVO
 -> editar nome/Recipe
 -> SALVAR
```

Um acessório não pode ser o primeiro conteúdo do novo Draft.

## Catálogo -> Draft

Novo helper:
`applyCatalogSelectionToDraft`

Aceita:
- WEAPON;
- OPTIC;
- POINTER;
- BIPOD;
- GRIP;
- MAGAZINE.

Compatibilidade continua engine-derived.

Ação grande:
`← EQUIPAR NO RASCUNHO`

Duplo clique na linha do Catálogo usa a mesma semântica.

A gramática visual da linha usa:
`←  <tipo> | <nome>  →`

Nesta candidata o ListBox continua sendo um controle único; portanto as setas dentro da linha são indicação visual e a ação direta é fornecida por duplo clique/botão grande. Não há hit-zone independente por seta dentro da linha nesta versão.

## Aplicação física

`EQUIPAMENTO →` permanece visível e reservado.

Nenhum código UI da R2 chama:
- applyWeaponConfiguration;
- setUnitLoadout;
- add/remove weapon;
- add/remove weapon attachment.

Gate físico continua **DEFERRED_0_7**.

## LIMPAR

Novo helper:
`clearWeaponKitDraft`

Semântica:
- preserva arma-base;
- remove optic/muzzle/pointer/bipod-grip/magazine do Draft;
- recalcula dirty comparando com baseRecipe;
- não altera repository automaticamente;
- não altera loadout.

## P4 — CONTEÚDO DO EQUIPAMENTO

Permanece read-only.

Faixa:
`Visualizar: Principal | Porte | Secundária`

Busca P4 é atalho sincronizado da busca do Catálogo nesta candidata.

## Footer

- outer background removido/transparente;
- Contexto / Resultado / Histórico permanecem em faixas próprias;
- Histórico recebe contraste maior.

## Performance

Preservar contrato da 0.6-D R3:
- focused refresh;
- cache de projeção/filtro;
- janela de 32;
- sem full refresh em wheel/slider;
- instrumentação `UI_PERF`.

Retorno a ~246–254 ms por passo de scroll é regressão bloqueadora.

## Cold-open

Hotfix anterior preservado.
R2 considera Equipment materializado inclusive quando o slot legítimo está sem arma; o placeholder `Lendo o equipamento atual...` é o único estado ainda não pronto.

## Testes

Runner histórico R1:
- `fn_runDelivery0_6_ETests.sqf`;
- preservado byte a byte.

Novo runner:
- `fn_runDelivery0_6_ER2Tests.sqf`;
- **528 sites de assertion explícitos no source**;
- o total de runtime NÃO é pré-homologado porque existem blocos condicionais;
- o `AUTO_TEST_SUMMARY` do RPT é a autoridade.

Validação estática da candidata:
- **75 PASS / 0 FAIL**.

Também confirmado:
- Nexus byte-idêntico à Equivalence R1;
- UICommon byte-idêntico à Equivalence R1;
- Items byte-idêntico à Equivalence R1.

## Gate manual obrigatório

1. iniciar missão sem PBOs SP_ORG;
2. UICommon 12/12;
3. Items+UICommon 12/12;
4. reiniciar missão;
5. abrir Weapons pela primeira vez sem clicar;
6. confirmar Catálogo + Equipment preenchidos;
7. confirmar P1 `NOVO / DUPLICAR / EXCLUIR / PUBLICAR`;
8. confirmar título `ARMAS DO KIT`;
9. NOVO -> estado NOVO sem kit inválido;
10. selecionar arma -> EQUIPAR NO RASCUNHO;
11. enviar acessório compatível;
12. editar nome inline -> SALVAR;
13. LIMPAR / DESCARTAR / SALVAR COMO NOVO;
14. PUBLICAR não muta repository/backend;
15. EQUIPAMENTO -> não muta loadout;
16. wheel/slider com gate humano de fluidez;
17. executar AUTO R2;
18. enviar RPT + prints.

## Items

Nenhuma convergência visual de Items entra nesta entrega.

Pendências continuam:
- ITENS DO KIT;
- destaque por linha ALTERADO;
- Mostrar -> Visualizar;
- `Vasculhando inventário e catalogando itens...`;
- footer/tokens;
- investigação visual de transparência mission-first.

## Próximo gate

R2 só libera 0.6-F depois de:
- AUTO verde;
- manual verde;
- performance verde;
- RPT sem nova regressão SP_ORG.

Depois:
- 0.6-F Final Visual Adaptation/Regression;
- 0.7 Slot-Safe Weapon Application;
- 0.8 Multiplayer Authority/Reconciliation.
