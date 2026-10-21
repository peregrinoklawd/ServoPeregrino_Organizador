# Weapons UC-001-C R1 — Carregadores, magazine wells, muzzles e variantes

> **PONTO DE CONTINUIDADE OFICIAL (21/10/2026):** [`docs/87_WEAPONS_CONTINUIDADE_UC001C_PROXIMO_CHAT_20261021.md`](87_WEAPONS_CONTINUIDADE_UC001C_PROXIMO_CHAT_20261021.md). **Leia esse handoff e `machine/PROJECT_STATE.json` antes de desenvolver Weapons em outro chat.** GitHub branch `feature/weapons-uc-001-c-magazine-compatibility`; PR #12 Draft, SEM MERGE. UC-001-B R2 APROVADA (1518/1518) com exceção `UC001B-DEFER-001` aceita. UC-001-C R1 **AUTO Arma 3 1589/1589 PASS**, mas **não homologada fisicamente para multi-muzzle**: operador observou GL e fuzil misturados no combo Carregador. **Design por muzzle + Recipe versionada, D2 seguro, captura e migração** discutido em [docs/86](86_WEAPONS_UC001C_MAGAZINES_BY_MUZZLE_AND_CATALOG_BUTTON_MIGRATION.md), AINDA NÃO IMPLEMENTADO. Reutilizar `CATALOG_TO_DRAFT` nos futuros botões por linha do catálogo; só então remover clique no nome P2 (WUX-004); preservar scroll de armas (WUX-005) depois dos botões. **Nenhum SQF/UI alterado nesse checkpoint.** Os checkpoints históricos abaixo podem dizer "teste pendente" por terem sido escritos antes do RPT atual. 


**Checkpoint 21/10/2026 — UC-001-C R1 runtime AUTO confirmado 1589/1589 PASS, 0 FAIL/BLOCKED** (RPT real 11.234 linhas; build 0.7.6.1). Manual físico multi-muzzle ainda não comprovado; PR #12 continua Draft. **WUX-004**: clicar no nome da arma P2 chama indevidamente CATALOG_TO_DRAFT (IDC 2021). **WUX-005**: selecionar kit/trocar arma-base reinicia catalogOffset=0; preservar scroll das armas e recomputar somente acessórios dependentes. **Não implementar UI agora**, revisar após setas/botões por linha de catálogo. **UC001C-MUZZLE-001**: potencial divergência magazine do launcher vs campo primaryMagazine na aplicação D2; requer teste físico direcionado, não falha demonstrada. Registrar e continuar pendência aceita UC001B-DEFER-001 (MCC grip CBA-only). Análise completa: `docs/85_WEAPONS_UC001C_R1_RPT_REVIEW_UX_OBSERVATIONS_2026_10_21.md`.


**Situação atual após 21/10:** candidata mission-first com RPT real **1589/1589 PASS automático**, porém sem homologação manual física multi-muzzle. A declaração anterior de RPT pendente foi superada pela execução de 21/10 e deve ser lida apenas como histórico.
**Nova branch:** `feature/weapons-uc-001-c-magazine-compatibility`, derivada do marcador imutável `baseline/weapons-uc001b-r2-approved` (UC-001-B homologada pelo usuário em 16/10/2026; 1518/1518, com `UC001B-DEFER-001` explicitamente aceito).
**Display:** 0.7-G; **semantic** 0.7.6.1; **build** `0.7.6.1-uc001-c-r1-magazines-wells-variants-mission-first`.

## Problema / referências documentadas

`compatibleMagazines _weapon` (Arma 3 >=2.10) já reúne compatíveis para qualquer muzzle e os magazine wells conhecidos pelo motor. `compatibleMagazines [_weapon,_muzzle]` restringe o resultado ao cano/lançador indicado. `BIS_fnc_compatibleMagazines` está obsoleto para consulta geral desde v2.10, mas o legado Weapon 0.7-E R5 usa-o como fallback restrito de classes ocultas READY/USED do `SECONDARY`. Ver documentação Bohemia:
- https://community.bistudio.com/wiki/compatibleMagazines
- https://community.bistudio.com/wiki/BIS_fnc_compatibleMagazines
- https://community.bistudio.com/wiki/Arma_3:_Weapon_Config_Guidelines (CfgMagazineWells)

O código herdado colocava descoberta de magazines, cálculo por muzzle e união de variantes diretamente no `getWeaponCompatibility`. A C separa isso em serviço único e acrescenta metadados de proveniência **sem autorizar automaticamente qualquer classe `CfgMagazineWells` que o motor não aceite**.

## Entrega C R1

