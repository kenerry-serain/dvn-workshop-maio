---
name: terraform-deploy
description: Executa o deploy de stacks Terraform no projeto. Use esta skill sempre que o usuário pedir para fazer deploy, apply, provisionar, ou subir infraestrutura Terraform — mesmo que não mencione explicitamente "terraform-deploy". Quando um nome de stack for passado como argumento (ex: "01-networking-stack-ai"), faz o deploy apenas daquela stack. Quando nenhum argumento for passado, faz o deploy de todas as stacks disponíveis. Sempre ignora a stack de remote backend.
---

## O que esta skill faz

Executa o pipeline completo de deploy para uma ou mais stacks Terraform:

1. `terraform fmt` — formata o código
2. `terraform validate` — valida a configuração
3. `terraform plan` — gera e exibe o plano de execução
4. `terraform apply -auto-approve` — aplica as mudanças

## Identificando as stacks

O projeto fica em `/Users/kenerry/Repositories/dvn-workshop-maio/`. As stacks são diretórios na raiz do projeto que:
- Contêm arquivos `*.tf`
- **Não** se chamam `remote-backend` ou qualquer variação (ex: `00-remote-backend`, `remote_backend`, `01-remote-backend-stack-ai`, `00-remote-backend-stack-ai`) — essas devem ser sempre ignoradas

Para listar as stacks disponíveis:
```bash
ls -d /Users/kenerry/Repositories/dvn-workshop-maio/*/
```

## Argumentos

- **Com argumento** (ex: `terraform-deploy 01-networking-stack-ai`): faz o deploy apenas da stack especificada
- **Sem argumento**: descobre automaticamente todas as stacks (exceto remote-backend) e faz o deploy de cada uma em sequência

## Pipeline de deploy por stack

Execute os passos abaixo para cada stack, sempre na ordem indicada. Se qualquer passo falhar, pare e reporte o erro antes de continuar.

### Passo 1 — fmt
```bash
cd <caminho-da-stack>
terraform fmt
```
Se arquivos foram reformatados, liste-os. Não é um erro — apenas registre.

### Passo 2 — validate
```bash
terraform validate
```
Se falhar, exiba a mensagem de erro completa e **não prossiga** para os próximos passos desta stack.

### Passo 3 — plan
```bash
terraform plan -var-file="envs/production.tfvars"
```
Exiba o output completo do plan para o usuário antes de continuar. Se não houver arquivo `envs/production.tfvars`, rode sem `-var-file`.

### Passo 4 — apply
```bash
terraform apply -auto-approve -var-file="envs/production.tfvars"
```
Se não houver arquivo `envs/production.tfvars`, rode sem `-var-file`.

## Output esperado

Para cada stack, apresente um bloco de status claro:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stack: 01-networking-stack-ai
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ fmt      — OK
✓ validate — Success
✓ plan     — 12 to add, 0 to change, 0 to destroy
✓ apply    — Apply complete! Resources: 12 added
```

Se houver erro em qualquer passo, marque com `✗` e exiba a mensagem de erro.

## Múltiplas stacks

Quando deploying todas as stacks, faça uma de cada vez (não em paralelo) para evitar conflitos de state. Ao final, exiba um resumo geral de todas as stacks.
