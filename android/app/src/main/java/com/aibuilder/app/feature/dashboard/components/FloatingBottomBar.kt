package com.aibuilder.app.feature.dashboard.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.aibuilder.app.R
import com.aibuilder.app.core.designsystem.AppColors
import com.aibuilder.app.core.designsystem.AppGradients

/**
 * iOS Frosted Glass Floating Bottom Navigation Bar
 * with center Plus button protruding / clipping from the top edge.
 */
@Composable
fun FloatingBottomBar(
    activeTab: String,
    onTabSelected: (String) -> Unit,
    onAddClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    // Total height is 88dp so the Plus button can protrude 22dp above the 66dp frosted bar
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(92.dp)
            .padding(horizontal = 16.dp),
        contentAlignment = Alignment.BottomCenter
    ) {
        // 1. iOS Frosted Glass Pill Dock Bar
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .height(66.dp)
                .shadow(
                    elevation = 20.dp,
                    shape = RoundedCornerShape(33.dp),
                    spotColor = Color(0x33141432),
                    ambientColor = Color(0x14141432)
                ),
            shape = RoundedCornerShape(33.dp),
            // iOS Glass translucent white fill with subtle frosted tone
            color = Color.White.copy(alpha = 0.88f),
            border = androidx.compose.foundation.BorderStroke(
                1.dp,
                Color.White.copy(alpha = 0.70f)
            )
        ) {
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Left 2 items (Projects & Templates)
                Row(
                    modifier = Modifier.weight(1f),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    NavTabItem(
                        label = "Projects",
                        iconRes = R.drawable.ic_nav_projects,
                        isSelected = activeTab == "Projects",
                        onClick = { onTabSelected("Projects") }
                    )

                    NavTabItem(
                        label = "Templates",
                        iconRes = R.drawable.ic_nav_templates,
                        isSelected = activeTab == "Templates",
                        onClick = { onTabSelected("Templates") }
                    )
                }

                // Center gap for the clipping plus button
                Spacer(modifier = Modifier.width(68.dp))

                // Right 2 items (Assets & Profile)
                Row(
                    modifier = Modifier.weight(1f),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    NavTabItem(
                        label = "Assets",
                        iconRes = R.drawable.ic_nav_assets,
                        isSelected = activeTab == "Assets",
                        onClick = { onTabSelected("Assets") }
                    )

                    NavTabItem(
                        label = "Profile",
                        iconRes = R.drawable.ic_nav_profile,
                        isSelected = activeTab == "Profile",
                        onClick = { onTabSelected("Profile") }
                    )
                }
            }
        }

        // 2. The Plus Button clipping / protruding from the top of the bar
        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = 2.dp) // Vertically centered so top half extends above the frosted bar
                .size(64.dp)
                .clickable { onAddClick() },
            contentAlignment = Alignment.Center
        ) {
            // Luminous Aura Glow Ring around Plus Button
            Canvas(modifier = Modifier.fillMaxSize()) {
                val center = Offset(size.width / 2f, size.height / 2f)
                val radius = size.minDimension / 2f

                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            AppColors.AtmosphereViolet.copy(alpha = 0.65f),
                            AppColors.AtmospherePink.copy(alpha = 0.40f),
                            AppColors.AtmosphereCyan.copy(alpha = 0.25f),
                            Color.Transparent
                        ),
                        center = center,
                        radius = radius * 1.30f
                    ),
                    radius = radius * 1.30f,
                    center = center
                )
            }

            // Dark inner circle with glowing gradient rim
            Box(
                modifier = Modifier
                    .size(54.dp)
                    .clip(CircleShape)
                    .border(
                        width = 2.5.dp,
                        brush = AppGradients.FabAuraRing,
                        shape = CircleShape
                    )
                    .background(AppColors.Ink),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "New Website",
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

@Composable
private fun NavTabItem(
    label: String,
    @DrawableRes iconRes: Int,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(16.dp))
            .clickable { onClick() }
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = painterResource(id = iconRes),
            contentDescription = label,
            modifier = Modifier.size(24.dp),
            colorFilter = ColorFilter.tint(
                if (isSelected) AppColors.Ink else Color(0xFF71717A)
            )
        )
        Spacer(modifier = Modifier.height(3.dp))
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) AppColors.Ink else Color(0xFF71717A)
        )
    }
}
