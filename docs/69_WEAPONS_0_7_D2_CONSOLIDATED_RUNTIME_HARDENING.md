# Weapons 0.7-D2 — Consolidated Runtime Hardening

08/10/2026. **STATIC READY / RUNTIME PENDING**. Não homologada.

Branch: `feature/weapons-0.7-d2-consolidated-runtime-hardening`.
Origem D1 confirmada no GitHub antes de criar branch: `8c177c4a05b4018231bd0c11538bcfa2cc81f53a`.
Display `0.7-D2`, semantic `0.7.3.2`, build `0.7.3.2-consolidated-runtime-hardening-d2-mission-first`.
A convenção é display por candidata; nada exige reter o nome D1. Uma missão canônica, um pacote, um gate principal. R6/A/B2/C/D permanecem internos.

## Evidência D1 e cascata

RPT real: `Texto colado(20261008-040823).txt`; resumo D: **1104 PASS / 5 FAIL / 0 BLOCKED / 1109**.
A = 672/673, B = 888/890, C = 975/978, D = 1104/1109. Quatro FAILs compartilham a mesma causa: o assert A exige UI deferred, mas D1 habilita UI física em executor posterior. B/C/D adicionam um FAIL cada porque os gates cumulativos anteriores não estão verdes.

A substitui o assert por prova semântica: schemas Plan/Snapshot congelados, dryRunOnly=true, mutationAuthorized=false, simulate com sucesso e mutationPerformed=false, igualdade exata getUnitLoadout antes/depois. Nenhuma allow-list de versões UI. Quantidade A continua 673 e as rejeições de tampering/autoridade permanecem.
B também verifica disponibilidade do executor separado/schema descritivo em vez de expandir lista de markers UI. O harness R6 preserva geometrias/labels/action routing; seu antigo clique físico non-mutating usa seleção inválida explícita e exige recusa sem delta, evitando equipar o player durante regressão authoring. Aplicação válida é testada em unidade isolada e no handler player somente em NO_OP.

## HANDGUN_REPLACE — investigação e limite da conclusão

Defeito confirmado no source: D1 hardcode `9` enquanto o core usa `getNumber (configFile >> CfgMagazines >> magazine >> count)`. O RPT confirma SUCCESS e pós-validação exata, mas o assert literal falha. Essa expectativa não é portável entre configurações/modsets. O RPT contém uma P07 inicial com 17 rounds (diagnóstico PRIMARY_INSERT), além da baseline explícita de 7 no cenário HANDGUN. Nome de magazine não é capacidade canônica.

**O RPT D1 não registra o Cfg count da ACP nem o row posterior completo**: o dump monolítico Result foi truncado. Portanto não há evidência para declarar ACP=8, 9 ou 10, nem para confirmar chambering ou mudança entre frames. A causa da divergência numérica física exata permanece dependente do novo RPT. Não fingimos executar Arma neste ambiente.

Correção conservadora: runner calcula expectativa independente pela configuração ativa para NEW_MAGAZINE_FULL_CAPACITY; exige classe e ammo exatamente iguais. PRESERVE_OBSERVED_AMMO mantém o valor parcial explícito. Nenhuma aceitação de faixa/qualquer valor, nenhum refill, fullMagazines=false preservado, nenhum sleep ad hoc no executor e nenhum relaxamento da pós-validação C.

Logs curtos evitam truncamento do Result:
- AMMO_D2: desiredMagazineClass, configCount, slot, policy;
- AMMO_D2_ROW EXPECTED: row calculado pelo builder, com rounds esperados;
- IMMEDIATE_AFTER_SET: row capturado logo após setUnitLoadout;
- POST_VALIDATION: row observado pelo validador;
- AMMO_D2_RETURN/ROW AFTER_EXECUTE: row e classe/ammo depois do executor, currentWeapon/currentMuzzle;
- AMMO_D2_DETAIL: magazinesAmmoFull;
- AMMO_D2_STABLE/STABLE_ROW: captura no próximo diag_frameNo, timeout de 2s, igualdade exata do loadout com captura pós-retorno.

O próximo-frame é uma prova observacional do runner scheduled, não alteração da política física. Divergência vira FAIL, nunca ajuste automático de expectativa. Se revelar normalização posterior, deverá ser investigada antes de homologação e antes de adaptar o core. Preservar ammo observado não promete corrigir mod que altera equipamento posteriormente.

| Situação | Política preservada |
|---|---|
| Mesma arma/família e mesmo magazine | PRESERVE_OBSERVED_AMMO: valor exato do snapshot |
| Magazine novo/diferente | NEW_MAGAZINE_FULL_CAPACITY: capacidade Cfg ativa |
| Recipe sem magazine | NO_RECIPE_MAGAZINE: vazio |
| NO_OP | não muta, valida estado observado |
| SECONDARY runtime variant | somente equivalência type=4/shared baseWeapon já aprovada |

