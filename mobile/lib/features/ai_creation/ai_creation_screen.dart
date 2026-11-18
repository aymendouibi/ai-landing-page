import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ai_creation_controller.dart';

class AiCreationScreen extends StatelessWidget {
  const AiCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiCreationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          // Ambient soft gradient in upper header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                            const Color(0xFF311042).withValues(alpha: 0.3),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFBCE1FD).withValues(alpha: 0.7),
                            const Color(0xFFE4D4FF).withValues(alpha: 0.6),
                            const Color(0xFFF6F8FC).withValues(alpha: 0.0),
                          ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        // Return icon button
                        GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.04,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              LucideIcons.arrowLeft,
                              size: 19,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kicker
                        Text(
                          'ai_creator_kicker'.tr,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isDark
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFF6366F1),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Hero Title
                        Text(
                          'ai_creator_hero_title'.tr,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            height: 1.12,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'ai_creator_hero_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Main Card: "What would you like to create?"
                        _buildPromptCard(context, controller, isDark),

                        const SizedBox(height: 24),

                        // "Choose a style" Section
                        Text(
                          'ai_creator_choose_style'.tr,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStyleSelector(context, controller, isDark),

                        const SizedBox(height: 24),

                        // "Make it yours" Section
                        Text(
                          'ai_creator_make_yours'.tr,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMakeItYoursCard(context, controller, isDark),

                        const SizedBox(height: 20),

                        // Error message if any
                        Obx(() {
                          final err = controller.errorMessage.value;
                          if (err == null) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF450A0A)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF991B1B)
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.circleAlert,
                                  size: 16,
                                  color: isDark
                                      ? const Color(0xFFF87171)
                                      : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    err,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Progress stage indicator
                        Obx(() {
                          final stage = controller.progressStage.value;
                          if (stage == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  stage,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFFA5B4FC)
                                        : const Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Generate Button (Alluring Vibrant Purple)
                        Obx(() {
                          final loading = controller.isLoading.value;
                          return Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFF7C3AED),
                                  Color(0xFF6D28D9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withValues(alpha: 0.38),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () => controller.generateWebsite(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'ai_creator_generate_btn'.tr,
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        }),

                        const SizedBox(height: 10),

                        // Footer Note
                        Center(
                          child: Text(
                            'ai_creator_footer_note'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Prompt Card ("What would you like to create?") ---
  Widget _buildPromptCard(
    BuildContext context,
    AiCreationController controller,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131726) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ai_creator_prompt_heading'.tr,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Optional Title / Brand Name field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2030) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262D42)
                    : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.globe,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFA5B4FC)
                      : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.titleController,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'ai_creator_title_hint'.tr,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Inner gray prompt text container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2030) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.promptController,
                  maxLines: 5,
                  minLines: 3,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'ai_creator_prompt_placeholder_new'.tr,
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Obx(
                    () => Text(
                      '${controller.promptLength.value} / 2,000',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // "Try an idea" label
          Text(
            'ai_creator_try_idea'.tr,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Suggestion Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildIdeaChip(
                label: 'ai_creator_try_portfolio'.tr,
                onTap: () => controller.applyIdeaPrompt('portfolio'),
                isDark: isDark,
              ),
              _buildIdeaChip(
                label: 'ai_creator_try_online_store'.tr,
                onTap: () => controller.applyIdeaPrompt('online store'),
                isDark: isDark,
              ),
              _buildIdeaChip(
                label: 'ai_creator_try_saas'.tr,
                onTap: () => controller.applyIdeaPrompt('saas product'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaChip({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2337) : const Color(0xFFF1F3FB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF474C78),
          ),
        ),
      ),
    );
  }

  // --- 2. Choose a Style Selector ---
  Widget _buildStyleSelector(
    BuildContext context,
    AiCreationController controller,
    bool isDark,
  ) {
    return Obx(() {
      final selected = controller.selectedStyle.value;

      return Row(
        children: [
          Expanded(
            child: _buildStyleOption(
              label: 'ai_creator_style_clean'.tr,
              isSelected: selected == AiCreationStyle.clean,
              previewWidget: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2436) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C354E)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              onTap: () => controller.setStyle(AiCreationStyle.clean),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStyleOption(
              label: 'ai_creator_style_bold'.tr,
              isSelected: selected == AiCreationStyle.bold,
              previewWidget: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191A29),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA5B4FC),
                  ),
                ),
              ),
              onTap: () => controller.setStyle(AiCreationStyle.bold),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStyleOption(
              label: 'ai_creator_style_soft'.tr,
              isSelected: selected == AiCreationStyle.soft,
              previewWidget: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E2442)
                      : const Color(0xFFF1E9FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E3AED),
                  ),
                ),
              ),
              onTap: () => controller.setStyle(AiCreationStyle.soft),
              isDark: isDark,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStyleOption({
    required String label,
    required bool isSelected,
    required Widget previewWidget,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeBorderColor = isDark
        ? const Color(0xFFA5B4FC)
        : const Color(0xFF6366F1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131726) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeBorderColor
                : (isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9)),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(child: previewWidget),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFF4F46E5))
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF334155)),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.check,
                    size: 14,
                    color: isDark
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF4F46E5),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Make It Yours Card ---
  Widget _buildMakeItYoursCard(
    BuildContext context,
    AiCreationController controller,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131726) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Language Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'language'.tr,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedLanguage.value,
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          LucideIcons.chevronDown,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      dropdownColor: isDark
                          ? const Color(0xFF1E2436)
                          : Colors.white,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                      items: controller.availableLanguages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) controller.setLanguage(newVal);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          ),

          // Row 2: AI-selected sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ai_creator_selected_sections_title'.tr,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ai_creator_selected_sections_desc'.tr,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
