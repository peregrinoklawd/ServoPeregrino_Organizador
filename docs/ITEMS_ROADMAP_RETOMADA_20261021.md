# Items — roadmap de retomada (21/10/2026)

## Atualização do checkpoint — R2.1 testada visualmente em 21/10/2026

A missão R2.1 foi aberta no Arma 3 e o operador confirmou **logo BGD no header, linhas alteradas laranja e comportamento funcional observado**. O RPT prova inicialização da UI e catálogo, sem novo `Picture bgd_logo_ca.paa not found`, mas mostra duas chamadas a `fileExists` com caminho absoluto causando `Invalid path (only relative paths supported)`; o arquivo PAA **aparece na interface**, logo não tratar `fileExists=false` como falha da textura. Evidência detalhada: [67_ITEMS_HEADER_BGD_R2_1_TEXTURE_PATH_FIX.md](67_ITEMS_HEADER_BGD_R2_1_TEXTURE_PATH_FIX.md).

**Próximos passos, nesta ordem recomendada enquanto MP não estiver disponível:**
1. **R2.2 — higiene diagnóstica do header**: retirar `fileExists` do caminho absoluto e log enganoso, validar novamente em SP/RPT sem regressão, depois congelar R2 (sem mexer na aparência aprovada).
2. **UX-ITEMS-04 — família original de botões/ícones**: documentar requisitos e protótipos para Uniforme/Colete/Mochila, aproveitando controles/estados/escala genéricos em UICommon e mantendo as texturas próprias por módulo. Não copiar ACE, não antecipar ícones de Weapons sem sua revisão. Incluir PNG masters, PAA compilado e QA de 1080p e ultrawide.
3. **UX-ITEMS-03 — microtextos defasados**: conferir tooltips e textos herdados de `Mostrar`, `Onde aplicar o kit?`, CLOSE_UI sem confirmação; entregar delta separado de iconografia.
4. **UX/semântica do dirty geral**: discutir comportamento quando todas as linhas voltam ao baseline mas indicador geral permanece `ALTERADO`; não alterar sem decisão de domínio/contrato.
5. **Performance de catálogo com modset grande**: documentar o primeiro build de 24.747 ms / 7.092 itens, investigar opções de cache/progresso sem perder CONFIG_ALL; focused refresh de 10 ms continua saudável. Otimização como gate próprio, não misturar com botões.
6. **0.13-A MP**: validar PBO atual e biblioteca pública com host + cliente real quando disponível, depois 0.13-B (JIP), C (persistência), D (ACL/concorrência), E (soak) e F (contratos Nexus).

Somente resultados efetivamente observados podem elevar os status. Não fazer merge nem atualizar `main` automaticamente.

## Checkpoint ativo — R2 branding e footer (21/10/2026)

Nova branch de desenvolvimento: `feature/items-uicommon-brand-footer-r2-20261021`, derivada da UX R1. Ver [66_ITEMS_UICOMMON_BGD_BRAND_FOOTER_R2.md](66_ITEMS_UICOMMON_BGD_BRAND_FOOTER_R2.md).

- [x] Localizar logo institucional do BGD-HQ; copiar exatamente o PNG canônico, preservando SHA.
- [x] Gerar PAA transparente 256x256 para Arma 3 e sincronizar addon/mission por CI.
- [x] Criar `SPORG_UICommon_HeaderBrand` sem hardcode de BGD.
- [x] Items usa logo próprio em IDC 107; Weapon permanece neutro.
- [x] Remover caminho cinza de TARGET_ONLY, renderizar HISTÓRICO roxo pelo footer UICommon.
- [x] Preparar checklist RPT e missão dedicada a R2.
- [ ] **Teste manual em Arma SP e homologação R2**.
- [ ] Após R2, planejar em outra entrega família de ícones de botões originais (não nesta).

O gate de biblioteca pública MP Items 0.13-A permanece adiado até haver outro jogador disponível.

## PRIORIDADE ATUAL — UX R1 antes de Multiplayer (21/10/2026)

