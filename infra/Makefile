# --- Variáveis ---
CLUSTER_NAME = terraform-cstrader
TF_VARS = -var-file env.tfvars

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

# --- IMAGENS ---
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

# Ingress
# 1. Ativa o addon de Ingress no cluster (só precisa de ser feito uma vez)
ingress-enable:
	@echo "🔌 Enabling Ingress addon..."
	minikube addons enable ingress -p $(CLUSTER_NAME)
	@echo "⏳ Waiting for Ingress controller to be ready..."
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s


ingress-ip:
	@echo "🔧 Updating /etc/hosts..."
	@IP=$$(minikube ip -p $(CLUSTER_NAME)); \
	\
	# 1. Verifica se já existe (grep). Se NÃO existir (!), adiciona.
	if ! grep -q "cstrader.local" /etc/hosts; then \
		echo "Writing $$IP cstrader.local to /etc/hosts..."; \
		sudo sh -c "echo '$$IP cstrader.local' >> /etc/hosts"; \
		echo "✅ Added!"; \
	else \
		echo "⚠️ Entry already exists. Skipping to avoid duplicates."; \
	fi
# 3. Corre o Túnel (Este comando BLOQUEIA o terminal, é normal)
tunnel:
	@echo "🚇 Starting Minikube Tunnel (Sudo required)..."
	@echo "⚠️  KEEP THIS TERMINAL OPEN "
	minikube tunnel -p $(CLUSTER_NAME)


start_terraform: init apply-cluster ingress-enable images apply-app ingress-ip tunnel
	@echo "✅ CSTrader deployed! Run 'make ingress-ip' to see access info."


# Limpeza
clean:
	minikube delete --all

	rm -rf .terraform
	rm -f *.tfstate
	rm -f *.tfstate.backup
	rm -f *.plan
	rm -f .terraform.lock.hcl

	terraform init