import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/designsystem/colors.dart';
import '../../core/designsystem/typography.dart';
import 'ai_creation_controller.dart';

class AiCreationScreen extends StatelessWidget {
  const AiCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiCreationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'AI Website Creator',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
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
                      child: const Icon(Icons.auto_awesome, color: AppColors.atmosphereViolet),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staged AI Generator',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tell AI about your business. It extracts brand identity, design tokens, plans sections, and writes conversion copy.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error display
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Input Prompt
              const Text(
                'Describe your business or website idea',
                style: AppTypography.itemTitle,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: TextField(
                  controller: controller.promptController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Create a sleek portfolio website for a modern architecture and urban design studio named Apex Form Studio with high-converting sections and clean minimalist typography.',
                    hintStyle: TextStyle(color: Color(0xFF9E9EA7), fontSize: 14),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Industry Selector Chips
              const Text('Select Industry', style: AppTypography.itemTitle),
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
                          selectedColor: AppColors.ink,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.ink,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : AppColors.borderSubtle,
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Generate Website with AI',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
