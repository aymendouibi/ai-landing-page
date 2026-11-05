package com.aibuilder.app.feature.editor

import android.webkit.JavascriptInterface
import com.google.gson.Gson
import com.google.gson.JsonObject

class EditorJsBridge(
    private val onSectionSelected: (String) -> Unit,
    private val onEditorReady: () -> Unit
) {
    private val gson = Gson()

    @JavascriptInterface
    fun postMessage(message: String) {
        try {
            val json = gson.fromJson(message, JsonObject::class.java)
            val action = json.get("action")?.asString

            when (action) {
                "SELECT_SECTION" -> {
                    val payload = json.getAsJsonObject("payload")
                    val sectionId = payload?.get("sectionId")?.asString
                    if (!sectionId.isNullOrEmpty()) {
                        onSectionSelected(sectionId)
                    }
                }
                "EDITOR_READY" -> {
                    onEditorReady()
                }
            }
        } catch (_: Exception) {}
    }

    @JavascriptInterface
    fun onSectionSelected(sectionId: String) {
        onSectionSelected.invoke(sectionId)
    }
}
