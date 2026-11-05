package com.aibuilder.app.feature.templates

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.model.Template
import com.aibuilder.app.core.model.TemplateCategory
import com.aibuilder.app.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class TemplatesUiState(
    val isLoading: Boolean = false,
    val categories: List<TemplateCategory> = emptyList(),
    val templates: List<Template> = emptyList(),
    val selectedCategoryId: String? = null,
    val error: String? = null
)

@HiltViewModel
class TemplatesViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(TemplatesUiState())
    val uiState: StateFlow<TemplatesUiState> = _uiState.asStateFlow()

    init {
        loadCategories()
        loadTemplates()
    }

    fun loadCategories() {
        viewModelScope.launch {
            try {
                val res = apiService.getTemplateCategories()
                if (res.isSuccessful && res.body() != null) {
                    _uiState.value = _uiState.value.copy(categories = res.body()!!)
                }
            } catch (_: Exception) {}
        }
    }

    fun loadTemplates(categoryId: String? = null) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, selectedCategoryId = categoryId)
            try {
                val res = apiService.getTemplates(categoryId = categoryId)
                if (res.isSuccessful && res.body() != null) {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        templates = res.body()!!.data
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, error = e.message)
            }
        }
    }

    fun useTemplate(templateId: String, name: String, onUsed: (String) -> Unit) {
        viewModelScope.launch {
            try {
                val projRes = apiService.getProjects()
                val projectId = projRes.body()?.data?.firstOrNull()?.id ?: return@launch

                val res = apiService.useTemplate(
                    id = templateId,
                    body = mapOf("name" to name, "project_id" to projectId)
                )

                if (res.isSuccessful && res.body() != null) {
                    val webMap = res.body()!!["website"] as? Map<*, *>
                    val websiteId = webMap?.get("id") as? String
                    if (websiteId != null) {
                        onUsed(websiteId)
                    }
                }
            } catch (_: Exception) {}
        }
    }
}
