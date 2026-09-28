# Servo Peregrino Organizador — visão funcional por módulo

Documento resumido para apresentação e alinhamento entre equipes.

## Legenda

- ✅ **Implementado** — já existe no projeto atual.
- 🟡 **Desenvolvido em linha histórica madura** — já foi desenvolvido/testado anteriormente e aguarda consolidação ou migração para a arquitetura atual.
- 🔵 **Planejado** — faz parte do desenho aprovado e deverá ser implementado.
- ⚪ **Evolução futura** — ideia registrada para uma etapa posterior do projeto.

## Princípio do projeto

O Servo Peregrino Organizador é formado por vários módulos independentes.

Cada funcionalidade tem **um único módulo responsável**. Os demais módulos podem usar essa funcionalidade, mas não devem criar outra versão dela.

O objetivo é evitar:
- funções duplicadas;
- menus diferentes fazendo a mesma coisa;
- dois sistemas diferentes controlando o mesmo dado;
- conflitos entre mods;
- retrabalho entre equipes.

---

## Nexus — base de comunicação entre os módulos

Responsável pela infraestrutura comum usada pelos outros módulos.

Funcionalidades:

- ✅ Resultado das ações em um formato padronizado
- ✅ Diagnóstico de erros e problemas
- ✅ Registro de logs
- ✅ Identificação das funcionalidades disponíveis
- ✅ Regras padronizadas de comunicação entre módulos
- ✅ Envio e recebimento de eventos entre módulos
- ✅ Controle de inicialização dos módulos
- ✅ Controle de versão
- 🔵 Identificação de serviços opcionais disponíveis no servidor

**O Nexus não implementa funcionalidades de jogo.**

---

## Hub — Central do Organizador

Responsável por reunir os módulos em uma experiência única para o jogador.

Funcionalidades:

- 🔵 Criar um menu principal do Servo Peregrino Organizador
- 🔵 Mostrar somente os módulos que estiverem instalados e disponíveis
- 🔵 Criar botões para abrir Itens, Armas, Equipamentos, Conjuntos, Armeiro, Condição das Armas e Configurações
- 🔵 Facilitar a navegação entre os módulos
- 🔵 Levar o jogador diretamente para o módulo correto já com a arma, item ou conjunto selecionado
- 🔵 Mostrar um resumo do equipamento atual do personagem
- 🔵 Mostrar a arma atualmente selecionada
- 🔵 Mostrar um resumo da condição da arma quando esse módulo estiver disponível
- 🔵 Mostrar peso/carga e alertas importantes
- 🔵 Mostrar restrições do servidor
- 🔵 Mostrar problemas de disponibilidade de itens ou peças quando houver controle de estoque
- 🔵 Mostrar custos quando houver sistema de economia
- 🔵 Criar ações integradas que utilizem vários módulos ao mesmo tempo
- 🔵 Criar um conjunto completo a partir do equipamento atual
- 🔵 Ajudar a aplicar um conjunto completo
- 🔵 Verificar disponibilidade antes de aplicar um conjunto
- 🔵 Verificar se algum item ou arma está proibido antes da aplicação
- 🔵 Oferecer atalhos como “Abrir no Armeiro” quando uma arma precisar de manutenção
- 🔵 Criar ações diferentes dependendo do contexto, como bancada, arma ou caixa selecionada
- 🔵 Reunir notificações e avisos dos módulos em um único local

**O Hub coordena as ações, mas não substitui os outros módulos.**

Exemplo:

**Nexus faz os módulos conversarem entre si.**  
**Hub faz o jogador conversar com os módulos.**

Nenhum módulo deve depender do Hub para funcionar.

---

## Items — itens e kits de itens

Responsável pelos itens e pelo conteúdo de Uniforme, Colete e Mochila.

Funcionalidades:

