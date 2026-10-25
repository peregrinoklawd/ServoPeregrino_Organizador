# Policy P0 — contratos v1 e viabilidade (fechado em 25/10/2026)

**Status: CONCLUÍDO NO ESCOPO DE CONTRATOS E LABORATÓRIO SP.** RPTs reais: A/B 20/20 PASS; C–F 140/140 PASS históricos (regex anterior); auditoria G REVIEW identificou 532 elegíveis fora da regra anterior; G2 PASS 12/12 recuperou os 532, sem incompatibilidades restantes; nova regressão H **156/156 PASS**, 0 erros SQF; Python revisado **8/8 PASS**, **32 fixtures**. **Não há addon Policy instalado, PBO homologado, loader em uso, integração Items/Weapons ou autoridade multiplayer validada nesta fase.**

**Fonte de evidência:** [A/B](evidence/P0_SP_SMOKE_RPT_20261024.md), [C–F histórico](evidence/P0_NEGATIVE_SP_RPT_20261024.md), [G](evidence/P0_G_CLASSNAME_AUDIT_RPT_20261025.md), [G2](evidence/P0_G2_REGEX_COMPARISON_RPT_20261025.md), [H](evidence/P0_H_REVISED_CLASSNAME_SQF_RPT_20261025.md) e [Python revisado](evidence/P0_G2_PYTHON_REGRESSION_20261025.md).

**Branch de encerramento original:** `feature/policy-0.1-p0-contracts`. **Branch de continuidade:** `feature/policy-0.1-a-core`, criada da anterior para P1. Baseline de Items/UICommon preservada: `baseline/items-uicommon-r2-2-sp-homologated-20261021`.

> Nota documental: esta versão recompõe a seção 2.1 que havia sofrido duplicação acidental de trechos em uma edição anterior. Não altera as decisões técnicas homologadas.

## 1. Escopo e ownership

Policy é um **addon opcional**, dependência planejada apenas do **Nexus**, proprietário das regras whitelist/blacklist aplicáveis a classes exatas de Items, Weapons, acessórios, magazines e equipamentos. Sem Policy instalada e sem obrigatoriedade explícita, consumidores mantêm modo OPEN. A existência de classe no modset (`isClass` / ambiente) **não** é autorização Policy; compatibilidade física de acessórios/munições (`compatibleItems`, `compatibleMagazines`) pertence a Weapons. Role Kits e adapters BGD/FTAC ficam fora do MVP; BGD não é dependência obrigatória.

Uma política **obrigatória** cujo snapshot esteja `PENDING`, `INVALID` ou ausente não pode autorizar operações de ADD/APPLY por omissão (*fail closed*). Remoções de itens já presentes podem permanecer disponíveis conforme regra do consumidor. Kits persistidos não devem ser destruídos por alterações de política ou ausência temporária de mods.

## 2. Contratos de dados

### 2.1 PolicyExport v1 (portátil e sem autoridade)

```json
{
  "schema": "SPORG_POLICY_EXPORT",
  "schemaVersion": 1,
  "whitelist": ["FirstAidKit", "30Rnd_556x45_Stanag"],
  "blacklist": ["ItemGPS", "121_SP10M_18_FDE"]
}
```

**Campos exatos:** `schema`, `schemaVersion`, `whitelist`, `blacklist`; quaisquer outros rejeitados, especialmente `admin`, `source`, `revision`, `fingerprint` e fragmentos SQF. Versão é número inteiro 1. Listas são arrays de strings, até **4.096 entradas cada**. Texto serializado limitado a **512 KiB**. Cada classname passa por `trim`, exige **1–128 caracteres** com formato final **`^[A-Za-z0-9_]{1,128}$`**, com **dígito inicial permitido**. Rejeitar duplicação case-insensitive **dentro da mesma lista**, preservar escrita original para exibição; usar `toLowerANSI` em comparações/índices. A presença da mesma classe em ambas as listas não invalida o documento: **blacklist vence** e conflito pode ser exposto ao editor.

A regra de nome foi confrontada com **133.399 classes reais** na modlist usada na auditoria; o máximo encontrado foi 78 caracteres. O resultado não é prova universal para todos os mods futuros. Importação e exportação futura usam `fromJSON`/`toJSON`; **nunca avaliar texto importado como código**. O P1 opera sobre HashMap já interpretado; interface/importação externa pertence ao P5.

### 2.2 PolicySnapshot v1

```json
{
  "schema": "SPORG_POLICY_SNAPSHOT",
  "schemaVersion": 1,
  "state": "ACTIVE",
  "source": "ADDON_FALLBACK",
  "revision": 1,
  "fingerprint": "IMPLEMENTATION_DEFINED",
  "whitelist": [],
  "blacklist": []
}
```

Estados possíveis: **ACTIVE, PENDING, INVALID, ABSENT**. Fontes conceituais: **ADDON_FALLBACK, MISSION_EXPLICIT, SERVER_ACTIVE, NONE**. `revision` e `fingerprint` pertencem à instância confiável da política. `revision` monotônico só após existir publicador autoritativo; fingerprint identifica conteúdo canônico, não é assinatura de segurança. Clientes não enviam revisão ou origem que valha como autoridade. Índices de consulta (`HashMap`) ficam **separados do DTO**. P1 pode gerar contexto **não autoritativo** para testes (`revision=0`, fingerprint explícito), sem alegar que uma fonte server-side foi ativada.

