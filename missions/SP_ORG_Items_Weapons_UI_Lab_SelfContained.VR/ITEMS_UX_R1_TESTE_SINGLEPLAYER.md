# Items UX R1 — guia de teste em single-player (21/10/2026)

## Proveniência

- Fonte: `baseline/uicommon-0.2-final-homologated@f92137769cf4d0478a5872aae157f5a229177c85`.
- Branch: `feature/items-0.13-retomada-20261021`.
- Identidade de pacote: `SP_ORG_Items_UX_R1_UICommon_0_2_FINAL.VR`.
- UICommon **0.2 FINAL / 0.2.0.10**, imutável; Items **0.13-A** (UX R1 candidata), Weapons do laboratório **0.6-F R6**, sem mudança funcional de Weapons.
- Modo: **mission-first self-contained**; não habilitar PBOs SP_ORG ao executar a missão. MP público continua fora deste gate.

## Gates manuais — realce do rascunho

1. Abrir Items, criar kit privado com 2+ itens distintos, SALVAR e reabrir. Estado geral SALVO e nenhuma linha laranja.
2. Somar 1 unidade em uma linha (botão +). **Somente** a linha correspondente fica laranja, com mesma linguagem visual do Weapons (RGBA [1,0.76,0.28,0.18]).
3. Reduzir a quantidade novamente à original. A linha volta à cor normal. Confirmar outras linhas intactas.
4. Aumentar/reduzir por digitação (campo de quantidade). Deve alterar apenas a linha certa. Zero remove sem criar "linha fantasma".
5. Adicionar outro item ao kit que não existia no snapshot. Essa linha fica laranja. Remover faz a marcação desaparecer junto com a linha.
6. Fazer mudança com item EXACT (quando disponível). Mudança de stateData/quantidade precisa aparecer como divergência sem inventar munição.
7. Filtrar em `ITENS DO KIT` e apagar filtro. A cor deve sobreviver ao refresh focado e também ao refresh completo.
8. SALVAR. Todas as linhas voltam à cor normal, permanecendo sem cor após fechar/reabrir.
9. Fechar/reabrir com draft alterado sem salvar. O destaque deve persistir porque o baseline salvo continua preservado. Não deve reaparecer confirmação de fechar.
10. Em draft NOVO sem snapshot salvo, não pintar tudo de laranja apenas porque ainda não existe baseline.

Observação: `dirty` geral tem comportamento histórico de flag de mutação e pode continuar ALTERADO após fazer/desfazer uma edição sem salvar, mesmo que todas as linhas visíveis tenham retornado ao snapshot; o destaque por linha é derivado da comparação real, não do flag. Reavaliar eventual recalculo de dirty geral em etapa própria.

## Gates manuais — CAPTURAR

1. Com um kit privado já salvo e selecionado, modificar o rascunho: inserir um item "A" que **não** está no equipamento físico.
2. Selecionar `Visualizar:` UNIFORME, COLETE ou MOCHILA e verificar o conteúdo físico mostrado.
3. Clicar `CAPTURAR`: deve abrir confirmação explicando **SUBSTITUIR** ITENS DO KIT, não fazer merge; deve indicar equipamento visualizado e ausência de autosave.
4. Escolher **Cancelar**: rascunho, quantidade, nome, kitId, identidade, equipamento físico e kit salvo permanecem iguais.
5. Clicar de novo e **Confirmar**: a lista ITENS DO KIT vira exatamente o conteúdo físico da visualização escolhida; "A" desaparece se não estava lá. Nome/kitId do kit selecionado e destination preferido são preservados.
6. Com o equipamento com 2+ classes, verificar quantidades, modos EXACT e ausência de mistura de UNIFORME com COLETE/MOCHILA.
7. Antes de SALVAR, fechar/reabrir: o rascunho capturado permanece em memória. Usar DESCARTAR e confirmar que o kit salvo anterior continua intacto.
8. Repetir e SALVAR explicitamente: só agora o kit salvo adota o conteúdo capturado.
9. Sem draft aberto, CAPTURAR confirmado cria um novo Draft NEW (sem persistir até SALVAR).
10. Testar equipamento ausente/indisponível (por exemplo visualizar MOCHILA sem mochila). A captura deve falhar sem alterar o rascunho anterior; não pode salvar automaticamente ou modificar inventário.
11. Verificar resposta ao clique enquanto há alterações dirty: confirmação permite substituição, sem antigo erro `ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE`.
12. Durante uma confirmação, se outra rotina modificar a revisão do draft, o callback deve recusar o overwrite (salvaguarda revision).

## Regressão e desempenho

- DnD/ghost, setas de Catálogo/EQUIPAMENTO, Whole-Kit/EXACT, capacidade, peso, barra de pesquisa e feedback sonoro.
- Scroll de Catálogo deve continuar `CATALOG_FOCUSED`, `fullRefresh=false`, sem equipamento recapturado.
- Operações de quantidade/linha devem continuar `DRAFT_FOCUSED`; abertura/cancelamento de diálogo não devem produzir full refresh.
- Rodar os testes automáticos disponíveis no laboratório e guardar sumários. **Resultados 43/43, 16/16 e 594/594 da UICommon FINAL continuam históricos; esta UX R1 precisa de RPT novo.**
- Enviar RPT completo e prints (linha antes/depois, confirmação do CAPTURAR, conteúdo do equipamento).

**Gate atual**: implementado em source e synchronized mission-first, **PENDENTE DE TESTE ENGINE MANUAL E RPT**. Não é declaração de homologação, nem substitui a validação MP da 0.13-A.
