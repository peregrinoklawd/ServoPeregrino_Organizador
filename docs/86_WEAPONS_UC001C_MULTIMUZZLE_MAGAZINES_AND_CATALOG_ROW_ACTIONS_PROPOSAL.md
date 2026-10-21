# Arma 3 SP_ORG Weapons — Proposta UC-001-C: magazines por muzzle e migração da ação do nome da arma para botões de catálogo
**Data:** 2026-10-21  
**Natureza:** proposta arquitetural de continuidade / registro de observação e decisão de direção, **NÃO implementação aprovada para alterar o SQF agora**.  
**Source of truth:** UC-001-C R1 na branch `feature/weapons-uc-001-c-magazine-compatibility`, PR #12 Draft. UC-001-B R2 congelada em `baseline/weapons-uc001b-r2-approved`.  
**Aprovação atual:** UC-001-C R1 AUTO 1589/1589 PASS, manual de listas de munição executado pelo operador em 21/10. O operador **observou munições de lançadores misturadas no seletor único de carregadores**. Não declarar validação física da seleção por muzzle em D2 sem log.  
**Pendências correlatas:** `WUX-004`, `WUX-005`, `UC001C-MUZZLE-001` (detalhes em `docs/85_WEAPONS_UC001C_R1_RPT_REVIEW_UX_OBSERVATIONS_2026_10_21.md`).

## 1. Confirmação técnica e regras de domínio

A API do motor já faz a distinção:
- `compatibleMagazines weaponClass`: agrega magazines de **todos os muzzles**.
- `compatibleMagazines [weaponClass,muzzleName]`: revistas específicas de um muzzle; `"this"` identifica a principal quando aplicável.
- `getUnitLoadout` / `setUnitLoadout` row por slot de arma: `[weaponClass,muzzleAccessory,pointer,optic,primaryMagazine,secondaryMagazine,bipod]`, `primaryMagazine=[className,rounds]`, `secondaryMagazine=[className,rounds]`.
- `CfgMagazineWells` é fonte de descoberta e diagnóstico, mas não sobrepõe a autoridade do motor. `muzzles[]` define os canos e suas classes podem ter `magazineWell[]`.

Fontes Bohemia Interactive:  
- https://community.bistudio.com/wiki/compatibleMagazines  
- https://community.bistudio.com/wiki/Unit_Loadout_Array  
- https://community.bistudio.com/wiki/Arma_3:_Weapon_Config_Guidelines

**Causa do UX observada no source code atual:**
- `fn_resolveMagazineCompatibility.sqf` expõe corretamente `magazinesByMuzzle` e `muzzles` junto com agregado `magazines`.
- `fn_buildCompatibilitySelectorModel.sqf` monta somente **um seletor** `magazineClass` a partir do agregado.
- `fn_validateWeaponRecipeSemantic.sqf` aprova a classe se estiver no agregado, sem informar muzzle.
- `fn_buildApplicationTargetLoadout.sqf` recebe `magazineClass` e o posiciona sempre em `primaryMagazine`; `secondaryMagazine` é somente **preservada** quando a arma é equivalente, sem autoria independente. Esta é a lacuna `UC001C-MUZZLE-001`.
- `fn_validateWeaponRecipeStructural.sqf` aceita **schema fechado** `0.4-recipe-candidate` com as chaves exatas `schemaVersion,configuration,magazineClass`. Não acrescentar campo à margem sem versionamento explícito.
- `fn_prepareObservedCaptureRecipe.sqf` e `fn_captureEquippedWeaponToDraft.sqf` capturam `magazineClass` só do muzzle principal; preservação completa do segundo magazine exige ampliar o contrato de captura e reporte de omissões.
- `fn_getWeaponRecipeFingerprint.sqf` e comparação de recipes dependem do esquema; atualizar com migração.
- Testes AUTO C R1 1589/1589 **não comprovam** mudança física de magazine secundário.

## 2. Decisão de UX sugerida: dois seletores contextuais dentro de ARMAS DO KIT, NÃO outro painel inteiro

