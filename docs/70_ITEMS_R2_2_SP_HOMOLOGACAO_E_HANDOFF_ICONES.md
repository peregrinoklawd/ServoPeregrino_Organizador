# Items / UICommon — R2.2 homologação SP e handoff da família de ícones

Data da validação: **2026-10-21**. Branch de origem: `feature/items-uicommon-brand-footer-r2-20261021`.

## 1. Decisão: R2.2 FECHADA no escopo testado

O operador executou em Arma 3 single-player, Virtual Reality, a missão:

`SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix.VR`

O operador enviou screenshot com UI Items aberta e o RPT `Texto colado(20261021-185835).txt`, e depois solicitou explicitamente **fechar a R2.2**. O screenshot confirma o logo BGD presente no header e a interface Items operante. O teste anterior R2.1 já havia confirmado o realce laranja de itens e CAPTURAR; essas rotinas foram preservadas byte a byte no hotfix R2.2.

### Evidência específica de engine/RPT

```text
15:55:12 Mission file: SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix
15:55:26 [SP_ORG] [UICOMMON] [INFO] UICommon inicializado. [...] build=0.2.0.11-header-brand-slot-r2-candidate
15:55:26 [SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] READY mode=SERVER revision=0 entries=0 scope=SESSION
15:56:09 [SP_ORG] [ITEMS] [BRAND_HEADER] pathAssigned=true source=MISSION idc=107 texture=C:\...\SP_ORG_Items_HeaderBGD_FooterR2_2_DiagnosticFix.VR\items\data\bgd_logo_ca.paa
15:56:36 Catalog CONFIG_ALL construído: 7092 itens elegíveis, 73470 configs visitados, 50735 candidatos, 26484 ms
15:57:44 [SP_ORG] [ITEMS] [UI_PERF] mode=CATALOG_FOCUSED [...] totalMs=14 [...] fullRefresh=false equipmentRecapture=false
```

No RPT apresentado **não reaparece** `Invalid path (only relative paths supported)` nem `Picture ...bgd_logo_ca.paa not found` após o hotfix. A origem anterior foi `fileExists` recebendo caminho absoluto; a remoção dessa sonda foi o **único delta runtime entre R2.1 e R2.2**. O novo log registra corretamente `pathAssigned`, sem alegar `fileExists=true`.

O screenshot mostra `HISTÓRICO` roxo, logo BGD e painéis sem regressão visual evidente. A regra do footer permanece a mesma: `#B9A3E8` pelo `UICommon_fnc_renderFooter`, inclusive `TARGET_ONLY`; não alterar esse contrato nesta etapa.

### Limites do aceite

**Aceito/Homologado**: **R2.2 no escopo de smoke SP de Items/UICommon (logo, correção da cor do footer, eliminação do erro de caminho, continuidade da UX R1)**. CI de pacote e paridade addon/mission já aprovados na candidata.

**NÃO homologado por este gate**:
- comportamento de autoria/publicação/sincronização em multiplayer da Items 0.13-A;
- PBO de produção de Items/UICommon e CfgRemoteExec na engine;
- regressão exaustiva de Weapons em outros módulos/releases (mission-first mantém código antigo do laboratório);
- todos os warnings de mods externos. O RPT ainda apresenta erros em `CBA_fnc_addPerFrameHandler` e warnings de mods; a associação causal com SP_ORG **não foi demonstrada**. Mantê-los em triagem externa sem bloquear o aceite restrito do hotfix.

R2.2 **não altera** a freeze original `baseline/uicommon-0.2-final-homologated@f92137769cf4d0478a5872aae157f5a229177c85`. UICommon 0.2.0.11 passou apenas pelo gate R2.2 SP; não chamar de versão pública FINAL nem mesclar na `main` automaticamente.

## 2. Histórico de releases de UI

| Checkpoint | Estado |
|---|---|
| Items 0.12 FINAL | Integration Freeze histórico preservado |
| UICommon 0.2.0.10 | Homologado em 07/10, fallback de regressão |
| Items UX R1 (CAPTURAR / linhas laranja) | Implementada e aprovada manualmente em SP; preservada |
| Items + UICommon R2 / R2.1 | Corrigidos footer e textura; R2.1 exibia logo mas sonda inválida gerava warning |
| **Items + UICommon R2.2** | **HOMOLOGADA em SP no escopo de logo + footer + diagnóstico** |
| Items 0.13-A Public Library | Código existente, **validação MP de clientes reais pendente** |

## 3. Escopo técnico congelado na R2.2

- UICommon: `SPORG_UICommon_HeaderBrand` genérico, sem marca institucional embutida.
- Items: controle IDC **107** recebe textura do BGD via `getMissionPath` (mission-first) ou addon path; `fileExists` removido; sem mudanças de arte/posição.
- Footer: todas as atualizações passam pelo renderer comum com `HISTÓRICO` roxo.
- CAPTURAR: confirmação antes de substituir `entries`, sem autosave e sem afetar kit persistido até SALVAR.
- Destaque: linhas alteradas laranja contra snapshot salvo, independente do status geral dirty.
- Weapons: nenhuma alteração de runtime nesta entrega.

**Preservar este estado como checkpoint antes de iniciar a implementação de ícones.**

## 4. Próxima frente — UX-ITEMS-04 Iconografia original

**O usuário aprovou o princípio, mas pediu R1 menos detalhada e priorização absoluta de silhueta identificável.** A R0 está disponível para comparação, não foi homologada.

Próximo gate: **três ícones R1 novos para Uniforme, Colete e Mochila**, reconhecíveis a 24 px, com no máximo 1 ou 2 recortes principais; proporção e peso semelhantes, off-white monocromático e fundo transparente. Testar lado a lado em 24 / 32 / 48 px e dois estados do botão (normal/selecionado) antes de integração.

A implementação futura deverá manter **ícone + texto** inicialmente em ambos os grupos de Items:
- `APP_TARGET` (2111 / 2112 / 2113) → seleção de destino;
- `EQUIPMENT_VIEW` (4110 / 4111 / 4112) → visualização do container.

Esses grupos são independentes: não alterar destino ao mudar visualização. Não desenhar estado verde nos PNGs (UICommon cuida da seleção). Não reutilizar silhuetas do ACE. Não mexer em Weapons, em lógica física ou em catálogo.

Após a aprovação artística: SVG/PNG fonte versionados, qualificação PAA/alpha/round-trip, renderização Arma SP e regression RPT, gate próprio antes da homologação. A família Weapons será planejada posteriormente usando o mesmo estilo.

## 5. Outras pendências preservadas

- Revisar microtextos de tooltips obsoletos (`Mostrar`, `Onde aplicar o kit?`, aviso antigo em Fechar).
- Reavaliar dirty geral após desfazer todas as diferenças do draft, sem mudar lógica por acidente.
- Catálogo grande: primeiro build em 26,484 s para 7.092 itens; refresh focal 13–14 ms. Otimizar em outro gate, sem interferir na integração visual.
- Testar Public Library 0.13-A com host+cliente real quando disponível; seguir 0.13-B JIP, 0.13-C persistência, 0.13-D ACL, 0.13-E robustez, 0.13-F integração Nexus.
