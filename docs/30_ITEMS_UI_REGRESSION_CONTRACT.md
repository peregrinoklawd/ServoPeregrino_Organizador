# Items — contrato mestre de regressão pós-UICommon

> **ATUALIZAÇÃO CANÔNICA — 22/10/2026:** este documento contém checkpoints de regressão anteriores à entrega Items UX R1. As frases abaixo que dizem que **CAPTURAR com confirmação** e o **realce laranja por linha** são funcionalidades futuras ficaram **SUPERADAS**: ambas foram implementadas e aprovadas manualmente em SP. A R2.2 também foi homologada em SP, com logo BGD e HISTÓRICO roxo. A biblioteca pública **0.13-A continua pendente de testes MP com clientes reais**. Para executar novos gates usar [homologação R2.2](70_ITEMS_R2_2_SP_HOMOLOGACAO_E_HANDOFF_ICONES.md) e [continuidade autossuficiente](74_CONTINUIDADE_AUTOSSUFICIENTE_ITEMS_POLICY_20261022.md). Não alterar os critérios históricos de regressão; interpretar a data de cada trecho.

## Atualização de leitura — Items + UICommon 0.2 FINAL (21/10/2026)

A redação deste documento nasceu em 01/10 e inclui algumas melhorias então **futuras** que foram realizadas depois, na UICommon 0.2 homologada em 07/10:

- P2 já se intitula **ITENS DO KIT**, com indicador geral **SALVO/ALTERADO**;
- P4 já usa **Visualizar:** e o destino Whole-Kit passou a **Qual o destino?**;
- o rodapé compartilhado e o focused refresh foram exercitados no RPT aprovado da UICommon 0.2 F1;
- os labels atuais e os tooltips legados podem divergir: auditar microtextos sem mudar semântica.

**Permanece futuro** o destaque individual de linhas de draft divergentes (nova entrada ou quantidade alterada), apesar de o título e o status geral já estarem implementados. O **CAPTURAR com diálogo de confirmação e substituição** está descrito em [64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md](64_ITEMS_FUTURE_CAPTURE_CONFIRMATION.md), ainda não implementado na baseline.

**Biblioteca pública multiplayer**: status pendente de teste completo com clientes reais, independentemente dos **16/16** checks de equivalência com UICommon. Para versão, branch, escopo de retomada e ordem de gates, consultar [ITEMS_CONTINUIDADE_RETOMADA_20261021.md](ITEMS_CONTINUIDADE_RETOMADA_20261021.md).

O checklist original abaixo continua válido para proteger as invariantes, exceto onde esta nota distingue algo já realizado de algo ainda futuro.

Data de criação: 2026-10-01.

## Objetivo

Este documento congela o comportamento de Items que não pode regredir durante a extração e adoção do UICommon.

A baseline de referência é a última versão PBO multiplayer testada pelo usuário em 01/10/2026.

Status adotado:
- **Items baseline multiplayer: HOMOLOGADA para as funcionalidades efetivamente testadas.**
- **Public Loadouts / biblioteca pública multiplayer: funcionalidade existente, mas validação manual completa ainda PENDENTE.**
- Pendência de teste NÃO significa falha.

A migração para UICommon deve preservar comportamento antes de introduzir mudanças de UX.

## Regra de gate

A adoção de UICommon em Items só pode ser considerada equivalente quando:
1. a suíte automática relevante não mostrar regressão nova;
2. o checklist manual abaixo não mostrar perda funcional;
3. performance de scroll/slider/refresh permanecer igual ou melhor;
4. o RPT não introduzir novo erro SP_ORG;
5. Public Loadouts permanecerem classificados separadamente até teste manual real.

## 1. Inicialização e interface

- [ ] Addon/missão carrega sem erro SP_ORG de config/SQF.
- [ ] Interface abre normalmente.
- [ ] Interface fecha e reabre sem perda indevida de estado.
- [ ] Quatro painéis permanecem íntegros.
- [ ] Layout funciona em 1080p e ultrawide.
- [ ] Header não apresenta sobreposição.
- [ ] Fechar permanece ancorado corretamente.
- [ ] Linguagem permanece player-facing.
- [ ] Buscas e controles de limpar permanecem coerentes.
- [ ] Wheel da UI não dispara PrevAction/NextAction do gameplay.

