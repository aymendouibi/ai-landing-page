package com.aibuilder.app.feature.editor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.network.ApiService
import com.google.gson.Gson
import com.google.gson.JsonObject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class EditorUiState(
    val isLoading: Boolean = false,
    val websiteId: String = "",
    val websiteName: String = "",
    val revisionNumber: Int = 1,
    val document: JsonObject? = null,
    val selectedSectionId: String? = null,
    val viewport: ViewportMode = ViewportMode.Mobile,
    val isSaving: Boolean = false,
    val error: String? = null
)

enum class ViewportMode {
    Mobile, Tablet, Desktop
}

@HiltViewModel
class EditorViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(EditorUiState())
    val uiState: StateFlow<EditorUiState> = _uiState.asStateFlow()

    private val gson = Gson()
    private val lockToken = UUID.randomUUID().toString()

    fun loadWebsite(websiteId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, websiteId = websiteId)
            try {
                // Acquire edit lock
                apiService.acquireLock(websiteId, mapOf("lock_token" to lockToken))

                val res = apiService.getWebsite(websiteId)
                if (res.isSuccessful && res.body() != null) {
                    val webMap = res.body()!!["website"] as? Map<*, *>
                    val name = webMap?.get("name") as? String ?: "Website"
                    val revNum = (webMap?.get("revision_number") as? Number)?.toInt() ?: 1
                    val docObj = gson.toJsonTree(webMap?.get("document")).asJsonObject

                    _uiState.value = EditorUiState(
                        isLoading = false,
                        websiteId = websiteId,
                        websiteName = name,
                        revisionNumber = revNum,
                        document = docObj
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, error = e.message)
            }
        }
    }

    fun selectSection(sectionId: String) {
        _uiState.value = _uiState.value.copy(selectedSectionId = sectionId)
    }

    fun setViewport(mode: ViewportMode) {
        _uiState.value = _uiState.value.copy(viewport = mode)
    }

    fun updateSectionProps(sectionId: String, newProps: Map<String, Any>) {
        val currentDoc = _uiState.value.document ?: return
        val docCopy = gson.fromJson(currentDoc.toString(), JsonObject::class.java)

        try {
            val pages = docCopy.getAsJsonArray("pages")
            for (p in pages) {
                val page = p.asJsonObject
                val sections = page.getAsJsonArray("sections")
                for (s in sections) {
                    val sec = s.asJsonObject
                    if (sec.get("id")?.asString == sectionId) {
                        val props = sec.getAsJsonObject("props")
                        for ((k, v) in newProps) {
                            props.addProperty(k, v.toString())
                        }
                    }
                }
            }

            _uiState.value = _uiState.value.copy(document = docCopy)
            saveDocument(docCopy)
        } catch (_: Exception) {}
    }

    private fun saveDocument(doc: JsonObject) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true)
            try {
                val body = mapOf(
                    "document" to gson.fromJson(doc.toString(), Map::class.java),
                    "expected_revision_number" to _uiState.value.revisionNumber,
                    "lock_token" to lockToken,
                    "description" to "Mobile Visual Editor autosave"
                )
                val res = apiService.updateDocument(_uiState.value.websiteId, body)
                if (res.isSuccessful && res.body() != null) {
                    val webMap = res.body()!!["website"] as? Map<*, *>
                    val newRev = (webMap?.get("revision_number") as? Number)?.toInt() ?: (_uiState.value.revisionNumber + 1)
                    _uiState.value = _uiState.value.copy(isSaving = false, revisionNumber = newRev)
                } else {
                    _uiState.value = _uiState.value.copy(isSaving = false)
                }
            } catch (_: Exception) {
                _uiState.value = _uiState.value.copy(isSaving = false)
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        // Release editing lock on exit
        if (_uiState.value.websiteId.isNotEmpty()) {
            viewModelScope.launch {
                try {
                    apiService.releaseLock(_uiState.value.websiteId, mapOf("lock_token" to lockToken))
                } catch (_: Exception) {}
            }
        }
    }
}
