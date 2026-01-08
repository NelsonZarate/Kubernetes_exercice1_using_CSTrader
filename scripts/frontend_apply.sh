frontend:
	# 1. Cria o ConfigMap a partir da tua pasta local
	kubectl create configmap nginx-conf --from-file=frontend/conf.d/ --dry-run=client -o yaml | kubectl apply -f -
	# 2. Aplica o Deployment e Service
	kubectl apply -f frontend_deployment.yaml
	kubectl apply -f frontend_service.yaml