O usuário decidiu trabalhar agora em single-player, adiando o gate MP até dispor de outro jogador. **Ordem operacional atual:** (1) Items UX R1 CAPTURAR + realce por linha → RPT/prints/homologação SP; (2) retomar Items 0.13-A Authority MP; (3) Items 0.13-B/C/D/E/F. Os Gates numerados abaixo permanecem históricos/temáticos e **não são ordem obrigatória**.

- [x] Código candidato CAPTURAR confirmado e substituição de `entries` com preservação do kit selecionado.
- [x] Código candidato realce laranja por `baseline.entries` em FULL + DRAFT_FOCUSED.
- [x] Sincronizar os mesmos seis arquivos entre addon e missão; sem mudanças de Weapons/UICommon.
- [x] Preparar missão self-contained identificada como `SP_ORG_Items_UX_R1_UICommon_0_2_FINAL.VR` (arquivos fonte no Git).
- [x] Roteiro SP criado em `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/ITEMS_UX_R1_TESTE_SINGLEPLAYER.md`.
- [x] Empacotamento ZIP pelo GitHub Actions executado com sucesso; verificação local de integridade e SHA256 registrada.
- Pacote verificado: `SP_ORG_Items_UX_R1_UICommon_0_2_FINAL.zip` (SHA256 `2f2b990683001eefae4d2ca22d1a8b7d99665b5739852bf659fe73ba13b44079`); workflow run [39626658726](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/39626658726), artifact `12357007178`. Confere zip válido e conteúdo estrutural; **não comprova funcionamento no Arma**.
- [ ] Executar Arma SP, suíte automática + teste manual, enviar RPT/prints.
- [ ] Homologar e congelar UX R1 após aprovação; somente então iniciar UX R2 ou MP.

**Importante**: o Items usa o orange do Weapons como **padrão de apresentação**, mas a comparação de linhas é específica do Items. Nenhuma alteração foi necessária na UICommon 0.2 FINAL.

> Complementa `docs/history/SP_ORG_0_13_ROADMAP.md` e NÃO reclassifica validações passadas. A fonte funcional é `baseline/uicommon-0.2-final-homologated@f92137769cf4d0478a5872aae157f5a229177c85`.

## Gate 0 — Continuidade e provenance [DOCUMENTAÇÃO]

- [x] Reconhecer UICommon 0.2 FINAL (07/10) como baseline de Items para continuidade.
- [x] Isolar branch `feature/items-0.13-retomada-20261021` diretamente da baseline, sem merge.
- [x] Documentar versão, testes homologados, riscos, pendências e contratos.
- [x] Registrar backlog CAPTURAR importando somente a especificação, não o runtime.
- [x] Conferir delta documental contra a base: 8 arquivos exclusivamente em `docs/` e `machine/` nos 8 primeiros commits; nenhum `addons/` ou `missions/` alterado (comparação GitHub, 21/10/2026).
- [ ] Criar PR em Draft somente se desejável após revisão da documentação; não merge automático.

## Gate 1 — Fechar Items 0.13-A Server Authority Foundation [PENDENTE DE RUNTIME MP]

### Preparação
- [ ] Congelar hashes/revisões das fontes atuais Nexus, UICommon 0.2.0.10 e Items 0.13-A.
- [ ] Gerar pacote PBO reproduzível dessas fontes atuais. **Packaging R2 antigo não representa necessariamente a baseline com UICommon.**
- [ ] Gate estático (CfgPatches/dependências/CfgFunctions/CfgRemoteExec/sintaxe).
- [ ] Validar load real de todos PBOs, UI e RPT sem `Unable to open`.
- [ ] Regredir a equivalência UICommon e Items usando a mesma fonte.
- [ ] Preservar dívida histórica 516/523, sem falsa homologação pela suíte nova.

### Smoke mínimo multiplayer
- [ ] Host + cliente real na mesma build; preferir dois autores + observador.
- [ ] Private kit no cliente -> `PUBLICAR` -> servidor recebe request -> callback correto.
- [ ] Host e clientes veem mesmo `publicId`, snapshot e revision.
- [ ] Republicar mesmo source+author atualiza, não duplica.
- [ ] Dois autores produzem identidades/autorias distintas.
- [ ] Edição privada não altera público antes de republicar.
- [ ] `SALVAR NO PRIVADO` gera ID privado independente.
- [ ] Autor público derivado do owner/UID real do servidor.
- [ ] Verificação de isolamento Repository privado.
- [ ] Smoke de regressão: DnD/ghost, Whole-Kit/EXACT, Equipment, capacidade, carga, áudio, busca, scroll e focused refresh.
- [ ] Guardar RPT, hashes, evidência e decisão formal; atualizar `PROJECT_STATE` somente após isso.

