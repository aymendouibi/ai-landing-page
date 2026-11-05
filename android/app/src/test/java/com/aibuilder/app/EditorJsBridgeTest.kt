package com.aibuilder.app

import com.aibuilder.app.feature.editor.EditorJsBridge
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class EditorJsBridgeTest {

    @Test
    fun testSelectSectionMessageDispatchesCallback() {
        var selectedId = ""
        val bridge = EditorJsBridge(
            onSectionSelected = { id -> selectedId = id },
            onEditorReady = {}
        )

        bridge.onSectionSelected("sec_hero_123")
        assertEquals("sec_hero_123", selectedId)
    }

    @Test
    fun testEditorReadyDispatchesCallback() {
        var ready = false
        val bridge = EditorJsBridge(
            onSectionSelected = {},
            onEditorReady = { ready = true }
        )

        // Simulates bridge receiving the message from WebView
        bridge.postMessage("""{"action":"EDITOR_READY","payload":{}}""")
        assertTrue(ready)
    }
}

