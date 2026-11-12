# InfraGuardian

**Autor:** Fernando Scherer  
**Repositório:** https://github.com/fernandosscherer/InfraGuardian  
**Versão:** 1.0.1

Skill de auditoria, segurança e manutenção preventiva para servidores Linux de diferentes distribuições, versões e provedores. Inclui módulos especializados para cPanel/WHM quando presentes, mas não depende de painel ou fornecedor específico.

## Instalação rápida

Instalação no destino universal do agente:

```bash
curl -fsSL https://raw.githubusercontent.com/fernandosscherer/InfraGuardian/main/install.sh | bash
```

## Instalação local

Execute na raiz do repositório:

```bash
bash install.sh install --source . --target universal
```

Outros destinos disponíveis:

```bash
bash install.sh install --source . --target opencode
bash install.sh install --source . --target claude
bash install.sh install --source . --target project
```

## How to use

InfraGuardian é uma Skill para agentes de IA, não um executável de linha de comando independente. Depois de instalar, abra o agente no ambiente em que a Skill foi instalada e solicite a tarefa em linguagem natural.

**Auditoria geral:**

```text
Use InfraGuardian para auditar este servidor Linux.
```

**Segurança e e-mail:**

```text
Use InfraGuardian no modo MAIL para verificar a segurança e a configuração do serviço de e-mail.
```

**Manutenção preventiva:**

```text
Use InfraGuardian para elaborar um plano de manutenção preventiva deste servidor.
```

Também é possível solicitar os modos específicos: `AUDIT`, `MAIL`, `SECURITY`, `MIGRATION`, `PERFORMANCE`, `BACKUP`, `RECHECK` e `REMEDIATION-PLAN`. O modo `REMEDIATION` exige autorização explícita para cada ação.

## Segurança

A Skill opera em **READ-ONLY por padrão**. Não executa correções, reinicializações, exclusões, alterações DNS ou atualizações sem autorização específica. O instalador não usa sudo e instala apenas os arquivos da Skill no ambiente do agente.

## Compatibilidade

Adapta as verificações à distribuição, versão, init system, painel e ferramentas detectadas. cPanel/WHM, Exim e Dovecot são módulos opcionais; também considera outros painéis, MTAs e serviços quando disponíveis. Versões EOL ou não testadas são identificadas como limitações.
