# Armorer — ownership e migração

## Papel

Dono da bancada física, Preview 3D e workflow/UI de montagem, inspeção e manutenção.

## Já comprovado historicamente

- estações físicas;
- sessão por operador;
- lease/autoridade multiplayer por estação;
- preview 3D;
- `originalConfiguration`, `confirmedConfiguration`, `workingConfiguration`;
- commit/rollback;
- fontes de conteúdo como AUTO, VIRTUAL, PLAYER_INVENTORY, CONTAINER e STATION_STOCK.

## Construção/montagem

Armorer oferece a experiência de bancada para:
- montar/desmontar;
- escolher acessórios;
- criar/editar receitas;
- aplicar configuração.

O modelo e a validação de WeaponConfiguration/WeaponRecipe pertencem a **Weapons**.

## Manutenção

Armorer oferece:
- inspeção;
- interface de limpeza;
- interface de lubrificação;
- reparo;
- troca de peças;
- apresentação de condição;
- fluxo transacional do serviço.

O cálculo/estado autoritativo de desgaste e as transições lógicas de manutenção pertencem a **WeaponCondition**.

## Não deve possuir

- catálogo/semântica geral de Items;
- identidade privada de Weapons;
- fórmula própria de desgaste;
- condition state duplicado;
- banco/economia diretamente;
- engine própria de whitelist/blacklist.

## Integrações futuras

- Weapons: identidade, configuração, compatibilidade e receitas;
- WeaponCondition: condição, desgaste e manutenção lógica;
- Stock/Economy/Persistence: opcionais via providers;
- Policy: regras allow/deny;
- Adapters: compatibilidade com mods externos.

## Migração

Importar a baseline histórica autoritativa sem reescrever ou adicionar features. O primeiro gate do Armorer no monorepo é provar equivalência funcional.
