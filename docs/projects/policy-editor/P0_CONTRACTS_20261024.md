# P0 — Contratos de Policy e prova de viabilidade (24/10/2026)

**Status atualizado após ambos os RPTs de 24/10:** **smoke Arma SP A/B 20/20 PASS + C/D/E/F 140/140 PASS = 160/160 PASS, 0 FAIL**. P0 permanece **EM REVISÃO FINAL DE CONTRATOS** (regex com modset real e suíte Python); runtime addon e MP continuam não implementados/testados. Evidências: [A/B](evidence/P0_SP_SMOKE_RPT_20261024.md), [C–F](evidence/P0_NEGATIVE_SP_RPT_20261024.md).  
**Baseline imutável:** `baseline/items-uicommon-r2-2-sp-homologated-20261021` (`67f4574`).  
**Branch:** `feature/policy-0.1-p0-contracts`.  
**Ownership:** addon opcional `ServoPeregrino_Organizador_Policy`, depende só de Nexus. Sem runtime Policy instalado nesta entrega.

## 1. Fronteiras e decisões

1. Policy decide **autorização exata de classname**; não substitui `isClass`, que decide existência/ambiente. Role Kits e adapters BGD/FTAC excluídos do MVP.
2. Duas listas vazias = OPEN; branca não vazia = filtro obrigatório; negra não vazia = exclusão; interseção = DENY. Cliente comum não controla regras autoritativas.
3. Sem Policy instalada e sem exigência de sincronismo Policy: módulos consumidores mantêm comportamento OPEN (compatibilidade). Com política autoritativa **exigida**, mas snapshot pendente, inválido ou versão incompatível: bloquear **ADDS/APPLY protegidos**, não inventar OPEN.
4. **Política estática por sessão** no MVP. Não construir hot reload como requisito P1/P2.
5. Não tocar em `CfgRemoteExec` global, UICommon, Items e Weapons no P0.

## 2. Representações — schema v1 (contrato proposto)

### 2.1 PolicyExport (portabilidade, somente dados)

~~~json
{
  "schema": "SPORG_POLICY_EXPORT",
  "schemaVersion": 1,
  "whitelist": ["FirstAidKit", "ItemGPS"],
  "blacklist": ["ItemGPS"]
}
~~~

Campos **exatos**; `schema` string constante; `schemaVersion` inteiro 1; listas de strings, sem aninhamento. Campos não reconhecidos são **rejeitados**, sobretudo `serverRevision`, `admin`, `source` ou funções/fragmentos de SQF. Tamanho máximo proposto: 4096 entradas por lista, 128 caracteres por classname, 512 KiB de texto de entrada; confirmar limites por teste de engine/uso real.

**Normalização:** trim de espaços laterais; comparação por `toLowerANSI`; manter ortografia original válida para exibição/consulta ao config. MVP somente identificadores com letras ASCII, dígitos e `_`, começando por letra ou `_`. **Essa regra é provisória até amostragem de classes dos mods do usuário.** Rejeitar duplicatas case-insensitive dentro da mesma lista. Uma classe nas duas listas **não é schema inválido**: é conflito informado e a blacklist vence.

Formato importável: JSON via `fromJSON` / `toJSON` (disponíveis no Arma 3 2.18, versão mínima atual do Nexus). **Nunca `compile` / `call compile` sobre texto importado.** Validar tipos, limites, chaves e versão antes de criar/ativar snapshot. A ordem das chaves no JSON não é garantia de hash; canonicalizar listas ordenadas case-insensitive para fingerprints determinísticos. `toJSON` só recebe tipos permitidos.

### 2.2 PolicySnapshot (efetivo em sessão)

HashMap conceitual:
~~~json
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
~~~

`state`: `ACTIVE`, `PENDING`, `INVALID`, `ABSENT`; `source`: `ADDON_FALLBACK`, `MISSION_EXPLICIT`, `SERVER_ACTIVE` e `NONE`. `revision` cresce monotonamente **somente no servidor autoritativo**, nunca do payload importado. `fingerprint` identifica conteúdo após normalização, **não é assinatura criptográfica nem autorização**. `whitelist/blacklist` são dados serializáveis; índices de lookup `HashMap` separados do DTO no runtime. Não confiar em `revision/source/fingerprint` enviados por clientes.

