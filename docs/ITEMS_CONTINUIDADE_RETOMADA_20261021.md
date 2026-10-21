# SP_ORG Items — continuidade canônica de retomada (21/10/2026)

## ATUALIZAÇÃO CANÔNICA — R2.2 homologada SP (21/10/2026)

R2.2 foi executada pelo operador no Arma 3 com RPT e screenshot; **homologada no escopo do hotfix do header/footer em single-player**. O logo BGD aparece, a rotina `[BRAND_HEADER]` informa `pathAssigned=true` e o aviso anterior de caminho absoluto não reaparece no RPT. CAPTURAR, laranja do draft e lógica de Items foram preservados; multiplayer público 0.13-A continua pendente.

**Documento de referência prioritário:** [70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md](70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md). O desenvolvimento **seguinte é a iconografia R1 simplificada**, inicialmente somente desenho/avaliação, em frente isolada. A baseline UICommon 0.2.0.10 (07/10) não é reescrita. Demais adendos abaixo são registros cronológicos, não estado atual.

## ADENDO 21/10/2026 — correção R2.1 da textura no header

O usuário executou R2 no Arma: header sem logo. RPT confirmou `Picture items\\data\\bgd_logo_ca.paa not found`. **Não era falha confirmada do conteúdo PAA**, mas um arquivo não localizado pelo caminho relativo do HPP.

A R2.1 usa `getMissionPath "items\data\bgd_logo_ca.paa"` e `ctrlSetText` no controle 107, com telemetria `[BRAND_HEADER]`. A missão nova é `SP_ORG_Items_HeaderBGD_FooterR2_1_TexturePathFix.VR`; preservar a R2 antiga como evidência de falha, não como entrega pronta. Teste no engine e RPT R2.1 ainda pendentes.

- Detalhes: [docs/67_ITEMS_HEADER_BGD_R2_1_TEXTURE_PATH_FIX.md](67_ITEMS_HEADER_BGD_R2_1_TEXTURE_PATH_FIX.md).
- Sem mudanças na UX R1, no módulo Weapons e no contrato do footer roxo.
- BGD-HQ Watch: preferir ImageToPAA oficial, decode/round-trip e inspeção alpha/mips antes de liberar a textura final.

## Continuidade adicional — Items Header BGD / Footer R2 (21/10/2026)

Após aprovação manual da UX R1, a próxima candidata está **isolada** em `feature/items-uicommon-brand-footer-r2-20261021`.

- [R2: logo BGD, root cause de HISTÓRICO cinza e gates](66_ITEMS_UICOMMON_BGD_BRAND_FOOTER_R2.md).
- A UICommon **0.2.0.10** aprovada em 07/10 continua congelada como fallback; branch R2 contém UICommon **0.2.0.11 candidate**, com **slot visual genérico** `SPORG_UICommon_HeaderBrand`.
- Items injeta marca canônica BGD no IDC 107; logo original preservado em `assets/branding/bgd/bgd-logo-primary.png`, PAA derivado com alfa no addon e na missão.
- HISTÓRICO cinza comprovadamente vinha de `fn_refreshPhysicalTargetUI.sqf`, cor hardcoded `#81918E`; TARGET_ONLY foi migrado a `UICommon_fnc_renderFooter`, roxo `#B9A3E8`.
- Botões com ícones originais continuam **fora** da R2. Library MP continua pendente, sem bloquear teste SP.
- Missão: `SP_ORG_Items_HeaderBGD_FooterR2_UICommon_0_2_0_11.VR`; roteiro SP `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/HEADER_BGD_FOOTER_R2_TEST.md`.
- **Ainda não homologar R2**: aguardar engine, teste manual, screenshots e RPT.

## Atualização de prioridade — Items UX R1 (21/10/2026)

**Decisão do usuário:** devido à indisponibilidade temporária de outro jogador para testar MP, **inverter os gates de execução**: primeiro UX Items (CAPTURAR + realce laranja), depois fechar 0.13-A multiplayer. A pendência MP permanece registrada e NÃO bloqueia teste SP da UX.

