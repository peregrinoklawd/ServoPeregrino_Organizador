# ServoPeregrino_Organizador_Hub

**STATUS: SLOT DE MÓDULO — planejado.**

O Hub será a **Central do Organizador**: camada opcional de navegação e integração voltada ao jogador.

## Responsabilidade

- menu principal do SP_ORG;
- descobrir quais módulos estão disponíveis;
- mostrar somente funcionalidades realmente instaladas;
- navegar entre módulos;
- encaminhar contexto entre módulos;
- reunir alertas e informações resumidas;
- orquestrar ações que envolvem vários módulos.

## Regra

O Hub **coordena; não executa lógica de domínio**.

Exemplos:
- "Criar kit de itens" abre/aciona Items;
- "Ver condição da arma" usa WeaponCondition;
- "Abrir no Armeiro" usa Armorer;
- "Salvar conjunto completo" coordena Items + Weapons + Equipment + Sets.

Nenhum módulo de domínio deve depender do Hub para funcionar.

Ver:
- `docs/modules/Hub.md`
- `docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md`
- `machine/FEATURE_OWNERSHIP.json`
