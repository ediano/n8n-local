# Perguntas Frequentes (FAQ)

## 🤔 Geral

### O que é n8n?

n8n é uma ferramenta de automação de workflows extensível e de código aberto. Permite conectar diferentes aplicações e serviços para automatizar tarefas.

### Por que usar Docker?

Docker garante que o ambiente seja consistente em qualquer máquina, eliminando o problema "funciona na minha máquina". Também facilita a instalação e atualização.

### Este projeto é oficial do n8n?

Não, este é um projeto independente para facilitar o desenvolvimento local com n8n.

## 🔧 Configuração

### Posso mudar as credenciais padrão?

Sim! É recomendado, especialmente se pretende expor o serviço. Edite as variáveis de ambiente no `docker-compose.yml` ou use um arquivo `.env`.

### Como expor o n8n para internet?

⚠️ **Não recomendado em desenvolvimento**. Para produção:

1. Configure um domínio
2. Use um proxy reverso (nginx, Traefik)
3. Configure SSL/TLS com Let's Encrypt
4. Implemente autenticação forte
5. Configure firewall apropriado

### Posso usar outro banco de dados?

O n8n suporta SQLite, PostgreSQL e MySQL. Este projeto usa PostgreSQL por ser mais robusto para produção.

## 🐛 Problemas Comuns

### "Port is already allocated"

**Causa**: Outra aplicação está usando a porta.

**Solução**:

```bash
# Linux/Mac - encontrar processo
sudo lsof -i :5678

# Ou mudar a porta no docker-compose.yml
ports:
  - "8080:5678"
```

### "Cannot connect to PostgreSQL"

**Causa**: PostgreSQL não iniciou completamente ou há problema de rede.

**Solução**:

```bash
# Verificar logs
./n8n.sh logs postgres
# ou
docker compose logs postgres

# Reiniciar serviços
./n8n.sh restart
# ou
docker compose restart

# Se persistir, recriar
docker compose down -v
docker compose up -d
```

### "n8n não aparece no navegador"

**Causa**: Container n8n não está executando o n8n.

**Solução**:

```bash
# Entrar no container
./n8n.sh shell
# ou
docker compose exec n8n fish

# Iniciar n8n manualmente
n8n start
```

### "Perdi meus workflows"

**Causa**: Volumes foram removidos com `docker-compose down -v`.

**Solução**: Sempre faça backup antes de remover volumes. Infelizmente, sem backup, os dados são irrecuperáveis.

**Prevenção**:

```bash
# Usar script helper
./n8n.sh backup

# Ou backup manual
docker compose exec postgres pg_dump -U admin n8n_base > backup_$(date +%Y%m%d).sql
```

### Container reinicia constantemente

**Causa**: Erro na aplicação ou falta de recursos.

**Solução**:

```bash
# Ver logs
docker-compose logs n8n

# Verificar recursos
docker stats

# Aumentar recursos se necessário
```

## 💾 Dados e Backup

### Onde os dados são armazenados?

Em volumes Docker:

- `n8n_data`: Dados do n8n
- `postgres_data`: Banco de dados

### Como fazer backup?

```bash
# Backup completo do PostgreSQL
docker-compose exec postgres pg_dumpall -U admin > backup_completo.sql

# Backup apenas do n8n
docker-compose exec postgres pg_dump -U admin n8n_base > backup_n8n.sql
```

### Como restaurar backup?

```bash
# Restaurar banco
docker-compose exec -T postgres psql -U admin n8n_base < backup_n8n.sql
```

### Como exportar workflows?

1. Acesse n8n interface
2. Vá para Settings → Export
3. Selecione os workflows
4. Clique em Download

## 🚀 Performance

### O n8n está lento

**Possíveis causas**:

- Workflows complexos
- Muitas execuções simultâneas
- Recursos limitados

**Soluções**:

1. Aumentar recursos do PostgreSQL:

```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: "2GB"
```

2. Otimizar workflows
3. Limpar execuções antigas

### Como limpar execuções antigas?

Via n8n interface:

- Settings → Executions → Clear all executions

Ou via SQL:

```bash
docker-compose exec postgres psql -U admin n8n_base -c "DELETE FROM execution_entity WHERE \"stoppedAt\" < NOW() - INTERVAL '30 days';"
```

