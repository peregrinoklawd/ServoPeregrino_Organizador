# Armorer — ownership e migração

## Papel

Superfície física e workflow de inspeção/manutenção/modificação de armas.

## Já comprovado historicamente

- estações físicas;
- sessão por operador;
- lease/autoridade multiplayer por estação;
- preview 3D;
- `originalConfiguration`, `confirmedConfiguration`, `workingConfiguration`;
- commit/rollback;
- fontes de conteúdo como AUTO, VIRTUAL, PLAYER_INVENTORY, CONTAINER e STATION_STOCK.

## Não deve possuir

- catálogo/semântica geral de Items;
- estado privado de Weapons;
- banco/economia diretamente;
- fórmula de política whitelist/blacklist.

## Integrações futuras

Armorer consome contratos de Weapons e, opcionalmente, Stock/Economy/Persistence.

## Migração

Importar a baseline histórica autoritativa sem reescrever ou adicionar features. O primeiro gate do Armorer no monorepo é provar equivalência funcional.
