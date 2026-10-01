# UICommon 0.1 — arquitetura, modularidade e estratégia de migração

Data: 2026-10-01.

## Decisão

Criar um addon técnico independente:

`ServoPeregrino_Organizador_UICommon.pbo`

Ele será distribuído no mesmo pacote/core do Nexus, mas NÃO será incorporado ao `Nexus.pbo`.

Distribuição alvo:

```
@ServoPeregrino_Core/
  addons/
    ServoPeregrino_Organizador_Nexus.pbo
    ServoPeregrino_Organizador_UICommon.pbo
```

Motivo:
- instalação simples;
- ownership técnico separado;
- versionamento independente;
- ausência de acoplamento UI dentro do Nexus;
- reutilização por múltiplas interfaces;
- módulos continuam independentes entre si.

## Dependências

Direção permitida:

```
UICommon -> Nexus
Items    -> Nexus + UICommon
Weapons  -> Nexus + UICommon
Armorer  -> Nexus + UICommon   (quando aplicável)
```

Proibido:
- Nexus -> UICommon;
- Items -> Weapons;
- Weapons -> Items;
- UICommon -> Items;
- UICommon -> Weapons;
- lógica de domínio dentro de UICommon.

Módulos sem interface não precisam declarar UICommon apenas porque o PBO está no pacote Core.

## Princípio

Compartilhar infraestrutura e gramática de UI; nunca compartilhar estado privado de domínio.

UICommon pode possuir:
- tokens visuais;
- geometria/spacing;
- controles genéricos;
- busca genérica;
- virtualização/list window;
- row pool;
- scroll/wheel;
- seleção/foco;
- tooltips genéricos;
- pointer helpers;
- drag visual;
- drop-target geométrico;
- feedback visual;
- rodapé;
- invalidation/focused refresh;
- helpers de structured text;
- instrumentação de performance.

UICommon NÃO possui:
- ItemKit;
- WeaponKit;
- WeaponRecipe;
- compatibilidade de armas;
- capacidade de container;
- Application Engine;
- inventário;
- persistence de kits;
- condição/desgaste;
- aplicação física específica.

## Performance como contrato

Interação local deve invalidar somente a superfície necessária.

Exemplos:
- wheel/slider Catálogo -> P3;
- mudança de visualização física -> P4;
- mutação de Draft -> P2;
- troca de kit -> refresh de contexto mais amplo.

Listas grandes usam controles reutilizáveis/row pool em vez de criar e destruir controles a cada scroll.

Projeções e metadados caros devem permanecer cacheados enquanto a origem não mudar.

## Processo de migração

### Gate 0 — congelamento
- Items: última baseline PBO MP informada como homologada, com Public Loadouts pendentes.
- Weapons: requisitos 0.6-E R2 congelados.
- nenhuma feature nova nos dois módulos durante a extração inicial.

### Gate 1 — UICommon foundation
Criar addon isolado com:
- lifecycle/build/runtime;
- capability própria;
- theme tokens;
- helpers puros iniciais;
- testes próprios.

Nenhuma dependência de Items/Weapons.

### Gate 2 — Items equivalence
Extrair/adaptar infraestrutura genérica de Items.
Não alterar UX deliberadamente.
Rodar:
- automático;
- checklist mestre de regressão;
- RPT;
- performance;
- SP/MP conforme aplicável.

Só avançar se Items ficar igual ou melhor.

### Gate 3 — Weapons 0.6-E R2 sobre UICommon
Migrar a UI mission-first de Weapons.
Implementar requisitos congelados de R2.
Validar runtime/manual/performance.

### Gate 4 — convergência visual de Items
Aplicar em Items apenas os padrões compartilhados já validados:
- terminologia;
- status;
- footer;
- mensagens;
- alinhamentos;
- outras decisões aprovadas.

## Mission-first + PBO

Serão mantidos dois gates usando os mesmos fontes/contratos:

1. Mission Lab — desenvolvimento rápido.
2. Addon/PBO — validação de empacotamento e runtime real.

Não manter duas implementações independentes.

## Missão conjunta planejada

`SP_ORG_Items_Weapons_UI_Lab.VR`

Objetivo:
- abrir Items;
- fechar;
- abrir Weapons;
- comparar lado a lado na mesma sessão;
- executar AUTO UICommon;
- executar AUTO Items;
- executar AUTO Weapons;
- registrar métricas/RPT comparáveis.

A missão é laboratório, não owner de domínio.

## Versionamento inicial

UICommon inicia como 0.1 experimental.

Não publicar API v1 estável nesta etapa.

Consumidores devem declarar a versão mínima quando a integração real começar.
