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
    val userName: String? = null,
    val userInitials: String = "MR",
    val projects: List<Project> = emptyList(),
    val websites: List<Website> = emptyList(),
    val showNewWebsiteSheet: Boolean = false,
    val activeTab: String = "Projects",
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
        observeUser()
        loadData()
    }

    private fun observeUser() {
        viewModelScope.launch {
            sessionManager.userName.collect { name ->
                val initials = name?.split(" ")
                    ?.filter { it.isNotBlank() }
                    ?.mapNotNull { it.firstOrNull()?.uppercaseChar() }
                    ?.take(2)
                    ?.joinToString("")
                    ?.ifEmpty { "MR" } ?: "MR"

                _uiState.value = _uiState.value.copy(
                    userName = name,
                    userInitials = initials
                )
            }
        }
    }

    fun setTab(tab: String) {
        _uiState.value = _uiState.value.copy(activeTab = tab)
    }

    fun openNewWebsiteSheet() {
        _uiState.value = _uiState.value.copy(showNewWebsiteSheet = true)
    }

    fun closeNewWebsiteSheet() {
        _uiState.value = _uiState.value.copy(showNewWebsiteSheet = false)
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val projRes = apiService.getProjects()
                val webRes = apiService.getWebsites()

                val projects = if (projRes.isSuccessful) projRes.body()?.data ?: emptyList() else emptyList()
                val websites = if (webRes.isSuccessful) webRes.body()?.data ?: emptyList() else emptyList()

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    projects = projects,
                    websites = websites
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, error = e.message)
            }
        }
    }

    fun createBlankWebsite(onCreated: (String) -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                var projectId = _uiState.value.projects.firstOrNull()?.id
                if (projectId == null) {
                    val projRes = apiService.getProjects()
                    val existingProj = projRes.body()?.data?.firstOrNull()
                    projectId = existingProj?.id ?: run {
                        val createProjRes = apiService.createProject(mapOf("name" to "My Project"))
                        val projMap = createProjRes.body()?.get("project") as? Map<*, *>
                        projMap?.get("id") as? String
                    }
                }

                if (projectId == null) {
                    _uiState.value = _uiState.value.copy(isLoading = false, error = "Could not find or create project workspace")
                    return@launch
                }

                val res = apiService.createWebsite(mapOf(
                    "name" to "Untitled Website",
                    "project_id" to projectId
                ))
                if (res.isSuccessful && res.body() != null) {
                    val websiteMap = res.body()!!["website"] as? Map<*, *>
                    val websiteId = websiteMap?.get("id") as? String
                    if (websiteId != null) {
                        _uiState.value = _uiState.value.copy(isLoading = false, showNewWebsiteSheet = false)
                        loadData()
                        onCreated(websiteId)
                    } else {
                        _uiState.value = _uiState.value.copy(isLoading = false, error = "Failed to parse website response")
                    }
                } else {
                    _uiState.value = _uiState.value.copy(isLoading = false, error = "Server returned error on creation")
                }
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

