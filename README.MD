# CSTrader - CS:GO Skin Marketplace

**CSTrader** é uma aplicação full‑stack distribuída para negociação de skins de CS:GO. Inclui marketplace em tempo real, gestão de inventário, carteira de fundos e painel administrativo seguro.

---

## 🏗️ Arquitetura

O sistema é composto por Frontend (Nginx servindo ficheiros estáticos) e Backend (FastAPI), expostos através de um Ingress Controller. A persistência é feita com PostgreSQL em StatefulSet.

```mermaid
graph TD
    User((Utilizador)) -->|HTTP Request| Ingress[Ingress Controller]

    subgraph Kubernetes Cluster
        Ingress -->|/| Frontend[Serviço Frontend\n(Nginx)]
        Ingress -->|/api| Backend[Serviço Backend\n(FastAPI)]
        Backend -->|Read/Write| DB[(PostgreSQL\nStatefulSet)]
        Job[Admin Init Job] -.->|Seed Data| DB
        Migrations[Alembic Job] -.->|Schema Update| DB
    end
```

## 🚀 Pré-requisitos

- Docker
- Minikube
- kubectl
- make

## ⚡ Quick Start

Os scripts do Make automatizam todo o ciclo (start do cluster, build das imagens, deploy, migrações e seed). Use os comandos abaixo conforme o caso.

Primeira instalação (cria cluster, imagens, aplica infra, migra e cria admin):

```bash
make start_JARVIS
```

Se o Minikube já estiver a correr e quiser apenas reconstruir e reaplicar:

```bash
make run
```

O que `make start_JARVIS` faz (resumo):

- Inicia o Minikube
- Ativa addons (Ingress, Registry)
- Constrói as imagens Docker (`cstrader:latest` e `cstrader-frontend:latest`)
- Carrega as imagens no Minikube
- Aplica os manifests (Database, API, Frontend)
- Configura regras de Ingress
- Executa migrações Alembic
- Cria o utilizador admin por defeito
- Inicia port‑forwarding para acesso local

## 🎮 Acesso

Após o deploy (o passo `make deploy` verifica a aplicação), o acesso local é via port‑forward:

- Aplicação: http://localhost:8080/
- Docs da API (Swagger): http://localhost:8080/api/docs

## 🛠️ Comandos disponíveis (Makefile)

- `make start_JARVIS` — Setup completo (cluster, imagens, deploy, migrações e seed).
- `make start` — Inicia o Minikube.
- `make images` — Constrói imagens Docker e carrega no Minikube.
- `make db` — Aplica StatefulSet e Service do PostgreSQL.
- `make api` — Aplica o Backend, Secrets e Admin Job.
- `make apply_frontend` — Aplica o Frontend (Nginx) e ConfigMaps.
- `make ingress` — Aplica regras de Ingress.
- `make migrations` — Executa migrações Alembic dentro do pod.
- `make admin` — Re-executa o Job de inicialização do admin.
- `make deploy` — Faz port‑forward e valida endpoint.
- `make clean` — Remove o cluster Minikube (teardown).

## 🔐 Credenciais do Admin (por defeito)

O sistema inicializa automaticamente uma conta de super‑admin via `infra/backend/admin_job.yaml`.

- Email: `admin@cstrader.com`
- Password: definido em `infra/backend/admin-credentials.yaml` (ex.: `SuperSecureAdmin123!`)

> Nota: altere as credenciais em produção e guarde segredos num Secret do Kubernetes.

## 📂 Estrutura do Projeto (resumo)

- `backend/` — Aplicação Python (FastAPI), Dockerfile e migrações Alembic.
- `frontend/` — Ficheiros estáticos (HTML/JS/CSS) servidos pelo Nginx.
- `infra/` — Manifests Kubernetes (Deployments, Services, StatefulSets, Secrets, Ingress).
- `Makefile` — Automação para desenvolvimento e deploy.