### 2.3 PolicyDecision v1

```json
{
  "schema": "SPORG_POLICY_DECISION",
  "schemaVersion": 1,
  "className": "ItemGPS",
  "allowed": false,
  "code": "POLICY_DENY_BLACKLIST",
  "source": "SERVER_ACTIVE",
  "revision": 1,
  "fingerprint": "IMPLEMENTATION_DEFINED"
}
```

Códigos: `POLICY_ALLOW_OPEN`, `POLICY_ALLOW_WHITELIST`, `POLICY_DENY_BLACKLIST`, `POLICY_DENY_NOT_WHITELIST`, `POLICY_NOT_READY`, `POLICY_INVALID`. A decisão por classe: (1) blacklist contém → DENY; (2) whitelist não vazia e classe ausente dela → DENY; (3) whitelist preenchida contendo classe → ALLOW_WHITELIST; (4) whitelist vazia e classe não bloqueada → ALLOW_OPEN. Ambas vazias = OPEN. `ABSENT` apenas é OPEN quando Policy é opcional; `PENDING`/`INVALID` nunca são OPEN.

O resultado de `evaluate` **não substitui** a validação ambiental nem autoriza mutações no servidor. Em P6 o executor revalidará a revisão mais recente no servidor.

## 3. Fontes e precedência — implementação futura P2/P6

Fonte interna candidata: `configFile >> "CfgSPORGPolicy"`, declarada exclusivamente pelo addon Policy. Opt-in do operador na missão: `missionConfigFile >> "CfgSPORGPolicy"` com `enabled=1`, `schemaVersion=1` e arrays explícitos. Fonte autoritativa ativada pelo servidor futuramente (P6) prevalece sobre missão; missão válida prevalece sobre fallback interno. Configuração explícita inválida resulta em `INVALID`, **não em fallback OPEN silencioso**.

```cpp
// Apenas exemplo de description.ext — não instalado por P1.
class CfgSPORGPolicy
{
    enabled = 1;
    schemaVersion = 1;
    whitelist[] = {};
    blacklist[] = {"ItemGPS"};
};
```

Não inferir que `server.cfg` é diretamente legível como `configFile`, nem prometer arquivos externos genéricos sem adapter/spike. A política inicial é **estática por sessão**. Ativação ao vivo pelo administrador e notificação dos clientes são capacidades futuras opcionais.

## 4. Nexus e consumo pelos outros módulos

Nexus possui registro de capabilities por ID, versão, provider e metadata; ele **não despacha automaticamente** funções por strings. Capabilities candidatas `policy.evaluate` v1 e `policy.snapshot` v1; provider `ServoPeregrino_Organizador_Policy`. Consumidores devem testar a capacidade/versão e chamar funções públicas fixas, nunca `compile` de textos enviados por cliente.

Editor administrativo deverá enxergar **catálogo base completo**, inclusive itens proibidos, para configurar regras. Jogador verá projeção autorizada. Alteração de revisão invalida apenas projeção de autorização e diagnósticos de kit; não força o scan custoso de `CONFIG_ALL` de Items. Ausência de mod: vermelho; classe presente porém proibida: amarelo; rascunho alterado: laranja (ausência tem precedência). A ordem amarelo/laranja quando simultâneos requer validação UX.

## 5. Gates e fronteiras

- **P0 fechado:** contratos v1 e viabilidade em single-player, após G2 e H.
- **P1:** construir motor puro SQF e registrar capabilities, sem loader ou autoridade MP; entrega de addon source é candidata até RPT próprio.
- **P2:** loader de fallback/mission e estado efetivo estático por sessão.
- **P3/P4:** integração Items, cache/projeção, diagnóstico e aplicação segura parcial; não destruir kits.
- **P5:** editor, portabilidade de JSON, refresh e persistência local de rascunho.
- **P6:** autenticação admin, ativação servidor, revisão e sincronismo MP/JIP, autoridade em cada mutação.
- **P7:** adapters opcionais, hardening e distribuição/PBO.

**Segurança:** não definir propriedades globais `mode`/`jip` em `CfgRemoteExec` do addon; usar funções especificamente autorizadas após revisão de MP. Clipboard `copyFromClipboard` tem limitações no multiplayer; interface alternativa será testada em P5. Arquivos externos e file-patching precisam avaliação própria.

**Referências complementares:** [Roadmap](ROADMAP.md), [Policy](../../modules/Policy.md), [continuidade P0](../../75_POLICY_P0_CONTINUIDADE_20261024.md), [Bohemia missionConfigFile](https://community.bistudio.com/wiki/missionConfigFile), [Bohemia fromJSON](https://community.bistudio.com/wiki/fromJSON) e [Bohemia Arma 3 server security](https://community.bistudio.com/wiki/Arma_3:_Server_Security).
