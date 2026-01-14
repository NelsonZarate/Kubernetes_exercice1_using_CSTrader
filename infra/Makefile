plan:
	terraform plan -out k8s.plan

plan-cstrader:
	terraform plan -out k8s.plan -var-file cstrader.tfvars

images: 
	docker build -f backend/ops/Dockerfile  -t cstrader:latest .
	docker build -f frontend/Dockerfile -t cstrader-frontend:latest frontend/
	minikube image load cstrader:latest
	minikube image load cstrader-frontend:latest

apply:
	terraform apply k8s.plan