Referências primárias dos comandos: https://community.bistudio.com/wiki/setUnitLoadout e https://community.bistudio.com/wiki/magazinesAmmoFull . Não inferir chambering apenas desses documentos.

## Registro e metadata

`description.ext` remove getApplicationFeedback somente do bloco Items/UI; permanece exatamente uma vez em Weapons/UI, no path existente. Não foi criado arquivo falso Items. Static resolve todas as funções por diretório, incluindo Items. O warning `items\functions\ui\fn_getApplicationFeedback.sqf not found` deixa de ter sua causa no pacote; o próximo RPT confirma ausência.

Marker ativo: `LOCAL_DRAFT_AND_CATALOG_APPLY_0_7_D2`; openInterface distingue visual baseline 0.6-F R6 do application runtime. BuildInfo/initialize/runtime, tooltips, onLoad, hints, ações e LEIA_PRIMEIRO coerentes. Metadata histórica de releases anteriores continua histórica; não reescrevemos homologações passadas.

## Catálogo → Equipamento

`executeCatalogApplication` produz intenção transitória sem ler drafts, depois delega a executeDraftApplication -> Plan -> Snapshot -> único applyApplicationPlan B/C -> post-validation -> rollback automático se necessário. Não existe CatalogDirectSetUnitLoadout.

| Kind | Semântica física |
|---|---|
| WEAPON | getWeaponCatalogEntry valida PRIMARY/HANDGUN/SECONDARY natural. Configuration/Recipe transitórias com acessórios/magazine vazios, como a criação de arma-base authoring. Equipar arma não concede magazine implícito. P4 visualiza o slot natural |
| OPTIC | configuration física atual P4, selector optic engine-derived |
| POINTER | configuration física atual P4, selector pointer |
| MUZZLE/SUPPRESSOR | selector muzzle, quando recebido como categoria; catálogo visual atual não ganhou filtro novo |
| BIPOD | selector bipod/UnderBarrelSlot compatível |
| GRIP | somente representável se class explicitamente listada pelo engine no selector bipod/UnderBarrelSlot atual; não converte grips de outra representação nem os força a bipod |
| MAGAZINE | Recipe física P4, selector magazineClass, política B acima |
| Outros | unsupported/not applicable sem mutação |

Acessório/magazine em destino vazio: “Nenhuma arma equipada neste destino.” Incompatível: recusa antes da mutação, feedback humano. Classes inválidas/categoria sem mapeamento seguro também são recusadas. Biblioteca pública Weapons ainda reservada, sem provider/repository público ativo; nenhuma publicação é chamada pela rota.

As três ações continuam distintas: Catálogo→Draft faz authoring; EQUIPAR RASCUNHO aplica draft atual sem salvar; EQUIPAMENTO→ aplica seleção diretamente à arma física, sem editar draft/criar kit/salvar/publicar.

3151 fica acionável, no mesmo local, com tooltip de uso real. Sem seleção recebe orientação no clique; compatibilidade física pertence ao destino P4 e é determinada no clique. Todos os IDCs/x/y/w/h são preservados. Nenhuma alteração UICommon ou Items funcional.

Após operação: EQUIPMENT_FOCUSED reason=CATALOG_TO_EQUIPMENT. P4 recaptura estado real após sucesso/rollback; footer compartilhado renderiza feedback. Catálogo conserva class/kind/offset, sem P1/P2/P3 rebuild, FULL ou reconstrução de repository/projeção. A seleção de acessório pode ser compatível com draft e incompatível com P4: feedback no clique explica.

## Safety e regressão

Rollback C/validador C byte-idênticos à D1. TARGET_DIVERGENCE/PROTECTED_DIVERGENCE/AMMO_DIVERGENCE continuam no gate C com 10 domínios, loadout completo/ammo/fingerprint/animSpeedCoef. Stale é PRE_MUTATION, sem rollback. Fault continua restrito a unidade LAB não-player, local, marcada; UI não fornece fault. Não há novo multiplayer, RemoteExec/JIP ou mudança de CfgRemoteExec. UNDO_DEFERRED; MP_DEFERRED_0_8; sem PBO final/main merge.

Source executável não invoca CBA_fnc_addPerFrameHandler; RPT mostra erros CBA sem stack SP_ORG responsável. Adjacência temporal não prova causalidade. Classificação: ruído externo não atribuído ao SP_ORG com evidência disponível, reavaliável se surgir stack causal. Não alteramos CBA.

## Único AUTO TEST

Ação: **SP_ORG LAB - TESTAR WEAPONS 0.7-D2**.
Runner: `ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_D2Tests`.

