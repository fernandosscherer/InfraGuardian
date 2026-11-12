# Investigação de e-mail e spam

1. Identificar MTA/MDA e versão antes de executar comandos.
2. Conferir fila, mensagens adiadas, rejeições, logs e picos de envio.
3. Correlacionar remetente, conta, script, IP de origem e autenticação.
4. Verificar envios por PHP/aplicações e possíveis credenciais comprometidas.
5. Conferir SPF/DKIM/DMARC, PTR/rDNS, HELO, TLS e reputação.
6. Preservar evidências; não apagar fila nem logs.

Fila vazia não comprova ausência de spam: mensagens abusivas podem ter sido entregues.
