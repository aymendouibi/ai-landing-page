package com.aibuilder.app.feature.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aibuilder.app.core.database.SessionManager
import com.aibuilder.app.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface AuthUiState {
    object Idle : AuthUiState
    object Loading : AuthUiState
    object Success : AuthUiState
    data class Error(val message: String) : AuthUiState
}

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val apiService: ApiService,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _uiState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            try {
                val res = apiService.login(mapOf("email" to email, "password" to password))
                if (res.isSuccessful && res.body() != null) {
                    val auth = res.body()!!
                    sessionManager.saveSession(auth.token, auth.user.id, auth.user.name, auth.user.email)
                    _uiState.value = AuthUiState.Success
                } else {
                    _uiState.value = AuthUiState.Error(res.errorBody()?.string() ?: "Login failed.")
                }
            } catch (e: Exception) {
                _uiState.value = AuthUiState.Error(e.message ?: "Network error.")
            }
        }
    }

    fun register(name: String, email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            try {
                val res = apiService.register(mapOf("name" to name, "email" to email, "password" to password))
                if (res.isSuccessful && res.body() != null) {
                    val auth = res.body()!!
                    sessionManager.saveSession(auth.token, auth.user.id, auth.user.name, auth.user.email)
                    _uiState.value = AuthUiState.Success
                } else {
                    _uiState.value = AuthUiState.Error(res.errorBody()?.string() ?: "Registration failed.")
                }
            } catch (e: Exception) {
                _uiState.value = AuthUiState.Error(e.message ?: "Network error.")
            }
        }
    }

    fun handleGoogleIdToken(idToken: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            try {
                val res = apiService.googleAuth(mapOf("id_token" to idToken))
                if (res.isSuccessful && res.body() != null) {
                    val auth = res.body()!!
                    sessionManager.saveSession(auth.token, auth.user.id, auth.user.name, auth.user.email)
                    _uiState.value = AuthUiState.Success
                } else {
                    _uiState.value = AuthUiState.Error("Google sign-in failed.")
                }
            } catch (e: Exception) {
                _uiState.value = AuthUiState.Error(e.message ?: "Network error.")
            }
        }
    }
}
