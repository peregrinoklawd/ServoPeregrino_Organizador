# Weapons 0.1-B — WeaponInstance Lifecycle / Event-Delta Evidence

## Estado

**MISSION-FIRST FUNCTIONAL GATE: APPROVED (single-player).**

- AUTO TEST final: **128/128 PASS**.
- Live Take/Put manual: **3/3 PASS**.
- PBO Packaging: **DEFERRED**.
- Multiplayer/JIP/reconnect: **DEFERRED**.
- Identidade física intrínseca: **NOT CLAIMED**.

Esta entrega foi desenvolvida e homologada como laboratório mission-first derivado da 0.1-A. O addon source integrado na branch ainda precisa receber esse delta antes de qualquer publicação de PBO correspondente.

## Problema investigado

Arma 3 expõe eventos e snapshots suficientes para observar movimentações e configurações, mas a evidência utilizada aqui não fornece um identificador físico individual universal para uma arma em todos os carriers. Portanto, a solução não usa classname, fingerprint, índice de cargo ou posição como serial.

## Estratégia aprovada

`EVENT_DELTA_EVIDENCE_CANDIDATE` classifica a evidência de uma transição:

| Evidência | Resultado | Significado |
|---|---|---|
| exatamente um candidato antes/depois | `CORRELATED` | continuidade lógica sustentada pela transição; não prova física intrínseca |
| mais de um candidato indistinguível | `AMBIGUOUS` | o sistema se recusa a escolher um instanceId |
| delta ausente/insuficiente | `UNPROVEN` | nenhuma continuidade é assumida |

Invariante: **`physicalIdentityProven=false` em todos os casos**.

## Gate manual aprovado

1. B/C: caixa com uma MX; jogador faz TAKE 1→0 → `CORRELATED/1`.
2. B/C: jogador devolve a mesma MX; PUT 0→1 → `CORRELATED/1`.
3. E: caixa com duas MX idênticas; jogador retira uma; TAKE 2→1 → `AMBIGUOUS/2`, `instanceId=""`.

O terceiro passo é o principal gate: mesmo existindo dois IDs lógicos candidatos, o sistema não atribui arbitrariamente um deles à arma retirada.

## Lições incorporadas

- Snapshot vazio é estado válido. `beforeObservations=[]` não significa “snapshot ausente”; presença passou a ser controlada explicitamente por `beforeCaptured`.
- Eventos Take/Put são evidência de transição, não prova de identidade física universal.
- Ammo diferente não pode ser usado para “resolver” duas configurações físicas idênticas quando ammo não pertence a WeaponConfiguration.
- A estratégia deve falhar conservadoramente para AMBIGUOUS/UNPROVEN em vez de inventar binding.

## Limites

Não fecha identidade universal, transferência A→B em multiplayer, JIP/reconnect, concorrência remota, persistência ou recuperação pós-restart. Nenhum contrato `weapons.instance.v1` foi congelado.

## Próxima entrega concluída depois desta

0.2 — WeaponConfiguration. Ver [23_WEAPONS_0_2_WEAPON_CONFIGURATION.md](23_WEAPONS_0_2_WEAPON_CONFIGURATION.md).
