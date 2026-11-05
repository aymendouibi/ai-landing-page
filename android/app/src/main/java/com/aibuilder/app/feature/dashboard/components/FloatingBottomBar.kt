package com.aibuilder.app.feature.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.GridView
import androidx.compose.material.icons.outlined.Image
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.aibuilder.app.core.designsystem.AppColors
import com.aibuilder.app.core.designsystem.AppGradients

@Composable
fun FloatingBottomBar(
    activeTab: String,
    onTabSelected: (String) -> Unit,
    onAddClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 20.dp),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .height(68.dp)
                .shadow(
                    elevation = 16.dp,
                    shape = RoundedCornerShape(36.dp),
                    spotColor = Color(0x22141432),
                    ambientColor = Color(0x10141432)
                ),
            shape = RoundedCornerShape(36.dp),
            color = Color.White.copy(alpha = 0.94f),
            border = androidx.compose.foundation.BorderStroke(1.dp, AppColors.BorderSubtle)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 8.dp),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Tab 1: Projects
                BottomNavItem(
                    label = "Projects",
                    icon = Icons.Outlined.Folder,
                    isSelected = activeTab == "Projects",
                    onClick = { onTabSelected("Projects") }
                )

                // Tab 2: Templates
                BottomNavItem(
                    label = "Templates",
                    icon = Icons.Outlined.GridView,
                    isSelected = activeTab == "Templates",
                    onClick = { onTabSelected("Templates") }
                )

                // Center Glowing '+' FAB
                Box(
                    modifier = Modifier
                        .size(54.dp)
                        .clip(CircleShape)
                        .border(
                            width = 2.5.dp,
                            brush = AppGradients.FabAuraRing,
                            shape = CircleShape
                        )
                        .background(AppColors.Ink)
                        .clickable { onAddClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "New Website",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }

                // Tab 3: Assets
                BottomNavItem(
                    label = "Assets",
                    icon = Icons.Outlined.Image,
                    isSelected = activeTab == "Assets",
                    onClick = { onTabSelected("Assets") }
                )

                // Tab 4: Profile
                BottomNavItem(
                    label = "Profile",
                    icon = Icons.Outlined.Person,
                    isSelected = activeTab == "Profile",
                    onClick = { onTabSelected("Profile") }
                )
            }
        }
    }
}

@Composable
private fun BottomNavItem(
    label: String,
    icon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(16.dp))
            .clickable { onClick() }
            .padding(horizontal = 10.dp, vertical = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = label,
            tint = if (isSelected) AppColors.Ink else AppColors.InkMuted,
            modifier = Modifier.size(22.dp)
        )
        Spacer(modifier = Modifier.height(3.dp))
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) AppColors.Ink else AppColors.InkMuted
        )
    }
}