- ✅ Criar kit de itens
- ✅ Editar kit de itens
- ✅ Renomear kits
- ✅ Duplicar kits
- ✅ Excluir kits
- ✅ Mesclar kits
- ✅ Mesclar conteúdos de kits diferentes
- ✅ Capturar os itens que o personagem está carregando
- ✅ Capturar conteúdo do Uniforme
- ✅ Capturar conteúdo do Colete
- ✅ Capturar conteúdo da Mochila
- ✅ Catálogo automático de itens disponíveis
- ✅ Pesquisar itens
- ✅ Filtrar itens
- ✅ Organizar itens por categorias
- ✅ Adicionar item a um kit
- ✅ Adicionar item diretamente ao inventário
- ✅ Aumentar ou diminuir quantidade
- ✅ Informar quantidade manualmente
- ✅ Remover itens
- ✅ Arrastar e soltar itens entre áreas da interface
- ✅ Editar um kit antes de salvar
- ✅ Salvar kits privados
- ✅ Publicar kits
- ✅ Visualizar kits públicos
- ✅ Copiar kit público para a biblioteca privada
- ✅ Aplicar um kit inteiro
- ✅ Adicionar conteúdo de um kit ao inventário atual
- ✅ Remover do inventário os itens de um kit
- ✅ Substituir conteúdo existente por outro kit
- ✅ Limpar conteúdo de Uniforme, Colete ou Mochila
- ✅ Aplicar o máximo possível quando não houver espaço suficiente
- ✅ Aplicar uma operação somente se ela puder ser concluída por inteiro
- ✅ Simular a operação antes de alterar o inventário
- ✅ Detectar se o inventário mudou durante uma operação
- ✅ Desfazer alterações quando uma operação falhar
- ✅ Preservar a quantidade de munição existente em carregadores parcialmente utilizados
- ✅ Mostrar capacidade de Uniforme, Colete e Mochila
- ✅ Mostrar o peso/carga total do personagem
- ✅ Compartilhar kits entre jogadores com controle do servidor
- 🔵 Sincronizar kits públicos para jogadores que entrarem depois
- 🔵 Manter kits públicos após reinício do servidor
- 🔵 Respeitar listas de itens permitidos e proibidos
- 🔵 Consultar quantidade disponível em estoque
- 🔵 Consultar preços
- 🔵 Utilizar sistemas de persistência do servidor

**Items não deve controlar armas, desgaste de armas, manutenção ou economia.**

---

## Weapons — armas, montagem e configuração

Responsável pelo que a arma **é** e por como ela é montada/configurada.

Funcionalidades:

- 🔵 Criar kit de armas
- 🔵 Criar configurações de armas
- 🔵 Criar receitas de armas
- 🔵 Salvar receitas de armas
- 🔵 Validar quais acessórios podem ser usados em cada arma
- 🔵 Validar quais carregadores são compatíveis
- 🔵 Controlar encaixes de acessórios
- 🔵 Montar a configuração de uma arma
- 🔵 Trocar uma arma sem alterar o restante do equipamento do personagem
- 🔵 Alterar somente a arma desejada
- 🔵 Alterar somente os acessórios desejados
- 🔵 Dar identidade individual para cada arma
- 🔵 Criar um número de série definitivo para cada arma
- 🔵 Manter informações históricas da identidade da arma
- 🔵 Permitir persistência da identidade e configuração da arma
- 🔵 Fornecer essas informações para o Armeiro, o módulo de Condição das Armas e os conjuntos completos

**Weapons não deve calcular desgaste, sujeira, lubrificação, corrosão ou reparos.**

---

## WeaponCondition — condição, desgaste e manutenção da arma

Responsável por como a arma **está** ao longo do tempo.

Funcionalidades:

