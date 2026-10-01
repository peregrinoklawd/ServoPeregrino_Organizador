# Weapons 0.6-E R2 — requisitos de UI congelados antes do UICommon

Data: 2026-10-01.

## Estado

A 0.6-E R1 fechou 536/536 AUTO, mas foi superada por feedback manual de UX.

A 0.6-E R2 existe como especificação/candidata, mas sua implementação final fica temporariamente congelada enquanto UICommon 0.1 é criado.

Isso NÃO cancela, reduz ou substitui os requisitos de R2.

## Regra

Weapons não avança para 0.6-F, 0.7 ou novas features antes do gate UICommon + runtime/manual da R2.

## Requisitos obrigatórios de R2

### Estrutura
Quatro painéis:
1. MEUS KITS DE ARMAS;
2. KIT SELECIONADO / RASCUNHO;
3. CATÁLOGO DE ARMAS;
4. CONTEÚDO DO EQUIPAMENTO.

A linguagem visual deve convergir com Items sem copiar lógica de domínio.

### P1 — MEUS KITS DE ARMAS
Ordem:
- NOVO;
- DUPLICAR;
- EXCLUIR;
- PUBLICAR.

RENOMEAR não fica em P1.

PUBLICAR permanece reservado enquanto não houver biblioteca pública real de Weapons.

### P2 — KIT SELECIONADO / RASCUNHO
- nome inline na faixa de título;
- status SALVO / ALTERADO / NOVO;
- busca abaixo do título;
- ações no topo:
  - SALVAR;
  - SALVAR COMO NOVO;
  - DESCARTAR;
  - LIMPAR;
- destrutivas com hierarquia visual apropriada;
- rename confirmado por SALVAR;
- focused refresh não pode apagar texto digitado.

### P3 — CATÁLOGO DE ARMAS
- lista contínua virtualizada;
- wheel + scrollbar/slider;
- busca;
- filtros por slot;
- filtros player-facing:
  - Todos;
  - Arma;
  - Óticas;
  - Apontadores;
  - Bipés;
  - Carregadores;
  - Empunhaduras;
- linha com setas nas bordas;
- esquerda aplica ao Draft/Rascunho;
- botão grande EQUIPAR NO RASCUNHO com a mesma semântica;
- direita permanece visual/reservada para aplicação física 0.7;
- compatibilidade continua derivada da engine, sem whitelist inventada.

A ação lógica deve aceitar:
- WEAPON;
- OPTIC;
- POINTER;
- BIPOD/GRIP;
- MAGAZINE.

### P4 — CONTEÚDO DO EQUIPAMENTO
- read-only até o gate físico 0.7;
- busca/contexto conforme candidata R2;
- rótulo Visualizar:;
- Principal / Porte / Secundária alinhados na mesma faixa;
- arma equipada e attachments observados;
- não antecipar aplicação física para obter simetria artificial.

### Fluxo de criação
NOVO prepara RASCUNHO NOVO aguardando arma.

Seleção de arma no Catálogo + seta esquerda/EQUIPAR NO RASCUNHO cria/forma WeaponKit válido e selecionado.

Eliminar o fluxo ruim em que o usuário precisava saltar entre Catálogo e P1 apenas para criar.

### Footer
- sem grande outer frame;
- três faixas alinhadas:
  - CONTEXTO;
  - RESULTADO;
  - HISTÓRICO;
- Histórico com contraste suficiente sem competir com Resultado.

### Performance
Preservar as lições da 0.6-D R3:
- focused refresh;
- cache de projeção/filtro;
- nada de full refresh em cada wheel/slider;
- row reuse;
- instrumentar tempo por refresh;
- gate humano de fluidez é obrigatório.

O retorno ao padrão ~246–254 ms por interação observado na R2 histórica é regressão bloqueadora.

## Limites de domínio
- R2 não aplica loadout físico.
- aplicação slot-safe permanece 0.7.
- MP authority/JIP/reconnect permanece 0.8.
- UICommon não toma ownership de WeaponKit/Recipe/compatibilidade.
