#include "..\..\script_version.hpp"

/*
    Contrato cumulativo: 27 gates funcionais 0.10 (364..390) + 8 regressões corretivas 0.10.0.7 (391..398).
    Este arquivo descreve comportamento esperado; não executa os gates.
    Formato por entrada: [id, grupo, checkpoint, descrição].
*/
[
    ["ITEMS-0.10-364","WHOLE_KIT","CP-B","Whole-Kit ADD BEST_EFFORT cria um único ApplicationPlan dry-run contendo todas as entradas elegíveis, sem mutação durante o planejamento."],
    ["ITEMS-0.10-365","WHOLE_KIT","CP-B","Whole-Kit ADD BEST_EFFORT aplica o subconjunto possível e reporta PARTIAL/rejectedEntries quando a capacidade é insuficiente."],
    ["ITEMS-0.10-366","WHOLE_KIT","CP-B","Whole-Kit ADD STRICT rejeita atomicamente antes do commit quando qualquer entrada não pode ser aplicada."],
    ["ITEMS-0.10-367","WHOLE_KIT","CP-B","Whole-Kit REMOVE BEST_EFFORT remove o conteúdo disponível e reporta faltantes sem corromper o restante."],
    ["ITEMS-0.10-368","WHOLE_KIT","CP-B","Whole-Kit REMOVE STRICT não muta o container quando qualquer quantidade requerida está ausente."],
    ["ITEMS-0.10-369","REPLACE_CLEAR","CP-B","REPLACE é obrigatoriamente STRICT e planeja a substituição do CONTENT mutável pelo estado desejado do kit."],
    ["ITEMS-0.10-370","REPLACE_CLEAR","CP-B","REPLACE bem-sucedido produz CONTENT mutável semanticamente equivalente ao kit solicitado."],
    ["ITEMS-0.10-371","REPLACE_CLEAR","CP-B","Falha durante REPLACE executa rollback focal e restaura exatamente o fingerprint mutável anterior."],
    ["ITEMS-0.10-372","REPLACE_CLEAR","CP-B","CLEAR remove todo CONTENT mutável do target selecionado."],
    ["ITEMS-0.10-373","REPLACE_CLEAR","CP-B","CLEAR preserva integralmente weapons, equipment e nested containers reservados."],
    ["ITEMS-0.10-374","REPLACE_CLEAR","CP-B","Falha durante CLEAR executa rollback focal e restaura exatamente o fingerprint anterior."],
    ["ITEMS-0.10-375","TRANSACTION_HARDENING","CP-B","ApplicationPlan stale é rejeitado na revalidação e nenhuma mutação é executada."],
    ["ITEMS-0.10-376","TRANSACTION_HARDENING","CP-B","Lock de aplicação possui identidade/token; concorrência é recusada e lock stale pode ser recuperado sem liberar lock de outro owner."],
    ["ITEMS-0.10-377","DRAFT_APPLICATION","CP-B","Draft NEW não salvo pode ser aplicado fisicamente sem exigir persistência prévia."],
    ["ITEMS-0.10-378","DRAFT_APPLICATION","CP-B","Ao aplicar um Draft dirty ligado a kit persistido, o estado corrente do Draft é a fonte autoritativa, não a versão salva antiga."],
    ["ITEMS-0.10-379","DRAFT_APPLICATION","CP-B","Aplicar um kit salvo usa snapshot lógico e não altera o repositório nem a identidade persistida do ItemKit."],
    ["ITEMS-0.10-380","TARGET_RESOLUTION","CP-B","Target explícito da aplicação é respeitado; ANY resolve de forma determinística sem misturar containers e preferredTarget atua somente como fallback previsto pelo contrato."],
    ["ITEMS-0.10-381","APPLY_RESULT","CP-B","ApplyResult de operação de kit agrega appliedEntries, rejectedEntries, status e operação sem perder os resultados por entrada."],
    ["ITEMS-0.10-382","UI_PHYSICAL","CP-C","UI só anuncia/permite mutação física quando Application Engine e target estão válidos; falha de readiness permanece segura e não física."],
    ["ITEMS-0.10-383","FULL_DND","CP-C","Identidade e payload do drag são congelados no START; mudança posterior de seleção não troca o objeto arrastado."],
    ["ITEMS-0.10-384","FULL_DND","CP-C","Drop no Kit Selecionado mantém a semântica lógica: catálogo/equipment/kit alimentam o Draft sem mutação física."],
    ["ITEMS-0.10-385","FULL_DND","CP-C","Drop no destino físico executa a operação correspondente à origem por um comando explícito e target-scoped, inclusive entradas unitárias e kits inteiros."],
    ["ITEMS-0.10-386","UI_COMMANDS","CP-C","Setas e DnD convergem para o mesmo serviço/comando de transferência; um gesto produz uma única mutação sem duplicação."],
    ["ITEMS-0.10-387","UI_COMMANDS","CP-C","Delete, decremento e quantidade 0 em contexto físico convergem para REMOVE/remoção total prevista, preservando a semântica EXACT de magazines."],
    ["ITEMS-0.10-388","FULL_DND","CP-C","Drop inválido, origem alterada ou soltura fora de target cancela o gesto sem alterar Draft, storage ou inventário."],
    ["ITEMS-0.10-389","UI_REFRESH","CP-D","Mutação física concluída recaptura somente o necessário e preserva seleção/scroll quando válidos; seleção pura não dispara refresh completo."],
    ["ITEMS-0.10-390","END_TO_END","CP-D","Fluxo UI físico end-to-end altera somente o target contratado e preserva reserved cargo e segmentos de loadout fora do target, com rollback íntegro quando necessário."],
    ["ITEMS-0.10.0.7-391","TARGET_SWITCH","HOTFIX-0.10.0.7","Trocar applicationTarget usa refresh target-only, mantém equipmentView/lista e não executa mutação ou rollback."],
    ["ITEMS-0.10.0.7-392","VISIBLE_FAILURE","HOTFIX-0.10.0.7","Botões físicos permanecem clicáveis em estado bloqueado e todo clique recusado produz feedback/histórico visível."],
    ["ITEMS-0.10.0.7-393","ROUND_TRIP","HOTFIX-0.10.0.7","Draft misto ITEM + MAGAZINE EXACT faz ADD seguido de REMOVE e retorna ao fingerprint físico exato inicial."],
    ["ITEMS-0.10.0.7-394","QUANTITY_ARITHMETIC","HOTFIX-0.10.0.7","ADD+ADD+REMOVE+REMOVE preserva aritmética +2,+1,baseline sem quantidade fantasma, inclusive EXACT."],
    ["ITEMS-0.10.0.7-395","TARGET_ISOLATION","HOTFIX-0.10.0.7","Troca de target entre comandos não desfaz target anterior e cada comando muta apenas o container explicitamente resolvido."],
    ["ITEMS-0.10.0.7-396","REPLACE_CLEAR_CHAIN","HOTFIX-0.10.0.7","REPLACE permanece após target switch e CLEAR afeta somente o novo target, sem rollback implícito."],
    ["ITEMS-0.10.0.7-397","EXACT_REMOVE_HARDENING","HOTFIX-0.10.0.7","REMOVE de magazine EXACT cujo estado esperado não existe falha explicitamente sem reconstruir cargo."],
    ["ITEMS-0.10.0.7-398","PHYSICAL_TRACE","HOTFIX-0.10.0.7","Cada comando físico recebe commandId e physicalTrace únicos, com PRE/POST correlacionável e singleDispatch."]
]
