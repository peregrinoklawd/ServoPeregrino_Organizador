# Backlog de iconografia original — família SP_ORG

**Data:** 22/10/2026  
**Status:** BACKLOG ARQUIVADO / **NÃO INICIAR INTEGRAÇÃO NA UI NESTE MOMENTO**.  
**Decisão vigente:** Items e Weapons mantêm **botões somente com texto** até nova autorização. O objetivo deste documento é impedir perda de ideias e preservar a coerência entre módulos.

## Regras da família visual

- Não copiar, reproduzir ou traçar ícones do ACE Arsenal; inspiração limitada à legibilidade por silhueta.
- Formas originais, limpas, reconhecíveis em 24px; mesma densidade óptica entre ícones.
- Monocromático sobre alfa transparente, sem fundo, estado ou cor de seleção gravados no asset.
- Separar arte-master aprovada de derivados técnicos (SVG, PNG, PAA), com SHA e revisão; pipeline ImageToPAA/round-trip/render Arma.
- UICommon é dono apenas de controles genéricos e estados visuais; cada módulo define o significado e fornece o asset.
- Não misturar seleção do destino de aplicação com seleção do equipamento visualizado, nem usar cor/símbolo de autorização sem estudo de contraste.
- Nada deve ser publicado como asset de runtime antes de review artístico e gates de SP/RPT.

## Prioridade 1 — Weapons (9 ícones)

| ID | Nome aprovado para backlog | Papel visual a distinguir |
|---|---|---|
| W-01 | **Arma Principal** | Arma longa principal |
| W-02 | **Arma Porte** | Pistola/arma curta |
| W-03 | **Arma Lançador** | Arma/lançador secundário; diferenciar de principal |
| W-04 | **Mira** | Óptica/mira |
| W-05 | **Apontador** | Laser/lanterna/dispositivo apontador |
| W-06 | **Boca** | Dispositivo de boca da arma (ex.: muzzle) |
| W-07 | **Bipe** | Apoio de dois pés |
| W-08 | **Carregador** | Munição/carregador da alimentação principal |
| W-09 | **Carregador Secundário** | Segunda alimentação, segundo cano ou lançador acoplado; **não confundir com carregador principal** |

**Observação de domínio:** W-09 foi pedido explicitamente para distinguir as munições de lançador ou canos adicionais que hoje podem aparecer no mesmo seletor de carregadores. **Criar o ícone não corrige automaticamente essa separação funcional**: Weapons precisa primeiro definir slots e compatibilidade de munição por arma. Essa decisão será tratada pela própria trilha Weapons, não pelo UICommon.

A família visual será útil aos filtros de acessórios e menus de arma, mas seu contrato técnico depende da versão homologada da interface Weapons vigente no momento da implementação; **não reconstruir de memória a branch atual**.

## Prioridade 2 — Outros módulos / equipamento (9 ícones)

| ID | Nome | Uso previsto |
|---|---|---|
| E-01 | **Capacete/Gorro (Headgear)** | Cobertura de cabeça |
| E-02 | **Item de rosto (Facewear)** | Máscara/balaclava/peça facial |
| E-03 | **Óculos de visão noturna** | NVG |
| E-04 | **Binóculo/Telemetro** | Observação e aferição de distância |
| E-05 | **Mapa** | Ferramenta de navegação |
| E-06 | **Terminal / UAV** | Controle/terminal de veículos não tripulados |
| E-07 | **Bússola** | Orientação |
| E-08 | **Rádio** | Comunicações |
| E-09 | **Relógio** | Tempo/hora/azimute, conforme módulo |

São ideias para Equipment/Weapons/Hub e outros módulos. **Não existe definição de IDC ou obrigação de implementação**; os módulos consumidores serão definidos conforme a necessidade real.

## Família Items já escolhida (preservada, mas UI em pausa)

Três PNGs **aprovados pelo usuário e versionados com hash verificado**:

- `assets/ui/icons/items/approved/uniforme_aprovado_original.png`;
- `assets/ui/icons/items/approved/colete_1_aprovado_original.png`;
- `assets/ui/icons/items/approved/mochila_corrigida_aprovada_original.png`.

Os masters **não devem ser redesenhados nem substituídos**. A geração de PAA/integração está **suspensa por decisão do usuário**; os botões permanecem texto. Consultar `assets/ui/icons/items/approved/SELECTION_20261021.json`.

## Plano de retomada quando autorizado

1. Definir a família visual de referência a partir dos masters Items aprovados e discutir as diferenças necessárias de Weapons.
2. Produzir poucas silhuetas candidatas por ícone, revisar em 24/32/48px, sem produzir todos de uma vez.
3. Aprovar ícones por conjunto de domínio (armas/slots, acessórios, equipamentos).
4. Versionar arte master; derivar e validar PAA, alfa, mipmaps e render.
5. Integrar ícone + texto em entrega isolada, sem alterar semântica de botões, testar mouse/keyboard/hover/selected e RPT.
6. Migrar para botões sem texto **somente com decisão posterior do usuário**.

**Todos os 18 ícones das duas listas continuam BACKLOG, não assets aprovados e não trabalho já executado.**
