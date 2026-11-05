package com.aibuilder.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.aibuilder.app.core.designsystem.AiBuilderTheme
import com.aibuilder.app.core.navigation.Screen
import com.aibuilder.app.feature.ai_creation.AiCreationScreen
import com.aibuilder.app.feature.ai_creation.AiCreationViewModel
import com.aibuilder.app.feature.auth.AuthScreen
import com.aibuilder.app.feature.auth.AuthViewModel
import com.aibuilder.app.feature.dashboard.DashboardScreen
import com.aibuilder.app.feature.dashboard.DashboardViewModel
import com.aibuilder.app.feature.editor.EditorScreen
import com.aibuilder.app.feature.editor.EditorViewModel
import com.aibuilder.app.feature.templates.TemplatesScreen
import com.aibuilder.app.feature.templates.TemplatesViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AiBuilderTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    AiBuilderAppNavigation()
                }
            }
        }
    }
}

@Composable
fun AiBuilderAppNavigation() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = Screen.Auth.route
    ) {
        composable(Screen.Auth.route) {
            val viewModel: AuthViewModel = hiltViewModel()
            AuthScreen(
                viewModel = viewModel,
                onAuthSuccess = {
                    navController.navigate(Screen.Dashboard.route) {
                        popUpTo(Screen.Auth.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Dashboard.route) {
            val viewModel: DashboardViewModel = hiltViewModel()
            DashboardScreen(
                viewModel = viewModel,
                onNavigateToEditor = { websiteId ->
                    navController.navigate(Screen.Editor.createRoute(websiteId))
                },
                onNavigateToTemplates = {
                    navController.navigate(Screen.Templates.route)
                },
                onNavigateToAiCreation = {
                    navController.navigate(Screen.AiCreation.route)
                },
                onLogout = {
                    navController.navigate(Screen.Auth.route) {
                        popUpTo(Screen.Dashboard.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Templates.route) {
            val viewModel: TemplatesViewModel = hiltViewModel()
            TemplatesScreen(
                viewModel = viewModel,
                onNavigateBack = { navController.popBackStack() },
                onTemplateSelected = { websiteId ->
                    navController.navigate(Screen.Editor.createRoute(websiteId))
                }
            )
        }

        composable(Screen.AiCreation.route) {
            val viewModel: AiCreationViewModel = hiltViewModel()
            AiCreationScreen(
                viewModel = viewModel,
                onNavigateBack = { navController.popBackStack() },
                onGenerationComplete = { websiteId ->
                    navController.navigate(Screen.Editor.createRoute(websiteId)) {
                        popUpTo(Screen.Dashboard.route)
                    }
                }
            )
        }

        composable(
            route = Screen.Editor.route,
            arguments = listOf(navArgument("websiteId") { type = NavType.StringType })
        ) { backStackEntry ->
            val websiteId = backStackEntry.arguments?.getString("websiteId") ?: ""
            val viewModel: EditorViewModel = hiltViewModel()
            EditorScreen(
                websiteId = websiteId,
                viewModel = viewModel,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}

