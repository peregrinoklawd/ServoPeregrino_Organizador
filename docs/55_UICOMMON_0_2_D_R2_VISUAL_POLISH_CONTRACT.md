# UICommon 0.2-D R2 — Shared Visual Polish Contract

Data: 06/10/2026.

## Status de entrada

A R1 executou em Arma real com:
- UICommon Foundation: 31/31;
- Items + UICommon: 16/16;
- Weapons: 594/594, 0 FAIL;
- build UICommon: `0.2.0.3-shared-visual-hpp-d1`.

A R1 é a baseline técnica da R2.

## Objetivo da R2

Fazer uma rodada deliberada de acabamento visual compartilhado em Items + Weapons sem alterar:
- domínio;
- persistência;
- busca;
- seleção;
- filtros;
- DnD;
- wheel;
- aplicação;
- draft;
- focused refresh;
- autoridade;
- IDs funcionais;
- atalhos;
- semântica de cada painel.

A R2 compartilha **aparência**, nunca comportamento.

## Contrato de performance para arredondamento

O Arma 3 não possui border-radius genérico nos controles atuais.

A R2 pode usar superfícies/texturas visuais compartilhadas somente onde o número de controles é pequeno e estável:
- quatro painéis;
- footer;
- campos de busca;
- barras de carga/capacidade;
- botões estáticos/de ação quando a implementação preservar eventos e recoloração.

É proibido adicionar múltiplos controles decorativos por:
- linha do catálogo;
- linha de equipamento;
- linha de draft;
- item virtualizado.

Motivo: nenhuma melhoria estética pode aumentar custo proporcional ao tamanho do catálogo.

## Checklist visual fechado

### 1. Superfícies / cantos
- [ ] Dar aparência de cantos suavizados/arredondados aos quatro painéis.
- [ ] Footer seguir a mesma linguagem.
- [ ] Botões principais e destrutivos receberem a mesma linguagem quando tecnicamente seguro.
- [ ] Barras de carga/capacidade receberem extremidades suavizadas.
- [ ] Não adicionar decoração por linha virtualizada.

### 2. Busca compacta
Aplicar aos quatro painéis dos dois módulos:
- [ ] fundo único;
- [ ] lupa semitransparente dentro do campo;
- [ ] botão X dentro do campo, à direita;
- [ ] campo menor em altura;
- [ ] preservar os IDCs atuais do edit e do clear;
- [ ] preservar os eventos atuais;
- [ ] recuperar espaço vertical sem alterar a semântica dos filtros/listas.

A busca global futura no header NÃO será funcional nesta R2.

### 3. MEUS KITS — somente visual
- [ ] Items: equalizar rowHeight, tipografia, seleção, padding/ritmo visual.
- [ ] Weapons: mesma gramática visual.
- [ ] Não alterar conteúdo das linhas.
- [ ] Não alterar seleção.
- [ ] Não alterar PRIVATE/PUBLIC/tipo.
- [ ] Não alterar repository/draft/lifecycle.

### 4. Títulos/vocabulário já decidido
- [ ] Items `KIT SELECIONADO` -> `ITENS DO KIT`.
- [ ] Weapons permanece `ARMAS DO KIT`.
- [ ] Items `Mostrar:` -> `Visualizar:`.
- [ ] Estado SALVO / ALTERADO / NOVO permanece separado.

### 5. Footer compartilhado
- [ ] mesma largura visual dos quatro painéis;
- [ ] Items e Weapons com mesma geometria;
- [ ] CONTEXTO / RESULTADO / HISTÓRICO em três faixas;
- [ ] HISTÓRICO com menor contraste;
- [ ] RESULTADO visualmente mais importante que HISTÓRICO;
- [ ] sem outer frame pesado;
- [ ] sem alterar strings/semântica produzidas pelos domínios.

### 6. Header / espaçamento
- [ ] preservar âncora da direita;
- [ ] manter X como extremo;
- [ ] manter operador/unidade/carga existentes;
- [ ] apenas compactar/alinhar se necessário;
- [ ] nenhuma nova função global de busca nesta R2.