## 2. Catálogo

- [ ] CONFIG_ALL continua construído/cacheado corretamente.
- [ ] Conteúdo vanilla e modded permanece disponível.
- [ ] Busca textual funciona.
- [ ] Filtros/categorias funcionam.
- [ ] Ordenação permanece previsível por displayName/className.
- [ ] Lista permanece contínua, sem paginação perceptível.
- [ ] Wheel funciona.
- [ ] Slider contínuo funciona.
- [ ] Busca/filtro reposiciona janela corretamente.
- [ ] Virtualização evita materializar milhares de controles.
- [ ] Somente janela visível é renderizada.
- [ ] Scroll não dispara full refresh desnecessário.
- [ ] Seleção permanece correta durante scroll.
- [ ] Informações/imagem do item selecionado permanecem corretas.
- [ ] Tooltip funciona.
- [ ] Seta esquerda envia ao Draft/Rascunho.
- [ ] Seta direita altera o Equipment atualmente visualizado.
- [ ] Seta direita não usa indevidamente o destino de Whole-Kit.

## 3. Kit Selecionado / Draft

- [ ] Criar novo Draft.
- [ ] Carregar kit salvo.
- [ ] Alterar nome.
- [ ] Alterar destino preferencial.
- [ ] Adicionar item do Catálogo.
- [ ] Capturar item do Equipment.
- [ ] Merge de entradas iguais.
- [ ] Incrementar quantidade.
- [ ] Decrementar quantidade.
- [ ] Editar quantidade diretamente.
- [ ] Remover entrada.
- [ ] Quantidade 0 mantém a semântica destrutiva definida.
- [ ] Limpar conteúdo.
- [ ] Descartar alterações.
- [ ] Salvar Draft.
- [ ] Salvar como novo kit.
- [ ] Sem autosave silencioso.
- [ ] Refresh focal não perde texto digitado.
- [ ] Excluir backing kit preserva conteúdo aberto como Rascunho/Novo Kit.
- [ ] Seleção automática posterior não substitui silenciosamente Rascunho preservado.

## 4. Biblioteca privada

- [ ] Listar kits privados.
- [ ] Selecionar/trocar entre kits.
- [ ] Criar e salvar.
- [ ] Renomear.
- [ ] Duplicar/clonar.
- [ ] Excluir.
- [ ] Exclusões consecutivas mantêm seleção coerente.
- [ ] Repository privado permanece íntegro.
- [ ] Storage carrega.
- [ ] Storage salva.
- [ ] Migração/versionamento de storage não regride.
- [ ] IDs permanecem válidos/únicos.
- [ ] Cópias defensivas evitam mutação acidental.

## 5. Biblioteca pública — PENDENTE DE VALIDAÇÃO MANUAL COMPLETA

- [ ] Alternar PRIVADOS/PÚBLICOS.
- [ ] Biblioteca pública é read-only na UI.
- [ ] Busca pública funciona.
- [ ] Seleção pública funciona.
- [ ] PUBLICAR envia snapshot do kit privado.
- [ ] Republicar atualiza snapshot do mesmo source/author sem duplicar.
- [ ] Revisão pública incrementa corretamente.
- [ ] SALVAR NO PRIVADO gera novo ItemKit.
- [ ] Cópia pública não reutiliza publicId como private kitId.
- [ ] origin=["PUBLIC_COPY", publicId] é preservado.
- [ ] Nome copiado trata colisão corretamente.
- [ ] Copiar público -> privado não troca aba/busca/seleção pública.
- [ ] Badge COPIADO aparece e é transitório.
- [ ] Badge PUBLICADO aparece e é transitório.
- [ ] Som de cópia funciona.
- [ ] Som de publicação funciona.
- [ ] 0.13-A: cliente solicita publicação ao servidor.
- [ ] Servidor é autoridade exclusiva da mutação pública.
- [ ] Identidade pública do autor é derivada do remetente real.
- [ ] Cliente não acessa Repository privado de outro jogador.
- [ ] Callback remoto é aceito somente da autoridade esperada.
- [ ] Dois ou mais clientes observam a mesma revisão publicada.

