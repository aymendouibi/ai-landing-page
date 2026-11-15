class PastSubscriptionHelper {
  static String getItemTitle(Map<String, dynamic> item) {
    if (item['title'] != null && item['title'].toString().contains('·')) {
      return item['title'].toString();
    }
    final plan = item['plan']?.toString() ?? 'Premium';
    final interval = item['interval']?.toString() ?? 'monthly';
    final isYearly = interval.toLowerCase().contains('year');
    return '$plan · ${isYearly ? 'Yearly' : 'Monthly'}';
  }

  static String getItemDate(Map<String, dynamic> item) {
    final rawDate = item['date']?.toString() ?? '';
    final periodEnd = item['period_end']?.toString();
    if (periodEnd != null && periodEnd.isNotEmpty && !rawDate.contains('–')) {
      return '$rawDate – $periodEnd';
    }
    return rawDate.isNotEmpty ? rawDate : '1 Oct – 1 Nov 2026';
  }

  static String getItemTime(Map<String, dynamic> item) {
    if (item['time'] != null && item['time'].toString().isNotEmpty) {
      return item['time'].toString();
    }
    if (item['payment_time'] != null &&
        item['payment_time'].toString().isNotEmpty) {
      return item['payment_time'].toString();
    }
    final createdAt = item['created_at']?.toString();
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } catch (_) {}
    }
    return '';
  }

  static String getItemYear(Map<String, dynamic> item) {
    if (item['year'] != null && item['year'].toString().isNotEmpty) {
      return item['year'].toString();
    }
    final date = getItemDate(item);
    final match = RegExp(r'\b(20\d\d)\b').allMatches(date);
    if (match.isNotEmpty) {
      return match.first.group(0)!;
    }
    if (item['created_at'] != null) {
      try {
        final dt = DateTime.parse(item['created_at'].toString());
        return dt.year.toString();
      } catch (_) {}
    }
    return '2026';
  }

  static Map<String, List<Map<String, dynamic>>> groupByYear(
    List<Map<String, dynamic>> list,
  ) {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final item in list) {
      final year = getItemYear(item);
      map.putIfAbsent(year, () => []).add(item);
    }
    return map;
  }
}
