package com.aibuilder.app.core.designsystem

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * App Design System Tokens sampled strictly from design.md & high-fidelity references.
 */
object AppColors {
    // Backdrop & Surfaces
    val Background = Color(0xFFF4F5FA)
    val Surface = Color(0xFFFFFFFF)
    val SurfaceMuted = Color(0xFFECEEF4)
    val SurfaceNeutral = Color(0xFFF1F1F1)

    // Ink (Typography & Actions)
    val Ink = Color(0xFF0C0C14)
    val InkSecondary = Color(0xFF3D3D4A)
    val InkMuted = Color(0xFF62626F)

    // Borders
    val BorderSubtle = Color(0x140C0C14) // rgba(12,12,20, 0.08)
    val BorderStrong = Color(0x240C0C14) // rgba(12,12,20, 0.14)

    // Atmosphere & Luminous AI Accents
    val AtmosphereViolet = Color(0xFF7C5CFF)
    val AtmosphereCyan = Color(0xFF2BC8E8)
    val AtmospherePink = Color(0xFFE46BFF)
    val AtmosphereBlue = Color(0xFF4F6BFF)

    // Subtle AI Surface Wash
    val AiCardWashStart = Color(0xFFF6F4FF)
    val AiCardWashEnd = Color(0xFFEFF8FF)
}

object AppGradients {
    val BackdropAura = Brush.radialGradient(
        colors = listOf(
            AppColors.AtmosphereViolet.copy(alpha = 0.12f),
            AppColors.AtmosphereCyan.copy(alpha = 0.06f),
            Color.Transparent
        ),
        center = Offset(800f, -100f),
        radius = 900f
    )

    val FabAuraRing = Brush.sweepGradient(
        listOf(
            AppColors.AtmosphereViolet,
            AppColors.AtmospherePink,
            AppColors.AtmosphereCyan,
            AppColors.AtmosphereBlue,
            AppColors.AtmosphereViolet
        )
    )

    val AiOrbGradient = Brush.radialGradient(
        colors = listOf(
            Color.White,
            AppColors.AtmosphereCyan,
            AppColors.AtmosphereViolet,
            AppColors.AtmospherePink
        ),
        center = Offset(30f, 30f),
        radius = 70f
    )

    val AiCardGradient = Brush.linearGradient(
        colors = listOf(
            AppColors.AiCardWashStart,
            AppColors.AiCardWashEnd
        )
    )
}

object AppTypography {
    val LargePageTitle = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 34.sp,
        lineHeight = 36.sp,
        color = AppColors.Ink
    )

    val SectionHeading = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        color = AppColors.Ink
    )

    val SheetTitle = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        color = AppColors.Ink
    )

    val HeroCardTitle = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 20.sp,
        lineHeight = 26.sp,
        color = AppColors.Ink
    )

    val ItemTitle = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        color = AppColors.Ink
    )

    val Body = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        color = AppColors.InkSecondary
    )

    val Helper = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 13.sp,
        lineHeight = 18.sp,
        color = AppColors.InkMuted
    )

    val Micro = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 11.sp,
        lineHeight = 15.sp,
        color = AppColors.Ink
    )
}
