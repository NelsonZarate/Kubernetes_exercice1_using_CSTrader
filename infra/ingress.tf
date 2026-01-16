resource "null_resource" "fix_ingress_webhook" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission || true && sleep 10"
  }
}
resource "kubernetes_ingress_v1" "cstrader_ingress" {
  metadata {
    name      = "cstrader-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "cstrader.local"
      http {
        
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.frontend.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        # Rota para a API
        path {
          path = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.api.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service_v1.api,
    kubernetes_service_v1.frontend,
    null_resource.fix_ingress_webhook
  ]
}