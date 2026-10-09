# Weapons 0.7-E E1 — Capturar arma equipada → Rascunho (mission-first)

Data: 09/10/2026. Branch candidata: `feature/weapons-0.7-e-equipment-capture`.
Fonte: `baseline/weapons-0.7-d2-r1-homologated` (D2 R1 HOMOLOGADA pelo operador, preservar intacta).
Display `0.7-E`, semantic `0.7.4.1`, build `0.7.4.1-equipment-to-draft-e1-mission-first`.
Estado: **STATIC/RUNTIME CANDIDATE — aguardando RPT real e aprovação manual**.
Uma missão: `SP_ORG_Weapons_0_7_E_Equipment_Capture_E1.VR`; uma ação cumulativa:
`SP_ORG LAB - TESTAR WEAPONS 0.7-E`.

## Objetivo e contrato

A operação **CAPTURAR ARMA EQUIPADA** fica no painel P4 (CONTEÚDO DO EQUIPAMENTO), IDC `4123`. Usa exclusivamente o slot de arma visualizado, PRIMARY/HANDGUN/SECONDARY, e permanece desabilitada se vazio.

Fluxo **P4 → P2**:
- Lê a configuração física com `getEquipmentSlotSnapshot` / `captureWeaponConfiguration`, sem mutar o inventário.
- Usa `WeaponConfiguration` existente (arma, boca, ponteiro, óptica, bipé/grip) e classe de magazine carregado para criar `WeaponRecipe` canônica.
- **Não registra a quantidade de tiros** no WeaponRecipe. `observedLoadedState` só aparece na resposta transitória da captura.
- Valida a Recipe antes de alterar o estado da interface. Se incompatível/vazia, recusa sem alterar rascunho ou repositório.

### Se existe WeaponKit selecionado

A captura troca `draft.recipe` e `draft.targetSlot` do kit selecionado; compara com `baseRecipe/baseTargetSlot` para decidir `dirty`. **Não modifica o WeaponKit salvo**, outras drafts, depósito ou equipamento físico. Repetir captura idêntica mantém a revisão do rascunho. A configuração pode ser salva mais tarde pressionando SALVAR.

### Se não existe WeaponKit selecionado ou NOVO está ativo

Cria somente `pendingCapturedDraft` em `SP_ORG_WEAPONS_UI_STATE`, com `pendingNewKit=true` e `selectedKitId=""`.
**Nenhum WeaponKit é criado no repositório nessa etapa.** A Recipe e seus acessórios são exibidos imediatamente em ARMAS DO KIT (NOVO), podendo ser editados por compatibilidade do P2 e pelo Catálogo.
`SALVAR` valida o nome e cria **um** novo WeaponKit session-local com a Recipe final. `DESCARTAR` cancela o pending sem salvar, restaurando a seleção anterior se ainda existir. `LIMPAR` remove somente acessórios/magazine do pending, preservando a arma-base. `SALVAR COMO NOVO` fica indisponível para o pending, porque SALVAR já cria um novo kit.

**Como capturar como novo quando já há um kit selecionado:** pressione NOVO em MEUS KITS, visualize o slot desejado em P4 e depois CAPTURAR ARMA EQUIPADA.

### Três direções independentes

- `CATÁLOGO → EQUIPAR NO RASCUNHO`: authoring de seleção lógica.
- `ARMAS DO KIT → EQUIPAR RASCUNHO`: aplicação física pelo pipeline Plan/Snapshot/Apply/Validate/Rollback D2.
- `CONTEÚDO DO EQUIPAMENTO → CAPTURAR ARMA EQUIPADA`: observação física → Recipe lógica, sem aplicar/salvar.

Nenhum novo `setUnitLoadout`, `remoteExec`, `CfgRemoteExec` ou provider de persistência foi introduzido no serviço de captura.
UICommon 0.2, Items e o core B/C/D2 permanecem congelados.
`UNDO_DEFERRED`, `MP_DEFERRED_0_8`, JIP e addon/PBO não fazem parte da entrega.

## TESTE AUTOMÁTICO

O runner `runDelivery0_7_ETests.sqf` mantém o runner D2 canônico de **1360 checks**, seguido de **36 novos checks E**. Meta cumulativa: **1396/1396, 0 FAIL, 0 BLOCKED**.

Cobertura E:
- Baseline D2 cumulativa;
- Alvo local isolado;
- Captura de slot equipado e Recipe observada;
- Classe da arma, optic, magazine;
- Dirty-state e mudança de destino;
- Proibição de persistir ammo restante;
- Nenhuma mutação de loadout, kit salvo e repository durante captura;
- Captura repetida sem novo revision;
- NOVO pending real sem WeaponKit salvo;
- Edição de compatibilidade do pending;
- Botão P4 e readiness físico;
- SALVAR explícito materializa WeaponKit;
- Cleanup do pending;
- Recusa em destino vazio, estado intocado;
- Limpeza da unidade LAB e equipamento do jogador preservado.

**Importante:** fechar a UI antes de executar o AUTO TEST e não abri-la durante a execução. As ações visuais de abrir Weapons exibem uma mensagem de espera enquanto o runner está ativo; testes internos continuam podendo abrir a UI sob controle do harness. Interferência externa poderá afetar assertions de draft legado.

## CHECKLIST MANUAL

1. Abrir a missão, aguardar carregamento e rodar `SP_ORG LAB - TESTAR WEAPONS 0.7-E` com a interface fechada; aguardar resumo e coletar RPT integral.
2. Abrir Weapons; selecionar kit salvo e P4 PRIMARY com uma arma física equipada; clicar CAPTURAR; conferir P2 com arma, acessórios e magazine; SALVO muda para ALTERADO se há diferença; botão SALVAR é opcional.
3. Alterar o draft capturado e verificar equipamento físico/repositório inalterados até ação explícita de equipar/salvar.
4. Selecionar NOVO e um slot físico com arma, clicar CAPTURAR; confirmar P2 NOVO com arma capturada e **sem novo item salvo em MEUS KITS**; editar acessórios, SALVAR e só então conferir novo kit na lista.
5. Fazer NOVO → CAPTURAR → DESCARTAR sem salvar; repositório permanece igual.
6. Selecionar slot físico vazio em P4; CAPTURAR deve ficar desabilitado; captura programática devolve `WEAPONS_UI_CAPTURE_SLOT_EMPTY`.
7. Repetir captura idêntica e validar ausência de mudanças desnecessárias; trocar slot PRIMARY/PORTE/SECUNDÁRIA e confirmar destino correto.

## Critério de aceite e pontos em aberto

Aceitar somente depois do RPT real: **1396 PASS, 0 FAIL, 0 BLOCKED**, mais testes manuais aprovados.
Uma validação estática/GitHub Actions GREEN **não equivale a homologação no Arma**.
Riscos a verificar no RPT: captura de armas modded / variantes SECONDARY, transição de slot do kit ao salvar, renderização da Recipe pendente NOVO e concorrência de refresh ao digitar nome.

Não fazer merge main nem modificar `baseline/weapons-0.7-d2-r1-homologated`.
