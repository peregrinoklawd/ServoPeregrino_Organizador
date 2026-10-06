# Política de nome das missões de teste

Data: 06/10/2026.

## Regra

A partir da próxima entrega, nenhum ZIP de teste deve reutilizar o mesmo nome de missão da entrega anterior.

O source canônico continua em:

`missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`

Isso evita duplicação e divergência de centenas de arquivos no Git.

No empacotamento, a pasta distribuída é renomeada conforme a entrega/revisão usando:

`missions/PACKAGE_MISSION_NAME.txt`

Formato recomendado:

`SP_ORG_UI_Lab_<Modulo>_<Entrega>_<Revisao>.VR`

Exemplos:
- `SP_ORG_UI_Lab_UICommon_0_2_C_C2_Approved.VR`
- `SP_ORG_UI_Lab_UICommon_0_2_D_R1.VR`
- `SP_ORG_UI_Lab_UICommon_0_2_D_R2.VR`

## Motivo

O nome diferente:
- evita sobrescrever a missão anterior na pasta `missions` do Arma;
- deixa claro qual candidata gerou o RPT;
- reduz risco de testar arquivos antigos sem perceber;
- preserva uma única baseline canônica no repositório.

## Gate

Toda nova candidata distribuída deve atualizar `PACKAGE_MISSION_NAME.txt` antes do workflow de pacote.