- 🔵 Manter o estado atual de cada arma
- 🔵 Controlar um único sistema responsável pela condição da arma
- 🔵 Contabilizar disparos
- 🔵 Acumular disparos sem precisar recalcular tudo a cada tiro
- 🔵 Calcular desgaste provocado pelos disparos
- 🔵 Calcular desgaste do cano
- 🔵 Calcular desgaste do ferrolho e partes móveis
- 🔵 Calcular desgaste de molas e componentes internos
- 🔵 Controlar nível de sujeira
- 🔵 Controlar lubrificação
- 🔵 Controlar corrosão
- 🔵 Calcular confiabilidade da arma
- 🔵 Detectar exposição à água
- 🔵 Registrar tempo nadando com a arma
- 🔵 Registrar tempo com a arma submersa
- 🔵 Calcular efeitos da água sem precisar verificar tudo a cada quadro do jogo
- 🔵 Controlar condição individual das peças
- 🔵 Avaliar quando uma arma precisa de manutenção
- 🔵 Calcular o resultado de uma limpeza
- 🔵 Calcular o resultado de uma lubrificação
- 🔵 Calcular o resultado de um reparo
- 🔵 Calcular o resultado da troca de uma peça
- ⚪ Considerar calor e ciclos de aquecimento
- ⚪ Considerar poeira, areia e lama
- ⚪ Permitir identificação individual de peças, caso necessário
- ⚪ Provocar panes de acordo com condição e manutenção
- 🔵 Permitir integração com sistemas de desgaste de outros mods
- 🔵 Garantir que apenas um sistema controle oficialmente a condição da mesma arma

**WeaponCondition não deve criar receitas de armas nem controlar a interface da bancada.**

---

## Armorer — Armeiro

Responsável pela bancada e pela interação do jogador com a arma.

Funcionalidades:

- 🟡 Bancada física de armeiro
- 🟡 Sessão individual de trabalho
- 🟡 Impedir duas pessoas de utilizarem a mesma bancada ao mesmo tempo
- 🟡 Visualização 3D da arma
- 🟡 Girar e inspecionar a arma
- 🟡 Montar acessórios
- 🟡 Remover acessórios
- 🟡 Testar alterações antes de confirmar
- 🟡 Confirmar alterações
- 🟡 Desfazer alterações quando necessário
- 🔵 Criar receitas de armas pela interface da bancada
- 🔵 Editar receitas
- 🔵 Salvar receitas
- 🔵 Montar uma arma utilizando uma receita
- 🔵 Inspecionar a condição da arma
- 🔵 Apresentar desgaste das peças
- 🔵 Iniciar manutenção
- 🔵 Interface para limpeza
- 🔵 Interface para lubrificação
- 🔵 Interface para diagnóstico
- 🔵 Interface para reparo
- 🔵 Trocar peças
- 🔵 Consumir peças e ferramentas do inventário
- 🔵 Consumir peças e ferramentas de caixas
- 🔵 Consumir peças do estoque da bancada
- 🔵 Consultar disponibilidade de peças
- 🔵 Consultar custo de manutenção
- 🔵 Consultar custo de reparos
- 🔵 Registrar histórico de manutenção quando o servidor oferecer esse recurso
- ⚪ Utilizar cronógrafo
- ⚪ Fazer zeragem de armas
- ⚪ Testar agrupamento dos disparos
- ⚪ Integrar um pequeno estande de testes
- ⚪ Emitir um relatório técnico da arma

Divisão importante:

- **Weapons** informa qual é a arma, sua configuração e quais peças/acessórios são compatíveis
- **WeaponCondition** informa a condição, desgaste e resultado das manutenções
- **Armorer** oferece a bancada, a interface e o fluxo usado pelo jogador

---

## Equipment — equipamentos do personagem

Responsável pela estrutura do equipamento utilizado pelo personagem.

Funcionalidades:

