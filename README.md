# InfraGuardian

**Autor:** Fernando Scherer  
**Repositório:** https://github.com/fernandosscherer/InfraGuardian  
**Versão:** 1.0.1

Skill de auditoria, segurança e manutenção preventiva para servidores Linux de diferentes distribuições, versões e provedores. Inclui módulos especializados para cPanel/WHM quando presentes, mas não depende de painel ou fornecedor específico.

## Instalação rápida

```bash
curl -fsSL https://raw.githubusercontent.com/fernandosscherer/InfraGuardian/main/install.sh | bash
```

## Instalação local

```bash
./install.sh install --source . --target universal
./install.sh install --source . --target opencode
./install.sh install --source . --target claude
./install.sh install --source . --target project
```

## Segurança

A Skill opera em **READ-ONLY por padrão**. Não executa correções, reinicializações, exclusões, alterações DNS ou atualizações sem autorização específica. O instalador não usa sudo e instala apenas os arquivos da Skill no ambiente do agente.

## Compatibilidade

Adapta as verificações à distribuição, versão, init system, painel e ferramentas detectadas. cPanel/WHM, Exim e Dovecot são módulos opcionais; também considera outros painéis, MTAs e serviços quando disponíveis. Versões EOL ou não testadas são identificadas como limitações.
