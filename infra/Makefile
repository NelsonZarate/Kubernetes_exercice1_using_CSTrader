# --- Variáveis ---
CLUSTER_NAME = terraform-cstrader
TF_VARS = -var-file cstrader.tfvars

# Ficheiros de output dos planos
PLAN_CLUSTER = cluster.plan
PLAN_APP = app.plan

.PHONY: init plan-cluster apply-cluster images plan-app apply-app start clean

# 1. Inicializar
init:
	terraform init

# --- FASE 1: O CLUSTER ---

# Cria o plano APENAS para o Minikube (ignora o resto por enquanto)
plan-cluster:
	@echo "🔍 Planning Minikube Cluster..."
	terraform plan -target=minikube_cluster.docker -out=$(PLAN_CLUSTER) $(TF_VARS)

# Aplica o plano do cluster
apply-cluster: plan-cluster
	@echo "🚀 Creating Minikube Cluster..."
	terraform apply $(PLAN_CLUSTER)

# --- FASE 2: AS IMAGENS ---

# Constrói e carrega as imagens (requer que o apply-cluster já tenha sido feito)
images:
	@echo "🛠️  Building images locally..."
	docker build -f ../backend/ops/Dockerfile -t cstrader:latest ..
	docker build -f ../frontend/Dockerfile -t cstrader-frontend:latest ../frontend/
	
	@echo "📦 Loading images into Minikube cluster: $(CLUSTER_NAME)..."
	minikube -p $(CLUSTER_NAME) image load cstrader:latest
	minikube -p $(CLUSTER_NAME) image load cstrader-frontend:latest

# --- FASE 3: A APLICAÇÃO (K8S) ---

# Agora que o cluster existe e tem imagens, planeamos o resto (Deployments, Services, etc)
plan-app:
	@echo "🔍 Planning Kubernetes App resources..."
	terraform plan -out=$(PLAN_APP) $(TF_VARS)

# Aplica o plano da aplicação
apply-app: plan-app
	@echo "🚀 Deploying App to Kubernetes..."
	terraform apply $(PLAN_APP)

# --- COMANDO MESTRE (JARVIS) ---
start_terraform: init apply-cluster images apply-app
	@echo "✅ CSTrader deployed successfully via Terraform!"

# Limpeza
clean:
	terraform destroy -auto-approve $(TF_VARS)
	rm -f $(PLAN_CLUSTER) $(PLAN_APP)