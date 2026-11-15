import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/designsystem/app_snackbar.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/models/website.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/dashboard_controller.dart';

class CustomDomainsSheet extends StatefulWidget {
  final List<Website>? initialWebsites;
  final List<Map<String, dynamic>>? initialDomains;

  const CustomDomainsSheet({
    super.key,
    this.initialWebsites,
    this.initialDomains,
  });

  static void show(
    BuildContext context, {
    List<Website>? initialWebsites,
    List<Map<String, dynamic>>? initialDomains,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CustomDomainsSheet(
        initialWebsites: initialWebsites,
        initialDomains: initialDomains,
      ),
    );
  }

  @override
  State<CustomDomainsSheet> createState() => _CustomDomainsSheetState();
}

class _CustomDomainsSheetState extends State<CustomDomainsSheet> {
  final _domainController = TextEditingController();

  // State
  List<Website> _websites = [];
  Website? _selectedWebsite;
  List<Map<String, dynamic>> _domains = [];
  Map<String, dynamic>? _dnsInstructions;
  bool _isLoading = true;
  bool _isAttaching = false;
  String? _errorMessage;
  final Set<String> _verifyingIds = {};

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _loadWebsites() async {
    setState(() => _isLoading = true);
    try {
      if (widget.initialWebsites != null && widget.initialWebsites!.isNotEmpty) {
        _websites = List.from(widget.initialWebsites!);
      } else if (Get.isRegistered<DashboardController>()) {
        final dc = Get.find<DashboardController>();
        if (dc.websites.isNotEmpty) {
          _websites = dc.websites.toList();
        }
      }

      if (_websites.isEmpty) {
        _websites = await ApiClient.getWebsites();
      }

      if (widget.initialDomains != null) {
        _domains = List.from(widget.initialDomains!);
      }

      if (_websites.isNotEmpty && _selectedWebsite == null) {
        _selectedWebsite = _websites.first;
        if (widget.initialDomains == null) {
          await _loadDomains();
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load websites');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDomains() async {
    if (_selectedWebsite == null) return;
    try {
      final data = await ApiClient.getDomains(_selectedWebsite!.id);
      final rawDomains = data['domains'] as List? ?? [];
      setState(() {
        _domains = rawDomains.map((d) => d as Map<String, dynamic>).toList();
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Could not load domains');
    }
  }

  Future<void> _handleAddDomain() async {
    final text = _domainController.text.trim().toLowerCase();
    if (text.isEmpty || !text.contains('.')) {
      AppSnackbar.error(
        'custom_domains_valid_domain_prompt'.tr,
        context: context,
      );
      return;
    }

    if (_selectedWebsite == null) {
      AppSnackbar.error(
        'custom_domains_select_website'.tr,
        context: context,
      );
      return;
    }

    setState(() {
      _isAttaching = true;
      _dnsInstructions = null;
      _errorMessage = null;
    });

    try {
      final result = await ApiClient.attachDomain(
        _selectedWebsite!.id,
        text,
      );
      _domainController.clear();

      // Store DNS instructions to show
      setState(() {
        _dnsInstructions = result['dns_instructions'] as Map<String, dynamic>?;
      });

      // Reload domains list
      await _loadDomains();

      if (mounted) {
        AppSnackbar.success(
          'custom_domains_added_success'.trParams({'domain': text}),
          context: context,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = msg);
      if (mounted) {
        AppSnackbar.error(msg, context: context);
      }
    } finally {
      setState(() => _isAttaching = false);
    }
  }

  Future<void> _verifyDomain(Map<String, dynamic> domain) async {
    final domainId = domain['id']?.toString() ?? '';
    if (domainId.isEmpty || _selectedWebsite == null) return;

    setState(() => _verifyingIds.add(domainId));

    try {
      final result = await ApiClient.verifyDomain(
        _selectedWebsite!.id,
        domainId,
      );
      final verified = result['verified'] == true;

      if (mounted) {
        if (verified) {
          AppSnackbar.success(
            'custom_domains_dns_verified'.tr,
            context: context,
          );
        } else {
          AppSnackbar.info(
            'custom_domains_dns_propagating'.tr,
            context: context,
          );
        }
      }

      await _loadDomains();
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(
          e.toString().replaceFirst('Exception: ', ''),
          context: context,
        );
      }
    } finally {
      setState(() => _verifyingIds.remove(domainId));
    }
  }

  Future<void> _deleteDomain(Map<String, dynamic> domain) async {
    final domainId = domain['id']?.toString() ?? '';
    final domainName = domain['domain']?.toString() ?? 'this domain';
    if (domainId.isEmpty || _selectedWebsite == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'custom_domains_disconnect_title'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.inkOf(context),
          ),
        ),
        content: Text(
          'custom_domains_disconnect_confirm'.tr,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.inkSecondaryOf(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'common_cancel'.tr,
              style: TextStyle(color: AppColors.inkMutedOf(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text('custom_domains_disconnect'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiClient.deleteDomain(_selectedWebsite!.id, domainId);
      await _loadDomains();
      if (mounted) {
        AppSnackbar.info('$domainName disconnected.', context: context);
        AppSnackbar.info(
          'custom_domains_disconnected_notice'.trParams({'domain': domainName}),
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error('Failed to remove domain: $e', context: context);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.copied(message: '$label copied to clipboard', context: context);
    AppSnackbar.copied(
      message: 'custom_domains_copied'.trParams({'label': label}),
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
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: EdgeInsets.fromLTRB(22, 16, 22, 24 + bottomInset),
        child: Column(
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
                        'custom_domains_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'custom_domains_subtitle'.tr,
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

            // Website Picker
            if (_websites.isNotEmpty) ...[
              _buildWebsitePicker(isDark),
              const SizedBox(height: 14),
            ],

            // Add Domain Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _domainController,
                    decoration: InputDecoration(
                      hintText: 'e.g. mybrand.com',
                      filled: true,
                      fillColor: AppColors.surfaceMutedOf(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.globe,
                        size: 16,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkOf(context),
                    ),
                    enabled: !_isAttaching,
                    onSubmitted: (_) => _handleAddDomain(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isAttaching ? null : _handleAddDomain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.inkOf(context),
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAttaching
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : Text(
                          'custom_domains_connect'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DNS Instructions (shown after attaching a domain)
            if (_dnsInstructions != null) ...[
              _buildDnsInstructions(isDark),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle,
                        size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Domain list header
            Text(
              '${'custom_domains_connected_count'.tr} (${_domains.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.inkOf(context),
              ),
            ),
            const SizedBox(height: 10),

            // Domain list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _domains.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _domains.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildDomainCard(_domains[index], isDark),
                        ),
            ),

            // DNS tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppColors.inkSecondaryOf(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'custom_domains_propagation_notice'.tr,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.inkSecondaryOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsitePicker(bool isDark) {
    final seenIds = <String>{};
    final uniqueWebsites = <Website>[];
    for (final s in _websites) {
      if (seenIds.add(s.id)) {
        uniqueWebsites.add(s);
      }
    }
    final hasSelected = _selectedWebsite != null &&
        uniqueWebsites.any((s) => s.id == _selectedWebsite!.id);
    final selectedId = hasSelected ? _selectedWebsite!.id : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSubtleOf(context),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedId,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.inkMutedOf(context),
          ),
          dropdownColor: AppColors.surfaceOf(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.inkOf(context),
          ),
          hint: Text(
            'custom_domains_select_website'.tr,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          selectedItemBuilder: (BuildContext ctx) {
            return uniqueWebsites.map<Widget>((site) {
              return Row(
                children: [
                  Icon(
                    LucideIcons.layoutDashboard,
                    size: 15,
                    color: AppColors.inkMutedOf(ctx),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      site.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkOf(ctx),
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: uniqueWebsites.map((site) {
            return DropdownMenuItem(
              value: site.id,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.layoutDashboard,
                    size: 15,
                    color: AppColors.inkMutedOf(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      site.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (site.status == 'published' || site.status == 'live')
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id == null) return;
            setState(() {
              _selectedWebsite = _websites.firstWhere((w) => w.id == id);
              _domains = [];
              _dnsInstructions = null;
              _errorMessage = null;
              _isLoading = true;
            });
            _loadDomains().then((_) {
              setState(() => _isLoading = false);
            });
          },
        ),
      ),
    );
  }

  Widget _buildDomainCard(Map<String, dynamic> domain, bool isDark) {
    final domainName = domain['domain']?.toString() ?? '';
    final status = domain['status']?.toString().toLowerCase() ?? 'pending';
    final isActive = status == 'active';
    final isFailed = status == 'failed';
    final domainId = domain['id']?.toString() ?? '';
    final isVerifying = _verifyingIds.contains(domainId);

    final sslStatus = domain['ssl_status'];
    String sslLabel = 'Pending';
    if (sslStatus is Map) {
      sslLabel = sslStatus['status']?.toString() ?? 'Pending';
    } else if (isActive) {
      sslLabel = 'Secured';
    }

    Color statusColor;
    IconData statusIcon;
    if (isActive) {
      statusColor = const Color(0xFF10B981);
      statusIcon = LucideIcons.shieldCheck;
    } else if (isFailed) {
      statusColor = const Color(0xFFDC2626);
      statusIcon = LucideIcons.alertTriangle;
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = LucideIcons.clock;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSubtleOf(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain info row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(statusIcon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domainName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedWebsite?.name ?? 'Website'} · SSL $sslLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive
                      ? 'Active'
                      : isFailed
                          ? 'Failed'
                          : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons for pending/failed domains
          if (!isActive) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // Verify DNS button
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: isVerifying ? null : () => _verifyDomain(domain),
                      icon: isVerifying
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: statusColor,
                              ),
                            )
                          : Icon(LucideIcons.refreshCw, size: 14, color: statusColor),
                      label: Text(
                        isVerifying ? 'Checking…' : 'Verify DNS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Disconnect button
                SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteDomain(domain),
                    icon: const Icon(LucideIcons.trash2,
                        size: 14, color: Color(0xFFDC2626)),
                    label: Text(
                      'common_remove'.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Active domain: just a disconnect option
          if (isActive) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _deleteDomain(domain),
                child: Text(
                  'common_disconnect'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMutedOf(context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDnsInstructions(bool isDark) {
    final cname = _dnsInstructions!['cname_record'] as Map<String, dynamic>?;
    final txt = _dnsInstructions!['txt_record'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.25)
            : const Color(0xFFE0F2FE).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0EA5E9).withValues(alpha: 0.3)
              : const Color(0xFF0EA5E9).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.settings,
                size: 15,
                color: isDark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              Text(
                'custom_domains_dns_required'.tr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CNAME Record
          if (cname != null) ...[
            _buildDnsRow(
              'CNAME',
              cname['name']?.toString() ?? '',
              cname['target']?.toString() ?? '',
              isDark,
            ),
            const SizedBox(height: 8),
          ],

          // TXT Record
          if (txt != null)
            _buildDnsRow(
              'TXT',
              txt['name']?.toString() ?? '',
              txt['value']?.toString() ?? '',
              isDark,
            ),

          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _dnsInstructions = null),
            child: Text(
              'common_dismiss'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMutedOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDnsRow(
    String type,
    String name,
    String value,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0EA5E9).withValues(alpha: 0.2)
                      : const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0284C7),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(value, '$type value'),
                child: Icon(
                  LucideIcons.copy,
                  size: 14,
                  color: AppColors.inkMutedOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Name: $name',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Value: $value',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.inkMutedOf(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.globe,
              size: 24,
              color: AppColors.inkMutedOf(context),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'custom_domains_no_domains'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.inkOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'custom_domains_get_started'.tr,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.inkMutedOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
