# SP_ORG Items + Weapons UI Lab — Weapons 0.6-F R5

## ADENDO 21/10/2026 — Items UX R1 (candidata SP)

**Este adendo prevalece sobre o título R5 histórico abaixo para o pacote desta branch.**
- Baseline congelada: UICommon 0.2 FINAL de 07/10/2026, sem alteração em UICommon nem no runtime Weapons.
- Identidade do ZIP/mission: `SP_ORG_Items_UX_R1_UICommon_0_2_FINAL.VR`.
- Mudança Items: CAPTURAR mostra confirmação e **substitui as entradas do rascunho**, preservando identidade, sem autosave/alterar inventário físico; cancelamento sem mutação. Rascunho salvo intacto até SALVAR.
- Mudança Items: realce laranja `[1,0.76,0.28,0.18]` por linha divergente em relação ao snapshot salvo; referência visual Weapons, implementação de comparação exclusiva Items.
- Teste obrigatório: [ITEMS_UX_R1_TESTE_SINGLEPLAYER.md](ITEMS_UX_R1_TESTE_SINGLEPLAYER.md).
- Status: **source candidate; nenhum novo RPT/engine PASS nesta entrega ainda**. A biblioteca pública MP permanece pendente até testes com outro jogador.
- Usar missão self-contained sem PBOs SP_ORG para validação SP; pacote é versionado sem alterar o diretório de fonte da missão.

Missão **100% self-contained** para validar a candidata Weapons 0.6-F R5.
Não carregue PBOs do Servo Peregrino durante este teste.

## Conteúdo
- Nexus mission-first
- UICommon 0.1.1
- Items 0.13-A + UICommon Equivalence R1 preservado
- Weapons 0.6-F R5 — Dynamic Draft Authoring

## Escopo da R5
- mantém o preview 2D proporcional/centralizado da R4;
- mantém filtros compactos e uniformes do Catálogo;
- corrige o `;` ausente no tooltip de `CatalogSearch`;
- corrige no runner as expectativas antigas de rótulos longos;
- ao enviar uma **arma** do Catálogo sem nenhum kit selecionado, cria automaticamente um novo kit no rascunho;
- um kit existente pode trocar dinamicamente a arma-base entre Principal/Porte/Secundária;
- `targetSlot` continua existindo internamente, mas não é exibido em ARMAS DO KIT nem no contexto do rodapé;
- ao salvar uma troca entre categorias, `targetSlot + Recipe` são persistidos juntos;
- o fluxo direto para o rascunho mostra mensagens explicativas ao jogador, sem códigos internos como `WEAPONS_UI_*`;
- a missão não define política global `mode/jip` em `CfgRemoteExec`; somente declara endpoints necessários.

## Continua fora de escopo
- aplicação física de armas: 0.7;
- autoridade/JIP/reconciliação MP: 0.8;
- botões por ícone: evolução futura;
- preview 3D real: evolução futura;
- convergência visual própria do Items: separada.

## Teste manual recomendado
1. iniciar sem PBOs SP_ORG;
2. abrir Weapons com zero kits;
3. escolher uma arma no Catálogo e usar `← EQUIPAR NO RASCUNHO`;
4. confirmar que um novo kit é criado automaticamente e marcado como NOVO;
5. sem salvar, escolher uma arma de outra categoria (por exemplo Principal -> Porte ou Secundária);
6. confirmar que a troca acontece sem bloqueio de tipo/slot;
7. confirmar que ARMAS DO KIT não mostra ao jogador o tipo interno da arma;
8. salvar e reabrir o kit;
9. confirmar que a arma escolhida permaneceu;
10. testar um acessório incompatível e confirmar mensagem amigável;
11. validar buscas independentes, busca global, wheel/slider, renomear, DESCARTAR e SALVAR COMO NOVO;
12. executar `SP_ORG LAB - TESTAR WEAPONS 0.6-F R5`;
13. enviar RPT + prints.

## Gates
A R5 só é homologada após AUTO + manual + performance verdes no Arma.
