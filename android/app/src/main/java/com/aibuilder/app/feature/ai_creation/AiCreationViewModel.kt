package com.aibuilder.app.feature.ai_creation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface AiGenerationStatus {
    object Idle : AiGenerationStatus
    data class Generating(val step: String, val progress: Int) : AiGenerationStatus
    data class Success(val websiteId: String) : AiGenerationStatus
    data class Error(val message: String) : AiGenerationStatus
}

@HiltViewModel
class AiCreationViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _status = MutableStateFlow<AiGenerationStatus>(AiGenerationStatus.Idle)
    val status: StateFlow<AiGenerationStatus> = _status.asStateFlow()

    fun generateWebsite(prompt: String, industry: String) {
        viewModelScope.launch {
            _status.value = AiGenerationStatus.Generating("Analyzing business & audience...", 15)

            try {
                // Fetch first project ID
                val projRes = apiService.getProjects()
                val projectId = projRes.body()?.data?.firstOrNull()?.id
                if (projectId == null) {
                    _status.value = AiGenerationStatus.Error("Please create a project workspace first.")
                    return@launch
                }

                _status.value = AiGenerationStatus.Generating("Planning conversion architecture...", 35)

                // Dispatch generation to AI pipeline
                val genRes = apiService.generateWebsite(
                    mapOf(
                        "project_id" to projectId,
                        "prompt" to prompt,
                        "industry" to industry,
                        "sync" to true
                    )
                )

                if (genRes.isSuccessful && genRes.body() != null) {
                    _status.value = AiGenerationStatus.Generating("Assembling structured document...", 90)
                    delay(500)

                    val body = genRes.body()!!
                    val websiteId = body["website_id"]?.toString()

                    if (!websiteId.isNullOrBlank()) {
                        _status.value = AiGenerationStatus.Success(websiteId)
                    } else {
                        _status.value = AiGenerationStatus.Error("Could not retrieve created website.")
                    }
                } else {
                    _status.value = AiGenerationStatus.Error("Generation request failed [${genRes.code()}].")
                }
            } catch (e: Exception) {
                _status.value = AiGenerationStatus.Error(e.message ?: "Failed to generate website.")
            }
        }
    }
}

