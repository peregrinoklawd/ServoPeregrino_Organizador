# Como continuar com outra IA / outro chat

## Source of Truth

Use o repositório **`peregrinoklawd/ServoPeregrino_Organizador`**, branch `main`.

Não reconstruir o projeto a partir da memória de chats ou ZIPs se o GitHub estiver disponível.

## Prompt de continuidade sugerido

```text
Estamos continuando o projeto Arma 3 Servo Peregrino Organizador (SP_ORG).
O repositório GitHub peregrinoklawd/ServoPeregrino_Organizador é o Source of Truth.

Antes de alterar qualquer runtime, leia:
- README.md
- docs/00_STATUS_ATUAL.md
- docs/01_ARQUITETURA.md
- docs/08_LICOES_APRENDIDAS_DO_DONT.md
- docs/09_ROADMAP_E_PROXIMO_PASSO.md
- docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md
- docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md
- docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md
- machine/PROJECT_STATE.json
- machine/MODULE_MATRIX.json
- machine/FEATURE_OWNERSHIP.json

Regras obrigatórias:
- nunca reconstruir uma baseline de memória;
- toda entrega parte da baseline/source imediatamente anterior;
- preservar contratos homologados;
- um domínio tem um único módulo proprietário;
- módulos não acessam estado privado de outros módulos;
- integração ocorre por Nexus capabilities/contracts/events/results;
- Application Target e Equipment View são authorities diferentes;
- não corrigir gates históricos 516/523 alterando runtime saudável;
- não chamar Items 0.13-A de persistente/JIP;
- validar Packaging R2 no Arma antes de Items 0.13-B;
- Weapons = identidade/configuração/receitas;
- WeaponCondition = condição/desgaste/manutenção lógica;
- Armorer = bancada/Preview/UI/workflow;
- Hub = navegação/experiência integrada/orquestração; não executa lógica de domínio e é opcional;
- somente um provider de condição pode ser autoritativo por arma/sessão.
```

## Estado imediato

- Nexus 1.1 estável.
- Items 0.12 FINAL homologada manualmente.
- Items 0.13-A implementada.
- Mission Lab R3 carrega e slots funcionam.
- Packaging R2 pendente de validação runtime.
- Armorer possui baseline histórica madura, ainda não importada no monorepo.
- Weapons addon source continua integrado até 0.1-A; mission-first está homologado até **0.6-C R1 (445/445)**. **0.6-D R1 WeaponKit Draft** é a candidata ativa, com **260/260 static**, runner esperado **471** e runtime Arma pendente.
- Hub/WeaponCondition/Equipment/Sets/Policy/ServerIntegration são planejados.

## Arquivos para alterações

- runtime atual: `addons/`;
- labs: `missions/`;
- API/inventário atual: `machine/FUNCTION_INDEX.json`;
- call graph: `machine/CALL_GRAPH_EDGES.csv`;
- estado: `machine/PROJECT_STATE.json`;
- ownership: `machine/FEATURE_OWNERSHIP.json`;
- matriz modular: `machine/MODULE_MATRIX.json`;
- histórico: `docs/history/`.

## Regra de provenance

Antes de nova entrega/release registrar:
- baseline usada;
- branch/commit;
- arquivos alterados;
- razão;
- hashes;
- testes estáticos;
- testes runtime realmente executados;
- testes ainda pendentes;
- documentação/PROJECT_STATE/ownership atualizados quando necessário.

## Regra de Git

Mudanças relevantes devem preferir:
1. branch;
2. commits pequenos/coerentes;
3. PR;
4. merge após revisão;
5. atualização da documentação de continuidade no mesmo ciclo.

## Continuidade Weapons

O addon source desta PR continua em **0.1-A**; não confundir isso com a linha funcional mission-first.

Baselines mission-first homologadas:
- 0.1-B: 128/128 + 3/3 live;
- 0.2: 175/175;
- 0.3 R2: 213/213;
- 0.4 R5: 251/251;
- 0.5: 301/301;
- 0.6-A R4: 362/362, shell visual congelado;
- 0.6-B R4: 397/397, seleção/informações congeladas.

Última baseline homologada:
- **0.6-C R1 — Compatibility Selectors**;
- build `0.6.2.1-compatibility-selectors-read-only-mission-first`;
- runtime **445/445 PASS**.

Candidata ativa:
- **0.6-D R1 — WeaponKit Draft**;
- build `0.6.3.1-weaponkit-draft-local-mission-first`;
- static **260/260**;
- runtime esperado **471**;
- não iniciar 0.6-E antes de RPT + teste manual da R1.

Continuam abertos: integração mission-first -> addon/PBO, Packaging, 0.6-D..F, 0.7 aplicação slot-safe, 0.8 MP/JIP/reconnect e identidade física intrínseca.
