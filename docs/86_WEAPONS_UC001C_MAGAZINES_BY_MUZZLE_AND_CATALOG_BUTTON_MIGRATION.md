# Weapons UC-001-C — Proposta para munição por cano e botões explícitos de catálogo

**Decisão e observação do operador:** 21/10/2026. **Status:** PROPOSTA / CONCEPÇÃO; **NÃO IMPLEMENTADA**. UC-001-C R1 permanece candidata auto-testada no Arma (1589/1589 PASS, sem gate físico multi-muzzle conclusivo), PR #12 Draft; UC-001-B R2 permanece homologada no baseline `baseline/weapons-uc001b-r2-approved`, lacuna MCC/CBA-only física expressamente diferida.

## 1. Problema reproduzido manualmente

O operador confirmou que, em arma com lançador acoplado ou vários muzzles, a lista única de **Carregador** mistura os carregadores principais e as granadas/munições do lançador. A UX não permite destinar explicitamente a munição ao cano correto.

**Causa verificada no Git:**
- `weapons/functions/catalog/fn_resolveMagazineCompatibility.sqf` resolve corretamente `magazinesByMuzzle` e `muzzles`, mas também produz `magazines` agregadas.
- `weapons/functions/ui/fn_buildCompatibilitySelectorModel.sqf` alimenta um único seletor `magazineClass` com esse agregado.
- `weapons/functions/recipe/fn_validateWeaponRecipeSemantic.sqf` valida só contra o agregado, não contra um muzzle.
- `weapons/functions/application/fn_buildApplicationTargetLoadout.sqf` escreve `magazineClass` no **campo primaryMagazine** e apenas preserva o **secondaryMagazine** em armas equivalentes.
- A Recipe `0.4-recipe-candidate` tem esquema **FECHADO** (`schemaVersion`, `configuration`, `magazineClass`); ampliar UI sem versionar contrato de domínio não resolveria.
- `fn_prepareObservedCaptureRecipe` e `fn_captureEquippedWeaponToDraft` representam somente magazine principal na Recipe; preservar captura completa de segundo muzzle exige contrato novo.

**Fatos de motor:** `compatibleMagazines weapon` reúne magazines de todos os canos; `compatibleMagazines [weapon,muzzle]` discrimina. `getUnitLoadout`/ `setUnitLoadout` usam `[weapon,silencer,pointer,optic,primaryMagazine,secondaryMagazine,bipod]` por row. Fontes:
- https://community.bistudio.com/wiki/compatibleMagazines
- https://community.bistudio.com/wiki/Unit_Loadout_Array
- https://community.bistudio.com/wiki/Arma_3:_Weapon_Config_Guidelines

## 2. Solução de UX preferida: seletor contextual adicional em ARMAS DO KIT

Não criar painel inteiro. Mostrar:
- **MX normal, pistola:** apenas `Carregador`.
- **MX GL, Katiba GL, rifle de mod com lançador:** `Carregador do fuzil` (magazines do muzzle principal) + `Munição do lançador` (magazines do muzzle secundário).
- **NLAW/Titan/lançador portátil independente com muzzle único:** apenas `Munição do lançador`. **SECONDARY como categoria de arma NÃO significa muzzle secundário.**
- **Arma de mod com shotgun acoplada ou outro segundo cano:** mesma lógica genérica, mas usar o `displayName` do muzzle; fallback `Munição secundária`, jamais supor por substring de classname que todo segundo muzzle lança granadas.
- **Mais de dois canos carregáveis:** descoberta/diagnóstico dinâmico; bloquear aplicação física genérica se não couber no mapeamento de 2 campos físicos do row. Não prometer apoio automático.

**Visibilidade:** mostrar o seletor adicional somente se houver um segundo muzzle com magazines compatíveis públicos, identificado por `muzzleId`; ocultá-lo se a arma não suporta munições independentes no outro cano. O catálogo pode continuar uma lista global para busca, mas precisa exibir e enviar `muzzleId` correto ao acionar botões de adicionar.

**Estados do seletor:** distinguir `MANTER` (não altera munição instalada), `DESCARREGAR` (remoção solicitada), `SELECIONAR classe` (equipar a classe). Não interpretar string vazia indistintamente como `preservar` e `limpar`. A política se aplicará independentemente ao segundo cano; a política atual de rounds e postvalidation D2 deve ser preservada até haver teste direcionado.

## 3. Contrato técnico futuro (proposta)

