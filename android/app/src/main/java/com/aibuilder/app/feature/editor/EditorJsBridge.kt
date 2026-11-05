package com.aibuilder.app.feature.editor

import android.webkit.JavascriptInterface
import org.json.JSONObject

class EditorJsBridge(
    private val onSectionSelected: (String) -> Unit,
    private val onEditorReady: () -> Unit
) {
    @JavascriptInterface
    fun postMessage(message: String) {
        try {
            val json = JSONObject(message)
            val action = json.optString("action")
            val payload = json.optJSONObject("payload")

            when (action) {
                "SELECT_SECTION" -> {
                    val sectionId = payload?.optString("sectionId")
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
