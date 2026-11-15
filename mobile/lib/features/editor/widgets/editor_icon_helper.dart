import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditorIconHelper {
  static const Map<String, IconData> iconMap = {
    // Popular & Badges
    'Zap': LucideIcons.zap,
    'Sparkles': LucideIcons.sparkles,
    'Star': LucideIcons.star,
    'Heart': LucideIcons.heart,
    'Shield': LucideIcons.shield,
    'ShieldCheck': LucideIcons.shieldCheck,
    'Rocket': LucideIcons.rocket,
    'Check': LucideIcons.check,
    'Flame': LucideIcons.flame,
    'Award': LucideIcons.award,

    // Tech & Devices
    'Smartphone': LucideIcons.smartphone,
    'Globe': LucideIcons.globe,
    'Cpu': LucideIcons.cpu,
    'Layers': LucideIcons.layers,
    'Code': LucideIcons.code,
    'Database': LucideIcons.database,
    'Cloud': LucideIcons.cloud,
    'Lock': LucideIcons.lock,
    'Wifi': LucideIcons.wifi,

    // Business & Commerce
    'TrendingUp': LucideIcons.trendingUp,
    'CreditCard': LucideIcons.creditCard,
    'ShoppingCart': LucideIcons.shoppingCart,
    'Users': LucideIcons.users,
    'Briefcase': LucideIcons.briefcase,
    'Coins': LucideIcons.coins,
    'Receipt': LucideIcons.receipt,
    'Target': LucideIcons.target,

    // Lifestyle, Food & Creative
    'Coffee': LucideIcons.coffee,
    'Camera': LucideIcons.camera,
    'Music': LucideIcons.music,
    'Palette': LucideIcons.palette,
    'Compass': LucideIcons.compass,
    'MapPin': LucideIcons.mapPin,
    'Clock': LucideIcons.clock,
    'Calendar': LucideIcons.calendar,
    'Smile': LucideIcons.smile,

    // Communication & Social
    'Mail': LucideIcons.mail,
    'MessageSquare': LucideIcons.messageSquare,
    'Phone': LucideIcons.phone,
    'Bell': LucideIcons.bell,
    'Send': LucideIcons.send,
    'Share2': LucideIcons.share2,
  };

  static final Map<String, String> _categoryMap = {
    'Zap': 'Popular',
    'Sparkles': 'Popular',
    'Star': 'Popular',
    'Heart': 'Popular',
    'Shield': 'Popular',
    'ShieldCheck': 'Popular',
    'Rocket': 'Popular',
    'Check': 'Popular',
    'Flame': 'Popular',
    'Award': 'Popular',

    'Smartphone': 'Tech',
    'Globe': 'Tech',
    'Cpu': 'Tech',
    'Layers': 'Tech',
    'Code': 'Tech',
    'Database': 'Tech',
    'Cloud': 'Tech',
    'Lock': 'Tech',
    'Wifi': 'Tech',

    'TrendingUp': 'Business',
    'CreditCard': 'Business',
    'ShoppingCart': 'Business',
    'Users': 'Business',
    'Briefcase': 'Business',
    'Coins': 'Business',
    'Receipt': 'Business',
    'Target': 'Business',

    'Coffee': 'Creative',
    'Camera': 'Creative',
    'Music': 'Creative',
    'Palette': 'Creative',
    'Compass': 'Creative',
    'MapPin': 'Creative',
    'Clock': 'Creative',
    'Calendar': 'Creative',
    'Smile': 'Creative',

    'Mail': 'Social',
    'MessageSquare': 'Social',
    'Phone': 'Social',
    'Bell': 'Social',
    'Send': 'Social',
    'Share2': 'Social',
  };

  static IconData getIcon(String? name) {
    if (name == null || name.trim().isEmpty) {
      return LucideIcons.sparkles;
    }
    final normalized = name.trim();

    // Exact match
    if (iconMap.containsKey(normalized)) {
      return iconMap[normalized]!;
    }

    // Case-insensitive / kebab-case normalization
    final clean = normalized
        .replaceAll('-', '')
        .replaceAll('_', '')
        .toLowerCase();
    for (final entry in iconMap.entries) {
      if (entry.key.toLowerCase() == clean) {
        return entry.value;
      }
    }

    return LucideIcons.sparkles;
  }

  static String getCategory(String iconName) {
    return _categoryMap[iconName] ?? 'General';
  }
}

class IconPickerSheet extends StatefulWidget {
  final String currentIcon;
  final ValueChanged<String> onSelect;

  const IconPickerSheet({
    super.key,
    required this.currentIcon,
    required this.onSelect,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentIcon,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IconPickerSheet(
        currentIcon: currentIcon,
        onSelect: (selected) => Navigator.of(ctx).pop(selected),
      ),
    );
  }

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Popular',
    'Tech',
    'Business',
    'Creative',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredIcons = EditorIconHelper.iconMap.keys.where((iconName) {
      final matchesQuery =
          _searchQuery.isEmpty || iconName.toLowerCase().contains(_searchQuery);
      final category = EditorIconHelper.getCategory(iconName);
      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'editor_select_icon'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'editor_search_icons_hint'.tr,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => _searchCtrl.clear(),
                      child: Icon(
                        LucideIcons.x,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Category Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Icons Grid
          Expanded(
            child: filteredIcons.isEmpty
                ? Center(
                    child: Text(
                      'editor_no_icons_found'.tr,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: filteredIcons.length,
                    itemBuilder: (context, index) {
                      final name = filteredIcons[index];
                      final iconData = EditorIconHelper.iconMap[name]!;
                      final isSelected =
                          widget.currentIcon.toLowerCase() ==
                          name.toLowerCase();

                      return GestureDetector(
                        onTap: () {
                          widget.onSelect(name);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.12)
                                : (isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0)),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData,
                                size: 24,
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : (isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
