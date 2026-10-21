# SP_ORG Items — continuidade canônica de retomada (21/10/2026)

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
