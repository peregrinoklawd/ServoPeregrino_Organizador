# Weapons 0.1-A — Foundation & Weapon Identity Spike

## Resultado para revisão

**Source candidato implementado; identidade física NÃO comprovada.** A entrega fornece foundation, modelos internos, emissão lógica SERVER/SESSION, testes e laboratório. Não é um sistema de rastreamento físico concluído. Os gates A–E permanecem **ABERTOS**, e a estratégia observacional atual não satisfaz preservação em B–E.

- Baseline: `main` em `fad4186ef878e00bdd4de3656e94bd1327fe08a2`.
- Branch: `feature/weapons-0.1-a-foundation-identity-spike`.
- Display: `0.1-A`; semantic: `0.1.0.1`; build: `0.1.0.1-a-foundation-identity-spike`.
- Estado: `FOUNDATION_IDENTITY_SPIKE_PENDING_RUNTIME_VALIDATION`.
- Addon: `addons/ServoPeregrino_Organizador_Weapons/`.
- Laboratório: `missions/SP_ORG_Weapons_0_1_A_Identity_Lab_4Slots.VR/`.
- Inventário de arquivos, hashes e testes: `../artifacts/weapons-0.1-A/`.

O gate de Items 0.13-A não foi alterado nem homologado. Weapons não aguarda Items ou Armorer: são núcleos independentes. Nenhum runtime de Items, Nexus ou Armorer foi modificado.

## Arquitetura e ownership

Weapons é dono da identidade, configuração, compatibilidade e receitas. Condição, desgaste e manutenção lógica pertencem exclusivamente a WeaponCondition. Bancada, Preview e workflows/UI pertencem a Armorer.

Dependências obrigatórias: `A3_Functions_F` e `ServoPeregrino_Organizador_Nexus`. Não há integração com outros módulos ou providers nesta entrega. Results, Diagnostics, compatibilidade e registro de capabilities usam as APIs públicas de Nexus. Não foi copiado nenhum motor ou estado privado de Items.

Somente **`weapons.runtime`**, versão de capability 1, é registrada. Esse número não é a versão de um contrato de identidade. `weapons.catalog`, `weapons.configuration` e `weapons.instance` continuam planejadas. Os contratos `weapons.instance.v1`, `weapons.configuration.v1`, `weapons.recipe.v1` e `weapons.kit.v1` **não estão publicados/congelados**.

## Modelos candidatos

`WeaponConfiguration` é um HashMap fechado:

| Campo | Semântica |
|---|---|
| schemaVersion | `0.1-A-candidate`, não v1 |
| weaponClass | Classe de arma com a representação fornecida/preservada |
| muzzle / pointer / optic / bipod | Classes dos acessórios ou string vazia |

Magazine carregado e contagem de munição **não pertencem a WeaponConfiguration**. A captura do formato nativo de sete campos produz também um `loadedState` interno (`0.1-A-loaded-state-candidate`) com `primaryMagazine` e `secondaryMagazine`. Esse estado é observacional/transitório e pode mudar a cada disparo sem alterar a montagem da arma.

O slot equipado é um **locator transitório**, não parte da identidade nem do fingerprint. A informação de tipo vem de `CfgWeapons.type`: rifle=1, handgun=2, launcher=4. A validação semântica de `WeaponConfiguration` consulta `compatibleItems` por slot. Compatibilidade/estado de magazines será modelada separadamente quando seu contrato próprio for amadurecido; nesta candidata ela é apenas observada.

O fingerprint é uma serialização canônica ordenada da **configuração**, não um hash curto e nunca uma identidade. Classnames armazenados são preservados; `toLowerANSI` é aplicado somente na chave de comparação/fingerprint. Ammo e magazines carregados ficam fora do fingerprint, portanto disparar não cria uma nova WeaponConfiguration.

`WeaponInstance` é um HashMap fechado com `schemaVersion`, `instanceId`, `serial`, `weaponClass`, `configuration`, `metadata`, `createdAt`, `updatedAt`. Metadata aceita somente `scope=SESSION` e `authority=SERVER`. Timestamps são arrays `systemTimeUTC`.