Fora do escopo atual e NÃO tratados como regressão:
- JIP/reconciliation explícito;
- persistência após restart;
- ACL/moderação;
- rate-limit/retry/timeout/recovery avançados.

## 6. Conteúdo do Equipamento

- [ ] Uniforme.
- [ ] Colete.
- [ ] Mochila.
- [ ] Troca de visualização atualiza somente o necessário.
- [ ] Conteúdo físico exibido é correto.
- [ ] Linha mantém esquerda / imagem / nome / - / quantidade / + / X.
- [ ] - decrementa.
- [ ] + incrementa.
- [ ] Campo de quantidade funciona.
- [ ] X remove imediatamente.
- [ ] Delete remove conforme contrato.
- [ ] Magazine EXACT preserva state/ammo.
- [ ] Toda mutação física converge ao Application Engine existente.

## 7. Authorities independentes

- [ ] Onde aplicar o kit? governa Whole-Kit.
- [ ] Visualização física governa ações diretas.
- [ ] Mudar visualização não muda destino Whole-Kit.
- [ ] Mudar destino Whole-Kit não muda visualização.
- [ ] Seta direita do Catálogo obedece à visualização física.
- [ ] DnD físico mantém semântica definida.
- [ ] Futuro rótulo Visualizar: não altera essa independência.

## 8. Whole-Kit / Application Engine

- [ ] APLICAR.
- [ ] REMOVER.
- [ ] SUBSTITUIR.
- [ ] LIMPAR onde previsto.
- [ ] QUALQUER/ANY resolve destino.
- [ ] UNIFORME.
- [ ] COLETE.
- [ ] MOCHILA.
- [ ] Respeito à capacidade.
- [ ] Simulação/plano pré-mudança quando previsto.
- [ ] Lock de aplicação.
- [ ] Snapshot pré-mudança.
- [ ] Rollback em falha.
- [ ] Fingerprint detecta alteração relevante.
- [ ] EXACT não fabrica stateData.
- [ ] Aplicação de uma linha não vira Draft inteiro por engano.

## 9. Drag and Drop

- [ ] Catálogo -> Draft.
- [ ] Catálogo -> Equipment.
- [ ] Equipment -> Draft.
- [ ] Draft row -> Equipment.
- [ ] Kit -> área lógica conforme contrato.
- [ ] Kit -> destino físico conforme contrato.
- [ ] Drop aceita área ampla do painel.
- [ ] Nome/ícone iniciam drag onde previsto.
- [ ] Botões/quantidade não iniciam drag indevidamente.
- [ ] Snapshot do drag é imutável.
- [ ] Ghost aparece.
- [ ] Ghost acompanha mouse.
- [ ] Ghost reutiliza o mesmo controle durante move.
- [ ] Ghost não participa do hit-test.
- [ ] Ghost desaparece em DROP/CANCEL/UNLOAD.
- [ ] Tooltip some durante drag.
- [ ] DnD não causa full refresh indevido.
- [ ] Equipment -> Equipment continua rejeitado enquanto não houver semântica explícita.

## 10. Carga e capacidade

- [ ] Header usa carga global real do jogador.
- [ ] Métrica global inclui o loadout conforme semântica nativa.
- [ ] Massa player-facing em kg.
- [ ] Apresentação não altera cálculo interno.
- [ ] Percentual normal <=100%.
- [ ] 100%+ · SOBRECARGA quando necessário.
- [ ] Barra visual fica contida.
- [ ] Tooltip preserva percentual bruto/excesso.
- [ ] Capacidade Uniforme separada.
- [ ] Capacidade Colete separada.
- [ ] Capacidade Mochila separada.
- [ ] Usado / Total / Livre corretos.
- [ ] Carga global não é confundida com capacidade de container.

## 11. Tooltip, feedback e áudio

