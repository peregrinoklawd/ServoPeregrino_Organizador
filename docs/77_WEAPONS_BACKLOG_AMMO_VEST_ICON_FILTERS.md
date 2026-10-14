# Weapons — Backlog funcional pós-R5 (14/10/2026)

Baseline de referência: `baseline/weapons-0.7-e-r5-homologated` (`52dd24af4f54ca9f3c9c6832f55ffdf772ff0314`). Nenhuma das melhorias abaixo está implementada na R5 ou incluída automaticamente na UC-001-A.

## WUX-002 — Adicionar carregadores ao colete no painel CONTEÚDO DO EQUIPAMENTO

**Pedido:** permitir, sem fechar Weapons, adicionar ao colete do jogador carregadores da mesma classe escolhida para a arma.

**Ownership:** a seleção da classe e a experiência de UI pertencem a Weapons; a inserção física em container/vest e regras de capacidade devem usar um contrato de serviço responsável por inventário (Items/Equipment, quando disponível), via Nexus e sem acessar estado privado entre módulos. Não misturar com o pipeline slot-safe de equipar arma.

**Fluxo proposto para avaliação:**
1. Em CONTEÚDO DO EQUIPAMENTO, ação textual `+ ADICIONAR CARREGADOR AO COLETE` próxima da informação do carregador da arma.
2. A classe de magazine deve ser inequívoca. Se houver divergência entre Recipe no rascunho e arma física exibida em P4, indicar qual fonte foi escolhida e permitir confirmar a classe antes de adicionar. Nunca presumir que o magazine de um muzzle secundário serve ao principal.
3. Quantidade inicial 1 e ajuste explícito (limitado), nunca inserir em lote silenciosamente.
4. Validar CfgMagazines, compatibilidade com a arma/muzzle selecionado via UC-001, existência do colete e capacidade real antes de mutar.
5. Operação explícita e isolada: adicionar exclusivamente os carregadores requisitados ao colete; preservar uniforme, mochila, armas, carregadores já existentes e as quantidades de munição carregadas.
6. Validar estado físico posterior, diagnosticar recusa (sem colete, sem espaço, classe inválida, restrição de política, localidade, ausência de estoque em ambiente que exija stock). Sem sucesso presumido, sem contornar políticas de servidor/stock.
7. Sem autosave da Recipe/WeaponKit e sem acionar EQUIPAR RASCUNHO. Em MP, autoridade e regras de estoque exigem contrato de servidor antes de habilitar a ação.
8. Considerar comportamento em falha parcial e rollback de inventário; não prometer rollback idêntico antes de verificá-lo no Arma.
9. Testes com uma e múltiplas unidades, colete lotado, colete ausente, slots PRIMARY/HANDGUN/SECONDARY, GL/muzzle adicional, mags DLC/modded, magazines de capacidade diferente, repeated-click e prova de que nenhuma outra peça do loadout foi alterada.

**Sequência:** especificação posterior à UC-001 de compatibilidade; execução física condicionada a teste isolado e contrato de inventário. Não inserir esta ação na R5 nem durante UC-001-A diagnóstica.

## WUX-003 — Filtros de categorias com botões compactos e imagens

**Pedido:** trocar parte dos filtros textuais de arma/acessório por ícones compactos, inspirados na identificação visual de categoria do ACE Arsenal e mods equivalentes.

- Candidatos: arma, mira/óptica, acessórios de boca, apontador, bipé, empunhadura, carregador e `Todos`.
- Preservar SALVAR, SALVAR COMO NOVO, DESCARTAR, LIMPAR, NOVO, DUPLICAR, EXCLUIR e outras ações operacionais como botões com texto.
- Ícones devem ser reais/adequados ao Arma 3, claros entre categorias e coerentes visualmente com Items e UICommon; evitar reaproveitar símbolo ambíguo.
- Tooltip textual em português, seleção visual clara, foco/teclado, hitbox suficiente, alternativa textual se o ícone estiver ausente.
- Comparar a densidade/legibilidade em 1080p, ultrawide e baixa resolução; preservar layout responsivo e scroll/cache focado.
- Não alterar regras de compatibilidade, filtros de resultados, ordenação ou IDCs públicos sem migração e regressão.
- Desenho e homologação visual independentes da UC-001 e da operação de magazines no colete.

## Regra de prioridade

`UC-001-A > UC-001-B > UC-001-C > UC-001-D` continua sendo o gate funcional prioritário. WUX-002 e WUX-003 são backlog aprovado para projeto/discussão, **não funcionalidades entregues**. A sequência específica de implementação será definida quando os pré-requisitos estiverem validados.