## 🔄 Atualizações

### Como atualizar o n8n?

```bash
docker-compose down
docker-compose build --no-cache n8n
docker-compose up -d
```

### Vou perder meus dados ao atualizar?

Não, desde que não use `docker-compose down -v`. Os dados estão nos volumes.

### Com que frequência devo atualizar?

- Desenvolvimento: Conforme necessário
- Produção: Teste em ambiente de homologação primeiro

## 🔒 Segurança

### É seguro usar as credenciais padrão?

**NÃO** em produção! Apenas em desenvolvimento local isolado.

### Como tornar o ambiente mais seguro?

1. Mudar credenciais padrão
2. Usar senhas fortes
3. Não expor portas desnecessariamente
4. Implementar SSL/TLS
5. Manter software atualizado
6. Fazer backups regulares
7. Limitar acesso por IP

### Devo usar HTTPS?

Em produção, **SIM**. Em desenvolvimento local, não é necessário.

## 🛠️ Desenvolvimento

### Como debugar workflows?

1. Use console.log no Function node
2. Verifique executions na interface
3. Teste nodes individualmente
4. Use o modo de teste do n8n

### Posso usar VS Code com este projeto?

Sim! O projeto inclui suporte para Dev Containers. Abra no VS Code e use "Reopen in Container".

### Como adicionar nodes customizados?

1. Entre no container:

```bash
docker-compose exec n8n fish
```

2. Instale o node:

```bash
cd /usr/src/app
npm install n8n-nodes-nome-do-node
```

3. Reinicie n8n

## 📱 Integrações

### Quais serviços posso integrar?

n8n suporta centenas de integrações. Veja a [lista completa](https://n8n.io/integrations).

### Como criar webhooks?

1. Adicione um Webhook node
2. Configure método HTTP (GET, POST, etc.)
3. Copie a URL gerada
4. Use em outros serviços

### Posso usar APIs customizadas?

Sim! Use o HTTP Request node para qualquer API REST.

## 🌐 Rede

### Os containers podem acessar a internet?

Sim, por padrão têm acesso completo à internet.

### Os containers podem acessar serviços no host?

Sim, use `host.docker.internal` como hostname (Mac/Windows) ou o IP do host (Linux).

### Como conectar a outro container Docker?

Se estiverem na mesma rede Docker, use o nome do serviço como hostname.

## 📊 Monitoramento

### Como monitorar uso de recursos?

```bash
docker stats
```

### Como ver logs em tempo real?

```bash
docker-compose logs -f
```

### Posso integrar com Prometheus/Grafana?

Sim, mas requer configuração adicional. n8n expõe métricas que podem ser coletadas.

## 🆘 Suporte

### Onde encontrar ajuda?

1. [Documentação oficial n8n](https://docs.n8n.io/)
2. [Fórum da comunidade](https://community.n8n.io/)
3. [GitHub Issues](https://github.com/n8n-io/n8n/issues)
4. Este README e documentação

### Como reportar bugs?

1. Verifique se já foi reportado
2. Colete logs e informações do sistema
3. Abra issue com descrição detalhada
4. Inclua passos para reproduzir

## 💡 Dicas e Truques

### Acelerar rebuild de images

Use cache do Docker:

```bash
docker-compose build
```

Sem cache (completo):

```bash
docker-compose build --no-cache
```

### Executar comandos rápidos

```bash
docker-compose exec n8n fish -c "n8n --version"
```

### Ver estrutura do banco de dados

```bash
docker-compose exec postgres psql -U admin n8n_base -c "\dt"
```

### Listar todos os volumes Docker

```bash
docker volume ls
```

### Inspecionar um volume

```bash
docker volume inspect n8n-local_n8n_data
```

## 🎓 Recursos de Aprendizado

### Onde aprender sobre n8n?

- [n8n Academy](https://n8n.io/academy/)
- [Documentação oficial](https://docs.n8n.io/)
- [Exemplos de workflows](https://n8n.io/workflows/)
- [YouTube - n8n](https://www.youtube.com/c/n8n-io)

### Onde aprender sobre Docker?

- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Play with Docker](https://labs.play-with-docker.com/)

---

**Não encontrou sua pergunta?** Abra uma issue ou contribua com este FAQ!
