# Items UX R2 — marca BGD no header e HISTÓRICO consistente

Data: 21/10/2026. **Candidata para teste Arma SP. Não homologada até RPT/manual.**

## Proveniência e branches

- Baseline congelada e comprovada: `baseline/uicommon-0.2-final-homologated@f92137769cf4d0478a5872aae157f5a229177c85` (07/10).
- Items UX R1 anterior: `feature/items-0.13-retomada-20261021`, testes manuais aprovados pelo usuário em 21/10, RPT enviado com `CAPTURE_EQUIPMENT_CONFIRMED`, refresh DRAFT_FOCUSED e ações DnD.
- **Branch R2 isolada:** `feature/items-uicommon-brand-footer-r2-20261021`, filha de Items UX R1. Não alterar/mergear a base congelada.
- Nova candidata UICommon: display 0.2, semantic **0.2.0.11**, build `0.2.0.11-header-brand-slot-r2-candidate`. A **0.2.0.10** continua o último UICommon homologado.
- Entrega testável: `SP_ORG_Items_HeaderBGD_FooterR2_UICommon_0_2_0_11.VR` (self-contained).

## 1. Root cause confirmado da faixa HISTÓRICO cinza

O renderer compartilhado `ServoPeregrino_Organizador_UICommon_fnc_renderFooter` recebe a banda 5002 com o rótulo `#B9A3E8` (roxo) e corpo `#D1C2F0`.

O caminho específico `fn_refreshPhysicalTargetUI.sqf`, utilizado por `APP_TARGET`/refresh físico e na troca de kits, sobrescrevia o controle 5002 diretamente com:

`(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];`

Isso introduzia o cinza `#81918E` em **todos** os refreshes TARGET_ONLY. Não era regra de status ou histórico vazio, mas inconsistência entre renderers.

**Fix**: TARGET_ONLY agora envia CONTEXTO, RESULTADO e HISTÓRICO ao mesmo `UICommon_fnc_renderFooter`, com o mesmo token roxo e escape compartilhado. Não altera conteúdo histórico, mutations, performance de catálogo nem semântica de destinos.

Obs.: a superfície escura translúcida sob a faixa (FooterHistoryBg) é intencional e continua igual. O bug corrigido é **cor dos textos/rótulo**, não o fundo da banda.

## 2. Asset canônico e importação rastreável

Fonte **BGD-HQ**: `RicGonzalezb/bgd-hq@main:comunicacao-social/identidade/assets/bgd-logo-primary.png`.

- SHA blob do PNG no BGD-HQ: `2916a99374ca8d13602dd7034ede7e2b84000294`.
- Copiado **sem mudanças de bytes** para `assets/branding/bgd/bgd-logo-primary.png` (SHA blob **idêntico**).
- É a marca principal monocromática da BGD segundo o catálogo canônico do BGD-HQ. **Não confundir** com logo de BGD Aviation ou Taurus.
- O PNG original tem fundo preto e dimensão original não potências de dois. Não usar diretamente em RscPicture.
- Derivado técnico Arma: `bgd_logo_ca.paa`, DXT5 alfa sobre transparência, canvas 256x256, branco preservado, proporção original preservada. A fonte PNG permanece imutável.
- Build reproduzível: `tools/brand/convert_png_to_paa.go` com pacote open-source `github.com/woozymasta/paa@v0.2.0` (biblioteca permissiva), execução automatizada em `.github/workflows/build-bgd-header-texture.yml`.
- Cópias equivalentes do PAA:
  - `addons/ServoPeregrino_Organizador_Items/data/bgd_logo_ca.paa`;
  - `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR/items/data/bgd_logo_ca.paa`.
- CI verificou geração das duas cópias. O render no engine **precisa ser testado**.

## 3. Ownership: UICommon genérico, Items fornecedor da marca

- `SPORG_UICommon_HeaderBrand` herda `SPORG_UICommon_PictureKeepAspect` e só padroniza imagem com transparência, sem nome BGD, sem asset ou lógica de domínio.
- Items define `SPORG_Items_HeaderBrand` e configura `FutureIconSlot` (IDC **107**, **mesma posição e dimensões** de antes) com a textura `bgd_logo_ca.paa` e tooltip institucional.
- A compilação addon usa `\ServoPeregrino_Organizador_Items\data\bgd_logo_ca.paa`.
- A missão self-contained ativa `SPORG_ITEMS_MISSION_BRAND_TEXTURE` antes de incluir `items_dialog.hpp`, usando `items\data\bgd_logo_ca.paa`; remove o define antes de compilar Weapons.
- `items_dialog.hpp` addon/mission são **idênticos**; apenas o define de contexto altera o caminho no pré-processamento. O PAA é duplicado byte a byte.
- Weapons mantém o próprio `FutureIconSlot` neutro. **Não injetar logo da BGD automaticamente em Weapons** sem validação posterior; não mexer nos filtros ou ícones.
- UICommon 0.2.0.10 permanece congelado no branch baseline; 0.2.0.11 R2 não foi declarado homologado.

## 4. Gates

**Estáticos**: PNG SHA original preservado; PAA presente nas duas árvores e com mesmo SHA; cabeçalho DXT5; paridade HPP/refresh; footer em `#B9A3E8` mesmo no TARGET_ONLY; UICommon genérico sem asset BGD; Weapons unchanged; saída ZIP self-contained.

**Manuais SP**:
1. abrir Items com 16:9 ou ultrawide e verificar **BGD completo** no slot onde antes havia vazio; textura nítida, transparente e sem distorção; tooltip;
2. abrir e conferir HISTÓRICO roxo; selecionar destinos ANY/UNIFORME/COLETE/MOCHILA, trocar `Visualizar:` e kits; pesquisar/adicionar/mover itens; HISTÓRICO deve permanecer roxo depois de qualquer atualização;
3. testar Resultado com mensagens INFO/WARN/SUCCESS para confirmar suas **cores dinâmicas inalteradas**, enquanto HISTÓRICO não muda;
4. validar CAPTURAR (cancelar/confirmar/substituir), realce laranja (aumentar/diminuir/salvar), DnD, slider e `DRAFT_FOCUSED`/CATALOG_FOCUSED;
5. abrir Weapons no mesmo laboratório; a UI/fluxos Weapons continuam inalterados; nenhuma marca auto-injetada lá;
6. executar testes automáticos da missão e enviar RPT completo + prints do header e footer antes/depois de APP_TARGET.

**Não fazemos afirmação de sucesso em runtime antes do RPT.** Autoridade pública MP Items 0.13-A continua com gate próprio pendente; botões/iconografia Items/Weapons permanecem backlog separado.
