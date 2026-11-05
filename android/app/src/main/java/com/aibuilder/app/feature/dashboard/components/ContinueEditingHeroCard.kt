package com.aibuilder.app.feature.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.aibuilder.app.core.designsystem.AppColors
import com.aibuilder.app.core.designsystem.AppTypography
import com.aibuilder.app.core.model.Website

@Composable
fun ContinueEditingHeroCard(
    website: Website?,
    onOpenClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val siteName = website?.name ?: "Lumen Coffee"
    val statusText = if (website?.status == "published") "Live · Published recently" else "Draft · Edited 2 hours ago"

    Card(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 14.dp,
                shape = RoundedCornerShape(22.dp),
                spotColor = Color(0x181E1E50),
                ambientColor = Color(0x081E1E50)
            )
            .clip(RoundedCornerShape(22.dp))
            .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(22.dp))
            .clickable { onOpenClick() },
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = AppColors.Surface)
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Mockup Canvas Preview Area
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(230.dp)
                    .background(Color(0xFFF5EFE8))
                    .padding(top = 16.dp, start = 14.dp, end = 14.dp)
            ) {
                // Desktop Browser Frame Mockup (Left / Center)
                Box(
                    modifier = Modifier
                        .fillMaxWidth(0.86f)
                        .fillMaxHeight()
                        .clip(RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp))
                        .background(Color(0xFFFAF7F2))
                        .border(
                            0.75.dp,
                            Color(0xFFE2DACF),
                            RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp)
                        )
                        .padding(horizontal = 14.dp, vertical = 10.dp)
                ) {
                    Column(modifier = Modifier.fillMaxSize()) {
                        // Desktop Nav Bar
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = siteName,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF2C241E),
                                fontFamily = FontFamily.Serif
                            )
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text("Shop", fontSize = 7.sp, color = Color(0xFF7A6B5D))
                                Text("Subscriptions", fontSize = 7.sp, color = Color(0xFF7A6B5D))
                                Text("Visit", fontSize = 7.sp, color = Color(0xFF7A6B5D))
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(4.dp))
                                        .background(Color(0xFF9E4B28))
                                        .padding(horizontal = 5.dp, vertical = 2.dp)
                                ) {
                                    Text("Order", fontSize = 6.sp, color = Color.White)
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Desktop Hero Content
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(modifier = Modifier.fillMaxWidth(0.55f)) {
                                Text(
                                    text = "Roastery and café in Portland",
                                    fontSize = 7.sp,
                                    color = Color(0xFF9E4B28),
                                    fontWeight = FontWeight.Medium
                                )
                                Spacer(modifier = Modifier.height(3.dp))
                                Text(
                                    text = "Small-batch coffee, roasted every Friday",
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold,
                                    lineHeight = 15.sp,
                                    fontFamily = FontFamily.Serif,
                                    color = Color(0xFF2C241E)
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "Single-origin beans from farms we visit, roasted in our shop and shipped same day.",
                                    fontSize = 7.sp,
                                    lineHeight = 9.sp,
                                    color = Color(0xFF7A6B5D),
                                    maxLines = 2,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Spacer(modifier = Modifier.height(6.dp))
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(4.dp))
                                        .background(Color(0xFF9E4B28))
                                        .padding(horizontal = 7.dp, vertical = 3.dp)
                                ) {
                                    Text("Order beans", fontSize = 6.5.sp, color = Color.White)
                                }
                            }

                            // Desktop Image Mockup
                            Box(
                                modifier = Modifier
                                    .width(76.dp)
                                    .height(115.dp)
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(Color(0xFFDCC8B4))
                            ) {
                                AsyncImage(
                                    model = "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80",
                                    contentDescription = null,
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier.fillMaxSize()
                                )
                            }
                        }
                    }
                }

                // Overlapping Mobile Mockup (Right)
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(x = 2.dp, y = 4.dp)
                        .width(135.dp)
                        .height(200.dp)
                        .shadow(
                            elevation = 12.dp,
                            shape = RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp),
                            spotColor = Color(0x301E1E40)
                        )
                        .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
                        .background(Color(0xFFFAF7F2))
                        .border(
                            1.dp,
                            Color(0xFFDDD2C4),
                            RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp)
                        )
                        .padding(horizontal = 9.dp, vertical = 8.dp)
                ) {
                    Column(modifier = Modifier.fillMaxSize()) {
                        // Mobile Nav
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = siteName,
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF2C241E),
                                fontFamily = FontFamily.Serif
                            )
                            Icon(
                                imageVector = Icons.Default.Menu,
                                contentDescription = null,
                                modifier = Modifier.size(10.dp),
                                tint = Color(0xFF2C241E)
                            )
                        }

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = "Roastery and café in Portland",
                            fontSize = 5.5.sp,
                            color = Color(0xFF9E4B28)
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "Small-batch coffee, roasted every Friday",
                            fontSize = 9.5.sp,
                            fontWeight = FontWeight.Bold,
                            lineHeight = 11.sp,
                            fontFamily = FontFamily.Serif,
                            color = Color(0xFF2C241E)
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(3.dp))
                                .background(Color(0xFF9E4B28))
                                .padding(horizontal = 5.dp, vertical = 2.dp)
                        ) {
                            Text("Order beans", fontSize = 5.5.sp, color = Color.White)
                        }

                        Spacer(modifier = Modifier.height(6.dp))

                        // Mobile photo
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(64.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFFDCC8B4))
                        ) {
                            AsyncImage(
                                model = "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80",
                                contentDescription = null,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }
                }
            }

            // Bottom Content Information Section
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 18.dp, vertical = 18.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Continue editing",
                        style = AppTypography.Helper
                    )
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = siteName,
                        style = AppTypography.HeroCardTitle,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = statusText,
                        style = AppTypography.Helper
                    )
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Near-black Primary Pill Action
                Surface(
                    modifier = Modifier
                        .clip(RoundedCornerShape(999.dp))
                        .clickable { onOpenClick() },
                    shape = RoundedCornerShape(999.dp),
                    color = AppColors.Ink,
                    shadowElevation = 2.dp
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 11.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(
                            text = "Open",
                            color = Color.White,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 15.sp
                        )
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(17.dp)
                        )
                    }
                }
            }
        }
    }
}