**Candidata implementada em source, NÃO homologada no Arma**:
- `CAPTURAR` agora abre confirmação. Cancelar não muda Draft nem inventário; confirmar pré-captura/prevalida e substitui somente `entries` preservando `kitId`, nome, modo, baseline, `preferredTarget` e `origin`; sem salvar, sem mutação física. Um Draft inexistente ainda gera NEW. Revisão de Draft é verificada no retorno do diálogo.
- `ITENS DO KIT` agora recebe fundo laranja RGBA `[1,0.76,0.28,0.18]` por linha que diverge do baseline salvo: quantidade, classe/entrada nova, `stateData` e EXACT. Voltar ao snapshot remove destaque; salvar reseta baseline; sem linha fantasma para exclusões.
- A referência de cor **é Weapons**, onde `fn_getDraftChangedFields.sqf` e `fn_refreshDraftUI.sqf` são código **exclusivo de domínio Weapons**; UICommon fornece controles/tema genérico mas não calcula `changedFields` nem aplica essa coloração de conteúdo.
- Itens alterados sincronizados 1:1 em `addons/ServoPeregrino_Organizador_Items/` e `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/items/`. UICommon, Nexus e Weapons permanecem sem alterações.
- Teste SP: `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/ITEMS_UX_R1_TESTE_SINGLEPLAYER.md`. Missão pacote `SP_ORG_Items_UX_R1_UICommon_0_2_FINAL.VR`.
- O dirty global do Draft ainda é histórico (mutation flag): uma linha que retorna ao original perde laranja, mas o status geral pode continuar ALTERADO até salvar. Não alterar sem um gate específico para semântica do dirty geral.
- **Status**: código candidato sob revisão/testes; nenhum RPT atual recebido, sem aprovação automática nem homologação de 0.13-A MP.

Este adendo de prioridade **substitui** recomendações antigas abaixo que colocavam o MP como bloqueador imediato da UX.

## 0. Mandato deste handoff

Retomar **Items** usando exclusivamente a versão integrada e homologada junto de **UICommon 0.2 FINAL em 07/10/2026**. Não voltar à fonte de `main` (snapshot setembro) nem reconstruir Items de memória, ZIP, RPT ou missão anterior.

- Repositório: `peregrinoklawd/ServoPeregrino_Organizador`.
- **Base imutável**: `baseline/uicommon-0.2-final-homologated`.
- Commit exato da base: `f92137769cf4d0478a5872aae157f5a229177c85`.
- **Branch de retomada**: `feature/items-0.13-retomada-20261021`, criada diretamente da base acima.
- Política: base congelada é fallback; trabalhar por deltas pequenos nesta branch; não fazer merge nem alterar Weapons/Nexus/UICommon sem decisão explícita e validação.
- O GitHub é source of truth dos arquivos; somente um RPT do Arma confirma comportamento em runtime. Status históricos preservados abaixo.

## 1. Estado real — distinguir validações diferentes

| Área | Estado comprovado | Não inferir |
|---|---|---|
| Items 0.12 FINAL | Integration Freeze, baseline de domínio homologada manualmente | Não usar como fonte de implementação desta retomada |
| Items 0.13-A (semantic `0.13.0.1`) | Código de Server Authority Foundation presente na base congelada | A biblioteca pública multiplayer **não está homologada integralmente** |
| Hotfix Items (02/10) | Fechar sem modal redundante preserva draft; rejeição física expõe causa/capacidade | Não reabrir esses fixes sem regressão reproduzida |
| Items + UICommon R1 (02/10) | 12/12 equivalência e smoke manual extenso aprovados; artefato Items PBO reconciliado com fonte visual | Não concluir autoridade MP apenas pela equivalência de UI |
| UICommon 0.2-F F1 (07/10) | UICommon 43/43, Items + UICommon 16/16, Weapons R6 594/594, todos 0 FAIL no gate conjunto; manual aprovado | Esses 16 checks não equivalem aos dez gates de autoridade MP 655..664 |
| Items UI da base | P2 `ITENS DO KIT`, `Visualizar:`, `Qual o destino?`, status SALVO/ALTERADO, footer compartilhado, focused refresh | Destaque por linha alterada ainda é backlog |
| Public Loadouts | Biblioteca pública e fluxo 0.13-A implementados | Sem teste multi-cliente específico homologado; JIP e persistência pós-restart permanecem fora de 0.13-A |

