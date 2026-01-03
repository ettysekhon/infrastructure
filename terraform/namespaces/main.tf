resource "kubernetes_namespace_v1" "auth_platform" {
  metadata {
    name = "auth-platform"

    labels = {
      name        = "auth-platform"
      managed-by  = "terraform"
      environment = local.environment
      tier        = "platform"
      purpose     = "authentication"
    }

    annotations = {
      description = "Shared authentication platform (Keycloak, OAuth, OIDC)"
    }
  }
}

resource "kubernetes_namespace_v1" "meal_planner" {
  metadata {
    name = "meal-planner"

    labels = {
      name        = "meal-planner"
      managed-by  = "terraform"
      environment = local.environment
      tier        = "application"
      app         = "conversational-meal-planner"
    }

    annotations = {
      description = "Conversational Meal Planner MCP application"
    }
  }
}

output "namespace_auth_platform" {
  value = kubernetes_namespace_v1.auth_platform.metadata[0].name
}

output "namespace_meal_planner" {
  value = kubernetes_namespace_v1.meal_planner.metadata[0].name
}

output "environment" {
  value = local.environment
}
