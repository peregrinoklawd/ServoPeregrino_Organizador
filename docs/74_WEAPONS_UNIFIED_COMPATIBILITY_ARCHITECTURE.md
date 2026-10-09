# SP_ORG Weapons — UC-001 Compatibilidade Unificada Completa
**Proposta canônica para próxima evolução depois da homologação do E1 R5**  
Estado: **APROVADA COMO NECESSIDADE FUNCIONAL — IMPLEMENTAÇÃO PENDENTE** (09/10/2026).  
Escopo: módulo Weapons; não significa reescrever Items, UICommon ou Nexus.

## Motivação comprovada

Na R3 R1, `MCC_RD704_AFG` equipado com `MCC_Handbrake_BLK` era válido no ACE Arsenal e mantido fisicamente, mas o Arma `compatibleItems [_weapon,"UnderBarrelSlot"]` retornava `false` para a peça; `CBA_fnc_compatibleItems` a incluía. R4 resolveu **somente UnderBarrelSlot**, foi homologada na interação física em 09/10 com `AUTO 1430/1430`, captura sem omissões e aplicação D2 pós-validada. Uma mesma divergência pode ocorrer nos demais slots — ainda **não investigados sistematicamente**.

O cliente exige **compatibilidade completa para todas as armas, acessórios e carregadores disponíveis no ambiente de mods**, e rejeita uma implementação restrita ao bipé/empunhadura. O objetivo é a mesma decisão consistente em catálogo, seletores, captura e aplicação física.

## Arquitetura a implementar (nunca presumir que está pronta na R5)

`WeaponCompatibilityResolver`: serviço único sob Weapons, com provedores independentes e resultado tipado `weaponClass`, `slot`, `items[]`, `sources[]`, `provenance`, `warnings[]`, `configModsetFingerprint`, `resolutionMode`.

**Fontes por slot e ordem de verificação**:

| Domínio | Arma 3 | CBA | ACE/ACE Arsenal/mods |
| --- | --- | --- | --- |
| Miras / CowsSlot | `compatibleItems` | avaliar `CBA_fnc_compatibleItems` com filtro documentado correspondente | variantes/regras adicionais verificadas por API disponível; não inferir a existência |
| Boca / MuzzleSlot | `compatibleItems` | idem | idem |
| Apontadores / PointerSlot | `compatibleItems` | idem | idem |
| Bipés / empunhaduras / UnderBarrelSlot | `compatibleItems` | contrato R4 já implementado (`bipod`) | preservar e estender somente com comprovação |
| Carregadores / MagazineWell / muzzle específico | `compatibleMagazines`, configuração `CfgMagazines`, `magazinesByMuzzle`, variantes `baseWeapon` | estudar suporte real do CBA para magazines, **sem supor filtro existente** | suporte a magazines de mods verificados no runtime |
| Famílias e presets da arma | `CfgWeapons`, `baseWeapon`, classe efetivamente equipada | apenas funções públicas documentadas | variações ACE de lançadores, presets e subclasses, sem confundir aliases com mesma identidade |

**Importante:** `BIS_fnc_compatibleItems` no diagnóstico retornou 2992 entradas e não representa diretamente autorização por slot. Nunca fazer union global cega. ACE Arsenal pode usar convenções, filtros e metadados que não se traduzem numa única função pública: confirmar APIs disponíveis antes de criar adaptadores.

### Regras não negociáveis

1. **Autoridade canônica do serviço:** mesmo resolver usado em `getWeaponCompatibility`, `buildCompatibilitySelectorModel`, `validateWeaponConfigurationSemantic`, `validateWeaponRecipeSemantic`, `prepareObservedCaptureRecipe`, `getUICatalogWindow` e validação de aplicação pertinente. Eliminar consultas divergentes por campo sem substituto.
2. **Decisão por slot:** só aceitar classe `CfgWeapons/CfgMagazines` válida, verificando escopo, tipo, `compatibleItems`/API adequada e munição para o muzzle pertinente. Não confundir classe existente com compatibilidade.
3. **Sem whitelist por MCC/RHS/ACE/mod específico**, sem forçar anexar classe rejeitada; as fontes e critérios devem estar registrados no diagnóstico por item.
4. **Aceite lógico não garante aceite físico:** Plan → Snapshot → Apply → Validate → Rollback (D2) continua estrito; se a engine recusar uma peça, retornar erro explícito e rollback. Não transformar falha física em sucesso.
5. **Receita sem munição restante**: manter `magazineClass` e variantes corretamente, nunca estado de tiros transitório.
6. **Ausência CBA/ACE**: fallback seguro para Arma 3 vanilla sem falha de carregamento ou dependência obrigatória de addon.
7. **Cache por sessão/modset/arma/slot**; invalidar com troca de classe ou Recipe, não reconstruir catálogo inteiro a cada tecla ou scroll. Não indexar globalmente dezenas de milhares de classes em toda interação.
8. **Auditoria:** `COMPAT_RESOLVE`, `COMPAT_SOURCE_DIFF`, `COMPAT_REJECT`, `COMPAT_PHYSICAL_VERIFY`; permitir rastrear classe, slot, fonte, motivo e diferença entre fontes. Não despejar listas gigantes a cada refresh.
9. **Preservar UI, kits e Items:** mudanças exclusivamente em Weapons; `UICommon 0.2`, Items e baseline D2 R1 são imutáveis sem aprovação explícita.

### Entregas subsequentes (incrementais, mas requisito de cobertura completa)

**UC-001-A — Inventário de fontes e matrix de compatibilidade:** diagnóstico por arma/slot, adaptadores disponíveis, divergências Arma/CBA/ACE, fingerprints e estudo de magazines/variantes. Sem mudança no executor.

**UC-001-B — Resolver unificado de todos os acessórios:** Muzzle/Cows/Pointer/UnderBarrel, catálogo, selector, captura e semântica; compatibilidade vanilla e mods, regressões por categoria.

**UC-001-C — Carregadores/armas/variantes:** magazine wells, subclasses, lançadores e presets, sempre com validação física e rollback.

**UC-001-D — End-to-end e performance:** captura física de arma modded → catálogo completo → seleção de acessórios → SALVAR/SALVAR COMO NOVO → reapertura do kit → equipagem em unidade isolada e manual → validação pós-apply, sem perda de munição/mudança de outros slots. Testes em vanilla, CBA sozinho, ACE+CBA e pack do operador.

### Critérios de aceite finais

- Todos os slots de acessórios e magazines alimentam o mesmo resolver e os mesmos campos em catálogo, rascunho, captura e validação.
- Divergências Arma 3/CBA/ACE são explicadas com `source` e motivo; peças válidas no ACE Arsenal demonstravelmente equipáveis aparecem no Organizador, sujeitas à pós-validação D2.
- `rhsusf_acc_grip2` para `MCC_RD704_AFG` continua recusado se os provedores e o motor mantiverem a recusa; `MCC_Handbrake_BLK` continua aceito.
- Nenhuma regressão dos gates de kit/undo/deferred, performance de busca/scroll, memória, todos os fluxos de salvamento e aplicação.
- Revisão e homologação com RPT completo antes de promover; não declarar **compatibilidade completa** por apenas concluir um slot.

**Sequência acordada:** resolver primeiro o bloqueio do SALVAR COMO NOVO na R5 e obter RPT/manual verde; UC-001 é então a prioridade explícita da próxima linha de trabalho. Não fazer merge na main nem tocar a baseline D2 R1 até aceite.
