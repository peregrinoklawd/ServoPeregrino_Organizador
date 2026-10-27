# Policy P1-C — dois PBOs de teste gerados (27/10/2026)

**STATUS: ARTEFATOS DE RUNTIME GERADOS E ESTRUTURALMENTE VERIFICADOS; GATE P1-C CONTINUA ABERTO ATÉ RPT DO ARMA 3.**

## Fonte e pipeline

- Repositório: `peregrinoklawd/ServoPeregrino_Organizador`
- Branch: `feature/policy-0.1-b-nexus-integration` — **sem merge**
- Fonte de verdade: `addons/ServoPeregrino_Organizador_Nexus/` e `addons/ServoPeregrino_Organizador_Policy/`, **sem modificações nos SQFs**.
- Construtor reprodutível: `tools/build_p1c_pbos.py`
- Workflow CI: `.github/workflows/policy-p1c-pbo-lab.yml`
- [Build executado e concluído com sucesso](https://github.com/peregrinoklawd/ServoPeregrino_Organizador/actions/runs/40437476079), artifact ID `12704817198`, nome `SPORG_Policy_P1C_Unsigned_PBOs`.
- Commit de fonte usado: `a66cff143565f1b97623c3c9f854040337d36950`.
- Empacotamento: **PBO Arma com extensão de prefixo, config.cpp texto, arquivos SQF intactos, registro terminador e SHA-1 interno**. Não foi usado Arma 3 Tools/Addon Builder: **não binarizado, não assinado, não homologado no jogo**. Validação estrutural inclui parser/readback e conferência byte a byte de todos os membros.

| PBO | Entradas internas | Funções .sqf | Tamanho | SHA-256 |
|---|---:|---:|---:|---|
| `ServoPeregrino_Organizador_Nexus.pbo` | 23 | 21 | 37.542 bytes | `8acbfbf33467267fb9f66290d9ed78b5222ba32559b0cdf23b8d2794475139d3` |
| `ServoPeregrino_Organizador_Policy.pbo` | 8 | 6 | 13.844 bytes | `ef6421f4c20acf9320eca866f71f7195ba39f4b2032c2dbb608554418b22740c` |

- ZIP produzido pelo GitHub Actions, `SPORG_Policy_P1C_Unsigned_PBOs.zip`: SHA-256 `abeee07306042a0a635384c43c0b91e4e43425fd82916f2f67d7c7a413128a8e`. ZIP sem corrupção, 5 entradas (2 PBOs, manifest, provenance, leia primeiro).
- ZIP integrado fornecido no chat: `SPORG_Policy_P1C_Pacote_Completo_Instalacao_e_Testes.zip`: 24.703 bytes, SHA-256 `ddd2a4a4bb9fb482684dca21c454306af5c4e1f7824316276a165be04979384b`; contém **os mesmos PBOs**, mais a missão P1-C original de 4 arquivos e o `ROTEIRO_POLICY_P1C_PBOS.md`. Não foi gerado nova mission/harness.
- **Não colocar arquivos ZIP dentro da pasta de addons**. Os dois PBOs são separados por pastas de mod `@SPORG_Nexus_P1C` e `@SPORG_Policy_P1C`; ativar individualmente no Arma 3 Launcher.

## Gates de testes a executar

1. **NEXUS_ONLY**, sem Policy, modset SP mínimo. Esperar `scenario=NEXUS_ONLY`, `nexusPatch=true`, `policyPatch=false`, `status=PASS`/`fail=0`; anexar **RPT completo desde o startup**.
2. **BOTH**, Nexus+Policy sem BGD, mesmo laboratório. Esperar `scenario=BOTH`, `nexusPatch=true`, `policyPatch=true`, `missionCfgFunctions=false`, `status=PASS`/`fail=0`. Auditar `CfgPatches`, `CfgFunctions`, preInit, capacidades Nexus/Policy, deny-wins, fail closed e ausência de erros SQF.
3. **BOTH + BGD**, após aprovação do cenário minimalista; verificar regressão e avisos externos comparando o [controle NONE em BGD](evidence/P1_C_CONTROL_NONE_BGD_SP_RPT_PASS_20261027.md).
4. **POLICY_WITHOUT_NEXUS** como teste isolado posterior: engine pode impedir missão antes do runner; recolher RPT de inicialização.

**Interpretação:** `p1cHomologated=false` permanece marcador deliberado da necessidade de revisão humana. `addonRuntime=true` sozinho não prova que PBO foi carregado; prova advém de `nexusPatch=true` e `policyPatch=true`.

**Proibições preservadas:** nada em Items/Weapons/UICommon, nada de `CfgRemoteExec` global, nada de P2 loader/P5 UI/P6 autoridade, sem merge na main.

Documentos: [checkpoint do laboratório](P1_C_ADDON_RUNTIME_LAB_PREP_20261026.md), [continuidade P1](CONTINUIDADE_POLICY_P1B_P1C_20261026.md).
