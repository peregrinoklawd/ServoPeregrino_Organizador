# Addons SP_ORG

Cada diretório de módulo representa um **PBO independente**.

## Regras

- `ServoPeregrino_Organizador_Nexus` é a infraestrutura transversal.
- Módulos de domínio dependem do Nexus apenas quando necessário.
- Um módulo não pode acessar estado/namespace privado de outro módulo.
- Integrações entre módulos usam capabilities, contracts, events e Results.
- Dependências opcionais devem degradar graciosamente.
- Diretórios que contêm apenas `README.md` são **slots de módulo** e NÃO fazem parte do build até receberem `config.cpp`, `$PBOPREFIX$` e source validado.
- Não mover Nexus/Items apenas por estética: paths de runtime existentes permanecem congelados até existir motivo técnico e migration gate.

## Módulos

Implementados:
- ServoPeregrino_Organizador_Nexus
- ServoPeregrino_Organizador_Items

Preparados para importação/desenvolvimento:
- ServoPeregrino_Organizador_Weapons
- ServoPeregrino_Organizador_WeaponCondition
- ServoPeregrino_Organizador_Equipment
- ServoPeregrino_Organizador_Sets
- ServoPeregrino_Organizador_Armorer
- ServoPeregrino_Organizador_Settings
- ServoPeregrino_Organizador_Policy
- ServoPeregrino_Organizador_ServerIntegration

Integrações externas:
- adapters/