- 🔵 Criar kit de equipamentos
- 🔵 Salvar configuração de equipamentos
- 🔵 Definir Uniforme
- 🔵 Definir Colete
- 🔵 Definir Mochila
- 🔵 Definir Capacete
- 🔵 Definir visão noturna
- 🔵 Definir óculos/máscaras
- 🔵 Definir binóculo
- 🔵 Definir equipamentos vinculados ao personagem
- 🔵 Aplicar uma configuração de equipamentos
- 🔵 Trocar um equipamento sem alterar desnecessariamente o restante
- 🔵 Relacionar um kit de itens com o equipamento
- 🔵 Relacionar uma arma ou kit de armas
- 🔵 Verificar se o equipamento está disponível
- ⚪ Respeitar listas de equipamentos permitidos/proibidos
- ⚪ Consultar estoque
- ⚪ Salvar a configuração no servidor

**Equipment cuida da estrutura do equipamento; Items continua cuidando do conteúdo carregado.**

---

## Sets — conjuntos completos

Responsável por combinar os kits dos outros módulos.

Funcionalidades:

- 🔵 Criar conjunto completo
- 🔵 Editar conjunto
- 🔵 Duplicar conjunto
- 🔵 Excluir conjunto
- 🔵 Combinar kit de itens, kit de armas e kit de equipamentos
- 🔵 Criar configurações para funções específicas
- 🔵 Criar conjunto para Médico
- 🔵 Criar conjunto para Fuzileiro
- 🔵 Criar conjunto para Antitanque
- 🔵 Criar conjunto para Atirador designado
- 🔵 Criar conjunto para Operador
- 🔵 Aplicar um conjunto completo ao personagem
- 🔵 Verificar se os módulos necessários estão disponíveis
- 🔵 Permitir aplicação parcial quando configurado
- ⚪ Compartilhar conjuntos
- ⚪ Publicar conjuntos para outros jogadores

**Sets combina as funcionalidades existentes; não cria uma segunda versão delas.**

---

## Policy — regras de itens e equipamentos permitidos

Responsável pelas listas de conteúdo permitido ou proibido.

Funcionalidades:

- 🔵 Lista de itens permitidos
- 🔵 Lista de itens proibidos
- 🔵 Lista de armas permitidas
- 🔵 Lista de armas proibidas
- 🔵 Lista de acessórios permitidos/proibidos
- 🔵 Lista de carregadores permitidos/proibidos
- 🔵 Lista de equipamentos permitidos/proibidos
- 🔵 Criar regras por item específico
- 🔵 Criar regras por família de itens
- 🔵 Criar regras por mod de origem
- 🔵 Criar regras por categoria
- 🔵 Criar regras por marcação
- 🔵 Permitir tudo por padrão
- 🔵 Trabalhar somente com uma lista de permitidos
- 🔵 Trabalhar somente com uma lista de proibidos
- 🔵 Combinar listas de permitidos e proibidos
- 🔵 Fazer a decisão final no servidor
- 🔵 Ocultar ou bloquear itens na interface
- 🔵 Conferir novamente a regra antes de executar a ação

**Regra proposta: uma proibição específica tem prioridade sobre uma permissão genérica.**

---

## ServerIntegration — integração com sistemas do servidor

Responsável por conectar o Organizador aos sistemas já existentes no servidor.

Funcionalidades:

- 🔵 Utilizar sistema de persistência existente no servidor
- 🔵 Utilizar sistema de estoque existente
- 🔵 Utilizar sistema de economia existente
- 🔵 Consultar quantidade disponível
- 🔵 Controlar estoque global
- 🔵 Controlar estoque por facção
- 🔵 Controlar estoque por base
- 🔵 Controlar estoque por estação
- 🔵 Controlar estoque de peças do Armeiro
- 🔵 Consultar preço de compra
- 🔵 Consultar preço de venda
- 🔵 Consultar custo de manutenção
- 🔵 Consultar custo de reparo
- 🔵 Reservar itens antes de uma operação
- 🔵 Confirmar retirada somente quando a operação for concluída
- 🔵 Liberar a reserva quando uma operação falhar
- 🔵 Devolver valores quando necessário
- 🔵 Integrar bancos de dados e sistemas externos sem alterar os demais módulos

