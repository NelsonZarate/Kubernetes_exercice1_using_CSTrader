# --- Variáveis ---
CLUSTER_NAME = terraform-cstrader
TF_VARS = -var-file env.tfvars

# Ficheiros de output dos planos
PLAN_CLUSTER = cluster.plan
PLAN_APP = app.plan

.PHONY: init plan-cluster apply-cluster images plan-app apply-app start clean

init:
	terraform init

plan:
	@echo "🔍 Planning Kubernetes App resources..."
	terraform plan -out=$(PLAN_APP) $(TF_VARS)

# Aplica o plano da aplicação
apply: plan
	@echo "🚀 Deploying App to Kubernetes..."
	terraform apply $(PLAN_APP)



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

tunnel:
	@echo "🚇 Starting Minikube Tunnel (Sudo required)..."
	@echo "⚠️  KEEP THIS TERMINAL OPEN "
	minikube tunnel -p $(CLUSTER_NAME)


start_terraform: init apply ingress-ip tunnel
	@echo "✅ CSTrader deployed! Run 'make ingress-ip' to see access info."


clean:
	minikube delete -p terraform-cstrader

	rm -rf .terraform
	rm -f *.tfstate
	rm -f *.tfstate.backup
	rm -f *.plan
	rm -f .terraform.lock.hcl

	terraform init