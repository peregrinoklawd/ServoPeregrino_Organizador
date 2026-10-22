# Items — Backlog futuro: confirmação no botão CAPTURAR

> **SUPERSESSÃO — 22/10/2026:** O nome deste arquivo e o histórico abaixo dizem "futuro/candidato" porque descrevem o backlog original de 07/10 e o início da UX R1 em 21/10. **Status ATUAL: CAPTURAR COM CONFIRMAÇÃO E SUBSTITUIÇÃO DO DRAFT IMPLEMENTADO, APROVADO MANUALMENTE SP e preservado na R2.2 homologada.** A aprovação **não** cobre os gates MP da biblioteca pública. Fonte: [homologação R2.2](70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md) e [handoff atual](74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md). Não reimplementar CAPTURAR por confundir este documento histórico com backlog ativo.

## Atualização — 21/10/2026

Este é o registro original do backlog de 07/10, preservado por rastreabilidade. Em 21/10, a implementação candidata foi criada **na branch de Items** `feature/items-0.13-retomada-20261021`, sem alterar Weapons, e aguarda homologação no Arma.

Decisão adicional de segurança/continuidade: quando já existe Draft EDIT/NEW, **substituir apenas `entries`**, preservando identificação do kit, nome, destino preferido e baseline; quando não existe Draft, criar NEW. A comparação orange usa o baseline anterior à captura; o Repository não recebe escrita antes do SALVAR. O botão continua chamado CAPTURAR. O cancelamento não escreve estado e captura falha não destrói Draft.

Tester: `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/ITEMS_UX_R1_TESTE_SINGLEPLAYER.md`. **Código em candidato; RPT e teste manual pendentes.** As menções a "futuro" abaixo descrevem seu estado em 07/10, não o estado atual desta branch.

Data de registro: 2026-10-07.

Status: **BACKLOG / NÃO IMPLEMENTAR NA ENTREGA WEAPONS 0.7-A**.

## Origem

Durante os testes integrados da missão UI Lab foi solicitado revisar o comportamento
do botão **CAPTURAR** no painel **CONTEÚDO DO EQUIPAMENTO** de Items.

## Comportamento desejado

Ao acionar **CAPTURAR**, o jogador não deve mais iniciar diretamente uma captura
sobre o rascunho atual.

O fluxo futuro deve ser:

1. jogador clica em **CAPTURAR** no painel **CONTEÚDO DO EQUIPAMENTO**;
2. a interface abre um diálogo de confirmação;
3. o diálogo informa explicitamente que a operação:
   - limpará os itens atualmente presentes em **ITENS DO KIT**;
   - substituirá esse conteúdo pelos itens atualmente presentes no
     **CONTEÚDO DO EQUIPAMENTO** da visualização/destino selecionado;
4. se o jogador confirmar:
   - limpar o conteúdo atual do rascunho;
   - capturar o conteúdo físico exibido no painel;
   - inserir o conteúdo capturado em **ITENS DO KIT**;
   - manter a alteração apenas como rascunho até o jogador salvar explicitamente;
5. se o jogador cancelar:
   - não alterar o rascunho;
   - não alterar o equipamento físico;
   - não persistir nada.

## Semântica

A operação deve ser entendida como:

**SUBSTITUIR CONTEÚDO DO RASCUNHO PELO CONTEÚDO DO EQUIPAMENTO**

e não como merge/adicionamento sobre o rascunho existente.

O botão continua sendo chamado **CAPTURAR**.

## Texto sugerido para confirmação

Título:

`Capturar conteúdo do equipamento?`

Mensagem:

`Esta ação limpará os itens atuais do rascunho e substituirá o conteúdo de ITENS DO KIT pelos itens atualmente exibidos em CONTEÚDO DO EQUIPAMENTO. Deseja continuar?`

A redação final pode ser ajustada na entrega de UI, preservando esse significado.

## Regras de segurança

- nenhum efeito físico no inventário;
- não salvar automaticamente o kit;
- não apagar/alterar o kit persistido antes de um comando explícito de salvar;
- cancelar deve ser totalmente observacional;
- a captura deve respeitar exatamente o destino/visualização de equipamento selecionado;
- falha na captura não deve destruir o rascunho anterior: a implementação futura deve
  preparar/capturar primeiro ou manter snapshot suficiente para restauração atômica.

## Critérios mínimos de teste futuro

Automatizar quando possível:

- CAPTURAR com rascunho preenchido abre confirmação;
- cancelar preserva o rascunho byte/logicamente equivalente;
- confirmar substitui o rascunho, não faz merge;
- itens antigos que não existem no equipamento desaparecem do rascunho;
- itens do equipamento aparecem com quantidades corretas;
- kit persistido permanece inalterado até Salvar;
- inventário físico permanece inalterado;
- falha de captura preserva/restaura o rascunho anterior;
- refresh deve ser DRAFT_FOCUSED quando tecnicamente possível, sem rebuild desnecessário do catálogo.

## Planejamento

Implementar somente quando Items voltar a ser a frente ativa.

Esta pendência não altera nem bloqueia:
- UICommon 0.2 congelada;
- Weapons 0.7-A;
- Weapons 0.7-B.

