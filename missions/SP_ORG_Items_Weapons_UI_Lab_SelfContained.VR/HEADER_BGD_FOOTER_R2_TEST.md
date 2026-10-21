# SP_ORG Items Header BGD / Footer R2 — instruções rápidas

**CANDIDATA R2, não homologada.** Esta missão é self-contained (Nexus, UICommon e Items/Weapons); desative os PBOs do SP_ORG para não carregar duas versões dos módulos.

## O que verificar

1. Abra a interface **Items** e observe o slot do header: o logo **BGD (crânio com chifres)** precisa aparecer centralizado, branco, com fundo transparente, sem deformação.
2. Observe a palavra **HISTÓRICO** no rodapé: cor **roxa** desde a primeira abertura.
3. Acione **Qual o destino?** várias vezes (Qualquer, Uniforme, Colete, Mochila), inclusive após trocar kits. Este era o caminho que forçava o cinza: a palavra HISTÓRICO deve continuar roxa **após cada clique**.
4. Troque **Visualizar:** Uniforme/Colete/Mochila, altere quantidades no rascunho, filtre Catálogo, arraste itens, use CAPTURAR (Cancelar/Confirmar), salve. HISTÓRICO não pode ficar cinza. RESULTADO pode variar de cor conforme tipo de resposta.
5. Regressão UX R1: linhas alteradas ficam laranja e perdem laranja ao retornar ao snapshot salvo; CAPTURAR substitui entries somente depois da confirmação.
6. Abra também Weapons e confirme que não há mudança de logo/posição/filtros: a infraestrutura compartilhada deve manter a interface homologada.
7. Execute os testes automáticos do laboratório e forneça **RPT + screenshot** do logo e do HISTÓRICO antes/depois da troca de destino.

### Diagnóstico

Root cause do cinza: `fn_refreshPhysicalTargetUI.sqf` aplicava `#81918E` diretamente na faixa 5002. Agora usa `UICommon_fnc_renderFooter` com `#B9A3E8` de forma igual aos outros refreshes.

Asset oficial: `assets/branding/bgd/bgd-logo-primary.png`, derivado Arma: `items/data/bgd_logo_ca.paa`.

Baseline: UICommon **0.2.0.10 homologada 07/10**; candidato **0.2.0.11**. Item 0.13-A MP segue pendente; entrega de botões gráficos está fora deste escopo.
