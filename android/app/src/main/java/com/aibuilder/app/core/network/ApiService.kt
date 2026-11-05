package com.aibuilder.app.core.network

import com.aibuilder.app.core.model.*
import com.google.gson.JsonObject
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // Auth
    @POST("api/v1/auth/register")
    suspend fun register(@Body body: Map<String, String>): Response<AuthResponse>

    @POST("api/v1/auth/login")
    suspend fun login(@Body body: Map<String, String>): Response<AuthResponse>

    @POST("api/v1/auth/google")
    suspend fun googleAuth(@Body body: Map<String, String>): Response<AuthResponse>

    @POST("api/v1/auth/apple")
    suspend fun appleAuth(@Body body: Map<String, String>): Response<AuthResponse>

    @POST("api/v1/auth/logout")
    suspend fun logout(): Response<Map<String, String>>

    @GET("api/v1/auth/me")
    suspend fun getProfile(): Response<Map<String, Any>>

    // Projects
    @GET("api/v1/projects")
    suspend fun getProjects(): Response<PaginatedResponse<Project>>

    @POST("api/v1/projects")
    suspend fun createProject(@Body body: Map<String, String>): Response<Map<String, Any>>

    @GET("api/v1/projects/{id}")
    suspend fun getProject(@Path("id") id: String): Response<Map<String, Any>>

    @DELETE("api/v1/projects/{id}")
    suspend fun deleteProject(@Path("id") id: String): Response<Map<String, String>>

    // Websites
    @GET("api/v1/websites")
    suspend fun getWebsites(@Query("project_id") projectId: String? = null): Response<PaginatedResponse<Website>>

    @POST("api/v1/websites")
    suspend fun createWebsite(@Body body: Map<String, Any>): Response<Map<String, Any>>

    @GET("api/v1/websites/{id}")
    suspend fun getWebsite(@Path("id") id: String): Response<Map<String, Any>>

    @PUT("api/v1/websites/{id}/document")
    suspend fun updateDocument(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<Map<String, Any>>

    @GET("api/v1/websites/{id}/revisions")
    suspend fun getRevisions(@Path("id") id: String): Response<PaginatedResponse<WebsiteRevision>>

    @POST("api/v1/websites/{id}/revisions/{revId}/restore")
    suspend fun restoreRevision(
        @Path("id") id: String,
        @Path("revId") revId: String
    ): Response<Map<String, Any>>

    @POST("api/v1/websites/{id}/lock")
    suspend fun acquireLock(@Path("id") id: String, @Body body: Map<String, String>): Response<Map<String, Any>>

    @POST("api/v1/websites/{id}/unlock")
    suspend fun releaseLock(@Path("id") id: String, @Body body: Map<String, String>): Response<Map<String, Any>>

    // Templates
    @GET("api/v1/templates")
    suspend fun getTemplates(
        @Query("category_id") categoryId: String? = null,
        @Query("search") search: String? = null
    ): Response<PaginatedResponse<Template>>

    @GET("api/v1/templates/categories")
    suspend fun getTemplateCategories(): Response<List<TemplateCategory>>

    @GET("api/v1/templates/{id}")
    suspend fun getTemplate(@Path("id") id: String): Response<Map<String, Any>>

    @POST("api/v1/templates/{id}/use")
    suspend fun useTemplate(
        @Path("id") id: String,
        @Body body: Map<String, String>
    ): Response<Map<String, Any>>
}

