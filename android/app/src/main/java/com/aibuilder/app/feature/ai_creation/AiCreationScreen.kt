package com.aibuilder.app.feature.ai_creation

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AiCreationScreen(
    viewModel: AiCreationViewModel,
    onNavigateBack: () -> Unit,
    onGenerationComplete: (String) -> Unit
) {
    val status by viewModel.status.collectAsState()

    var businessPrompt by remember { mutableStateOf("") }
    var selectedIndustry by remember { mutableStateOf("Technology") }

    val industries = listOf("Technology", "SaaS", "Restaurant", "Beauty & Wellness", "Fitness", "Real Estate", "Agency", "Portfolio")

    LaunchedEffect(status) {
        if (status is AiGenerationStatus.Success) {
            val siteId = (status as AiGenerationStatus.Success).websiteId
            onGenerationComplete(siteId)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("AI Website Creator", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                // Header card
                Card(
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Icon(
                            Icons.Default.AutoAwesome,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(36.dp)
                        )
                        Column {
                            Text(
                                "Staged AI Generator",
                                fontWeight = FontWeight.Bold,
                                fontSize = 16.sp,
                                color = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                            Text(
                                "Tell AI about your business. It extracts brand identity, designs tokens, plans sections, and writes conversion copy.",
                                fontSize = 12.sp,
                                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                            )
                        }
                    }
                }

                // Prompt Input
                OutlinedTextField(
                    value = businessPrompt,
                    onValueChange = { businessPrompt = it },
                    label = { Text("Describe your business or website idea") },
                    placeholder = { Text("e.g. A boutique matcha cafe in Kyoto offering ceremonial grade tea, artisan pastries, and online subscriptions.") },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(140.dp),
                    shape = RoundedCornerShape(12.dp)
                )

                // Industry Selector
                Text("Select Industry", fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                ScrollableTabRow(
                    selectedTabIndex = industries.indexOf(selectedIndustry).coerceAtLeast(0),
                    edgePadding = 0.dp
                ) {
                    industries.forEach { ind ->
                        Tab(
                            selected = selectedIndustry == ind,
                            onClick = { selectedIndustry = ind },
                            text = { Text(ind, fontSize = 13.sp) }
                        )
                    }
                }

                // Status view
                AnimatedVisibility(visible = status is AiGenerationStatus.Generating) {
                    val gen = status as? AiGenerationStatus.Generating
                    Card(modifier = Modifier.fillMaxWidth()) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            CircularProgressIndicator(
                                progress = { (gen?.progress ?: 0) / 100f },
                                modifier = Modifier.size(48.dp)
                            )
                            Text(
                                text = gen?.step ?: "Generating...",
                                fontWeight = FontWeight.Medium,
                                fontSize = 14.sp
                            )
                        }
                    }
                }

                if (status is AiGenerationStatus.Error) {
                    Text(
                        text = (status as AiGenerationStatus.Error).message,
                        color = MaterialTheme.colorScheme.error,
                        fontSize = 13.sp
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                Button(
                    onClick = {
                        if (businessPrompt.isNotBlank()) {
                            viewModel.generateWebsite(businessPrompt, selectedIndustry)
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    enabled = businessPrompt.isNotBlank() && status !is AiGenerationStatus.Generating,
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Icon(Icons.Default.AutoAwesome, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Generate Website with AI", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
