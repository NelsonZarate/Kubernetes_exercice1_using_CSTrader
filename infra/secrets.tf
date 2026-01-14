resource "kubernetes_secret_v1" "cstrader_env" {
  metadata {
    name      = "cstarder-env"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    SECRET_KEY                  = base64encode(var.secret_key)
    ALGORITHM                   = base64encode(var.algorithm)
    ACCESS_TOKEN_EXPIRE_MINUTES = base64encode(tostring(var.access_token_expire_minutes))

    DATABASE_DRIVER   = base64encode(var.database_driver)
    DATABASE_USERNAME = base64encode(var.database_username)
    DATABASE_PASSWORD = base64encode(var.database_password)
    DATABASE_HOST     = base64encode(var.database_host)
    DATABASE_PORT     = base64encode(tostring(var.database_port))
    DATABASE_NAME     = base64encode(var.database_name)

    ADMIN_EMAIL    = base64encode(var.admin_email)
    ADMIN_PASSWORD = base64encode(var.admin_password)
    ADMIN_NAME     = base64encode(var.admin_name)
  }

  type = "Opaque"
}
