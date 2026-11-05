package com.aibuilder.app.core.model

import com.google.gson.JsonObject
import com.google.gson.annotations.SerializedName

data class User(
    val id: String,
    val name: String,
    val email: String,
    val role: String,
    @SerializedName("avatar_url") val avatarUrl: String? = null
)

data class AuthResponse(
    val message: String,
    val user: User,
    val token: String
)

data class Project(
    val id: String,
    @SerializedName("user_id") val userId: String,
    val name: String,
    val description: String? = null,
    @SerializedName("websites_count") val websitesCount: Int = 0,
    val websites: List<Website> = emptyList(),
    @SerializedName("created_at") val createdAt: String? = null
)

data class Website(
    val id: String,
    @SerializedName("project_id") val projectId: String,
    val name: String,
    val slug: String,
    val status: String,
    val subdomain: String? = null,
    @SerializedName("revision_number") val revisionNumber: Int = 1,
    @SerializedName("current_revision_id") val currentRevisionId: String? = null,
    val document: JsonObject? = null,
    @SerializedName("current_revision") val currentRevision: WebsiteRevision? = null
)

data class WebsiteRevision(
    val id: String,
    @SerializedName("website_id") val websiteId: String,
    @SerializedName("revision_number") val revisionNumber: Int,
    val source: String,
    val description: String? = null,
    val document: JsonObject? = null,
    @SerializedName("created_at") val createdAt: String? = null
)

data class TemplateCategory(
    val id: String,
    val name: String,
    val slug: String,
    val icon: String? = null,
    @SerializedName("templates_count") val templatesCount: Int = 0
)

data class Template(
    val id: String,
    val name: String,
    val slug: String,
    val description: String? = null,
    val industry: String? = null,
    @SerializedName("preview_images") val previewImages: List<String>? = null,
    val status: String,
    @SerializedName("use_count") val useCount: Int = 0,
    @SerializedName("is_premium") val isPremium: Boolean = false,
    val category: TemplateCategory? = null,
    @SerializedName("active_version") val activeVersion: TemplateVersion? = null
)

data class TemplateVersion(
    val id: String,
    @SerializedName("template_id") val templateId: String,
    val version: Int,
    val document: JsonObject? = null
)

data class PaginatedResponse<T>(
    val data: List<T>,
    @SerializedName("current_page") val currentPage: Int,
    @SerializedName("last_page") val lastPage: Int,
    val total: Int
)