**Gate de saída**: 0 FAIL novo relevante, artefato correto carregado no engine, smoke multi-cliente aprovado e logs/provenance anexados. Teste de UI não substitui teste MP. Não declarar `0.13-A HOMOLOGADA` prematuramente.

## Gate 2 — UX Items (fila paralela, entregas pequenas)

A aprovação do MP não autoriza fundir alterações de UI sem os próprios testes. Planejar, em commits e revisões separados:

1. **UX-ITEMS-01: confirmação do CAPTURAR** — descrição detalhada `docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md`; segurança de cancelamento/falha; sem autosave, sem mutação física; teste automático e manual.
2. **UX-ITEMS-02: realce de linhas ALTERADAS** — contrato `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md`; snapshot salvo, diff por entrada/quantidade, normalização ao salvar, ausência de ghost de remoção.
3. **UX-ITEMS-03: tooltip e texto defasado** — remover contradições entre labels atuais (`Visualizar`, `Qual o destino?`) e microtextos antigos (`Mostrar`, `Onde aplicar o kit?`, aviso de modal CLOSE_UI). Nenhuma mudança de handler.
4. Auditar os demais itens de `docs/29_SHARED_UI_ITEMS_WEAPONS.md` antes de decidir mudanças cosméticas; não copiar cegamente comportamento de Weapons.

**Gate de UX**: `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md` completo no escopo, Items+UICommon equivalence sem regressão, manual com captura/draft/catálogo/equipamento, performance focal e RPT. Sem tocar código de Weapons.

## Gate 3 — Items 0.13-B: JIP & State Reconciliation [NÃO INICIADO]

- Bootstrap explícito do estado público autoritativo no join.
- Revisão, stale detection, update missed, refresh/recovery.
- Simular jogador entrando depois e conexão reconectada.
- RPT de host + cliente + JIP sem mutação inconsistente.

## Gate 4 — Items 0.13-C: Server Persistence & Recovery [NÃO INICIADO]

- Provider de persistência controlado, schema/versionamento/migração.
- last-good/recovery, mission restart/server restart.
- Impedir que persistência pública seja confundida com Repository privado em `profileNamespace`.

## Gate 5 — Items 0.13-D: Permissions/Concurrency/Moderation [NÃO INICIADO]

- ACL, update/delete autorizados, concorrência/locks.
- Rate limiting, validação de requests e moderação server-side.

## Gate 6 — Items 0.13-E: Soak/Large-Modset Hardening [NÃO INICIADO]

- Soak, limites/pruning, telemetria e timeout/retry/recovery.
- Catálogos grandes e sessões prolongadas; medir sem comprometer focused refresh.

## Gate 7 — Items 0.13-F: Contratos Nexus / Integração [NÃO INICIADO]

- Contratos públicos versionados para Items/Weapons/Equipment/Sets.
- Um módulo dono por domínio; sem acoplamento a estado privado ou dependência circular.
- Hub opcional continua orquestração, não execução de domínio.

## Fechamento — 0.13 FINAL e 1.0

Regression MP/UX, documentação operacional, hashes, contrato de release, assinatura/distribuição. Não equiparar `0.13 FINAL` a `1.0` automaticamente.

## Regras de trabalho

- Missão = laboratório rápido. Addon/PBO = produto e gate real de MP/distribuição.
- Toda candidata deve ter missão testável distribuível, hash, versão, alterações por arquivo, logs e checklist; homologação só com RPT real quando runtime estiver envolvido.
- Preservar o checkpoint UICommon 0.2 FINAL e o antigo 0.12 FINAL; trabalhar por delta e PR, não reconstrução.
- Históricos de `main` datados de setembro ou arquivos com instrução `Packaging R2` refletem a cronologia original, não a origem de source para esta retomada.
