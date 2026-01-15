resource "kubernetes_secret_v1" "cstrader_env" {
  metadata {
    name      = "cstarder-env"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    SECRET_KEY                  = (var.secret_key)
    ALGORITHM                   = (var.algorithm)
    ACCESS_TOKEN_EXPIRE_MINUTES = (tostring(var.access_token_expire_minutes))

    DATABASE_DRIVER   = var.database_driver
    DATABASE_USERNAME = var.database_username
    DATABASE_PASSWORD = var.database_password
    DATABASE_HOST     = var.database_host
    DATABASE_PORT     = tostring(var.database_port)
    DATABASE_NAME     = var.database_name

    ADMIN_EMAIL    = var.admin_email
    ADMIN_PASSWORD = var.admin_password
    ADMIN_NAME     = var.admin_name
  }

  type = "Opaque"
}
