start:
	minikube start

addons:
	minikube addons enable ingress
	minikube addons enable registry

images:
	docker build -f backend/ops/Dockerfile  -t cstrader:latest .
	docker build -f frontend/Dockerfile -t cstrader-frontend:latest frontend/
	minikube image load cstrader:latest
	minikube image load cstrader-frontend:latest

image_load:
	minikube image load cstrader:latest
	minikube image load cstrader-frontend:latest

# Gerar o service da DB
gen_db_service_yaml:
	kubectl create service clusterip database \
  --tcp=5432:5432 \
  --dry-run=client -o yaml > infra/database/database_service.yaml

# Gerar o deployment YAML da API
gen_api_deployment_yaml:
	kubectl create deployment api --image cstrader:latest --replicas 3 --port=8000 --dry-run=client -o yaml > infra/backend/api_deployment.yaml

# Gerar o service YAML da API
gen_api_service_yaml:
	kubectl create service loadbalancer api \
  --tcp=8000:8000 \
  --dry-run=client -o yaml > infra/backend/api_service.yaml

#Gerar o deployment frontend
gen_frontend_deployment_yaml:
	kubectl create deployment frontend --image cstrader_nginx --replicas 3 --port=3000 --dry-run=client -o yaml > infra/frontend/frontend_deployment.yaml

#Gerar o service frontend
gen_frontend_service_yaml:
kubectl create service loadbalancer frontend \
  --tcp=3000:3000 \
  --dry-run=client -o yaml > ingra/frontend/frontend_service.yaml

generate: gen_db_service_yaml gen_api_deployment_yaml gen_api_service_yaml gen_frontend_deployment_yaml gen_frontend_service_yaml

secrets:
	kubectl apply -f infra/database/secret.yaml

db:
	kubectl apply -f infra/database/database_statefulset.yaml
	kubectl apply -f infra/database/database_service.yaml

api:
	kubectl apply -f infra/backend/admin-credentials.yaml
	kubectl apply -f infra/backend/secret.yaml
	kubectl apply -f infra/backend/api_deployment.yaml
	kubectl apply -f infra/backend/api_service.yaml
	kubectl apply -f infra/backend/admin_job.yaml

apply_frontend:
	kubectl apply -f infra/frontend/nginx_configmap.yaml
	kubectl apply -f infra/frontend/frontend_deployment.yaml
	kubectl apply -f infra/frontend/frontend_service.yaml
sleep:
	sleep 10
ingress:
	kubectl apply -f infra/ingress/ingress.yaml

deploy:
	kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 --address 0.0.0.0
	curl -v http://localhost:8080/

migrations:
	@echo "Running migrations..."
	kubectl exec -it $$(kubectl get pods -l app=api -o jsonpath="{.items[0].metadata.name}") -- poetry run alembic -c backend/alembic.ini upgrade head

admin:
	@echo "Creating admin user..."
	kubectl apply -f infra/backend/admin-credentials.yaml
	kubectl apply -f infra/backend/admin_job.yaml

start_JARVIS: start addons images secrets db api apply_frontend ingress sleep migrations admin deploy

run: image_load secrets db api apply_frontend ingress migrations admin deploy

clean:
	minikube delete