- IDs e seriais são emitidos somente no servidor, sem entrada correspondente do cliente.
- Prefixos `WID-` e `SPW-`; sufixo composto por token de sessão e sequência.
- Token de sessão: UTC + oito componentes pseudoaleatórios; não é credencial nem UUID criptográfico.
- Na sessão, contador monotônico, seção não suspensível de alocação/inserção e detecção de duplicata evitam reuso. Limite explícito 9.999.999, anterior ao limite de precisão inteira relevante.
- Duas configurações iguais recebem IDs/seriais diferentes.
- Alterar configuração de um registro preserva ID, serial e criação. Trocar weaponClass é recusado.
- Leituras e retornos usam deep copy. Localizadores ficam fora da instância.
- “Serial definitivo” significa imutável após emissão; **não significa persistência após restart**.
- Reiniciar a missão perde o registry. Não há DB, provider ou recuperação externa.

## Funções implementadas

Prefixo comum: `ServoPeregrino_Organizador_Weapons_fnc_`.

| Camada | Funções |
|---|---|
| lifecycle | initialize, getBuildInfo |
| integration | validateNexus |
| runtime | getRuntimeStatus |
| domain | deepCopy, createWeaponConfiguration, normalizeWeaponConfiguration, validateWeaponConfigurationStructural, validateWeaponConfigurationSemantic, configurationFromWeaponArray, captureWeaponConfiguration, getConfigurationFingerprint, compareWeaponConfigurations, isValidIdentityToken, validateWeaponInstance |
| identity | initializeAuthority, createWeaponInstance, getWeaponInstance, updateWeaponInstanceConfiguration, inspectWeaponCarrier, getIdentityDiagnostics |
| tests/lab | runDelivery0_1ATests, installLabActions, serverHandleLabRequest, clientReceiveLabResult |

São funções internas candidatas, salvo o entry point de status anunciado em `weapons.runtime`. Não tratá-las como API pública v1. O índice JSON/CSV e o grafo de referências foram atualizados; o grafo inclui referências textuais, não prova de execução dinâmica.

## Investigação técnica e decisão do spike

Fontes primárias consultadas em 28/09/2026:

