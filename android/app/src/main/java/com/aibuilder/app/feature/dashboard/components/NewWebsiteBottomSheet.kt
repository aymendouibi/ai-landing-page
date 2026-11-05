package com.aibuilder.app.feature.dashboard.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.aibuilder.app.core.designsystem.AppColors
import com.aibuilder.app.core.designsystem.AppGradients
import com.aibuilder.app.core.designsystem.AppTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewWebsiteBottomSheet(
    onDismiss: () -> Unit,
    onDescribeToAi: () -> Unit,
    onStartFromTemplate: () -> Unit,
    onBlankWebsite: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppColors.Surface,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(top = 10.dp, bottom = 4.dp)
                    .width(36.dp)
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(AppColors.SurfaceMuted)
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 36.dp)
        ) {
            // Header Row: "New website" + Close Button
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "New website",
                    style = AppTypography.SheetTitle
                )

                // Circular Close Button
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(AppColors.SurfaceNeutral)
                        .clickable { onDismiss() },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = AppColors.Ink,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Option 1: "Describe it to AI"
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(18.dp))
                    .clickable {
                        onDismiss()
                        onDescribeToAi()
                    },
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = Color.Transparent)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppGradients.AiCardGradient)
                        .padding(horizontal = 16.dp, vertical = 18.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // 3D Luminous AI Orb
                        LuminousAiOrb(modifier = Modifier.size(52.dp))

                        Spacer(modifier = Modifier.width(16.dp))

                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Describe it to AI",
                                style = AppTypography.ItemTitle
                            )
                            Spacer(modifier = Modifier.height(3.dp))
                            Text(
                                text = "Get a full first draft from one sentence",
                                style = AppTypography.Helper
                            )
                        }

                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                            contentDescription = null,
                            tint = AppColors.InkMuted,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Option 2: "Start from a template"
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(18.dp))
                    .clickable {
                        onDismiss()
                        onStartFromTemplate()
                    },
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = AppColors.Surface)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 18.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Template Stack Thumbnail
                    TemplateStackThumbnail(modifier = Modifier.size(52.dp))

                    Spacer(modifier = Modifier.width(16.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Start from a template",
                            style = AppTypography.ItemTitle
                        )
                        Spacer(modifier = Modifier.height(3.dp))
                        Text(
                            text = "Browse designs by category",
                            style = AppTypography.Helper
                        )
                    }

                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = AppColors.InkMuted,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Option 3: "Blank website"
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(18.dp))
                    .clickable {
                        onDismiss()
                        onBlankWebsite()
                    },
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = AppColors.Surface)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 18.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Dashed Box with '+'
                    DashedPlusBox(modifier = Modifier.size(52.dp))

                    Spacer(modifier = Modifier.width(16.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Blank website",
                            style = AppTypography.ItemTitle
                        )
                        Spacer(modifier = Modifier.height(3.dp))
                        Text(
                            text = "Build it section by section",
                            style = AppTypography.Helper
                        )
                    }

                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = AppColors.InkMuted,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
}

/**
 * 3D Luminous AI Orb with realistic radial gradient highlight.
 */
@Composable
fun LuminousAiOrb(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val radius = size.minDimension / 2f
        val center = Offset(size.width / 2f, size.height / 2f)

        // Outer soft glow
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    AppColors.AtmosphereViolet.copy(alpha = 0.28f),
                    AppColors.AtmosphereCyan.copy(alpha = 0.12f),
                    Color.Transparent
                ),
                center = center,
                radius = radius * 1.35f
            ),
            radius = radius * 1.35f,
            center = center
        )

        // Main luminous sphere
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color(0xFFEDE9FE),
                    AppColors.AtmosphereViolet,
                    AppColors.AtmospherePink,
                    AppColors.AtmosphereCyan
                ),
                center = Offset(size.width * 0.38f, size.height * 0.35f),
                radius = radius * 1.05f
            ),
            radius = radius,
            center = center
        )

        // Glossy Specular Reflection
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color.White.copy(alpha = 0.92f),
                    Color.White.copy(alpha = 0.30f),
                    Color.Transparent
                ),
                center = Offset(size.width * 0.32f, size.height * 0.28f),
                radius = radius * 0.42f
            ),
            radius = radius * 0.42f,
            center = Offset(size.width * 0.32f, size.height * 0.28f)
        )
    }
}

/**
 * Stacked Template cards thumbnail.
 */
@Composable
fun TemplateStackThumbnail(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        // Background card tilted
        Box(
            modifier = Modifier
                .offset(x = (-4).dp, y = (-2).dp)
                .width(32.dp)
                .height(40.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(Color(0xFFE2E8F0))
                .border(0.5.dp, Color(0xFFCBD5E1), RoundedCornerShape(4.dp))
        )

        // Middle card
        Box(
            modifier = Modifier
                .offset(x = (-1).dp, y = (0).dp)
                .width(32.dp)
                .height(40.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(Color(0xFFF1F5F9))
                .border(0.5.dp, Color(0xFF94A3B8), RoundedCornerShape(4.dp))
        )

        // Foreground card with mock web content
        Column(
            modifier = Modifier
                .offset(x = (3).dp, y = (2).dp)
                .width(32.dp)
                .height(40.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(Color.White)
                .border(0.8.dp, Color(0xFF475569), RoundedCornerShape(4.dp))
                .padding(2.5.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header line
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.55f)
                    .height(2.5.dp)
                    .clip(RoundedCornerShape(1.dp))
                    .background(Color(0xFFCBD5E1))
            )

            // Hero title line
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.85f)
                    .height(3.5.dp)
                    .clip(RoundedCornerShape(1.dp))
                    .background(Color(0xFF0F172A))
            )

            // Mini image block
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(14.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(Color(0xFFD97706).copy(alpha = 0.6f))
            )
        }
    }
}

/**
 * Dashed rounded rectangle with '+' icon.
 */
@Composable
fun DashedPlusBox(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val strokeWidth = 1.5.dp.toPx()
            val dashLength = 5.dp.toPx()
            val gapLength = 4.dp.toPx()
            val cornerRadius = 10.dp.toPx()

            drawRoundRect(
                color = Color(0xFFCBD0DE),
                topLeft = Offset(strokeWidth / 2, strokeWidth / 2),
                size = Size(size.width - strokeWidth, size.height - strokeWidth),
                cornerRadius = CornerRadius(cornerRadius, cornerRadius),
                style = Stroke(
                    width = strokeWidth,
                    pathEffect = PathEffect.dashPathEffect(floatArrayOf(dashLength, gapLength), 0f)
                )
            )
        }

        Icon(
            imageVector = Icons.Default.Add,
            contentDescription = null,
            tint = AppColors.InkSecondary,
            modifier = Modifier.size(20.dp)
        )
    }
}

