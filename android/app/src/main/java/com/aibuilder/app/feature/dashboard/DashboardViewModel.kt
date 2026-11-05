package com.aibuilder.app.feature.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.database.SessionManager
import com.aibuilder.app.core.model.Project
import com.aibuilder.app.core.model.Website
import com.aibuilder.app.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DashboardUiState(
    val isLoading: Boolean = false,
    val projects: List<Project> = emptyList(),
    val websites: List<Website> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val apiService: ApiService,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val projRes = apiService.getProjects()
                val webRes = apiService.getWebsites()

                val projects = if (projRes.isSuccessful) projRes.body()?.data ?: emptyList() else emptyList()
                val websites = if (webRes.isSuccessful) webRes.body()?.data ?: emptyList() else emptyList()

                _uiState.value = DashboardUiState(
                    isLoading = false,
                    projects = projects,
                    websites = websites
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, error = e.message)
            }
        }
    }

    fun createWebsite(name: String, projectId: String, onCreated: (String) -> Unit) {
        viewModelScope.launch {
            try {
                val res = apiService.createWebsite(mapOf("name" to name, "project_id" to projectId))
                if (res.isSuccessful && res.body() != null) {
                    val websiteMap = res.body()!!["website"] as? Map<*, *>
                    val websiteId = websiteMap?.get("id") as? String
                    if (websiteId != null) {
                        onCreated(websiteId)
                    }
                    loadData()
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(error = e.message)
            }
        }
    }

    fun logout(onLoggedOut: () -> Unit) {
        viewModelScope.launch {
            try {
                apiService.logout()
            } catch (_: Exception) {}
            sessionManager.clearSession()
            onLoggedOut()
        }
    }
}

