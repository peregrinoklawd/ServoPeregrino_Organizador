# Weapons 0.7-E E1 R4 — Compatibilidade CBA no slot inferior

Checkpoint 2026-10-09. Candidata mission-first, semantic 0.7.4.4, runtime ainda pendente. Baseline D2 R1 congelada.

## Evidência do RPT R3 R1 (09/10, 18:59)

- AUTO 1420/1420, 0 FAIL, 0 BLOCKED; hotfix do targetSlot aprovado.
- MCC_RD704_AFG: compatibleItems vanilla=44; CBA=87; CBA acrescenta MCC_Handbrake_BLK.
- MCC_Handbrake_BLK: vanilla=false, cba=true, observado no físico=true, retido no teste isolado imediato e após espera.
- rhsusf_acc_grip2: vanilla=false, cba=false, teste físico isolado=false. Não confundir com a peça MCC que funciona.
- BIS_fnc_compatibleItems retornou 2992 itens; não usar como fonte conclusiva para esse slot.
- Captura de kit existente e NOVO deu capturePartial=true, ENGINE_ATTACHMENT_INCOMPATIBLE para MCC_Handbrake_BLK.
- isolatedDummyDeleted=false: diagnóstico antigo não aguardava remoção do dummy. R4 aguarda até 5s e exige confirmação.
- Erros de terceiros em CBA_fnc_addPerFrameHandler: presentes antes do diagnóstico; autoria não estabelecida.

## Implementação R4

- Novo resolvedor fn_getUnderbarrelCompatibility: consulta vanilla e CBA_fnc_compatibleItems(weaponClass, bipod), se presente.
- Aplica a classes CBA adicionais validação de existência, escopo público, grafia canônica e deduplicação.
- Mesma autoridade para catálogo e validação semântica somente no campo bipod.
- Não cria whitelist específica de mods nem flexibiliza o restante da Recipe.
- Captura mantém exclusões explícitas para incompatíveis e nunca grava automaticamente.
- Executor físico, pós-validação e rollback D2 preservados.

## Entrega e aceite

CI run 37997421548: SUCCESS, 214/214 estáticos.
ZIP SP_ORG_Weapons_0_7_E_CBA_Underbarrel_E1_R4.zip, missão única de 520 entradas; CRC sem erro.
SHA256 596df283b10dec4a572b1f7e02af99d1728b3a4df3719515f86b4d9013ffa7d8.
Commit empacotado 324918a09bdeca56a7108c66c9f3cf52bd39631c, artifact 11647966356.
Gate runtime: 1430 PASS, 0 FAIL, 0 BLOCKED.
Gate manual: MCC_RD704_AFG + MCC_Handbrake_BLK via ACE, auditar compatibilidade e remoção dummy; capturar em kit existente e NOVO; verificar rascunho e catálogo; equipar e conferir pós-validação. rhsusf_acc_grip2 deve continuar rejeitado se ausente nas listas.
Não homologar, fazer merge main, PBO ou iniciar MP/Undo antes de RPT e aprovação manual.
