# P1-C — aviso de dependência Policy sem Nexus e fechamento do gate SP (30/10/2026)

**Decisão de gate:** P1-C **HOMOLOGADO NO ESCOPO DE RUNTIME SINGLE-PLAYER (SP)**, considerando os testes positivos previamente auditados e a evidência visual do cenário negativo. Não equivale a homologação MP, distribuição assinada nem garantia de bloqueio do executável na ausência de dependência.

## Evidência adicional recebida

- Evidência: captura enviada pelo operador em 30/10/2026, arquivo original da conversa `image(20261030-215441).png`. A imagem não foi armazenada em binário neste repositório; o texto e a interpretação são preservados aqui. **Não inventar RPT para este cenário**.
- Procedimento relatado: Arma 3 iniciado com **apenas o addon Policy** (sem Nexus), após desativar Nexus no Launcher.
- Caixa de diálogo do Arma 3, transcrita da captura:

  ```text
  Addon 'ServoPeregrino_Organizador_Policy' requires addon
  'ServoPeregrino_Organizador_Nexus'
  ```

- Observação do operador: após confirmar o alerta, **o jogo continua abrindo**.

## Interpretação estrita

1. **PASS — reconhecimento da dependência ausente.** O motor percebe `requiredAddons` para `ServoPeregrino_Organizador_Nexus` ao tentar carregar o addon Policy sem Nexus, emitindo aviso específico com os dois nomes exatos. Isso fecha o cenário negativo originalmente previsto como **'recusa de dependência/erro reconhecível'**.
2. **NÃO COMPROVADO — bloqueio rígido do executável / supressão total do runtime Policy.** A engine não encerrou a inicialização do Arma 3. A captura não prova se houve descarte do addon, se as suas funções foram compiladas ou se a missão abriria. Não alegar nenhum desses comportamentos sem RPT adicional.
3. O cenário é de **dependência de distribuição/addon**, **não** do contrato de política obrigatória ausente (fail-closed de decisões), que foi testado separadamente nas baterias funcionais com ambos addons.
4. Em produção o operador deve carregar **Nexus + Policy** juntos. P1 não inclui instalador, auto-resolução de dependências, loader P2, assinatura, MP ou JIP.

## Matriz de fechamento P1

| Cenário | Evidência | Resultado |
|---|---|---|
| NONE sem addons (SP) | dois RPTs anteriores, 7/7 e 2 x 7/7 | PASS (controle negativo da missão) |
| NEXUS_ONLY (PBO real) | RPT 30/10, duas execuções 25/25 | PASS |
| BOTH (Nexus+Policy PBO reais, CBA/Canil) | RPT 30/10, duas execuções 50/50 | PASS |
| BOTH no modset BGD completo | RPT 30/10, 50/50 | PASS; ruído de terceiros auditado |
| POLICY_WITHOUT_NEXUS | captura de diálogo da engine 30/10 | **PASS para detecção de dependência; game continua abrindo; bloqueio absoluto não avaliado** |

Contabilidade dos RPTs positivos: 5 execuções, **200 asserções PASS, 0 FAIL**; contém baterias repetidas, não 200 IDs distintos. [Auditoria dos RPTs](P1_C_PBO_RUNTIME_3_RPTS_SP_PASS_20261030.md). [Build não binarizado e não assinado](../P1_C_PBO_BUILD_20261027.md).

## Conclusão e próximo marco

**P0 e P1 (A/B/C) homologados no escopo SP definido.** Nenhuma alteração em SQF ou rebuild de PBO foi necessária para o último gate. A propriedade `p1cHomologated=false` no runner de teste é marcador fixo de **decisão externa**; não foi alterada, nem invalida a homologação documental.

**Próximo trabalho autorizado:** planejamento e implementação do **P2 — loader estático de políticas**, com precedência de origem, estados, fallback interno, distinção required/optional e casos INVALID/PENDING, de forma mission-first para ciclos rápidos; preservar contrato P1 e autonomia BGD. **P2 ainda não foi implementado**.

**Risco residual deliberadamente aceito para encerramento P1-C:** sem RPT específico da inicialização Policy-only. Se futura distribuição precisar garantir 'engine não permite jogar/Policy não executa sem Nexus', criar gate de hard-block separado, não extrapolar a partir do popup.

Sem merge na main, sem alterações em Items/Weapons/UICommon, sem `CfgRemoteExec` global, sem alegação de MP/JIP/servidor autoritativo.