Total saudável determinístico: **1348 = 1109 legacy + 239 locais**.
- 18 cenários × 12 assertions = 216;
- handler Catalog real em player NO_OP = 12;
- baseline/registros/runtime/unidade/texts/cleanup = 11.

Cenários: armas PRIMARY/HANDGUN/SECONDARY naturais; optic/pointer/muzzle/bipod; grip não representável; magazine igual partial e novo PRIMARY; HANDGUN igual partial e magazine novo; acessório incompatível; destino vazio; categoria unsupported; falha pós-mutação Catalog com rollback C; draft PRIMARY REPLACE; draft HANDGUN REPLACE observado no próximo frame. Os cenários D anteriores cobrem INSERT/RECONFIGURE/NO_OP/SECONDARY família.
Cada cenário prova resultado/slot/estado físico, Plan autoridade, todos drafts exatos, repository exato (sem autosave/publish), fingerprint, fullMagazines=false, fase rollback, ammo observado vs pós-validação, feedback e próximo-frame exato. Dependente não executado é BLOCKED; não inflar PASS. Gate aceita somente total esperado + zero FAIL/BLOCKED.

UI gate mede P4 +1, FULL/P2/P3 sem incremento, seleção/offset/drafts/repository/loadout player exatos, P4 class e footer. Mutação de player com delta permanece validação manual; runner não rearranja seu loadout.

Static **169/169**, incluindo todos CfgFunctions paths, ownership, delimitadores/SQF/includes/macros, JSON, geometria, contagem derivada, pipeline único, sem store mutation Catalog, sem bloqueio permanente 3151, sem CBA/MP novo, C/RemoteExec preservados. Não é compilador SQF nem engine Arma.

## Gate manual único

1. Extrair somente a missão D2 e abrir VR sem PBO SP_ORG. Executar a ação D2, exigir 1348 PASS/0 FAIL/0 BLOCKED.
2. Abrir Weapons, selecionar kit, alterar óptica sem salvar, EQUIPAR RASCUNHO: arma/P4 atualizam, ALTERADO permanece, kit salvo e outros drafts intactos. Repetir: NO_OP.
3. Selecionar pistola Catálogo, EQUIPAMENTO→: somente HANDGUN, P4 PORTE, draft atual/kit salvo intactos. Repetir PRIMARY e SECONDARY.
4. P4 PRIMARY, selecionar óptica compatível, EQUIPAMENTO→: accessory físico muda; draft não. Repetir pointer/bipod e muzzle se categoria disponível.
5. Óptica incompatível e acessório em slot vazio: nenhum delta e feedback claro. Grip não mapeado: clean refusal.
6. Magazine compatível igual/diferente: observar ammo real e comparar AMMO_D2 config/rows/return/stable. Partial nunca deve completar silenciosamente.
7. Fechar/reabrir: draft session-local preservado, equipamento físico observado permanece, repository independente.
8. Confirmar EQUIPMENT_FOCUSED reason=CATALOG_TO_EQUIPMENT/APPLY_DRAFT, sem FULL gratuitous; demais equipamentos/contents intactos.
9. Enviar RPT completo e observações manuais. D2 só homologa depois da análise; não iniciar 0.8/Undo/outra entrega.

## Pacote oficial

Missão: `SP_ORG_Weapons_0_7_D2_Consolidated_Runtime_Hardening.VR`.
ZIP: `SP_ORG_Weapons_0_7_D2_Consolidated_Runtime_Hardening.zip`.
Workflow `.github/workflows/package-selfcontained-ui-lab.yml`, com trigger D2. Identidade mantém newline real, sem literal \n. Empacotamento oficial **GREEN**:
- commit source: `ecee6ee23cb0018c699c8047d7dc8fce3589cba5`;
- workflow: https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/37730110664 ;
- run `37730110664`, artifact `11529253605`, nome `SP_ORG_UI_Lab`;
- artifact outer digest: `9467011575f50fe6a744f88ec0f7acecfc15d855e895c080dfb5bc870f527b89`;
- missão ZIP SHA256: `7fcac528f8d23245f1cbc2b736aa8e18ba35a9d20a0f7d3360937cf3e1e465a1`;
- 462 arquivos; CRC íntegro; um root mission; file-list exata e bytes iguais ao source desse commit, admitindo somente CRLF/LF textual;
- static workflow e checkout remoto local: **169/169 PASS**;
- commit posterior apenas docs/machine não modifica a missão testável nem gera outro artifact.

Revisão do diff: Items/UICommon/addons/backlog Items intocados; única correção no registro Items elimina a função alheia. Nenhum merge main/tag homologation. Gate final continua STATIC READY / RUNTIME PENDING.
