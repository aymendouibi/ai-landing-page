package com.aibuilder.app.core.navigation

sealed class Screen(val route: String) {
    object Auth : Screen("auth")
    object Dashboard : Screen("dashboard")
    object Templates : Screen("templates")
    object AiCreation : Screen("ai_creation")
    object Editor : Screen("editor/{websiteId}") {
        fun createRoute(websiteId: String) = "editor/$websiteId"
    }
    object Publishing : Screen("publishing/{websiteId}") {
        fun createRoute(websiteId: String) = "publishing/$websiteId"
    }
}

