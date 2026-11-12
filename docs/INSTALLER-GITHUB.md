# Publicação e instalação via GitHub

**Autor:** Fernando Scherer  
**Repositório:** https://github.com/fernandosscherer/InfraGuardian

Instalação rápida:

```bash
curl -fsSL https://raw.githubusercontent.com/fernandosscherer/InfraGuardian/main/install.sh | bash
```

Instalação local:

```bash
./install.sh install --source . --target universal
```

O instalador oferece destinos universal, OpenCode, Claude Code e projeto local. Faz backup antes de substituir uma instalação existente, não usa sudo e não altera configurações do servidor.

## Compatibilidade
A skill detecta distribuição/versão Linux, init system, painel e stack de e-mail. cPanel/WHM é opcional; comandos e caminhos são adaptados ao ambiente.
