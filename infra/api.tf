resource "kubernetes_deployment_v1" "api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = { app = "api" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "api" }
    }

    template {
      metadata {
        labels = { app = "api" }
      }

      spec {
        container {
          name              = "cstrader"
          image             = "cstrader:latest"
          image_pull_policy = "Never"

          port {
            container_port = 8000
          }

          resources {
            requests = { cpu = "250m", memory = "128Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }

          # Referência ao Secret definido no main.tf
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.cstrader-env.metadata[0].name
            }
          }
        }
      }
    }
  }
  
  # A API só deve arrancar depois da DB (embora o ideal seja ter retry logic na app)
  depends_on = [
    kubernetes_secret_v1.cstrader-env,
    kubernetes_stateful_set_v1.database
  ]
}