| Arma / config | Campo 1 | Campo 2 | Observação |
|---|---|---|---|
| Fuzil padrão com apenas um muzzle | Carregador | não aparece | Não desperdiçar espaço |
| Fuzil com GL/lançador de granadas integrado | Carregador do fuzil | Munição do lançador | Campos independentes, opções consultadas por muzzle |
| Pistola padrão | Carregador | não aparece | Preservar UX atual |
| Lançador independente (categoria SECONDARY, um muzzle) | Munição do lançador | não aparece | **SECONDARY weapon NÃO é muzzle secundário** |
| Arma de mod com muzzle secundário (e.g. escopeta sob cano) | Carregador principal | Munição do sistema secundário | **Não presumir** que todo muzzle secundário é GL |
| Arma com >2 muzzles independentes carregáveis | Seletores dinâmicos apenas em pesquisa/diagnóstico | física bloqueada até contrato mapeável | Loadout row padrão oferece 2 magazine slots; não prometer suporte físico genérico sem ensaio |

**Condição de exibição:** a arma deve ter ao menos um muzzle além do principal com magazines públicas autorizadas pelo motor; identificar pelo **muzzleId**, não por texto "grenade" ou heurística de classname. Melhor rotular com `displayName` válido do muzzle (fallback genérico `Munição secundária`). Para arma de categoria SECONDARY com um único muzzle, manter apenas um campo rotulado com seu papel.

**Ações explícitas para o segundo seletor**:
- `Manter munição carregada` (não mexer na arma física; útil ao editar ótica/acessórios).
- `Sem munição` (solicitação explícita de descarregar o muzzle alvo no APPLY).
- `<classe compatível>` (definir a munição para o muzzle exato, respeitar política de quantidade atual de D2).
A distinção entre **não especificado, limpar e selecionar** é importante para preservar retrofit sem apagar munição já presente. Pode ser representada como política triestado `KEEP, CLEAR, SET` na receita evoluída (nomes de enum são apenas sugestão).

**Regra do catálogo**: na categoria Carregadores, cada opção precisa carregar informação de `muzzleId` e `targetField` ou ter um destino inequívoco no momento do envio. Quando magazine for aceito por mais de um muzzle, a transferência explícita precisa escolher o destino — **não inferir só pela classe**. Sugestão: mostrar agrupamento no catálogo `Fuzil / Sistema secundário` ou inserir ação de destino na linha ao acrescentar setas. Pesquisa global continua podendo encontrar tudo, mas botão aplica somente ao alvo documentado.

## 3. Evolução de Recipe e compatibilidade de baseline (proposta, não codificada)

**Não mexer diretamente no schema 0.4 fechado e nem renomear a semântica existente silenciosamente.**
- Introduzir versão nova da Recipe com `magazineClass` (principal e compatível com legado) e uma estrutura `secondaryMagazineSelection` contendo `muzzleId`, `policy=KEEP|CLEAR|SET`, `magazineClass`.
- Resolver arma com função `getMagazineOptionsByMuzzle` ou reutilizar `magazinesByMuzzle` como fonte canônica de UI, validação e aplicação.
- Validar `magazineClass` do principal **apenas** contra `magazinesByMuzzle["this"]` ou identificação canônica efetiva da boca primária (fallback para arma de mod com arranjo não padrão); validar o segundo contra `magazinesByMuzzle[muzzleId]`. **Não** usar o agregado como autorização de destino.
- Receita legada v0.4 migra no carregamento para a semântica antiga segura; política padrão da munição secundária deve ser `KEEP` apenas em arma equivalente, e descarregar/zerar secundária em troca de base quando apropriado; definir caso de primeira aplicação de kit e confirmar que o significado de `magazineClass` legado não se desloca.
- Atualizar estruturais, semânticas, normalização, fingerprints, comparação, criação, captura observada, rascunho, STORE, D2 plano/aplicação/pós-verificação e apresentação do UI, **tudo na mesma revisão**. Preservar `COUNT` físico pelo snapshot ao manter classe e arma equivalentes; só usar capacidade cheia no `SET` onde aprovado pela política atual.
- D2 deve aplicar magazines ao **row index 4 e 5 respectivamente**, garantindo `secondaryMagazine` condizente com `muzzleId`. Fazer preflight fail-closed caso muzzle não seja mapeável ao row 5; no erro pós-mutação, rollback de loadout completo sem perda dos rounds.
- Se arma de mod tiver mais de um muzzle secundário ou outros casos sem mapeamento inequívoco, reportar limitação explícita, não atribuir magazine arbitrariamente.
- **Não confundir magazine carregada no tubo/câmara/GL com carregadores SOBRANDO no colete/mochila** (`WUX-002` é outra feature). Não inventar contagem persistida na recipe.