- [ ] Tooltip Catálogo.
- [ ] Tooltip Draft.
- [ ] Tooltip Equipment.
- [ ] Tooltip pass-through.
- [ ] Tooltip não interfere no DnD.
- [ ] CONTEXTO correto.
- [ ] RESULTADO correto.
- [ ] HISTÓRICO recente correto.
- [ ] Feedback evita popup desnecessário.
- [ ] Som de movimento.
- [ ] Som de cópia.
- [ ] Som de remoção quando previsto.
- [ ] Som de publicação.
- [ ] Falha não toca som de sucesso.

## 12. Performance

- [ ] Wheel fluido.
- [ ] Slider fluido.
- [ ] Busca não reconstrói painéis sem dependência.
- [ ] Equipment View atualiza apenas área dependente.
- [ ] Mutação de Draft atualiza apenas área dependente.
- [ ] Troca de kit pode usar refresh amplo quando necessário.
- [ ] Projeção/cache de catálogo é reaproveitada.
- [ ] Metadados não são recalculados sem necessidade.
- [ ] Row pool/controles são reutilizados.
- [ ] RPT não recebe flood de mouse/hover.
- [ ] Nenhum retorno a refreshes de centenas de ms por interação.

## 13. Multiplayer — baseline informada pelo usuário

- [ ] Host usa Items normalmente.
- [ ] Clientes usam Items normalmente.
- [ ] Ações locais permanecem funcionais em MP.
- [ ] Estado privado permanece do jogador correto.
- [ ] Sem regressão de DnD.
- [ ] Sem regressão de Whole-Kit.
- [ ] Sem regressão de EXACT.
- [ ] Sem regressão de Equipment.
- [ ] Sem regressão de áudio.
- [ ] Sem regressão de carga/capacidade.
- [ ] Public Loadouts permanecem PENDENTE até teste específico.

## Mudanças de convergência a aplicar somente após equivalência

Depois que Items + UICommon provar equivalência, aplicar em rodada explícita:
- KIT SELECIONADO / RASCUNHO;
- SALVO / ALTERADO / NOVO onde fizer sentido;
- Mostrar -> Visualizar;
- rodapé padronizado;
- mensagem "Vasculhando inventário e catalogando itens...";
- padrões compartilhados validados pela Weapons 0.6-E R2.

Não misturar essas mudanças com o primeiro gate de extração.


## Delta visual futuro — ITENS DO KIT

Requisito aceito em 02/10/2026, ainda NÃO implementado nesta baseline:

- título do painel P2: **ITENS DO KIT**;
- indicador de estado continua SALVO / ALTERADO / NOVO;
- quando o draft estiver baseado em kit salvo, comparar cada entrada atual com o snapshot original;
- linhas atuais divergentes devem receber background com o mesmo acento visual do estado **ALTERADO**;
- quantidade alterada conta como divergência;
- entrada adicionada conta como divergência;
- entrada removida não gera linha fantasma nesta especificação.

Novos checks manuais futuros:
1. carregar kit salvo -> nenhuma linha marcada;
2. aumentar quantidade -> somente a linha alterada é marcada;
3. reduzir quantidade -> somente a linha alterada é marcada;
4. adicionar item -> nova linha é marcada;
5. desfazer mudança até valor original -> marcação some;
6. salvar -> todas as marcações somem e estado volta a SALVO;
7. fechar/reabrir draft alterado -> marcação continua coerente com snapshot salvo.


## Regra compartilhada de estabilidade dos testes de UI

Decisão compartilhada registrada em 05/10/2026:

Testes automáticos de UI devem validar contratos funcionais e estruturais, não a identidade textual da entrega.

NÃO usar como gate:
- texto literal de versão no header;
- número da revisão exibido;
- nome textual da candidata;
- strings cosméticas que mudam entre releases sem alterar comportamento.

Preferir:
- controle existe/está visível;
- ordem/posição relativa quando isso é requisito de UX;
- estado do ViewModel;
- capability estável;
- resultado da ação;
- invariantes de dados;
- ausência de mutação indevida;
- performance/focused refresh quando aplicável.

A regra vale para Items, Weapons e futuros consumidores de UICommon.
