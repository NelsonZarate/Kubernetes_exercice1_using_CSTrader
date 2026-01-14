# --- Minikube Cluster ---
resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "terraform-provider-minikube-acc-docker"
  addons = [
    "default-storageclass",
    "storage-provisioner"
  ]
}

# --- Namespace ---
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "app"
  }
}

# --- Database Secret ---
resource "kubernetes_secret_v1" "cstrader-env" {
  metadata {
    name      = "cstrader-env"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    username = base64encode(var.database_username)
    password = base64encode(var.database_password)
    dbname   = base64encode(var.database_name)
    SECRET_KEY                  = base64encode(var.secret_key)
    ALGORITHM                   = base64encode(var.algorithm)
    ACCESS_TOKEN_EXPIRE_MINUTES = base64encode(tostring(var.access_token_expire_minutes))
    DATABASE_DRIVER              = base64encode(var.database_driver)
    DATABASE_USERNAME            = base64encode(var.database_username)
    DATABASE_PASSWORD            = base64encode(var.database_password)
    DATABASE_HOST                = base64encode(var.database_host)
    DATABASE_PORT                = base64encode(tostring(var.database_port))
    DATABASE_NAME                = base64encode(var.database_name)
    ADMIN_EMAIL                  = base64encode(var.admin_email)
    ADMIN_PASSWORD               = base64encode(var.admin_password)
    ADMIN_NAME                   = base64encode(var.admin_name)
  }

  type = "Opaque"
}

# --- StatefulSet da Database ---
resource "kubernetes_stateful_set_v1" "database" {
  metadata {
    name      = "database"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = { app = "database" }
  }

  spec {
    service_name = "database"
    replicas     = 1

    selector {
      match_labels = { app = "database" }
    }

    template {
      metadata {
        labels = { app = "database" }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:17"

          port {
            container_port = 5432
            name           = "postgres"
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.cstrader-env.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.cstrader-env.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.cstrader-env.metadata[0].name
                key  = "dbname"
              }
            }
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata { name = "postgres-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = { storage = "1Gi" }
        }
      }
    }
  }

  depends_on = [kubernetes_secret_v1.cstrader-env]
}

# --- Deployment da API ---
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
          name  = "cstrader"
          image = "cstrader:latest"
          image_pull_policy = "Never"

          port {
            container_port = 8000
          }

          resources {
            requests = { cpu = "250m", memory = "128Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }

          # Todas as env vars vêm do Secret cstrader_env
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.cstrader_env.metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_secret_v1.cstrader_env]
}