## 4. Reaproveitamento da ação existente do nome da arma — decisão de direção do usuário

O operador decidiu em 21/10:
1. **Reaproveitar** o caminho funcional existente `CATALOG_TO_DRAFT` quando forem implementadas as ações de seta/botões **por linha no Catálogo de Armas** (padrão Items).
2. **Depois** de as ações explícitas estarem implementadas e testadas, remover a ação do nome `WeaponValue` IDC 2021 no `ARMAS DO KIT` (`weapons/ui/weapons_dialog.hpp`). Ele deve ser apenas título/seleção, não um atalho oculto de transferência.
3. Rever também `onLBDblClick = CATALOG_TO_DRAFT` da lista do Catálogo IDC 3120, pois o contrato desejado é **transferir apenas por botão do catálogo**.
4. Destino de cada botão de catálogo fica explícito: `P3 → P2` edita rascunho, `P3 → P4` aplica fisicamente via autoridade D2. Botão para magazine **precisa** usar `muzzleId` e escolher principal/secundário antes de alterar.
5. Não duplicar código de negócio por botão: UI faz evento com dados de linha + destino, reusa serviço `applyCatalogSelectionToDraft` ampliado, não confia no `selectedCatalogClass` global se usuário já clicou em outra linha.
6. **WUX-005** preservar scroll/posição nas armas, revalidar só projeção de acessórios e munições ao mudar arma de kit. Rever após botões de catálogo estarem concluídos.

**Status `WUX-004`:** `MIGRATE_BEHAVIOR_THEN_REMOVE_OLD_CLICK`; código da branch intacto nesta rodada.
**Status `WUX-005`:** `DEFERRED_AFTER_CATALOG_ROW_BUTTONS`; código intacto.

## 5. Proposta de execução incremental, com gates

- **C2 — contrato/semântica**: modelagem de `muzzleId` + Recipe nova/migração compatível, seletores independentes/diagnóstico; SQF unit tests que diferenciem magazine primário e GL em MX GL, e casos sem launcher.
- **C3 — integração D2**: plano de carga física por dois magazines carregados, manter/descarregar/trocar, rollback, quantidade de tiros, vanilla + armas de mods, casos inválidos fail-closed.
- **C4 — UX de botões e menus**: seletor extra contextual, botões por linha, migração `CATALOG_TO_DRAFT` para P3 e remoção de onClick do nome P2, preservação de scroll; sem alterações inadvertidas de Items/UICommon.
- **C5 — E2E**: Arma real, primeiro testes automáticos acumulativos (baseline 1589 como origem, adicionar só novos asserts), depois teste manual `MX GL` (fuzil + HE), `Katiba GL` (muzzle nomeado `EGLM`), `NLAW` (launcher standalone), `hgun_P07_F` (simples) e pelo menos um mod com magwell / GL; física pós-verificada e rollback sob falha. **Não homologar só pela UI**.
- A separação em ciclos C2–C5 é uma **proposta de planejamento**, não releases ou versões já abertas. Manter UC-001-B homologada, UC-001-C R1 como evidência técnica já aprovada em auto, PR #12 Draft sem merge. Priorizar segurança física de magazines vs filtros cosméticos.

## 6. Critérios de aceite previstos

1. Carregador do fuzil nunca apresenta HE do GL; munição do GL nunca apresenta magazine do fuzil.
2. Campo secundário só aparece para *muzzle* secundário válido com munições; não aparece em pistola/fuzil simples; launcher avulso usa um seletor só.
3. Ao trocar o principal, secundário preserva-se quando `KEEP` compatível; ao trocar GL não afeta principal.
4. Botão do Catálogo tem ação de envio com alvo inequívoco e não depende do último item global selecionado.
5. Clicar nome P2, clicar ou dar duplo clique na linha P3 (sem botão) não altera kit nem player.
6. Aplicação física com munições diferentes em campos primary/secondary confere ao `getUnitLoadout` e mantém rounds corretamente; reconfigurar e falhar restaura snapshot.
7. Receita 0.4 antiga continua abrindo e não ganha descarregamento involuntário; o usuário consegue perceber `KEEP/CLEAR/SET`.
8. Navegação em lista longa de armas conserva offset e seleção ao trocar foco/kit, e acessórios atualizam para arma corrente.
9. Tests e mensagens registram `muzzleId`, source, targetRow e razão de rejeição/rollback; RPT auditável.
