---
name: docker-push-ecr
description: Faz build e push de imagens Docker para repositorios ECR. Use esta skill sempre que o usuario pedir para buildar e enviar imagens para o ECR, fazer push de containers, subir imagem no registry, publicar imagem Docker na AWS — mesmo que nao mencione explicitamente "docker-push-ecr". Recebe pares de caminho-da-app e URI ECR como argumentos.
---

## O que esta skill faz

Executa o pipeline completo de build e push de imagens Docker para Amazon ECR:

1. Login no ECR via AWS CLI
2. Docker build com `--platform=linux/amd64`
3. Docker push para o repositorio ECR
4. Verificacao de que a imagem chegou ao registry

Suporta multiplas imagens em uma unica execucao.

## Argumentos

Recebe pares no formato `<caminho-da-app> <uri-ecr>`, separados por virgula ou em linhas separadas.

**Formato:**
```
<pasta-app-1> <uri-1>, <pasta-app-2> <uri-2>
```

**Exemplos de invocacao:**
```
/docker-push-ecr dvn-workshop-apps/backend/YoutubeLiveApp 654654554686.dkr.ecr.us-east-1.amazonaws.com/dvn-workshop/production/backend:latest
```

```
/docker-push-ecr dvn-workshop-apps/backend/YoutubeLiveApp 654654554686.dkr.ecr.us-east-1.amazonaws.com/dvn-workshop/production/backend:v1.0.0, dvn-workshop-apps/frontend/youtube-live-app 654654554686.dkr.ecr.us-east-1.amazonaws.com/dvn-workshop/production/frontend:v1.0.0
```

Se a tag nao for informada na URI, use `latest` como default.

## Workflow

### Passo 1 — Parsear argumentos

Extraia os pares (caminho, URI) dos argumentos. Para cada par:
- Valide que o caminho existe e contem um `Dockerfile`
- Valide que a URI tem formato valido de ECR (`<account>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>`)
- Extraia a regiao e o account ID da URI

Se alguma validacao falhar, reporte o erro e nao prossiga para aquele par.

### Passo 2 — Login no ECR

Faca login no ECR usando a regiao extraida da URI. O login so precisa ser feito uma vez por regiao, mesmo que haja multiplas imagens:

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
```

Se o login falhar, pare e reporte o erro (geralmente credenciais AWS nao configuradas).

### Passo 3 — Build e Push (para cada par)

Para cada par (caminho, URI), execute:

```bash
cd <caminho-da-app>
docker build --platform=linux/amd64 -t <uri-completa> .
docker push <uri-completa>
```

Se o build falhar, exiba o erro e continue para o proximo par (nao aborte tudo).

### Passo 4 — Verificacao

Apos o push, verifique que a imagem existe no registry:

```bash
aws ecr describe-images \
  --repository-name <repo-name> \
  --image-ids imageTag=<tag> \
  --region <region> \
  --query 'imageDetails[0].{pushedAt:imagePushedAt,size:imageSizeInBytes,digest:imageDigest}' \
  --output table
```

### Passo 5 — Reportar resultado

Apresente o resultado final:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Docker Push ECR — Resultado
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ ECR Login OK (us-east-1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Imagem 1: dvn-workshop/production/backend:v1.0.0
  App:    dvn-workshop-apps/backend/YoutubeLiveApp
  ✓ Build OK (linux/amd64)
  ✓ Push OK
  ✓ Verificado no ECR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Imagem 2: dvn-workshop/production/frontend:v1.0.0
  App:    dvn-workshop-apps/frontend/youtube-live-app
  ✓ Build OK (linux/amd64)
  ✓ Push OK
  ✓ Verificado no ECR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Se algum passo falhar, marque com `✗` e exiba a mensagem de erro.

## Notas importantes

- Sempre use `--platform=linux/amd64` no build para garantir compatibilidade com EKS (os nodes sao x86_64)
- O projeto base fica em `/Users/kenerry/Repositories/dvn-workshop-maio/` — caminhos relativos sao resolvidos a partir dai
- Se a tag nao for especificada na URI, assume `latest`
- Nao faca cleanup das imagens locais automaticamente — o usuario pode querer mante-las para debug
- Se o docker nao estiver rodando, informe o usuario antes de tentar qualquer operacao
