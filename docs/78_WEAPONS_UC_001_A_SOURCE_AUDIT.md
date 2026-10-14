# Weapons UC-001-A — Auditoria de Fontes e Matriz por Slot

Data: 14/10/2026. Branch: `feature/weapons-uc-001-a-compatibility-audit`.
Base **imóvel**: `baseline/weapons-0.7-e-r5-homologated` @ `52dd24af4f54ca9f3c9c6832f55ffdf772ff0314`.
Linha 0.7-E R5: `1446/1446` automático e manual aprovado no Arma; D2 R1 também preservada.

## Objetivo e limites

Executar laboratório **somente leitura** que registra divergências reais de fontes de compatibilidade para armas efetivamente equipadas (PRIMARY, HANDGUN, SECONDARY), com matrizes por slot:
- anexos: engine `compatibleItems [weapon, MuzzleSlot/PointerSlot/CowsSlot/UnderBarrelSlot]` versus API documentada `[weapon, "muzzle"/"pointer"/"optic"/"bipod"] call CBA_fnc_compatibleItems`;
- magazines: `compatibleMagazines weapon` e `compatibleMagazines [weapon,muzzle]` versus `CBA_fnc_compatibleMagazines` com contratos comprovados; apontar magazineWells e muzzles;
- variantes: `baseWeapon` e classe efetivamente observada, sem promover classes derivadas a equivalência sem teste;
- ACE/ACE Arsenal: apontar presença do addon e eventuais APIs públicas verificadas, sem inferir que há uma API universal. Ainda não é prova de compatibilidade com ACE Arsenal.

**Nenhum resolver de produção nesta fase; nenhuma união automática aplicada**. Os itens encontrados apenas por CBA permanecem informação diagnóstica em slots que ainda usam engine vanilla. O UnderBarrel da R4 mantém seu comportamento de produção.

## Estratégia de segurança

1. Não adicionar, remover ou aplicar itens/armas; não alterar `getUnitLoadout` do jogador, do alvo, repositório de kits, drafts ou estado da interface.
2. Não criar dummy para comparação física na UC-001-A. Laboratório histórico R3 de dummy continua separado.
3. Disponibilidade de CBA verificada via `isNil`; fallback vanilla seguro quando ausente.
4. Normalizar somente listas diagnósticas válidas (CfgWeapons ou CfgMagazines); preservar contagem bruta e classe física. Não tratar todas as classes do BIS Arsenal como compatíveis por slot.
5. Logs limitados e explicáveis: por categoria indicar contagens e **amostra reduzida** de diferenças, nunca despejar catálogos inteiros. RPT pode ser enviado para auditoria.
6. A coleta por armas atualmente equipadas não significa varredura de *todas* as armas do modset. Cobertura posterior: vanilla, CBA, ACE+CBA, MCC/RHS e armas com muzzle secundário.
7. Preservar baseline UICommon 0.2, Items e Weapons D2/E R5. Nenhum addon/PBO, Undo, MP/JIP, integração física ou alteração na regra de `CfgRemoteExec`.

## Gates UC-001-A

- CI valida arquivos, registro da função, contratos estáticos e pacote mission-first.
- Arma real: a ação `SP_ORG LAB - AUDITAR FONTES UC-001-A` emite `UC001A_SOURCE`, `UC001A_MAGAZINE` e `UC001A_SUMMARY`, identificando categorias, classes, fontes disponíveis e diferenças.
- Rodar também testes R5 cumulativos **1446 PASS / 0 FAIL / 0 BLOCKED** sem alterar semântica.
- Captura do loadout antes/depois do diagnóstico deve provar imutabilidade; testes manuais com armas de PRIMARY, HANDGUN e SECONDARY.
- Nenhuma conclusão de `UC-001-B` ou `compatibilidade completa` antes da auditoria RPT real.

## Fontes técnicas (contratos públicos)

- https://community.bistudio.com/wiki/compatibleItems
- https://community.bistudio.com/wiki/compatibleMagazines
- https://cbateam.github.io/CBA_A3/docs/files/jr/fnc_compatibleItems-sqf.html
- https://cbateam.github.io/CBA_A3/docs/files/common/fnc_compatibleMagazines-sqf.html
- https://community.bistudio.com/wiki/Arma_3:_Weapon_Config_Guidelines

## Backlog paralelo

WUX-002 (adicionar magazine ao colete) e WUX-003 (filtros por ícones) em `docs/77_WEAPONS_BACKLOG_AMMO_VEST_ICON_FILTERS.md`, **fora desta candidata**.

## Packaging/CI da candidata UC-001-A R1 (14/10/2026)

- GitHub Actions: https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38636973136 — **SUCCESS**.
- Commit mission-first empacotado: `40ccec1dd6c2e620ade61fb161814e2ff1a5a52b`.
- Validador estático: **35 PASS / 0 FAIL** (não é compilador SQF nem execução Arma).
- ZIP interno: `SP_ORG_Weapons_UC_001_A_Source_Audit_R1.zip`; SHA256: `f6775f1991e6a920910152e9d409d7e30e73b342ca92457162afb88d04979e61`.
- Artifact oficial: https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38636973136/artifacts/11929195446 (`SP_ORG_UI_Lab`, contém ZIP da missão e SHA256.txt).
- **RUNTIME ARMA NÃO EXECUTADO**: R5 1446/1446 deve regredir e auditoria UC-001-A requer RPT real; nenhum gate de compatibilidade completa homologado.
