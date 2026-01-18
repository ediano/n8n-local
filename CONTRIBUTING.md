# Guia de Contribuição

## 🤝 Como Contribuir

Obrigado por considerar contribuir com este projeto! Este documento fornece diretrizes para contribuição.

## 📋 Processo de Contribuição

1. **Fork o Projeto**

   - Faça um fork do repositório para sua conta

2. **Clone o Repositório**

   ```bash
   git clone https://github.com/seu-usuario/n8n-local.git
   cd n8n-local
   ```

3. **Crie uma Branch**

   ```bash
   git checkout -b feature/nome-da-sua-feature
   ```

4. **Faça suas Alterações**

   - Mantenha o código limpo e bem documentado
   - Siga as convenções do projeto

5. **Teste suas Alterações**

   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

6. **Commit suas Alterações**

   ```bash
   git add .
   git commit -m "feat: descrição clara da mudança"
   ```

7. **Push para o GitHub**

   ```bash
   git push origin feature/nome-da-sua-feature
   ```

8. **Abra um Pull Request**
   - Descreva claramente as mudanças realizadas
   - Adicione capturas de tela se aplicável

## 📝 Convenções de Commit

Utilizamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Mudanças na documentação
- `style:` - Formatação, sem mudança de código
- `refactor:` - Refatoração de código
- `test:` - Adição de testes
- `chore:` - Manutenção geral

## 🧪 Testando

Antes de submeter um PR, certifique-se de:

1. O ambiente inicia corretamente
2. O n8n é acessível em http://localhost:5678
3. A conexão com PostgreSQL funciona
4. Não há erros nos logs

## 📖 Documentação

- Mantenha o README.md atualizado
- Documente novas variáveis de ambiente
- Adicione comentários em configurações complexas

## 🐛 Reportando Bugs

Ao reportar bugs, inclua:

- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs atual
- Versão do Docker e Docker Compose
- Sistema operacional
- Logs relevantes

## 💡 Sugerindo Melhorias

Para sugerir melhorias:

- Descreva claramente a melhoria
- Explique por que seria útil
- Se possível, forneça exemplos de uso

## ✅ Checklist para Pull Requests

- [ ] O código está limpo e bem documentado
- [ ] As alterações foram testadas localmente
- [ ] A documentação foi atualizada (se necessário)
- [ ] Os commits seguem as convenções
- [ ] Não há conflitos com a branch principal

## 🙏 Agradecimentos

Toda contribuição é valiosa e apreciada!