**Se o servidor não possuir estoque, economia ou persistência, o Organizador continua funcionando normalmente.**

---

## Settings — configurações do Organizador

Responsável pelas configurações e preferências gerais.

Funcionalidades:

- 🔵 Preferências da interface
- 🔵 Configurações administrativas
- 🔵 Ativar/desativar funcionalidades opcionais
- 🔵 Configurações específicas de cada módulo
- 🔵 Ativar/desativar integrações
- 🔵 Parâmetros do servidor
- 🔵 Salvar conjuntos de configurações

**Settings não deve armazenar armas, kits, estoque ou outros dados de jogo.**

---

## Adapters — compatibilidade com outros mods

Responsável por permitir integração com outros mods sem misturar código específico dentro dos módulos principais.

Funcionalidades:

- 🔵 Integração com ACE
- 🔵 Integração com CBA
- 🔵 Integração com mods externos de armas
- 🔵 Integração com mods externos de desgaste/manutenção
- 🔵 Integração com sistemas externos de economia
- 🔵 Integração com sistemas externos de persistência
- 🔵 Integração com sistemas diferentes de inventário
- 🔵 Traduzir informações de outros mods para o formato esperado pelo Organizador
- 🔵 Ativar essas integrações somente quando os mods correspondentes estiverem presentes

---

# Resumo para alinhamento entre equipes

| Status | Funcionalidade | Módulo responsável |
|---|---|---|
| 🔵 | Menu principal e navegação entre os módulos | **Hub** |
| 🔵 | Ações integradas envolvendo vários módulos | **Hub** |
| 🔵 | Resumo integrado do personagem, arma, condição e alertas | **Hub** |
| ✅ | Criar e gerenciar kits de itens | **Items** |
| ✅ | Adicionar, remover e aplicar itens no inventário | **Items** |
| 🔵 | Criar kits, configurações e receitas de armas | **Weapons** |
| 🔵 | Identidade e número de série da arma | **Weapons** |
| 🔵 | Trocar arma sem alterar o restante do equipamento | **Weapons** |
| 🔵 | Desgaste e condição da arma | **WeaponCondition** |
| 🔵 | Efeito de disparos, água e submersão | **WeaponCondition** |
| 🔵 | Condição e desgaste das peças | **WeaponCondition** |
| 🔵 | Cálculo da manutenção e reparos | **WeaponCondition** |
| 🟡 | Bancada e visualização 3D da arma | **Armorer** |
| 🟡 | Montagem de armas pela bancada | **Armorer** |
| 🔵 | Interface completa de inspeção e manutenção | **Armorer** |
| 🔵 | Configuração de Uniforme, Colete, Mochila e demais equipamentos | **Equipment** |
| 🔵 | Combinar kits completos para uma função | **Sets** |
| 🔵 | Listas de itens e armas permitidos ou proibidos | **Policy** |
| 🔵 | Estoque e quantidade disponível | **ServerIntegration** |
| 🔵 | Preços, compra, venda e custos | **ServerIntegration** |
| 🔵 | Persistência em sistemas do servidor | **ServerIntegration** |
| 🔵 | Preferências e configurações gerais | **Settings** |
| 🔵 | Integração com ACE, CBA e outros mods | **Adapters** |
| ✅ | Comunicação padronizada entre os módulos | **Nexus** |

---

## Regra para novos mods

Antes de criar uma nova funcionalidade:

1. verificar se ela já pertence a algum módulo;
2. se já pertence, utilizar a funcionalidade existente;
3. não criar outra implementação fazendo a mesma coisa;
4. se for realmente uma funcionalidade nova, decidir primeiro qual módulo será responsável por ela;
5. registrar essa decisão na documentação do projeto.

O objetivo é impedir que diferentes mods criem ações, menus, dados e sistemas duplicados para resolver o mesmo problema.
