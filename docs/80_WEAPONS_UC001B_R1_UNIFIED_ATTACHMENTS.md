# Weapons UC-001-B R1 — Resolver unificado de acessórios (0.7-F)

Data: 14/10/2026. Candidata mission-first, não homologada no Arma.
Branch: `feature/weapons-uc-001-b-unified-attachments`.
Proveniência: UC-001-A (RPT PRIMARY/HANDGUN PASS, SECONDARY pendente), derivada da baseline homologada `baseline/weapons-0.7-e-r5-homologated` @ `52dd24af`.
R5 baseline: `1446/1446, 0 FAIL/BLOCKED`; nenhuma alteração nela ou na D2.

## Problema

A UC-001-A comparou Arma e CBA por slot. No MCC_RD704_AFG houve 44 opções vanilla vs 87 no CBA para UnderBarrelSlot, sem divergências observadas em optic/muzzle/pointer no conjunto testado. Não generalizar a ausência de divergência para todo modset. Os consumidores de Weapons ainda acessavam engine/código R4 de maneira independente.

## Implementação R1

1. `fn_resolveAttachmentCompatibility.sqf` fornece uma única consulta por `weaponClass` e pelos campos `muzzle/pointer/optic/bipod`.
2. Para cada campo, coleta `compatibleItems` da engine com `MuzzleSlot/PointerSlot/CowsSlot/UnderBarrelSlot`, incluindo entradas engine com classe válida; opcionalmente consulta `CBA_fnc_compatibleItems [weapon,"muzzle"/"pointer"/"optic"/"bipod"]`. Somente classes `CfgWeapons` públicas (`scope>=2`) entram **adicionalmente** pelo CBA; deduplicação case-insensitive.
3. Resultado tipado: arma, `slots`, `sourcesBySlot`, contagens e origens, `cbaAddedTotal`, `resolutionMode`; `COMPAT_SOURCE_DIFF` e `COMPAT_RESOLVE` no RPT. Cache limitado ao `missionNamespace` e chave de arma do modset fixo; sem recalcular na rolagem.
4. `fn_getWeaponCompatibility` usa o resolvedor para os 4 slots e mantém a descoberta de magazines e variantes anterior, para UC-001-C.
5. `fn_validateWeaponConfigurationSemantic` valida os 4 campos pela mesma fonte. Selectors e catálogo seguem `fn_getWeaponCompatibility`; captura e `Recipe` seguem os validadores semânticos existentes.
6. `fn_getUnderbarrelCompatibility` permanece como adaptador público delegado ao resolvedor, preservando o contrato R4 e regressões antigas.
7. A autoridade física **não foi alterada**: aplicação Plan/Snapshot/Apply/Validate/Rollback D2 continua sendo o veto definitivo. Não inserir anexos à força.
8. Nenhuma whitelist por mod, nenhuma mutação em Items/Nexus/UICommon. ACE Arsenal é apenas prova de presença no diagnóstico A, **não API universal presumida**.
9. Não alterar magazines/magWells, persistência ou MP nesta entrega.

## Validação

- CI própria UC-001-B estática e artefato mission-first.
- Ação `SP_ORG LAB - TESTAR UC-001-B R1` executa o acumulado R5, depois verifica no Arma:
  * engine+CBA por quatro slots em rifle, pistola e launcher;
  * catálogo e resolvedor iguais por campo;
  * validade semântica das classes resolvidas;
  * compatibilidade antiga do bipé;
  * cache da missão, rejeição de classe inválida;
  * nenhum WeaponKit ou loadout do jogador modificado pela parte B.
- Meta do runner cumulativo: **1516 PASS / 0 FAIL / 0 BLOCKED** (R5 1446 + B 70). Se a contagem mudar, não falsificar o resultado: auditar asserções e atualizar metadados/teste com evidência.
- Teste manual obrigatório para confirmar seleção e captura de acessórios MCC/TierOne/RHS e preservação de outras armas, com RPT.
- Repetir, quando puder, diagnóstico UC-001-A no slot SECONDARY como dívida de cobertura, mas **não bloquear o início da R1** por isso.
- Usar mods do operador, sem carregar PBO SP_ORG, mantendo interface fechada durante o runner.
- Falhas em addons externos: classificar a origem e não mascarar regressões SP_ORG.

## Próximas rodadas / fora do escopo

- UC-001-B R2: reproduções de equivalência com modset, correções com evidência, tratamento de classes fisicamente não equipáveis e medição de performance, eventual adaptação ACE por contrato comprovado.
- UC-001-C: magazines, magazine wells e subclasses/muzzles.
- UC-001-D: e2e real/performance.
- WST-001: persistência de kits no perfil para atravessar missões; nova entrega antes da distribuição definitiva, fora do resolvedor B.
- WUX-002 carregadores ao colete; WUX-003 filtros iconográficos, mantidos em backlog.
- MP/JIP, PBO, Undo e merge main continuam adiados.

Referências técnicas:
https://community.bistudio.com/wiki/compatibleItems
https://cbateam.github.io/CBA_A3/docs/files/jr/fnc_compatibleItems-sqf.html
