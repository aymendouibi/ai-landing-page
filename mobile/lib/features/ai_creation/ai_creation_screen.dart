import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/designsystem/colors.dart';
import '../dashboard/dashboard_controller.dart';
import '../profile/components/subscription_plan_sheet.dart';
import 'ai_creation_controller.dart';

class AiCreationScreen extends StatelessWidget {
  const AiCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiCreationController());
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.inkOf(context)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'ai_creator_title'.tr,
          style: TextStyle(color: AppColors.inkOf(context), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staged AI Info Banner
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtleOf(context)),
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.atmosphereViolet.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.sparkles, color: AppColors.atmosphereViolet),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ai_creator_badge'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.inkOf(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ai_creator_desc'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMutedOf(context),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Generation Credits Card
              if (Get.isRegistered<DashboardController>()) ...[
                Builder(builder: (context) {
                  final dc = Get.find<DashboardController>();
                  return Obx(() {
                    final isPro = dc.isPremium;
                    final used = dc.aiGenerationsUsed.value;
                    final max = dc.aiGenerationsMonthly.value;
                    final remaining = (max - used).clamp(0, max);
                    final isExhausted = max > 0 && used >= max;

                    final cardBg = isExhausted
                        ? (isDark ? const Color(0xFF450A0A) : Colors.red.shade50)
                        : (isPro
                            ? const Color(0xFF7C5CFF).withValues(alpha: isDark ? 0.2 : 0.08)
                            : AppColors.surfaceOf(context));
                    final cardBorder = isExhausted
                        ? (isDark ? const Color(0xFF991B1B) : Colors.red.shade200)
                        : (isPro
                            ? const Color(0xFF7C5CFF).withValues(alpha: 0.3)
                            : AppColors.borderSubtleOf(context));
                    final iconBg = isExhausted
                        ? (isDark ? const Color(0xFF7F1D1D) : Colors.red.shade100)
                        : (isPro
                            ? const Color(0xFF7C5CFF).withValues(alpha: 0.15)
                            : AppColors.surfaceMutedOf(context));
                    final iconColor = isExhausted
                        ? (isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700)
                        : (isPro ? const Color(0xFF7C5CFF) : AppColors.inkSecondaryOf(context));
                    final titleColor = isExhausted
                        ? (isDark ? const Color(0xFFFCA5A5) : Colors.red.shade900)
                        : AppColors.inkOf(context);
                    final badgeBg = isPro ? const Color(0xFF7C5CFF) : AppColors.surfaceMutedOf(context);
                    final badgeTextColor = isPro ? Colors.white : AppColors.inkMutedOf(context);
                    final subtitleColor = isExhausted
                        ? (isDark ? const Color(0xFFF87171) : Colors.red.shade700)
                        : AppColors.inkMutedOf(context);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isExhausted ? LucideIcons.circleAlert : LucideIcons.zap,
                              size: 18,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isPro ? 'Premium AI Pipeline' : 'Free Tier Credits',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isPro ? '90 GENS' : '4 GENS',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: badgeTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isExhausted
                                      ? 'Monthly limit reached. Upgrade to Premium for 90 generations!'
                                      : '$used / $max used ($remaining remaining this month)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isPro)
                            GestureDetector(
                              onTap: () => SubscriptionPlanSheet.show(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C5CFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'common_upgrade'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  });
                }),
              ],

              // Error display
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF450A0A) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF991B1B) : Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Input Prompt
              Text(
                'ai_creator_prompt_hint'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtleOf(context)),
                ),
                child: TextField(
                  controller: controller.promptController,
                  maxLines: 5,
                  style: TextStyle(
                    color: AppColors.inkOf(context),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ai_creator_prompt_placeholder'.tr,
                    hintStyle: TextStyle(
                      color: AppColors.inkMutedOf(context),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Industry Selector Chips
              Text(
                'select_industry'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkOf(context),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: controller.industries.map((ind) {
                      final isSelected = controller.selectedIndustry.value == ind;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(ind),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) controller.setIndustry(ind);
                          },
                          selectedColor: isDark ? Colors.white : AppColors.ink,
                          backgroundColor: AppColors.surfaceOf(context),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                : AppColors.inkOf(context),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : AppColors.borderSubtleOf(context),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Progress status message
              Obx(() {
                final stage = controller.progressStage.value;
                if (stage == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stage,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.atmosphereViolet,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Generate Action Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.generateWebsite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.atmosphereViolet,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.sparkles, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'generate_website_btn'.tr,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
