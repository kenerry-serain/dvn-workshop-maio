# Convenções para Manifestos Kubernetes

## Labels Padronizadas

Todo recurso Kubernetes deve incluir as seguintes labels:

```yaml
metadata:
  labels:
    app.kubernetes.io/name: <nome-da-app>
    app.kubernetes.io/version: <versao>
    app.kubernetes.io/component: <frontend|backend|worker|database>
    app.kubernetes.io/part-of: <nome-do-projeto>
    app.kubernetes.io/managed-by: <kubectl|helm|argocd>
    environment: <production|staging|dev>
```

Use estas mesmas labels como `matchLabels` e `selector` nos Deployments e Services (apenas `app.kubernetes.io/name` e `app.kubernetes.io/component` como selector).

## Deployments

### Replicas

Defina no mínimo **2 réplicas** para garantir alta disponibilidade. Nunca crie um Deployment com `replicas: 1` em produção.

```yaml
spec:
  replicas: 2
```

### Probes

Todo container deve definir `readinessProbe` e `livenessProbe`. Use o endpoint de health check da aplicação:

```yaml
containers:
  - name: app
    readinessProbe:
      httpGet:
        path: /health
        port: <porta>
      initialDelaySeconds: 5
      periodSeconds: 10
      timeoutSeconds: 3
      failureThreshold: 3
    livenessProbe:
      httpGet:
        path: /health
        port: <porta>
      initialDelaySeconds: 15
      periodSeconds: 20
      timeoutSeconds: 3
      failureThreshold: 3
```

- `readinessProbe` — começa mais cedo, falha mais rápido (controla tráfego)
- `livenessProbe` — começa mais tarde, intervalo maior (controla restart)

### Resources

Defina sempre `requests` e `limits` para CPU e memória:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

Ajuste conforme a aplicação, mas nunca omita.

### Strategy

Use `RollingUpdate` com configuração que garante zero downtime:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

## Service

Sempre que criar um Deployment, crie um Service do tipo **NodePort** associado:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <nome-da-app>
  labels:
    app.kubernetes.io/name: <nome-da-app>
    app.kubernetes.io/component: <componente>
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: <nome-da-app>
    app.kubernetes.io/component: <componente>
  ports:
    - port: <porta-do-service>
      targetPort: <porta-do-container>
      protocol: TCP
      name: http
```

## PodDisruptionBudget

Todo Deployment deve ter um PodDisruptionBudget associado para proteger contra evictions durante upgrades de nodes:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: <nome-da-app>
  labels:
    app.kubernetes.io/name: <nome-da-app>
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: <nome-da-app>
```

Use `minAvailable: 1` para Deployments com 2 réplicas, ou `maxUnavailable: 1` para Deployments com 3+ réplicas.

## Security Context

Todo container deve rodar como non-root e bloquear privilege escalation. Defina `securityContext` tanto no nível do Pod quanto do container:

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 1001
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
```

- Nunca use `runAsUser: 0` (root)
- Nunca defina `privileged: true`
- Nunca defina `allowPrivilegeEscalation: true`
- Use `readOnlyRootFilesystem: true` para impedir escrita no filesystem do container

Se a aplicação precisar escrever em diretórios temporários (ex: `/tmp`, cache), use um `emptyDir` montado no path necessário.

## Volumes

Quando montar volumes, use sempre `readOnly: true` por padrão. Só monte com escrita quando estritamente necessário (ex: `emptyDir` para temp/cache):

```yaml
volumes:
  - name: config
    configMap:
      name: app-config
  - name: tmp
    emptyDir: {}
containers:
  - name: app
    volumeMounts:
      - name: config
        mountPath: /etc/app/config
        readOnly: true
      - name: tmp
        mountPath: /tmp
        readOnly: false  # apenas para dirs temporários
```

Regras:
- ConfigMaps e Secrets: sempre `readOnly: true`
- PersistentVolumeClaims: `readOnly: true` salvo quando a app precisa escrever (banco de dados, uploads)
- `emptyDir` para cache/tmp: pode ser `readOnly: false` pois é efêmero e isolado ao Pod

## Estrutura de Arquivos

Organize manifestos no diretório `dvn-workshop-kubernetes/` na raiz do projeto. Cada aplicação tem seu subdiretório e cada recurso Kubernetes fica em seu próprio arquivo — nunca agrupe múltiplos recursos no mesmo arquivo:

```
dvn-workshop-kubernetes/
├── backend/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── pdb.yaml
└── frontend/
    ├── deployment.yaml
    ├── service.yaml
    └── pdb.yaml
```

**Regra**: um recurso por arquivo. Nomeie o arquivo pelo tipo do recurso em lowercase (ex: `deployment.yaml`, `service.yaml`, `pdb.yaml`, `configmap.yaml`, `ingress.yaml`).

## Checklist ao Gerar Manifestos

Antes de entregar qualquer manifesto, verifique:

- [ ] Labels padronizadas aplicadas em todos os recursos
- [ ] Deployment com >= 2 réplicas
- [ ] readinessProbe configurada
- [ ] livenessProbe configurada
- [ ] Resources (requests/limits) definidos
- [ ] Service NodePort criado
- [ ] PodDisruptionBudget criado
- [ ] Strategy RollingUpdate com maxUnavailable: 0
- [ ] Image com tag específica (nunca `:latest` em produção)
- [ ] `imagePullPolicy: IfNotPresent` para tags versionadas
- [ ] securityContext: runAsNonRoot, allowPrivilegeEscalation: false
- [ ] Volumes montados com readOnly: true (exceto emptyDir para tmp/cache)
