package com.aibuilder.app.feature.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
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

data class WebsitePreviewItem(
    val id: String,
    val title: String,
    val category: String,
    val headline: String,
    val body: String,
    val ctaText: String,
    val ctaColor: Color,
    val imageUrl: String,
    val isSerif: Boolean = true,
    val bgCanvasColor: Color = Color(0xFFFAF8F5)
)

/**
 * Mobile Website Preview Card in the "Recent" section.
 * The card itself renders as a direct viewport preview of the mobile website.
 */
@Composable
fun RecentProjectCard(
    item: WebsitePreviewItem,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .width(225.dp)
            .height(340.dp)
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(22.dp),
                spotColor = Color(0x181E1E50),
                ambientColor = Color(0x081E1E50)
            )
            .clip(RoundedCornerShape(22.dp))
            .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(22.dp))
            .clickable { onClick() },
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = item.bgCanvasColor)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(item.bgCanvasColor)
        ) {
            // Top Preview Content with padding
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 16.dp, start = 16.dp, end = 16.dp)
            ) {
                // Mini Nav Bar (Website Name + Hamburger)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = item.title,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = if (item.isSerif) FontFamily.Serif else FontFamily.SansSerif,
                        color = Color(0xFF1E1E24)
                    )
                    Icon(
                        imageVector = Icons.Default.Menu,
                        contentDescription = null,
                        tint = Color(0xFF1E1E24),
                        modifier = Modifier.size(14.dp)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Category Eyebrow
                Text(
                    text = item.category,
                    fontSize = 8.5.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color(0xFF71717A)
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Hero Headline
                Text(
                    text = item.headline,
                    fontSize = 19.sp,
                    fontWeight = FontWeight.Bold,
                    lineHeight = 23.sp,
                    fontFamily = if (item.isSerif) FontFamily.Serif else FontFamily.SansSerif,
                    color = Color(0xFF1E1E24),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(6.dp))

                // Body Paragraph
                Text(
                    text = item.body,
                    fontSize = 10.sp,
                    lineHeight = 14.sp,
                    color = Color(0xFF71717A),
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(10.dp))

                // CTA Button Tag
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(item.ctaColor)
                        .padding(horizontal = 9.dp, vertical = 5.dp)
                ) {
                    Text(
                        text = item.ctaText,
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Medium,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Bottom Image Slice filling bottom corners of the card
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(115.dp)
                    .clip(RoundedCornerShape(bottomStart = 22.dp, bottomEnd = 22.dp))
                    .background(Color(0xFFE4E4E7))
            ) {
                AsyncImage(
                    model = item.imageUrl,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}