### 7. Estados visuais
Padronizar tokens para:
- [ ] normal;
- [ ] hover/focus;
- [ ] selected;
- [ ] disabled;
- [ ] destructive;
- [ ] altered/dirty.

Os estados continuam decididos pelo módulo consumidor.

### 8. Melhorias já registradas que entram agora
- [ ] mensagem amigável de build do catálogo Items, somente se o caminho atual já expuser um feedback equivalente e a mudança for apenas de texto;
- [ ] preservar preview keep-aspect;
- [ ] preservar tooltip e ghost atuais sem refatoração;
- [ ] preservar destaque ALTERADO já existente onde implementado.

## Explicitamente fora da R2

- busca global funcional no header;
- mudança de comportamento de qualquer linha;
- sincronização de pesquisas;
- novo tooltip architecture;
- alteração do ghost/DnD;
- Preview 3D;
- aplicação física Weapons 0.7;
- comparação funcional Draft x Equipado;
- redesign de domínio;
- cache de compatibilidade de armas.

## Não regressão obrigatória

Runtime:
- UICommon: 31/31, 0 FAIL;
- Items + UICommon: 16/16, 0 FAIL;
- Weapons: 594/594, 0 FAIL.

Manual:
- buscas mantêm escopo atual;
- wheel/slider mantêm comportamento;
- DnD Items permanece igual;
- botões continuam acionando as mesmas ações;
- filtros continuam independentes;
- Catalog-to-Draft Weapons continua Draft + Catalog focused, sem FULL;
- UI legível em ultrawide;
- nenhuma linha perde informação ou ação.

## Critério de aceite visual

A R2 só pode ser congelada se:
1. o usuário aprovar a aparência de Items e Weapons;
2. as buscas compactas não cortarem texto;
3. os quatro painéis mantiverem alinhamento/simetria;
4. MEUS KITS estiver visualmente convergente sem mudança semântica;
5. footer tiver largura e hierarquia coerentes;
6. qualquer arredondamento não gerar stutter/queda perceptível;
7. todas as suítes automáticas terminarem com 0 FAIL.


## Implementação candidata

Commits:
- escopo: `1230edac8af190e831aa38483c121db10c4a1221`;
- primitives UICommon: `559b5fb7dc5f308ef797b2c4ed87b35f36f5ec00`;
- consumers Items/Weapons: `002ae145ec94defa59a66d17e775861823c91033`.

Build:
`0.2.0.4-shared-visual-polish-d2`.

Static invariants confirmados:
- UICommon HPP addon/mission parity;
- UICommon tests addon/mission parity;
- Items HPP/script/DnD/refresh addon/mission parity;
- zero domínio Items/Weapons no HPP compartilhado;
- CT_CONTROLS_TABLE usa ButtonFlat, sem arredondamento por linha;
- hit-test Items continua nos IDCs 2088/4088;
- visual arredondado Items usa IDCs separados 2089/4089;
- todos os IDCs de busca/clear foram preservados;
- comparação de eventos contra R1: **52/52 Items** e **47/47 Weapons** sem mudança de action/onKeyUp/onLBSelChanged/onLBDblClick;
- footer Weapons passa a ocupar x=.012 / w=.976, igual ao span dos quatro painéis;
- P4 Weapons move somente a apresentação: busca no topo e Visualizar abaixo;
- nenhuma busca global de header foi criada.

Runtime continua pendente.


## Resultado real da R2 — 06/10/2026

Automático:
- UICommon 35/35;
- Items + UICommon 16/16;
- Weapons 594/594, 0 FAIL.

Manual:
- buscas: aprovadas;
- linhas MEUS KITS: convergência aprovada;
- funções/DnD/barras: aprovados;
- footer: estrutura aprovada, Histórico com contraste insuficiente;
- acessórios Weapons: grandes demais;
- títulos Weapons: inconsistentes;
- cartões inferiores Weapons: desalinhados;
- cantos: **REPROVADOS**.

A textura `RscShortcutButton\normal_ca.paa` apenas criou sombra/gradiente. Não produziu recorte geométrico transparente perceptível nos painéis ou botões.

Conclusão: R2 funcionalmente verde, mas não homologada como fim da 0.2-D.
