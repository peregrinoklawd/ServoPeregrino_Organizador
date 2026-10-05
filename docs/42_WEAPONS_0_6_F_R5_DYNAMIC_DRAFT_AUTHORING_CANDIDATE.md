# Weapons 0.6-F R5 — Dynamic Draft Authoring Candidate

Data: 05/10/2026.

## Contexto

A R4 validou o novo preview 2D proporcional/centralizado e a padronização dos filtros do Catálogo, mas o teste real revelou três pontos de authoring que precisam ser resolvidos antes de congelar a linha 0.6:

1. ao enviar uma arma do Catálogo sem kit selecionado, o jogador recebia o código técnico `WEAPONS_UI_DRAFT_KIT_REQUIRED`;
2. a troca da arma-base era bloqueada quando a nova arma pertencia a outra categoria interna (`PRIMARY/HANDGUN/SECONDARY`);
3. o tipo interno do WeaponKit aparecia na UI embora seja metadado de implementação, não informação necessária ao jogador.

O RPT da R4 também expôs:
- erro de configuração no tooltip de `CatalogSearch` por `;` ausente;
- três FAILs do runner causados por expectativas antigas de rótulos longos depois da compactação visual;
- a missão ainda declarava política global `CfgRemoteExec mode=1/jip=0`, o que não deve ser propriedade do módulo/lab.

## Contrato da R5

### Catálogo -> ARMAS DO KIT sem kit selecionado
Se o jogador selecionar uma **arma** e usar `← EQUIPAR NO RASCUNHO` sem possuir kit selecionado:
- criar automaticamente um novo kit session-local;
- selecionar esse kit;
- marcar o estado como `NOVO`;
- preencher a arma-base com a arma escolhida;
- não executar mutação física no loadout.

Se tentar enviar um acessório sem arma-base:
- não expor código interno;
- explicar que é necessário escolher uma arma primeiro e que o kit será criado automaticamente quando ela for enviada.

### Troca dinâmica da arma-base
A UI não bloqueia mais a troca entre Principal/Porte/Secundária.

Internamente:
- a nova arma redefine o `targetSlot` do draft;
- acessórios/carregador são zerados para recalcular compatibilidade;
- `targetSlot + Recipe` são persistidos juntos ao SALVAR;
- `kitId` e nome são preservados.

O domínio continua validando coerência entre arma e `targetSlot`; a diferença é que a UI passa a atualizar ambos de forma atômica.

### Tipo interno não exposto
`targetSlot` continua existindo para roteamento/aplicação futura, mas:
- não aparece em ARMAS DO KIT;
- não aparece no CONTEXTO do footer;
- continua disponível internamente para regras e 0.7.

### Feedback
O fluxo direto de authoring deve mostrar mensagens explicativas em português.
Não mostrar ao jogador códigos `WEAPONS_UI_*` como mensagem principal.

## Correções adicionais
- corrigir `CatalogSearch.tooltip` com `;` ausente;
- ajustar runner para os rótulos compactos `PRINC.`, `SEC.`, `ÓTICA`, `BIPÉ`, `EMPUNH.`;
- remover `mode/jip` globais de `CfgRemoteExec` da missão, mantendo somente declarações de endpoints;
- preservar preview keep-aspect, filtros uniformes, buscas independentes, busca global, highlights âmbar e focused refresh.

## Gates
- aplicação física: continua em 0.7;
- multiplayer authority/JIP: continua em 0.8;
- botões por imagem: futuro;
- preview 3D real: futuro.

## Estado
Candidata mission-first preparada como `SP_ORG_Items_Weapons_UI_Lab_Weapons_0_6_F_R5_UICommon.zip`.

O espelho avançado de Weapons dentro da missão canônica do repositório ainda precisa ser sincronizado; não tratar o source E R1 atualmente presente nessa missão como equivalente à candidata R5.
