package com.aibuilder.app.feature.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.aibuilder.app.core.designsystem.AppColors
import com.aibuilder.app.core.designsystem.AppGradients
import com.aibuilder.app.core.designsystem.AppTypography
import com.aibuilder.app.feature.dashboard.components.ContinueEditingHeroCard
import com.aibuilder.app.feature.dashboard.components.FloatingBottomBar
import com.aibuilder.app.feature.dashboard.components.NewWebsiteBottomSheet
import com.aibuilder.app.feature.dashboard.components.RecentProjectCard
import com.aibuilder.app.feature.dashboard.components.WebsitePreviewItem

@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel,
    onNavigateToEditor: (String) -> Unit,
    onNavigateToTemplates: () -> Unit,
    onNavigateToAiCreation: () -> Unit,
    onLogout: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    var showProfileDialog by remember { mutableStateOf(false) }

    // Website previews for the "Recent" horizontal carousel
    val previewItems = remember(uiState.websites) {
        val list = mutableListOf<WebsitePreviewItem>()
        val recentSites = uiState.websites.drop(1)

        recentSites.forEach { site ->
            when (site.slug) {
                "studio-marlow" -> list.add(
                    WebsitePreviewItem(
                        id = site.id,
                        title = "Studio Marlow",
                        category = "Architecture, Copenhagen",
                        headline = "Quiet buildings for busy lives",
                        body = "Homes, libraries and small civic spaces, designed with the people who use them.",
                        ctaText = "See our work",
                        ctaColor = Color(0xFF0C0C14),
                        imageUrl = "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80",
                        isSerif = true,
                        bgCanvasColor = Color(0xFFFAF8F5)
                    )
                )
                "kite-yoga" -> list.add(
                    WebsitePreviewItem(
                        id = site.id,
                        title = "Kite Yoga",
                        category = "East 6th St, Austin",
                        headline = "Slow mornings start here",
                        body = "Small classes in a sunlit studio, timers to daily practice.",
                        ctaText = "See the schedule",
                        ctaColor = Color(0xFF5D6B50),
                        imageUrl = "https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80",
                        isSerif = false,
                        bgCanvasColor = Color(0xFFFAF8F4)
                    )
                )
                else -> {
                    val isBakery = site.name.contains("Boulangerie", ignoreCase = true)
                    val isApex = site.name.contains("Apex", ignoreCase = true)
                    list.add(
                        WebsitePreviewItem(
                            id = site.id,
                            title = site.name,
                            category = if (isBakery) "Artisanal Bakery, Paris" else if (isApex) "Architecture & Design" else "Digital Studio",
                            headline = if (isBakery) "Fresh Croissants, Crafted with Tech-Precision" else if (isApex) "Designing Tomorrow's Landmarks" else "Crafted for Modern Growth",
                            body = if (isBakery) "Experience the perfect blend of traditional French baking and modern digital quality." else if (isApex) "We blend cutting-edge design, sustainable practices, and flawless execution." else "Clean architecture, custom layout, and optimized speed for high conversion.",
                            ctaText = if (isBakery) "Explore Menu" else if (isApex) "Explore Projects" else "Open Editor",
                            ctaColor = if (isBakery) Color(0xFF2563EB) else if (isApex) Color(0xFF2563EB) else Color(0xFF0C0C14),
                            imageUrl = if (isBakery) "https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=400&q=80" else if (isApex) "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=400&q=80" else "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=400&q=80",
                            isSerif = isApex,
                            bgCanvasColor = Color(0xFFFAF8F5)
                        )
                    )
                }
            }
        }

        // Guarantee Studio Marlow and Kite Yoga exist in the carousel
        if (list.none { it.title == "Studio Marlow" }) {
            list.add(
                WebsitePreviewItem(
                    id = "showcase_studio_marlow",
                    title = "Studio Marlow",
                    category = "Architecture, Copenhagen",
                    headline = "Quiet buildings for busy lives",
                    body = "Homes, libraries and small civic spaces, designed with the people who use them.",
                    ctaText = "See our work",
                    ctaColor = Color(0xFF0C0C14),
                    imageUrl = "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80",
                    isSerif = true,
                    bgCanvasColor = Color(0xFFFAF8F5)
                )
            )
        }
        if (list.none { it.title == "Kite Yoga" }) {
            list.add(
                WebsitePreviewItem(
                    id = "showcase_kite_yoga",
                    title = "Kite Yoga",
                    category = "East 6th St, Austin",
                    headline = "Slow mornings start here",
                    body = "Small classes in a sunlit studio, timers to daily practice.",
                    ctaText = "See the schedule",
                    ctaColor = Color(0xFF5D6B50),
                    imageUrl = "https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80",
                    isSerif = false,
                    bgCanvasColor = Color(0xFFFAF8F4)
                )
            )
        }
        list
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
    ) {
        // Soft atmospheric wash at the top
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(280.dp)
                .background(AppGradients.BackdropAura)
        )

        // Main Scrollable Content
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 20.dp,
                end = 20.dp,
                top = 56.dp,
                bottom = 120.dp
            )
        ) {
            // Header Row: "Projects" + User Avatar "MR"
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 20.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Projects",
                        style = AppTypography.LargePageTitle
                    )

                    // Circular Avatar with User Initials
                    Box(
                        modifier = Modifier
                            .size(42.dp)
                            .clip(CircleShape)
                            .background(AppColors.Ink)
                            .clickable { showProfileDialog = true },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = uiState.userInitials,
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    }
                }
            }

            // Continue Editing Hero Card
            item {
                val primaryWebsite = uiState.websites.firstOrNull()
                ContinueEditingHeroCard(
                    website = primaryWebsite,
                    onOpenClick = {
                        if (primaryWebsite != null) {
                            onNavigateToEditor(primaryWebsite.id)
                        } else {
                            viewModel.openNewWebsiteSheet()
                        }
                    }
                )
            }

            // "Recent" Section Title
            item {
                Spacer(modifier = Modifier.height(28.dp))
                Text(
                    text = "Recent",
                    style = AppTypography.SectionHeading,
                    modifier = Modifier.padding(bottom = 14.dp)
                )
            }

            // Horizontal Carousel of Website Previews
            item {
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(14.dp),
                    contentPadding = PaddingValues(end = 12.dp)
                ) {
                    items(previewItems) { item ->
                        RecentProjectCard(
                            item = item,
                            onClick = {
                                if (item.id.startsWith("showcase_")) {
                                    val targetId = uiState.websites.firstOrNull()?.id
                                    if (targetId != null) {
                                        onNavigateToEditor(targetId)
                                    } else {
                                        viewModel.openNewWebsiteSheet()
                                    }
                                } else {
                                    onNavigateToEditor(item.id)
                                }
                            }
                        )
                    }
                }
            }
        }

        // iOS Frosted Glass Floating Bottom Bar with Clipping Plus Button
        FloatingBottomBar(
            activeTab = uiState.activeTab,
            onTabSelected = { tab ->
                viewModel.setTab(tab)
                when (tab) {
                    "Templates" -> onNavigateToTemplates()
                    "Profile" -> showProfileDialog = true
                    "Assets" -> {}
                    "Projects" -> {}
                }
            },
            onAddClick = { viewModel.openNewWebsiteSheet() },
            modifier = Modifier.align(Alignment.BottomCenter)
        )

        // New Website Bottom Sheet
        if (uiState.showNewWebsiteSheet) {
            NewWebsiteBottomSheet(
                onDismiss = { viewModel.closeNewWebsiteSheet() },
                onDescribeToAi = {
                    viewModel.closeNewWebsiteSheet()
                    onNavigateToAiCreation()
                },
                onStartFromTemplate = {
                    viewModel.closeNewWebsiteSheet()
                    onNavigateToTemplates()
                },
                onBlankWebsite = {
                    viewModel.createBlankWebsite { newId ->
                        onNavigateToEditor(newId)
                    }
                }
            )
        }

        // User Profile / Logout Dialog
        if (showProfileDialog) {
            AlertDialog(
                onDismissRequest = { showProfileDialog = false },
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(44.dp)
                                .clip(CircleShape)
                                .background(AppColors.Ink),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = uiState.userInitials,
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                                fontSize = 16.sp
                            )
                        }
                        Column {
                            Text(
                                text = uiState.userName ?: "Creator Account",
                                fontWeight = FontWeight.Bold,
                                fontSize = 17.sp
                            )
                            Text(
                                text = "user@aibuilder.local",
                                color = AppColors.InkMuted,
                                fontSize = 13.sp
                            )
                        }
                    }
                },
                text = {
                    Text(
                        "Manage your active projects or sign out to switch accounts.",
                        color = AppColors.InkSecondary,
                        fontSize = 14.sp
                    )
                },
                confirmButton = {
                    Button(
                        onClick = {
                            showProfileDialog = false
                            viewModel.logout(onLogout)
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = AppColors.Ink),
                        shape = RoundedCornerShape(999.dp)
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ExitToApp,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Sign Out")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showProfileDialog = false }) {
                        Text("Close", color = AppColors.InkMuted)
                    }
                },
                containerColor = AppColors.Surface,
                shape = RoundedCornerShape(22.dp)
            )
        }
    }
}