A homologação UICommon 0.2 ocorreu no mission-first `SP_ORG_UI_Lab_UICommon_0_2_F_F1.VR`, pacote documentado no commit `4e87ce134c117a0a1586a4f82c41ffbaaf6a5890`, com performance manual de scroll Items aproximadamente **12–20 ms**, `fullRefresh=false` e sem recapture de Equipment. É evidência daquele laboratório, **não benchmark universal**.

**Observação de provenance**: o `machine/PROJECT_STATE.json` da base data de 07/10 e conserva `ADVANCED_PENDING_0_13_A_RUNTIME_MULTIPLAYER_VALIDATION`; a abertura da branch agora não altera a versão/estado do runtime. O resumo específico da retomada está em `machine/ITEMS_CONTINUITY_20261021.json`. `main` pode estar defasada em relação às homologações feitas nas branches.

## 2. Arquivos de referência — ler antes de mexer

1. Este handoff e `docs/ITEMS_ROADMAP_RETOMADA_20261021.md`.
2. `docs/30_ITEMS_UI_REGRESSION_CONTRACT.md` — matriz principal de não regressão; entradas marcadas como futuras podem ter sido incorporadas na UICommon 0.2; conferir source.
3. `docs/62_UICOMMON_0_2_F_F1_EQUIVALENCE_CLEANUP.md` — homologação de 07/10.
4. `docs/35_ITEMS_UICOMMON_EQUIVALENCE_R1.md` e `docs/34_JOINT_UI_LAB_RUNTIME_FINDINGS_HOTFIX1.md`.
5. `docs/64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md` — requisito de CAPTURAR, trazido da branch de Weapons **apenas como documentação**, sem importar implementação.
6. `docs/history/SP_ORG_0_13_ROADMAP.md`, `docs/06_MULTIPLAYER_E_AUTORIDADE_0_13_A.md`, `docs/07_TESTES_E_HOMOLOGACAO.md`.
7. `addons/ServoPeregrino_Organizador_Items/` (config, UI, functions), `addons/ServoPeregrino_Organizador_UICommon/`, `addons/ServoPeregrino_Organizador_Nexus/`.
8. `machine/PROJECT_STATE.json`, `machine/FEATURE_OWNERSHIP.json`, `machine/FUNCTION_INDEX.json`.
9. `docs/29_SHARED_UI_ITEMS_WEAPONS.md` e `docs/12_CONTRATOS_UI_NAO_REGREDIR.md`.

## 3. Contratos funcionais congelados

- `applicationTarget` (Qual o destino? / Whole-Kit) **não** é `equipmentView` (Visualizar: / ações físicas diretas). Seta direita do Catálogo e drop físico obedecem ao equipamento visualizado.
- Preservar Whole-Kit, EXACT, STRICT/BEST_EFFORT conforme operação, snapshot, rollback, capacidade por container, carga global e sobrecarga explícita.
- Catálogo contínuo/virtualizado, busca, wheel, slider, focused refresh, DnD por painel inteiro, ghost funcional e tooltip pass-through.
- Draft não sofre autosave; CLOSE_UI sem confirmação redundante preserva alterações session-local. Transições destrutivas continuam com confirmação.
- Repository privado usa `profileNamespace` com primary/lastGood; biblioteca pública da 0.13-A é session-scoped e server-authoritative quanto a mutações (intenção/código, ainda sem validação MP final).
- `UICommon` fornece infraestrutura visual genérica. Não migrar semântica de ItemKit, equipamento ou engine físico para UICommon. Não introduzir dependência Items ↔ Weapons.
- Dívida aceita: gates automáticos antigos **516/523** podem dar falso negativo; não mudar runtime saudável só para satisfazer esses checks. Testes UI não devem bloquear por versão/header literal.

## 4. Gate obrigatório para encerrar 0.13-A — ainda NÃO executado nesta retomada

**Não confundir a aprovação de equivalência do UICommon com aprovação de multiplayer.** O antigo `Packaging R2` foi produzido antes da dependência real UICommon: **não assumir que seus PBOs representam esta baseline**.

