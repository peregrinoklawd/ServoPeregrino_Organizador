# Índice de documentação SP_ORG

## Novos registros canônicos — 22/10/2026

- [**Policy — módulo opcional e contrato funcional**](modules/Policy.md).
- [**Projeto Policy Editor — interface para montar/importar/exportar listas**](projects/policy-editor/README.md).
- [**Roadmap Policy P0–P7**](projects/policy-editor/ROADMAP.md).
- [**Backlog de 18 ícones para Weapons e outros módulos**](72_BACKLOG_ICONOGRAFIA_MODULOS.md).

**Última decisão:** continuar com **botões de texto**, sem integrar os PNGs já aprovados de Uniforme/Colete/Mochila. Estes arquivos permanecem guardados e verificados em `assets/ui/icons/items/approved/`. O Policy Editor é futuro; nenhuma whitelist/blacklist foi implementada no runtime. A baseline R2.2 homologada permanece congelada.

## Retomada Items — 21/10/2026

Para continuar **Items** a partir da UICommon 0.2 FINAL homologada em 07/10, **comece por**:
- [Handoff Items 21/10](ITEMS_CONTINUIDADE_RETOMADA_20261021.md)
- [Roadmap de retomada Items](ITEMS_ROADMAP_RETOMADA_20261021.md)
- [Contrato de regressão Items](30_ITEMS_UI_REGRESSION_CONTRACT.md)
- [CAPTURAR — especificação futura](64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md)
- `../machine/ITEMS_CONTINUITY_20261021.json` (estado por módulo)

Esta instrução é específica à branch `feature/items-0.13-retomada-20261021`; o catálogo geral abaixo contém marcos históricos e demais módulos.

Comece por:

1. `00_STATUS_ATUAL.md`
2. `01_ARQUITETURA.md`
3. `02_CONFIGURACAO_INSTALACAO_BUILD.md`
4. `03_API_NEXUS.md`
5. `04_API_ITEMS.md`
6. `05_MODELOS_DE_DADOS_E_CONTRATOS.md`
7. `06_MULTIPLAYER_E_AUTORIDADE_0_13_A.md`
8. `07_TESTES_E_HOMOLOGACAO.md`
9. `08_LICOES_APRENDIDAS_DO_DONT.md`
10. `09_ROADMAP_E_PROXIMO_PASSO.md`
11. `10_CONTINUAR_COM_IA.md`
12. `11_GIT_REPOSITORIO_E_VERSIONAMENTO.md`
13. `12_CONTRATOS_UI_NAO_REGREDIR.md`
14. `13_PACKAGING_INCIDENT_2026_09_25.md`
15. `14_API_REFERENCIA_AUTOGERADA.md`
16. `15_CONSTANTES_E_NAMESPACE.md`
17. **`16_BANCO_DE_IDEIAS_E_CONCEITOS.md`** — decisões, ideias, módulos futuros, providers, policies e Armorer 2.x.
18. `17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md` — divisão Weapons/WeaponCondition/Armorer, identidade, desgaste, ambiente e peças.
19. **`18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`** — funcionalidades por módulo e regra anti-duplicação.
20. **`19_VISAO_FUNCIONAL_COMPARTILHAVEL.md`** — resumo de funcionalidades por módulo pronto para compartilhar com outras equipes.
21. `20_HUB_ARQUITETURA_E_INTEGRACAO.md` — Central do Organizador, navegação dinâmica e orquestração entre módulos.

Histórico: `history/`. Estado global legível por máquina: `../machine/PROJECT_STATE.json`.
