---
name: dockerfile-generator
description: Gera Dockerfiles otimizados para aplicacoes. Use esta skill sempre que o usuario pedir para criar um Dockerfile, containerizar uma aplicacao, dockerizar um app, ou gerar imagem Docker — mesmo que nao mencione explicitamente "dockerfile-generator". Recebe como argumento o caminho da pasta da aplicacao, detecta a linguagem automaticamente e gera um Dockerfile com boas praticas de seguranca e tamanho.
---

## O que esta skill faz

Analisa uma aplicacao, detecta a linguagem/framework, e gera um Dockerfile production-ready seguindo boas praticas:

- **Multi-stage build** — separa build de runtime para imagem final minima
- **Alpine / distroless** — base images menores possiveis
- **Rootless container** — roda como usuario non-root (UID 1001)
- **HEALTHCHECK** — instrucao nativa do Docker para monitoramento
- **Teste automatico** — builda, roda, valida o health check e mata o container

## Argumentos

- **Obrigatorio**: caminho da pasta da aplicacao (ex: `dvn-workshop-apps/frontend/youtube-live-app`)
- **Opcional**: porta (se nao informada, detecta automaticamente ou usa a padrao da linguagem)
- **Opcional**: health check path (default: `/health`)

## Workflow

### Passo 1 — Detectar linguagem

Analise o conteudo da pasta e identifique a linguagem/framework pela presenca de:

| Arquivo | Linguagem/Framework |
|---------|-------------------|
| `package.json` + `next.config.*` | Next.js |
| `package.json` (sem next) | Node.js |
| `*.csproj` | .NET |
| `requirements.txt` ou `pyproject.toml` ou `Pipfile` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |

Reporte ao usuario qual linguagem foi detectada antes de prosseguir.

### Passo 2 — Gerar o Dockerfile

Crie o Dockerfile na raiz da pasta da aplicacao seguindo o template da linguagem detectada. Todos os Dockerfiles devem seguir estes principios:

#### Principios obrigatorios

1. **Multi-stage build**: minimo 2 stages (builder + runtime)
2. **Pin de versao**: use tags especificas nas base images (ex: `node:20-alpine`, nao `node:latest`)
3. **Alpine ou distroless**: prefira imagens alpine para runtime; para .NET use `mcr.microsoft.com/dotnet/aspnet` com tag alpine
4. **Non-root user**: crie um usuario dedicado com UID 1001 e use `USER` instruction
5. **HEALTHCHECK**: inclua instrucao `HEALTHCHECK` no Dockerfile apontando para o path configurado
6. **Ordem de layers otimizada**: copie arquivos de dependencia primeiro, depois o codigo (para cache de layers)
7. **Arquivo .dockerignore**: gere junto se nao existir, excluindo node_modules, .git, bin, obj, __pycache__, etc.
8. **Sem segredos na imagem**: nunca copie .env, credentials, ou chaves privadas

#### Template: Next.js

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./
RUN \
  if [ -f package-lock.json ]; then npm ci --only=production; \
  elif [ -f yarn.lock ]; then yarn install --frozen-lockfile --production; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install --frozen-lockfile --prod; \
  else npm install --only=production; fi

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
```

**Nota**: Next.js requer `output: "standalone"` no `next.config.js`. Verifique se esta configurado; se nao, informe o usuario que eh necessario adicionar.

#### Template: Node.js (Express/Fastify/etc)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build 2>/dev/null || true

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

#### Template: .NET

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runner
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
ENV DOTNET_RUNNING_IN_CONTAINER=true
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser
COPY --from=builder /app/publish .
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "<AppName>.dll"]
```

**Nota**: substitua `<AppName>` pelo nome real do `.csproj` (sem a extensao).

#### Template: Python (FastAPI/Flask/Django)