- [weaponsItems](https://community.bistudio.com/wiki/weaponsItems) e [weaponsItemsCargo](https://community.bistudio.com/wiki/weaponsItemsCargo): snapshots de configuração; formato extended serve como evidência adicional de muzzle.
- [weaponsInfo](https://community.bistudio.com/wiki/weaponsInfo): o índice de arma é interno e muda frequentemente; não usá-lo como serial.
- [weaponAccessoriesCargo](https://community.bistudio.com/wiki/weaponAccessoriesCargo) e [removeWeaponCargo](https://community.bistudio.com/wiki/removeWeaponCargo): mencionam `weaponId/creatorId`. Isso, isoladamente, não fornece uma rota comprovada de obtenção/preservação entre todos os carriers; há documentação marcada como não oficial/incompleta.
- [Event Handlers](https://community.bistudio.com/wiki/Arma_3:_Event_Handlers): Take/Put são sinais para investigar, não prova suficiente de continuidade.
- [compatibleItems](https://community.bistudio.com/wiki/compatibleItems) e [compatibleMagazines](https://community.bistudio.com/wiki/compatibleMagazines): validação de configuração baseada no engine.

**Conclusão limitada à evidência disponível:** não foi demonstrado um identificador nativo estável recuperável em todos os estados exigidos. Não se concluiu que seja impossível. A existência de parâmetros internos `weaponId/creatorId` também não autoriza inventar um getter ou presumir estabilidade.

O addon implementa um registry lógico e um observador conservador. O laboratório registra uma referência de teste ao slot inicial, mas a consulta sempre informa `physicalIdentityProven=false` e `resolvedInstanceId=""`. O registro lógico pode ser atualizado por comando explícito para testar a invariância de ID/serial; isso **não comprova associação física**.

| Tema | Comportamento da candidata |
|---|---|
| Authority | Registry e emissão no servidor; host é servidor em hosted/SP |
| Locator | Unit/slot/netId somente para referência de laboratório; índice de snapshot é ordinal de observação |
| Criação | Comando explícito captura no servidor; cliente não envia configuração, serial ou ID |
| Transferência | Nenhuma identidade é automaticamente transferida; inventário nativo realiza o movimento |
| Reconciliation | Não há remapeamento por classe, fingerprint, ordem ou slot |
| Ambiguidade | Configurações iguais no mesmo carrier geram `WEAPONS_IDENTITY_AMBIGUOUS`; nenhum ID é escolhido |
| Duplicate detection | Emissão verifica colisão; observador detecta fingerprints repetidos; duplicidade física não é “deduplicada” |
| Lost identity | Registro lógico preservado para diagnóstico; sem recuperação ou emissão automática substituta |
| Alteração externa | Take/Put de armas invalida referências da unidade; alterações via scripts podem não gerar esses sinais |
| Mods | Apenas leitura de configs; recriação de armas por mods não é rastreada nem suportada como identidade |
| SP/hosted | Caminho candidato preparado, ainda não executado neste ambiente |
| Dedicated | Authority não depende de UI; execução manual deve usar console do servidor, mas ainda não testada |
| JIP/reconnect | Sem bootstrap/rebind/recovery; netId/slot não promovidos a identidade; gate futuro |

Take/Put de acessórios não invalida automaticamente a referência, para permitir o teste lógico A. Um evento de arma invalida conservadoramente todos os slots da unidade. Nem a ausência de evento nem uma configuração idêntica provam que a arma é a mesma. Esse limite está no diagnóstico, não escondido no algoritmo.

Abordagens rejeitadas nesta entrega: fingerprint como identidade; classname como serial; posição no cargo; netId do holder como identidade de cada arma; remover/recriar armas e chamar isso de preservação; atribuir os dois IDs de teste às duas linhas do cargo por ordem; congelar v1 para mascarar incerteza.

## Segurança e limites do laboratório

Os dois únicos endpoints RemoteExec declarados por Weapons são `serverHandleLabRequest` e `clientReceiveLabResult`. O primeiro exige servidor, flag de laboratório ativada pelo servidor e correspondência `owner unit == remoteExecutedOwner`. Só aceita operações fechadas e captura dados físicos no servidor. O cliente receptor exige remetente 2 e interface local; `allowedTargets=0` permite o host receber a resposta, além dos clientes. JIP está desativado por endpoint.

**Weapons não define `CfgRemoteExec.Functions.mode` nem defaults globais de `jip`.** Essa política é global ao ambiente e não pertence a um módulo de domínio isolado. A missão `SP_ORG_Weapons_0_1_A_Identity_Lab_4Slots.VR` define `mode=1`, `jip=0`, os endpoints do laboratório e as funções BIS necessárias ao teste/Debug Console. As funções internas não são declaradas como endpoints. Uma futura missão de produção que escolha política permissiva (`mode=2`) precisará de hardening autoritativo próprio antes de expor este domínio; isso não é declarado resolvido pela 0.1-A.

O laboratório é para sessão de desenvolvimento confiável, não para servidor público; diagnosticar todo o registry pode gerar logs grandes. Há limite básico de frequência para comandos, sem pretensão de hardening anticheat. Eventos de invalidação não são descartados por esse limite.

## O que instalar/copiar no Arma 3

**Esta entrega contém source; nenhum PBO novo foi construído ou homologado neste ambiente.** Arma 3 Tools/Addon Builder não está instalado aqui. Não foi criado packer caseiro nem reutilizado PBO antigo como se correspondesse ao novo source.

1. Obter esta branch do repositório.
2. No Windows, usar **Arma 3 Tools → Addon Builder** para empacotar separadamente:
   - `addons/ServoPeregrino_Organizador_Nexus/` → `ServoPeregrino_Organizador_Nexus.pbo`;
   - `addons/ServoPeregrino_Organizador_Weapons/` → `ServoPeregrino_Organizador_Weapons.pbo`.
3. Preservar `$PBOPREFIX$` e incluir `.sqf`/`.hpp` nos arquivos copiados. Cada prefixo deve corresponder exatamente ao nome de seu addon. Não adicionar pasta externa ao prefixo.
4. Criar `@SP_ORG_Weapons_0_1_A/addons/` e colocar os dois PBOs acima nessa pasta. Adicionar `@SP_ORG_Weapons_0_1_A` como **Local Mod** no Launcher. Todos os participantes precisam da mesma build.
5. Copiar a pasta inteira `missions/SP_ORG_Weapons_0_1_A_Identity_Lab_4Slots.VR` para a pasta `mpmissions` do perfil do Arma 3. Para testar no editor SP, copiar também para `missions` do perfil. Não copiar apenas o SQM.
6. Hospedar no terreno **VR**, abrindo **SP_ORG Weapons 0.1-A - Identity Lab 4 Slots**. Há um slot host e três outros slots jogáveis, AI desativada.
7. Para o teste inicial, carregar somente Nexus + Weapons. Items, ACE, CBA e demais módulos não são necessários.

O produto é o addon. A missão só prepara objetos/ações/evidências; não contém cópia do domínio. Build/load ainda são gates próprios. Se o Addon Builder falhar, registrar o erro; não avançar para diagnosticar funções inexistentes.

## Testes executados e pendentes

Executado neste ambiente: `python tools/validate_weapons_0_1_a.py`, pré-processamento C de includes/macros e inspeção estática de dependências, símbolos, delimitadores, índices, endpoints e preservação dos outros módulos. Ver `STATIC_VALIDATION.txt` para o resultado efetivo. Isso **não é um compilador/intérprete SQF**.

Preparado, mas **NÃO EXECUTADO**: `[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_1ATests` dentro do Arma. No host, usar a ação **AUTO TEST**. No dedicated, executar a função localmente no console do servidor com a missão ativa.

Cobertura do AUTO TEST: lifecycle/idempotência, Nexus/capability/provider, criação, preservação de classname, deep copy aninhado, validação estrutural/semântica, entradas inválidas, schemas incompatíveis, comparação case-insensitive sem mutar o modelo, separação `WeaponConfiguration`/`loadedState`, prova de que ammo 30→29 não altera o fingerprint de configuração, emissão de duas instâncias, serial distinto, invariância após alteração, payload/ID/serial/class/metadata/timestamp inválidos, cópia defensiva e dependências mínimas. A verificação estática cobre ausência de acesso privado a Items e os gates de RemoteExec. A suite apaga somente os registros que criou e nunca rebobina a sequência autoritativa.

Não executados: empacotamento PBO, carga no Arma, suite SQF, testes SP/hosted/dedicated/MP real/JIP/reconnect. **Não há homologação runtime ou multiplayer.**

## Roteiro de laboratório e RPT

Primeiro procurar erros `Unable to open`, `Error in expression`, `Undefined variable`, `Missing ;` ou função não definida. A existência de lobby/slots não prova carga do addon.

Esperado para iniciar:

- `WEAPONS_INITIALIZED`;
- `[SP_ORG] [WEAPONS] [LAB_READY]`;
- ações de scroll `Weapons | ...`;
- `AUTO_TEST_SUMMARY` com `failed=0`; qualquer falha impede aprovar a foundation runtime;
- `RUNTIME_MANUAL_GATE=OPEN`, mesmo com suite verde.

A ação de alternância escolhe PRIMARY, SECONDARY ou HANDGUN; SECONDARY é o launcher. A configuração consultada é a do **slot selecionado**, não necessariamente a arma atualmente empunhada.

As caixas são marcadas no mapa: TRANSFER (vazia), DUPLICATES (duas MX idênticas, geradas no início) e ACCESSORIES. Para repetir a geração dos pares, reiniciar a missão; os novos seriais são de outra sessão. O RPT mostra `DUPLICATES_UNBOUND`: os dois IDs lógicos **não são atribuídos por posição** às duas armas físicas.

Capturar evidências antes/depois com **Capturar evidências locais (RPT)** em ambos os clientes e com **Consultar**/**Inspecionar caixa/holder**. Procurar `PROBE_LOCAL`, `PROBE_CARGO`, `INVENTORY_EVENT`, `[LAB]`, `WEAPONS_IDENTITY_UNPROVEN`, `WEAPONS_IDENTITY_AMBIGUOUS` e `WEAPONS_IDENTITY_UNRESOLVED`. Guardar o RPT completo do host e dos clientes e a versão do Arma/modset. Nomes/IDs exibidos são longos nesta candidata.

| Gate | Procedimento | Critério final desejado | Resultado honesto esperado nesta candidata |
|---|---|---|---|
| A — acessórios | Obter acessórios antes de registrar; registrar PRIMARY; anotar ID/serial; trocar optic, suppressor e pointer por I; atualizar referência; consultar | Mesmo ID/serial e configuração alterada, sem troca indevida de instância | Invariância lógica candidata; associação física ainda UNPROVEN. Se evento invalidar, UPDATE deve recusar, não reemitir |
| B — chão | Registrar e consultar; por I largar arma; observar holder; recuperar; consultar | Mesmo ID/serial acompanha a arma | Referência anterior pode ficar UNRESOLVED; nenhuma recuperação automática. Gate continua aberto |
| C — caixa | Registrar; mover via I para TRANSFER; observar caixa; retirar; consultar | Mesma instância antes/depois | Observações e referência lógica separadas; não afirmar preservação |
| D — MP | A registra e larga/guarda; B retira; ambos consultam e capturam evidências | B tem exatamente a instância de A | Sem binding cruzado; UNPROVEN, não serial “adivinhado”. Requer dois jogadores reais |
| E — idênticas | Inspecionar DUPLICATES antes de retirar; retirar/recolocar alternadamente; A e B trocam armas | Duas identidades físicas independentes sem colapso/troca | AMBIGUOUS no cargo duplicado; dois registros lógicos independentes, nenhum mapeamento inventado. Estratégia atual insuficiente para fechar E |

Repetir A–D com handgun e launcher quando aplicável; repetir E com mesma munição e mesmos acessórios. Não fechar um gate apenas por contagem de armas ou porque o registro antigo ainda existe no registry.

## Critérios de revisão e riscos

Pode-se aprovar o **source da foundation/spike** após revisão, sem aprovar identidade física. Aprovação runtime exige build/load e suite efetiva. Identidade de produção exige evidência física inequívoca em A–E, principalmente E. Colapsar duas armas, trocar seriais ou recuperar por fingerprint reprova a estratégia. UNPROVEN/AMBIGUOUS é diagnóstico correto do spike, mas **não é aprovação do requisito físico**.

Riscos conhecidos: ausência de token físico comprovado; eventos incompletos/fora de ordem e replicação; alterações externas silenciosas; mods que removem/recriam armas; mudança de classname/config variants; muzzle secundário limitado; registros/referências só de sessão; ausência de recovery em death/disconnect/JIP; código SQF e PBO ainda não executados no engine. Nenhum desses limites foi declarado resolvido por testes estáticos.

## Proposta técnica para 0.1-B

Aguardar revisão humana. Se a evidência revelar token nativo obtível, investigar sua estabilidade em todos os carriers e em MP antes de usá-lo como ponte para a identidade de domínio. Caso contrário, propor operações físicas controladas/transacionais e declarar quais caminhos externos continuarão ambíguos, com recusa/reconciliation explícita. Não transformar essa restrição em garantia universal. Somente depois decidir schema público e próximos consumidores. Nenhuma 0.1-B foi iniciada.
