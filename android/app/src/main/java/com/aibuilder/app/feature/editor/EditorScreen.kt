package com.aibuilder.app.feature.editor

import android.annotation.SuppressLint
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Tablet
import androidx.compose.material.icons.filled.Tv
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView

@SuppressLint("SetJavaScriptEnabled")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditorScreen(
    websiteId: String,
    viewModel: EditorViewModel,
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    var webViewInstance by remember { mutableStateOf<WebView?>(null) }

    // Bottom sheet state for editing section properties
    var headlineText by remember { mutableStateOf("") }
    var subheadlineText by remember { mutableStateOf("") }

    LaunchedEffect(websiteId) {
        viewModel.loadWebsite(websiteId)
    }

    // Sync updated document to WebView canvas via JavaScript Interface
    LaunchedEffect(uiState.document) {
        if (uiState.document != null && webViewInstance != null) {
            val jsonEscaped = uiState.document.toString().replace("'", "\\'")
            webViewInstance?.evaluateJavascript("if (window.updateDocument) { window.updateDocument('$jsonEscaped'); }", null)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(uiState.websiteName, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        Text(
                            text = if (uiState.isSaving) "Saving..." else "Rev #${uiState.revisionNumber} (Saved)",
                            fontSize = 11.sp,
                            color = MaterialTheme.colorScheme.primary
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    // Viewport Mode Buttons
                    IconButton(onClick = { viewModel.setViewport(ViewportMode.Mobile) }) {
                        Icon(
                            Icons.Default.PhoneAndroid,
                            contentDescription = "Mobile",
                            tint = if (uiState.viewport == ViewportMode.Mobile) MaterialTheme.colorScheme.primary else Color.Gray
                        )
                    }
                    IconButton(onClick = { viewModel.setViewport(ViewportMode.Tablet) }) {
                        Icon(
                            Icons.Default.Tablet,
                            contentDescription = "Tablet",
                            tint = if (uiState.viewport == ViewportMode.Tablet) MaterialTheme.colorScheme.primary else Color.Gray
                        )
                    }
                    IconButton(onClick = { viewModel.setViewport(ViewportMode.Desktop) }) {
                        Icon(
                            Icons.Default.Tv,
                            contentDescription = "Desktop",
                            tint = if (uiState.viewport == ViewportMode.Desktop) MaterialTheme.colorScheme.primary else Color.Gray
                        )
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(Color(0xFF0F172A)),
            contentAlignment = Alignment.TopCenter
        ) {
            val canvasWidthModifier = when (uiState.viewport) {
                ViewportMode.Mobile -> Modifier.width(375.dp)
                ViewportMode.Tablet -> Modifier.width(600.dp)
                ViewportMode.Desktop -> Modifier.fillMaxWidth()
            }

            Box(
                modifier = canvasWidthModifier
                    .fillMaxHeight()
                    .background(Color.White)
            ) {
                AndroidView(
                    modifier = Modifier.fillMaxSize(),
                    factory = { ctx ->
                        WebView(ctx).apply {
                            layoutParams = ViewGroup.LayoutParams(
                                ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT
                            )
                            settings.javaScriptEnabled = true
                            settings.domStorageEnabled = true
                            settings.useWideViewPort = true
                            settings.loadWithOverviewMode = true
                            settings.cacheMode = WebSettings.LOAD_DEFAULT

                            val bridge = EditorJsBridge(
                                onSectionSelected = { sectionId ->
                                    viewModel.selectSection(sectionId)
                                },
                                onEditorReady = {
                                    // Inject initial document
                                    uiState.document?.let { doc ->
                                        val jsonEscaped = doc.toString().replace("'", "\\'")
                                        post {
                                            evaluateJavascript("if (window.updateDocument) { window.updateDocument('$jsonEscaped'); }", null)
                                        }
                                    }
                                }
                            )

                            addJavascriptInterface(bridge, "AndroidBridge")

                            webViewClient = object : WebViewClient() {
                                override fun onPageFinished(view: WebView?, url: String?) {
                                    super.onPageFinished(view, url)
                                    uiState.document?.let { doc ->
                                        val jsonEscaped = doc.toString().replace("'", "\\'")
                                        evaluateJavascript("if (window.updateDocument) { window.updateDocument('$jsonEscaped'); }", null)
                                    }
                                }
                            }

                            // Load local renderer dev preview or bundled renderer
                            loadUrl("http://10.0.2.2:3000/")
                            webViewInstance = this
                        }
                    }
                )
            }

            // Bottom Section Editor Sheet
            AnimatedVisibility(
                visible = uiState.selectedSectionId != null,
                modifier = Modifier.align(Alignment.BottomCenter)
            ) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                "Editing Section",
                                fontWeight = FontWeight.Bold,
                                fontSize = 16.sp
                            )
                            Text(
                                text = uiState.selectedSectionId ?: "",
                                fontSize = 12.sp,
                                color = MaterialTheme.colorScheme.primary
                            )
                        }

                        OutlinedTextField(
                            value = headlineText,
                            onValueChange = { headlineText = it },
                            label = { Text("Headline / Title") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )

                        OutlinedTextField(
                            value = subheadlineText,
                            onValueChange = { subheadlineText = it },
                            label = { Text("Subheadline / Description") },
                            modifier = Modifier.fillMaxWidth()
                        )

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.End
                        ) {
                            TextButton(onClick = { viewModel.selectSection("") }) {
                                Text("Close")
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                            Button(
                                onClick = {
                                    val secId = uiState.selectedSectionId ?: return@Button
                                    val updates = mutableMapOf<String, Any>()
                                    if (headlineText.isNotBlank()) updates["headline"] = headlineText
                                    if (subheadlineText.isNotBlank()) updates["subheadline"] = subheadlineText
                                    viewModel.updateSectionProps(secId, updates)
                                }
                            ) {
                                Icon(Icons.Default.Check, contentDescription = null)
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Apply")
                            }
                        }
                    }
                }
            }
        }
    }
}
