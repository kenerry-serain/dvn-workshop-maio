# Convenções de Nomenclatura Terraform

## Nomes de Recursos e Data Sources

- Use `_` (underscore) como separador — nunca `-` (hífen) em identificadores Terraform
- Use letras minúsculas e números apenas
- **Não repita o tipo do recurso no nome** do identificador:
  ```hcl
  # correto
  resource "aws_route_table" "public" {}

  # errado
  resource "aws_route_table" "public_route_table" {}
  ```
- Use `this` quando o recurso é o único do tipo no contexto (ex: dentro de um módulo)
- Use nomes no **singular** sempre
- Use `-` (hífen) apenas dentro de *valores* expostos a humanos (ex: nomes de DNS, tags `Name`)
- Posicione `count` / `for_each` **primeiro** no bloco de resource; `tags` **por último** (antes de `depends_on` e `lifecycle`)
- Prefira `count = var.x ? 1 : 0` a `count = length(var.x) > 0 ? 1 : 0`

## Estrutura de Arquivos `.tf`

Utilize o padrão de nomenclatura com ponto como separador semântico:

| Arquivo | Conteúdo |
|---|---|
| `versions.tf` | bloco `terraform {}`, `required_version`, `required_providers` |
| `main.tf` | configuração do provider, data sources globais |
| `variables.tf` | declaração de todas as variáveis |
| `outputs.tf` | todos os outputs |
| `tags.tf` | locals com tags padrão do projeto |
| `vpc.tf` | recurso `aws_vpc` e `aws_internet_gateway` |
| `vpc.public-subnets.tf` | subnets públicas |
| `vpc.private-subnets.tf` | subnets privadas |
| `vpc.public-route-table.tf` | route table pública e associações |
| `vpc.private-route-table.tf` | route tables privadas e associações |
| `vpc.nat-gateway.tf` | EIPs e NAT Gateways |
| `vpc.flow-logs.tf` | VPC Flow Logs, CloudWatch Log Group, IAM Role |

**Regra geral**: quando um arquivo `.tf` cresce além de um único conceito, quebre-o usando o padrão `<recurso-pai>.<conceito-filho>.tf`.

## Variáveis — Objetos Agrupados

Prefira variáveis com atributos agrupados por recurso/contexto em vez de variáveis standalone:

```hcl
# correto — variável agrupada
variable "vpc" {
  description = "Configurações da VPC"
  type = object({
    name                    = string
    cidr                    = string
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    availability_zones      = list(string)
    enable_flow_logs        = bool
    flow_log_retention_days = number
  })
}

# errado — variáveis standalone dispersas
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" {}
```

Outras regras para variáveis:
- Inclua sempre `description`
- Ordem dos atributos: `description`, `type`, `default`, `validation`
- Use nomes no **plural** para `list(...)` e `map(...)`
- Evite dupla negativa: prefira `encryption_enabled` a `encryption_disabled`
- Defina `nullable = false` para variáveis que jamais devem ser `null`
- **Não use `default`** nas variáveis — os valores ficam em arquivo separado (ver abaixo)

## Valores de Variáveis — Arquivo Separado por Ambiente

Em vez de `default` no `variables.tf` ou `terraform.tfvars`, crie arquivos de valores nomeados por ambiente dentro de `envs/`:

```
01-networking-stack-ai/
├── variables.tf          # apenas declaração (sem default)
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── production.tfvars
```

Aplique passando o arquivo explicitamente:
```bash
terraform plan  -var-file="envs/production.tfvars"
terraform apply -var-file="envs/production.tfvars"
```

## Outputs

Siga o padrão `{name}_{type}_{attribute}`:

```hcl
# correto
output "vpc_id" {}
output "public_subnet_ids" {}       # plural para listas
output "nat_gateway_public_ips" {}  # plural para listas

# errado
output "this_vpc_id" {}
output "public_subnet" {}
```

- Sempre inclua `description`
- Use nome plural quando o output for uma lista
- Prefira `try()` a `element(concat(...))`

## Providers

- Use exclusivamente recursos nativos do provider `hashicorp/aws` — sem módulos comunitários ou de terceiros
- Versão do provider fixada com `~>` (ex: `~> 6.0`) no `versions.tf`
- Configure `default_tags` no provider para propagar tags a todos os recursos

## Exemplo de Estrutura de Stack

```
01-networking-stack-ai/
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── tags.tf
├── vpc.tf
├── vpc.public-subnets.tf
├── vpc.private-subnets.tf
├── vpc.public-route-table.tf
├── vpc.private-route-table.tf
├── vpc.nat-gateway.tf
├── vpc.flow-logs.tf
└── envs/
    ├── dev.tfvars
    ├── staging.tfvars
    └── production.tfvars
```
