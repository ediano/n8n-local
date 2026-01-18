# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Adicionado

- Documentação completa do projeto
- Guia de contribuição (CONTRIBUTING.md)
- Histórico de mudanças (CHANGELOG.md)

## [1.0.0] - 2025-01-17

### Adicionado

- Configuração inicial do Docker Compose
- Dockerfile customizado para n8n com Node.js 22
- Integração com PostgreSQL 18.0
- Suporte para VS Code Dev Containers
- Configuração de rede Docker customizada
- Persistência de dados com volumes Docker
- Licença MIT
- README básico

### Configurações

- n8n rodando na porta 5678
- PostgreSQL na porta 5432
- Limites de recursos para PostgreSQL (0.5 CPU, 1GB RAM)
- Variáveis de ambiente para integração com banco de dados

[unreleased]: https://github.com/ediano/n8n-local/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ediano/n8n-local/releases/tag/v1.0.0
