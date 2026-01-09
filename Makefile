start:
	minikube start
	
secrets:
	kubectl apply -f infra/database/secret.yaml

db:
	kubectl apply -f infra/database/database_statefulset.yaml
	kubectl apply -f infra/database/database_service.yaml

api:
	kubectl apply -f infra/backend/api_deployment.yaml
	kubectl apply -f infra/backend/api_service.yaml

frontend:
	kubectl apply -f infra/frontend/frontend_deployment.yaml
	kubectl apply -f infra/frontend/frontend_service.yaml

ingress:
	kubectl apply -f infra/ingress/ingress.yaml

all: start secrets db api frontend ingress

clean:
	kubectl delete -f api_service.yaml --ignore-not-found=true
	kubectl delete -f api_deployment.yaml --ignore-not-found=true
	kubectl delete -f database_service.yaml --ignore-not-found=true
	kubectl delete -f database_deployment.yaml --ignore-not-found=true
	kubectl delete -f storage.yaml --ignore-not-found=true
	kubectl delete -f secret.yaml --ignore-not-found=true