1. Criar nova versão de `WeaponRecipe` com o campo legado `magazineClass` reservado **somente ao muzzle primário** e uma estrutura explícita `secondaryMagazineSelection={muzzleId,policy:KEEP|CLEAR|SET,magazineClass}`. Nome/schema final a decidir no design; não adicionar diretamente à v0.4.
2. `magazinesByMuzzle` será fonte canônica de ambos os seletores, validação de Recipe e aplicação; não usar `magazines` agregado como autorização de qualquer slot. No caso de uma classe compatível com vários muzzles, o **destino deve ser explícito**; nunca inferir apenas por classe.
3. Migração/camada de compatibilidade para WeaponKits v0.4: preservar significado do carregador principal, não descarregar lançador por omissão, proteger família/arma alterada, adicionar novos fingerprints/normalização/validação/repositório apenas na versão nova. Teste de roundtrip, comparação e captura de loadout físico, incluindo `secondaryMagazine`.
4. Alterar o plano D2 para escrever magazines carregadas no índice 4 (**primary**) e índice 5 (**secondary**) de maneira independente e validada. `SET` respeita capacidade e política de quantidade; `KEEP` respeita classe e rounds observados apenas onde compatível; `CLEAR` descarrega somente muzzle alvo; rejeitar mapeamentos não suportados **antes da mutação**, pós-validar e restaurar todo o snapshot se houver falha.
5. **Magazine carregada no lançador** é distinta de munição reserva em colete/mochila; a funcionalidade `WUX-002` continua fora do escopo.

## 4. Decisão adicional confirmada: migrar ação do nome para os botões por linha

O operador pediu **reaproveitar a implementação existente `CATALOG_TO_DRAFT`** quando forem criadas as setas/botões por linha no `CATÁLOGO DE ARMAS` (padrão Items). **Depois** dos botões implementados e testados:
- Remover a ação `CATALOG_TO_DRAFT` do nome de arma em `ARMAS DO KIT`, `WeaponValue` IDC 2021, `weapons/ui/weapons_dialog.hpp`; nome deve identificar e/ou selecionar, nunca equipar sem ação clara.
- Revisar `onLBDblClick` de `CatalogList` IDC 3120, atualmente também chama `CATALOG_TO_DRAFT`, porque a regra desejada é **apenas botões dentro do Catálogo transferem** (inclui duplo clique inadvertido).
- Ações por linha devem carregar `catalogClass`, `kind`, `targetSlot` e `muzzleId` capturados no clique; não confiar em seleção global que possa ter mudado. Reusar o serviço de domínio, não duplicar lógica de transferência.
- Distinguir P3→P2 (edita Recipe/rascunho) de P3→P4 (equipagem física D2).
- `WUX-005`: preservar posição das listas de armas ao trocar foco/arma; revalidar apenas projeções de acessórios e magazines dependentes do baseWeapon. Revisar depois dos botões.

Esta é uma **decisão de comportamento futuro**, não autorização para alterar o SQF nesta rodada. Nenhuma linha funcional deve ser modificada só para registrar esta proposta.

## 5. Sequência proposta e aceite

**Etapas, ainda não versões lançadas:**
- C2: schema versionado + migração, resolver/seletor por muzzle e testes lógicos.
- C3: física D2 + captura/P4 + rollback e observação de rounds. Teste real da MX GL com rifle e granada simultâneos, troca isolada, `KEEP`, `CLEAR`, `SET`, falha segura, NLAW e mods.
- C4: menu contextual segundo muzzle + botões por linha de catálogo, migrar clique do nome e remover duplo clique de transferência, preservar scroll do catálogo.
- C5: testes cumulativos, RPT e revisão manual para homologação de integração completa. Reservar UC-001-D para E2E/performance e pendências anteriores.

**Critérios essenciais:** não misturar granada no combo do fuzil; não misturar cartucho do fuzil na munição do GL; menu adicional só quando cabível; ambos os magazines podem coexistir no loadout; snapshot D2 e rounds preservados em sucesso e rollback; kit legado v0.4 abre sem apagar munição; só botões explícitos do Catálogo transferem; nome da arma e duplo clique genérico não equipam; listas estáveis preservam navegação.

**Manter pendente:** `UC001B-DEFER-001`, `UC001A-SECONDARY`, `WST-001`, `WUX-002`, `WUX-003`, perf/UC-001-D, MP/PBO/JIP. A UC-001-C R1 **continua auto-verde 1589/1589, mas este novo desenho ainda não foi implementado nem homologado**.
