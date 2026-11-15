import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const FeedbackSheet(),
    );
  }

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _feedbackController = TextEditingController();
  int _selectedCategory = 0;
  final _categories = [
    'feedback_cat_feature',
    'feedback_cat_bug',
    'feedback_cat_ai',
    'feedback_cat_general',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      AppSnackbar.error('feedback_enter_message'.tr, context: context);
      return;
    }

    Navigator.pop(context);
    AppSnackbar.success(
      'feedback_thank_you'.tr,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(22, 16, 22, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkMutedOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'feedback_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'feedback_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.inkMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMutedOf(context),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.inkMutedOf(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Category Chips
            Text(
              'feedback_category'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_categories.length, (index) {
                final isSelected = _selectedCategory == index;
                return ChoiceChip(
                  label: Text(_categories[index].tr),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = index);
                  },
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : AppColors.inkOf(context),
                  ),
                  selectedColor: AppColors.inkOf(context),
                  backgroundColor: AppColors.surfaceMutedOf(context),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.inkOf(context)
                          : AppColors.borderSubtleOf(context),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Input Field
            Text(
              'feedback_message'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'feedback_placeholder'.tr,
                filled: true,
                fillColor: AppColors.surfaceMutedOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkOf(context),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: AppColors.borderSubtleOf(context),
                      ),
                    ),
                    child: Text(
                      'common_cancel'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondaryOf(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.inkOf(context),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'feedback_submit'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