A preparação do próximo teste deve:
1. empacotar/usar a **mesma fonte congelada** de Nexus + UICommon 0.2.0.10 + Items 0.13-A, sem copiar source velho da `main`; validar paths `$PBOPREFIX$`, `CfgPatches`, `CfgFunctions`, `CfgRemoteExec`; evitar packer experimental sem load gate;
2. garantir no RPT `Unable to open` ausente para os PBOs SP_ORG; funções inicializadas e UI abrindo; nada disso é automaticamente provado pelos testes mission-first;
3. hospedar laboratório MP com slots para host e **pelo menos um cliente real** (preferencialmente dois autores e um observador);
4. cliente salva kit privado, PUBLICAR passa por `ENVIADO`/resposta servidor; host e outros clientes veem mesma revisão e conteúdo;
5. republicação de mesmo source/author atualiza, sem duplicar; edição privada não altera público sem republicar;
6. `SALVAR NO PRIVADO` cria kit independente; identidade do autor é derivada no servidor; não há acesso cruzado ao Repository privado;
7. repetir regressão curta de busca, DnD/ghost, Equipment, Whole-Kit/EXACT, carga, capacidade, áudio e refresh;
8. salvar RPT, hashes dos artefatos, source commit, checks executados e resultado manual antes de alterar status de `0.13-A`.

Testes específicos de JIP/reconciliation, persistência entre restart, ACL, rate-limit e recuperação avançada **não são critérios de aprovação da 0.13-A**; são parte de 0.13-B/C/D/E.

**Este handoff não registra build/PBO novo, RPT novo, teste físico, CI ou aprovação MP.** Só registra a preparação da continuidade.

## 5. Backlog Items separado dos gates de autoridade

**UX-ITEMS-01 — CAPTURAR com confirmação e substituição de rascunho**:
- Semântica: substituir o conteúdo de `ITENS DO KIT` pelo conteúdo de `CONTEÚDO DO EQUIPAMENTO` **atualmente visualizado**, nunca merge.
- Confirmar com texto explícito antes de mudar draft; Cancelar = não muda nada.
- Primeiro capturar/preparar snapshot ou usar rollback atômico; falha não destrói draft anterior.
- Não modificar equipamento, nem autosalvar. Resultado fica em draft até SALVAR.
- Validar cancelamento, falha, quantidades, container selecionado, preservação de kit salvo, performance focused.
- Source atualmente registra `CAPTURE_EQUIPMENT` como chamada direta; requisito ainda **não implementado** nesta base.

**UX-ITEMS-02 — realce por linha divergente**:
- Em draft originado de kit salvo, comparar entries atuais com snapshot persistido e destacar linhas adicionadas/quantidades alteradas.
- Desfazer até valor original remove realce; SALVAR redefine baseline visual. Linhas removidas não criam fantasmas.
- Há indicador geral SALVO/ALTERADO, mas não comprovação de realce individual nessa base.

**UX-ITEMS-03 — auditoria de microtextos**:
- Revisar textos/tooltip legados que ainda dizem `Mostrar`, `Onde aplicar o kit?` ou falam em confirmação ao fechar, apesar dos rótulos e fluxos já homologados.
- Somente substituir depois de inventário de ocorrências e sem alterar eventos/semântica; baixo risco, mas precisa gate visual.

Esses itens são **candidatos futuros** e não foram implementados por esta retomada. UX pode ter branch/PR própria após preservar o gate de equivalência, sem transformar melhoria visual em alegação de MP aprovado.

## 6. Próximo passo prático e limites

1. Conferir esta branch contra `baseline/uicommon-0.2-final-homologated`: **somente documentação de retomada** deve divergir neste checkpoint.
2. Preparar artefato testável da 0.13-A integrada a UICommon (mission-first para equivalência + PBO para load/MP), mantendo nomes/versionamento e proveniência.
3. Solicitar/testar RPT no Arma com players reais; fechar apenas gates realmente executados.
4. Após aprovação 0.13-A: implementar 0.13-B (JIP & State Reconciliation) e, em entregas menores distintas, UX-ITEMS-01/02.
5. Continuar 0.13-C persistência pública, 0.13-D permissões/concorrência, 0.13-E robustez, 0.13-F contratos, 0.13 FINAL/1.0 conforme roadmap.

**Não fazer merge nesta rodada documental; não tocar na branch PR #12 de Weapons.**