### 2.3 PolicyDecision (resultado por classe)

HashMap/Result Nexus proposto:
~~~json
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
~~~

Códigos: `POLICY_ALLOW_OPEN`, `POLICY_ALLOW_WHITELIST`, `POLICY_DENY_BLACKLIST`, `POLICY_DENY_NOT_WHITELIST`, `POLICY_NOT_READY`, `POLICY_INVALID`. Validar `className`; não misturar `ITEMS_CLASS_UNAVAILABLE` neste resultado: a indisponibilidade ambiental é uma segunda dimensão, verificada pelo consumidor. Precedência visual *ausente vermelho > proibido amarelo > alterado laranja*, com amarelo x laranja ainda sujeito ao gate de UX.

**Regra de decisão:** blacklist contém classe => DENY; senão whitelist não vazia e não contém => DENY; senão whitelist não vazia => ALLOW_WHITELIST; senão => ALLOW_OPEN. Em `PENDING/INVALID` exigidos, nunca permitir ADD/APPLY. Em `ABSENT` opcional, compatibilidade OPEN. Resposta de `evaluate` **não autoriza o cliente MP a aplicar mutação**; executor valida em servidor na revisão vigente (P6).

## 3. Configuração — convenção candidata para P1/P2

**Addon interno:** `configFile >> "CfgSPORGPolicy"`, declarado **somente no futuro config.cpp do Policy** com `schemaVersion=1`, `whitelist[]={}`, `blacklist[]={}`. Isso ainda não existe em código. Não ler `CfgSPORGPolicy` de addons terceiros por autodiscovery.

**Opt-in do operador de missão:** `missionConfigFile >> "CfgSPORGPolicy"` em `description.ext`, exigindo `enabled=1` e `schemaVersion=1`, e listas declaradas. Ao iniciar, servidor lê e valida; caso a classe não exista ou `enabled != 1`, usa fallback interno. Se a fonte explícita existe e falha validação, retornar `INVALID`/diagnóstico, **não cair silenciosamente no fallback OPEN**.

~~~cpp
// description.ext da missão — exemplo do P0, NÃO instalado automaticamente
class CfgSPORGPolicy
{
    enabled = 1;
    schemaVersion = 1;
    whitelist[] = {};
    blacklist[] = {"ItemGPS"};
};
~~~

Hierarquia de fonte: `SERVER_ACTIVE` (somente autorização de servidor, pós-P6) > `MISSION_EXPLICIT` válida > `ADDON_FALLBACK`. **Não prometemos compatibilidade direta de `server.cfg` ou arquivos externos arbitrários**: `server.cfg` não é um `configFile` genérico da missão; edição fora do PBO, include via userconfig e adapters de arquivos necessitam spike separado. Um operador pode manter valores na missão/arquivo incluído conhecido, desde que o build seja feito com esse arquivo incluído.

## 4. Interoperabilidade Nexus e catálogo

O Nexus atual registra capabilities por `id/version/provider/metadata` e **não faz dispatch automático de funções**. Contrato candidato para P1: `policy.evaluate` v1 e `policy.snapshot` v1, publicados por Policy, `provider="ServoPeregrino_Organizador_Policy"`. Consumidores verificam `hasCapability`/versão, obtêm metadata, e usam **funções SQF públicas fixas/validadas**, não `compile` de provider ou id vindo de payload.

Provider de catálogo para futuro Editor: `catalog.base.items` v1 pode mapear ao `Items_fnc_getCatalog`, mas **somente quando Items estiver instalado**, com semântica de catálogo **não filtrado**. Hoje `Items_fnc_getCatalog` devolve o cache base e cria uma cópia por entrada; **não alterar isso neste P0**. Se Items ausente, editor deve oferecer provider opcional próprio reutilizável/paginação; *não* prometer scanner pronto. Evitar duplicar o scan de 73k classes. `Items_fnc_invalidateCatalogCache` realmente invalida o cache **base** e pode forçar 24–27 s de scan; não usar para refresh de revisão Policy.

## 5. Viabilidade: o que sabemos versus o que falta testar

