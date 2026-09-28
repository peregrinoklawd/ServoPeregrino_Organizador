# ServoPeregrino_Organizador_ServerIntegration

**STATUS: SLOT DE MÓDULO — planejado.**

Bridge opcional entre o SP_ORG e serviços já existentes no servidor.

Providers previstos:
- persistence.provider
- stock.provider
- economy.provider

Sem provider, os módulos continuam em modo standalone.

Com provider, operações seguem QUERY/QUOTE -> RESERVE -> COMMIT -> RELEASE/ROLLBACK.