- **`fn_resolveMagazineCompatibility.sqf`**: um resultado tipado com `weaponClass`, `magazines[]`, `muzzles[]`, `magazinesByMuzzle`, `magazineWellsByMuzzle`, `sourcesByMuzzle`, `magazineSource`, variantes de família `baseWeapon`, `engineMagazines`, `resolutionMode`, `cacheScope` e `physicalAuthority`.
- Autoridade de carregamento: `compatibleMagazines` por arma/cano; filtra `CfgMagazines` para classes `scope>=2` nas opções públicas; normaliza `configName` e elimina duplicatas sem diferenciar maiúsculas.
- Magazine wells: percorre o `magazineWell[]` do muzzle, inspeciona `CfgMagazineWells` e gera `COMPAT_MAGWELL_DIFF` para classes públicas declaradas em wells que a consulta de motor não incluiu. **A divergência é apenas diagnóstica**; não incluir magazines via *union* insegura.
- SECONDARY (type 4): mantém a busca das classes de variante da família `baseWeapon`, incluindo o fallback BIS restrito já homologado na R5. O contador legado preserva variantes ocultas conhecidas; opções públicas permanecem filtradas. `magazineSource` mantém marcadores antigos.
- Cache imutável da missão por className canônico e `deepCopy`, sem recalcular todo o scan a cada tecla/scroll; logs `COMPAT_MAG_RESOLVE` no *cache miss*.
- `getWeaponCompatibility` passa a delegar ao resolvedor; o UI selector `magazineClass` e `validateWeaponRecipeSemantic` já dependem desse catálogo. Metadados novos expostos para futuras auditorias.
- **Sem alteração de lógica de acessórios UC-001-B, `WeaponConfiguration`, física D2, rollback, Items, Nexus, UICommon, PBO, MP ou servidor.** Não confundir catalogação com autorização física.

## Validação planejada

Runner **`SP_ORG LAB - TESTAR UC-001-C R1`**:
- Invoca o runner legado da B R2 (1.518 verificações) com sua fixture isolada e 71 novas asserções C.
- Meta **1.589 PASS / 0 FAIL / 0 BLOCKED**. Asserções avaliam armas vanilla MX, MX GL, P07 e NLAW; igualdade resolver→catálogo→seletor/receita; compatibilidade da engine por muzzle; classes públicas e canonicidade; metadata de wells; família type 4; cache, falha segura em classes inválidas; kits e loadout preservados.
- O teste C é read-only; runner herdado B e R5 executam as suas fixtures físicas de teste isoladas e as restauram. **Não executar com a UI aberta.** Não atribuir PASS ao Arma com base somente em Python/CI estática.
- Após o AUTO, testar manualmente seleção de carregadores no rifle e no launcher, incluindo uma arma de pack do usuário (RHS / Tier One / MCC) e variante de carregador do magazine well; validar seletor, salvar no rascunho, aplicação e pós-validação D2 **sem alterar os outros slots**.
- Se houver `COMPAT_MAGWELL_DIFF`, comparar a declaração do addon e o `compatibleMagazines` real; não alterar a regra de compatibilidade sem prova.
- Registrar eventos `COMPAT_MAG_RESOLVE`, `COMPAT_MAGWELL_DIFF`, `AUTO_TEST_SUMMARY`, `DRAFT_APPLY` e `COMPAT_PHYSICAL_VERIFY` se emitidos.

## Pendências herdadas (não apagar)

- **UC001B-DEFER-001:** usuário aprovou pular o teste físico MCC com grip CBA-only em 16/10; retomada recomendada UC-001-D antes do PBO/MP. **Não marcar como PASS.**
- UC001A-SECONDARY diagnóstico equipado; observação de performance FULL / hooks CBA não atribuídos ao SP_ORG; WST-001 persistência de kits entre missões; WUX-002 magazine para colete, WUX-003 filtro de ícones; MP/JIP, PBO, Undo.
- **UC-001-D** é o gate real end-to-end/performance depois da C. Não anunciar `UC-001 completa` antes dele.

## Pacote

Pasta da missão: `SP_ORG_Weapons_UC_001_C_Magazines_Wells_R1.VR`, guardada como ZIP em artifact `SP_ORG_UI_Lab` na Actions da branch UC-001-C. Substituir neste documento o workflow/artifact assim que confirmado CI, mantendo o histórico.

## Primeira CI de compilação estática e pacote (16/10/2026)

- GitHub Actions: https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862452414 — **SUCCESS, 37/37 static PASS**, executada antes do ajuste final do LEIA_PRIMEIRO; não é teste SQF real.
- ZIP da missão no [artifact SP_ORG_UI_Lab](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862452414/artifacts/12030085733); `SP_ORG_Weapons_UC_001_C_Magazines_Wells_R1.zip`, SHA256 `ee7e778e578aca5795800762e2b550c78d7cab8514a44f8b5be67c7e32f44c0f`.
- Um novo pacote será produzido automaticamente após atualizar as instruções dentro da missão. Preferir o artifact mais recente com sucesso.
- **Não homologar C antes do RPT real 1589/1589 e teste manual**, nem substituir a aceitação formal da B.

## Artefato FINAL da candidata R1 / PR Draft (16/10/2026)

- **PR #12 Draft:** https://github.com/peregrinoklawd/ServoPeregrino_Organizador/pull/12 (base: `baseline/weapons-uc001b-r2-approved`, sem merge).
- **CI vencedora pós-LEIA_PRIMEIRO:** https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862586403 — 37/37 static PASS.
- **Download do pacote mission-first:** https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/38862586403/artifacts/12030335992
- ZIP interno: `SP_ORG_Weapons_UC_001_C_Magazines_Wells_R1.zip`; SHA256 `da2a23abc445bf5f4724b73013d4ec3ff1e39e5b063269e90b2b373171a4ffe8`.
- A CI só confirma estrutura e empacotamento; a missão ainda precisa ser executada no Arma, com 1589/1589 alvo.