| Área | Evidência | Consequência P0 |
|---|---|---|
| Config de missão | `missionConfigFile` lê `description.ext` | Opt-in explícito em missão é caminho candidato verificável em SP |
| JSON nativo | `fromJSON` / `toJSON` existem desde 2.18 | Import/export de **conteúdo**, sem avaliar código |
| Clipboard import | Wiki Bohemia: `copyFromClipboard` **desabilitado em multiplayer** | Não usar como única interface MP; importar por controle de texto colável, a validar |
| Arquivos | `loadFile` é leitura com restrições de file-patching; servidor pode restringir extensões | Não garantir ler caminho externo livre nem gravar arquivo físico via SQF |
| Persistência local | `profileNamespace` sobrevive à missão, mas não é arquivo de exportação | Futuro rascunho local P5, com limites/validação |
| Autoridade | Server aplica e valida snapshot; credentials são server-side | Implementar P6 só com teste MP real; não expor ativação por cliente comum |

**Referências Bohemia:** 
- https://community.bistudio.com/wiki/missionConfigFile
- https://community.bistudio.com/wiki/Description.ext
- https://community.bistudio.com/wiki/fromJSON
- https://community.bistudio.com/wiki/toJSON
- https://community.bistudio.com/wiki/copyFromClipboard
- https://community.bistudio.com/wiki/loadFile
- https://community.bistudio.com/wiki/Arma_3:_Server_Security

## 6. QA — evidência obtida e gates ainda obrigatórios

**Evidência nova:** [RPT do smoke SP 24/10](evidence/P0_SP_SMOKE_RPT_20261024.md): cenário sem `CfgSPORGPolicy` e cenário com opt-in explícito em `description.ext` foram aprovados na engine 2.22.154089 (10/10 cada). Testes negativos de schema/fail-closed C–F executados **140/140 PASS**, conforme [RPT adicional](evidence/P0_NEGATIVE_SP_RPT_20261024.md); addon runtime ainda inexistente. O arquivo de spike original no repo não deve ser confundido com o pacote de duas missões autoexecutáveis.

- Contratos de fixture, casos OPEN, BLACKLIST, WHITELIST, COMBINED, conflitos, duplicatas, tipos inválidos, campo injetado, ausência da dependência e fail-closed: `machine/policy/p0_contract_fixtures_v1.json`.
- Teste de oráculo Python **não é teste engine**: `tools/policy/test_p0_contracts.py`. Executar com `python -m unittest discover -s tools/policy -p 'test_*.py' -v`.
- Smoke independente SQF da engine (pacote de missões A/B executado e aprovado em 24/10, reexecutar se mudar o contrato): `spikes/policy-p0/runPolicyP0Smoke.sqf`, copiar para missão de teste e executar via `[] execVM "runPolicyP0Smoke.sqf"` no Debug Console (SP), conferir RPT. Necessário testar JSON, 4 modos, `missionConfigFile`, `configFile` e disponibilidade de funções.
- Repetir engine smoke com e sem classe de missão, e pelo menos um MP local para checar **limitação de entrada por clipboard** sem tratar como publicação/autoridade. Usuário precisa fornecer RPT de Arma para homologação. Houve duas rodadas de smoke Arma **SP isolado**, A–F 160/160 PASS; **não** houve teste MP nem PBO/loader real.
- Os smoke SP da engine estão verdes (160/160) e documentados. **P0 ainda exige revisão de classnames reais e QA Python documentado antes de congelar os contratos v1**. Teste completo de loader ocorre após implementação P1/P2. P1 começa depois de revisão P0 e gates considerados suficientes.

## 7. Ordem da continuidade

1. Validar teste offline e ler smoke no RPT do Arma (SP). Resolver campos/compatibilidade se o RPT apontar falhas.
2. Congelar contratos v1 e atualizar estados de continuidade.
3. P1: motor Policy puro/capabilities, sem mexer em Items.
4. P2: loaders de config; P3/P4: integrações Items/cache/aplicação; P5: editor local; P6: sincronismo servidor/admin real; P7: adapters e pacote.

**Preservação:** Items 0.13-A MP continua pendente; UICommon R2.2 homologação SP intocada; iconografia somente texto; sem merge na main.
