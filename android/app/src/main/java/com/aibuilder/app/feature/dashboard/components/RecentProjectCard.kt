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

data class ShowcaseRecentItem(
    val id: String,
    val title: String,
    val category: String,
    val headline: String,
    val body: String,
    val ctaText: String,
    val ctaColor: Color,
    val imageUrl: String,
    val bgCanvasColor: Color = Color(0xFFFAF7F2)
)

@Composable
fun RecentProjectCard(
    item: ShowcaseRecentItem,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .width(220.dp)
            .height(310.dp)
            .shadow(
                elevation = 10.dp,
                shape = RoundedCornerShape(20.dp),
                spotColor = Color(0x141E1E50),
                ambientColor = Color(0x061E1E50)
            )
            .clip(RoundedCornerShape(20.dp))
            .border(1.dp, AppColors.BorderSubtle, RoundedCornerShape(20.dp))
            .clickable { onClick() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = AppColors.Surface)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(item.bgCanvasColor)
                .padding(14.dp)
        ) {
            // Mini Nav Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = item.title,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Serif,
                    color = Color(0xFF1E1E24)
                )
                Icon(
                    imageVector = Icons.Default.Menu,
                    contentDescription = null,
                    tint = Color(0xFF1E1E24),
                    modifier = Modifier.size(12.dp)
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Category Eyebrow
            Text(
                text = item.category,
                fontSize = 7.5.sp,
                fontWeight = FontWeight.Medium,
                color = Color(0xFF71717A)
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Hero Headline
            Text(
                text = item.headline,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                lineHeight = 18.sp,
                fontFamily = FontFamily.Serif,
                color = Color(0xFF1E1E24),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(6.dp))

            // Body Paragraph
            Text(
                text = item.body,
                fontSize = 8.5.sp,
                lineHeight = 11.5.sp,
                color = Color(0xFF71717A),
                maxLines = 3,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(10.dp))

            // CTA Pill Button
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(4.dp))
                    .background(item.ctaColor)
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = item.ctaText,
                    fontSize = 7.5.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Bottom Image Slice
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(90.dp)
                    .clip(RoundedCornerShape(8.dp))
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