```dockerfile
FROM python:3.12-alpine AS builder
WORKDIR /app
RUN apk add --no-cache gcc musl-dev
COPY requirements.txt* pyproject.toml* ./
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt 2>/dev/null || \
    pip install --no-cache-dir --prefix=/install .

FROM python:3.12-alpine AS runner
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser
COPY --from=builder /install /usr/local
COPY . .
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Nota**: ajuste o CMD conforme o framework detectado (gunicorn para Flask/Django, uvicorn para FastAPI).

#### Template: Go

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server .

FROM alpine:3.20 AS runner
WORKDIR /app
RUN apk add --no-cache ca-certificates wget && \
    addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser
COPY --from=builder /app/server .
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
CMD ["./server"]
```

### Passo 3 — Gerar .dockerignore

Se nao existir um `.dockerignore` na pasta, crie um com exclusoes apropriadas para a linguagem:

**Node.js/.Next.js:**
```
node_modules
.next
.git
.env*
*.md
.DS_Store
coverage
.nyc_output
```

**.NET:**
```
bin
obj
.git
.env*
*.md
.DS_Store
*.user
*.suo
```

**Python:**
```
__pycache__
*.pyc
.git
.env*
*.md
.DS_Store
.venv
venv
.pytest_cache
```

**Go:**
```
.git
.env*
*.md
.DS_Store
vendor
```

### Passo 4 — Build e teste automatico

Apos gerar o Dockerfile, execute o teste automatico:

```bash
# Variaveis (ajustar conforme a linguagem detectada)
APP_DIR="<caminho-da-app>"
CONTAINER_NAME="dockerfile-test-$(date +%s)"
IMAGE_NAME="dockerfile-test:latest"
PORT=<porta-detectada>
HEALTH_PATH="<health-path>"

# Build
cd "$APP_DIR"
docker build -t "$IMAGE_NAME" .

# Run em background
docker run -d --name "$CONTAINER_NAME" -p "$PORT:$PORT" "$IMAGE_NAME"

# Aguardar startup (max 30s)
echo "Aguardando container iniciar..."
for i in $(seq 1 30); do
  if curl -sf "http://localhost:$PORT$HEALTH_PATH" > /dev/null 2>&1; then
    echo "Health check OK apos ${i}s"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "FALHA: Health check nao respondeu em 30s"
    docker logs "$CONTAINER_NAME"
    docker rm -f "$CONTAINER_NAME"
    docker rmi "$IMAGE_NAME" 2>/dev/null
    exit 1
  fi
  sleep 1
done

# Exibir resultado do health check
curl -v "http://localhost:$PORT$HEALTH_PATH"

# Exibir tamanho da imagem
docker images "$IMAGE_NAME" --format "Tamanho da imagem: {{.Size}}"

# Cleanup
docker rm -f "$CONTAINER_NAME"
docker rmi "$IMAGE_NAME" 2>/dev/null
```

### Passo 5 — Reportar resultado

Apresente o resultado final ao usuario:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dockerfile Generator — Resultado
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App:        <nome-da-app>
Linguagem:  <linguagem-detectada>
Porta:      <porta>
Health:     <health-path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Dockerfile gerado
✓ .dockerignore gerado
✓ Build OK
✓ Container iniciou
✓ Health check respondeu
✓ Container removido
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tamanho da imagem: <tamanho>
```

Se algum passo falhar, marque com `✗`, exiba os logs do container e sugira correcoes.

## Notas importantes

- Se a aplicacao nao tiver um endpoint `/health`, sugira ao usuario criar um antes de containerizar — ou use um path alternativo se o usuario informar
- Para Next.js, verifique se `output: "standalone"` esta no next.config e avise se nao estiver
- Para .NET, detecte a versao do SDK pelo `.csproj` (TargetFramework) e use a imagem correspondente
- Adapte os templates conforme necessario — eles sao pontos de partida, nao regras rigidas
- Se o docker nao estiver instalado ou nao estiver rodando, pule o Passo 4 e informe o usuario
