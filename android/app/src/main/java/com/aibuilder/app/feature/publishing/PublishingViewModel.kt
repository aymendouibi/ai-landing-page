package com.aibuilder.app.feature.publishing

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DomainItem(
    val id: String,
    val domain: String,
    val status: String,
    val verificationToken: String?,
    val cnameTarget: String? = "sites.yourplatform.com"
)

data class QaSummary(
    val passed: Boolean,
    val score: Int,
    val issuesCount: Int,
    val message: String
)

data class PublishingUiState(
    val isLoading: Boolean = false,
    val websiteId: String = "",
    val websiteName: String = "",
    val status: String = "draft",
    val subdomain: String = "",
    val liveUrl: String = "",
    val domains: List<DomainItem> = emptyList(),
    val qaSummary: QaSummary? = null,
    val errorMessage: String? = null,
    val successMessage: String? = null
)

@HiltViewModel
class PublishingViewModel @Inject constructor(
    private val apiService: ApiService,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val websiteId: String = checkNotNull(savedStateHandle["websiteId"])

    private val _uiState = MutableStateFlow(PublishingUiState(websiteId = websiteId))
    val uiState: StateFlow<PublishingUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                // Fetch website info
                val webRes = apiService.getWebsite(websiteId)
                if (webRes.isSuccessful) {
                    val body = webRes.body() ?: emptyMap()
                    val website = body["website"] as? Map<*, *> ?: body
                    val name = website["name"]?.toString() ?: "My Website"
                    val status = website["status"]?.toString() ?: "draft"
                    val subdomain = website["subdomain"]?.toString() ?: ""
                    val liveUrl = if (subdomain.isNotEmpty()) "https://$subdomain.yourplatform.com" else ""

                    _uiState.value = _uiState.value.copy(
                        websiteName = name,
                        status = status,
                        subdomain = subdomain,
                        liveUrl = liveUrl
                    )
                }

                // Fetch domains
                val domRes = apiService.getDomains(websiteId)
                if (domRes.isSuccessful) {
                    val body = domRes.body() ?: emptyMap()
                    val domainsList = (body["domains"] as? List<Map<String, Any>>) ?: emptyList()
                    val domainItems = domainsList.map { d ->
                        DomainItem(
                            id = d["id"]?.toString() ?: "",
                            domain = d["domain"]?.toString() ?: "",
                            status = d["status"]?.toString() ?: "pending",
                            verificationToken = d["verification_token"]?.toString()
                        )
                    }
                    _uiState.value = _uiState.value.copy(domains = domainItems)
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Failed to load publishing info: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun publish() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            try {
                val res = apiService.publishWebsite(websiteId)
                if (res.isSuccessful) {
                    val body = res.body()
                    val liveUrl = body?.get("live_url")?.toString() ?: _uiState.value.liveUrl
                    _uiState.value = _uiState.value.copy(
                        status = "published",
                        liveUrl = liveUrl,
                        successMessage = "Website successfully published to global CDN!"
                    )
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Publishing failed [${res.code()}]")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Publishing failed: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun unpublish() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            try {
                val res = apiService.unpublishWebsite(websiteId)
                if (res.isSuccessful) {
                    _uiState.value = _uiState.value.copy(
                        status = "draft",
                        successMessage = "Website unpublished successfully."
                    )
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Unpublish failed [${res.code()}]")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Unpublish failed: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun runVisualQa() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val res = apiService.runVisualQa(websiteId, mapOf("auto_fix" to true))
                if (res.isSuccessful) {
                    val body = res.body()
                    val report = body?.get("qa_report") as? Map<*, *>
                    if (report != null) {
                        val passed = report["passed"] as? Boolean ?: false
                        val score = (report["score"] as? Number)?.toInt() ?: 100
                        val issues = (report["issues_count"] as? Number)?.toInt() ?: 0
                        _uiState.value = _uiState.value.copy(
                            qaSummary = QaSummary(
                                passed = passed,
                                score = score,
                                issuesCount = issues,
                                message = if (passed) "All visual & WCAG accessibility standards passed!" else "Resolved $issues issues with auto-fix pass."
                            ),
                            successMessage = "Visual inspection and auto-fix complete."
                        )
                    }
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Visual QA check failed: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun addCustomDomain(domainName: String) {
        if (domainName.isBlank()) return
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            try {
                val res = apiService.addCustomDomain(websiteId, mapOf("domain" to domainName.trim()))
                if (res.isSuccessful) {
                    _uiState.value = _uiState.value.copy(
                        successMessage = "Domain added. Configure your DNS records to activate."
                    )
                    loadData()
                } else {
                    _uiState.value = _uiState.value.copy(errorMessage = "Failed to add domain [${res.code()}]")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Error adding domain: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun verifyDomain(domainId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            try {
                val res = apiService.verifyDomain(websiteId, domainId)
                if (res.isSuccessful) {
                    _uiState.value = _uiState.value.copy(
                        successMessage = "Domain verified and SSL certificate provisioned!"
                    )
                    loadData()
                } else {
                    _uiState.value = _uiState.value.copy(
                        errorMessage = "DNS not yet propagated. Please wait and verify again."
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Verification error: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }

    fun removeDomain(domainId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null, successMessage = null)
            try {
                val res = apiService.removeDomain(websiteId, domainId)
                if (res.isSuccessful) {
                    _uiState.value = _uiState.value.copy(successMessage = "Domain removed.")
                    loadData()
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Failed to remove domain: ${e.message}")
            } finally {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
        }
    }
}
