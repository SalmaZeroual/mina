import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/service_request_model.dart';
import '../../models/message_model.dart';
import '../../services/service_request_service.dart';
import '../../services/api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/routes.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});
  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _svc = ServiceRequestService();

  ServiceStatsModel _receivedStats = ServiceStatsModel();
  ServiceStatsModel _sentStats     = ServiceStatsModel();
  int _servicesCount = 0;

  List<ServiceRequestModel> _received = [];
  List<ServiceRequestModel> _sent     = [];

  bool _loading = true;
  String _receivedFilter = 'all';
  String _sentFilter     = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _svc.getStats(),
        _svc.getReceived(),
        _svc.getSent(),
      ]);
      final stats = results[0] as Map<String, ServiceStatsModel>;
      setState(() {
        _receivedStats = stats['received']!;
        _sentStats     = stats['sent']!;
        _received = results[1] as List<ServiceRequestModel>;
        _sent     = results[2] as List<ServiceRequestModel>;
        _loading  = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<ServiceRequestModel> _filter(List<ServiceRequestModel> list, String filter) {
    if (filter == 'all') return list;
    return list.where((r) => r.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Service Requests',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: AppTheme.primary),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Received'),
                if (_receivedStats.pending > 0) ...[
                  const SizedBox(width: 6),
                  _Badge(_receivedStats.pending),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Sent'),
                if (_sentStats.pending > 0) ...[
                  const SizedBox(width: 6),
                  _Badge(_sentStats.pending),
                ],
              ]),
            ),
          ],
        ),
      ),
      body: _loading
          ? const LoadingWidget()
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _load,
              child: TabBarView(
                controller: _tabs,
                children: [
                  // ── Received tab ─────────────────────────────────────────
                  ListView(children: [
                    // Stats row
                    _StatsRow(stats: _receivedStats, servicesCount: _servicesCount),
                    // Filter chips
                    _FilterRow(
                      selected: _receivedFilter,
                      onSelect: (f) => setState(() => _receivedFilter = f),
                    ),
                    // List
                    ..._filter(_received, _receivedFilter).map((r) =>
                        _ReceivedRequestCard(
                          request: r,
                          onAction: _load,
                        )),
                    if (_filter(_received, _receivedFilter).isEmpty)
                      _Empty(
                        icon: Icons.inbox_outlined,
                        title: 'No requests',
                        sub: _receivedFilter == 'all'
                            ? 'Hire requests from clients will appear here'
                            : 'No ${_receivedFilter} requests',
                      ),
                    const SizedBox(height: 80),
                  ]),

                  // ── Sent tab ─────────────────────────────────────────────
                  ListView(children: [
                    _SentStatsRow(stats: _sentStats),
                    _FilterRow(
                      selected: _sentFilter,
                      onSelect: (f) => setState(() => _sentFilter = f),
                    ),
                    ..._filter(_sent, _sentFilter).map((r) =>
                        _SentRequestCard(request: r, onAction: _load)),
                    if (_filter(_sent, _sentFilter).isEmpty)
                      _Empty(
                        icon: Icons.send_outlined,
                        title: 'No requests sent',
                        sub: _sentFilter == 'all'
                            ? 'Hire requests you send will appear here'
                            : 'No ${_sentFilter} requests',
                      ),
                    const SizedBox(height: 80),
                  ]),
                ],
              ),
            ),
    );
  }
}

// ── Stats row (provider view) ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final ServiceStatsModel stats;
  final int servicesCount;
  const _StatsRow({required this.stats, required this.servicesCount});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
              color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard(value: '${stats.total}',    label: 'Total',     color: const Color(0xFF6366F1), icon: Icons.all_inbox_outlined),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.pending}',  label: 'Pending',   color: const Color(0xFFF59E0B), icon: Icons.hourglass_empty_rounded),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.accepted}', label: 'Active',    color: AppTheme.primary,        icon: Icons.bolt_outlined),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _StatCard(value: '${stats.completed}', label: 'Completed', color: AppTheme.success,     icon: Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.cancelled}', label: 'Cancelled', color: Colors.grey,           icon: Icons.cancel_outlined),
        const SizedBox(width: 10),
        // Completion rate
        _StatCard(
          value: stats.total > 0
              ? '${((stats.completed / stats.total) * 100).round()}%'
              : '—',
          label: 'Success rate',
          color: const Color(0xFF14B8A6),
          icon: Icons.trending_up_rounded,
        ),
      ]),
    ]),
  );
}

// ── Stats row (client view) ───────────────────────────────────────────────────
class _SentStatsRow extends StatelessWidget {
  final ServiceStatsModel stats;
  const _SentStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Hiring Activity',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
              color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard(value: '${stats.total}',     label: 'Total sent',  color: const Color(0xFF6366F1), icon: Icons.send_outlined),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.pending}',   label: 'Pending',     color: const Color(0xFFF59E0B), icon: Icons.hourglass_empty_rounded),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.accepted}',  label: 'In progress', color: AppTheme.primary,        icon: Icons.bolt_outlined),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _StatCard(value: '${stats.completed}', label: 'Completed',   color: AppTheme.success,  icon: Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatCard(value: '${stats.cancelled}', label: 'Cancelled',   color: Colors.grey,        icon: Icons.cancel_outlined),
        const SizedBox(width: 10),
        const Expanded(child: SizedBox()),
      ]),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatCard({required this.value, required this.label,
      required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ── Filter chips ──────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.selected, required this.onSelect});

  static const _filters = [
    ('all', 'All'), ('pending', 'Pending'), ('accepted', 'Active'),
    ('completed', 'Completed'), ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: _filters.map((f) {
        final sel = selected == f.$1;
        return GestureDetector(
          onTap: () => onSelect(f.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: sel ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: sel ? AppTheme.primary : const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(f.$2,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : AppTheme.textSecondary)),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// ── Received request card (provider sees this) ────────────────────────────────
class _ReceivedRequestCard extends StatefulWidget {
  final ServiceRequestModel request;
  final VoidCallback onAction;
  const _ReceivedRequestCard({required this.request, required this.onAction});
  @override
  State<_ReceivedRequestCard> createState() => _ReceivedRequestCardState();
}

class _ReceivedRequestCardState extends State<_ReceivedRequestCard> {
  final _svc = ServiceRequestService();
  bool _acting = false;

  Future<void> _accept() async {
    setState(() => _acting = true);
    try {
      final convId = await _svc.acceptRequest(widget.request.id);
      widget.onAction();
      if (!mounted) return;
      // Open chat immediately
      _openChat(convId);
    } catch (e) {
      if (mounted) _snack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _acting = true);
    try {
      await _svc.declineRequest(widget.request.id);
      widget.onAction();
    } catch (e) {
      if (mounted) _snack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _acting = true);
    try {
      await _svc.completeRequest(widget.request.id);
      widget.onAction();
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  void _openChat(String convId) async {
    try {
      final data = await ApiService.get('/messages/conv/$convId');
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.chat,
            arguments: ConversationModel.fromJson(
                data['data'] as Map<String, dynamic>));
      }
    } catch (e) {
      if (mounted) _snack('Could not open chat', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusBorderColor(r.status)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03), blurRadius: 8,
            offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            AvatarWidget(
              initials: r.client['initials'] as String? ?? '?',
              avatarUrl: r.client['avatar_url'] as String?,
              size: 42,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.client['full_name'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(r.client['title'] as String? ?? '',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _StatusPill(r.status),
              const SizedBox(height: 4),
              Text(r.timeAgo,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ]),
        ),

        // Service name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            const Icon(Icons.handyman_outlined,
                size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 5),
            Expanded(child: Text(r.service['title'] as String? ?? '',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (r.budget != null)
              Text('Budget: \$${r.budget!.toInt()}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success)),
          ]),
        ),

        // Message
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(r.message,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
        ),

        // Actions
        if (r.status == 'pending') ...[
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _acting ? null : _decline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _acting ? null : _accept,
                  icon: _acting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Accept & Chat',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            ]),
          ),
        ] else if (r.status == 'accepted') ...[
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: r.conversationId == null
                      ? null
                      : () => _openChat(r.conversationId!),
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Open Chat',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _acting ? null : _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Mark Complete',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ] else ...[
          const SizedBox(height: 12),
        ],
      ]),
    );
  }

  Color _statusBorderColor(String status) {
    switch (status) {
      case 'pending':   return const Color(0xFFFBBF24).withOpacity(0.4);
      case 'accepted':  return AppTheme.primary.withOpacity(0.3);
      case 'completed': return AppTheme.success.withOpacity(0.3);
      case 'cancelled': return Colors.grey.withOpacity(0.3);
      default:          return const Color(0xFFE2E8F0);
    }
  }
}

// ── Sent request card (client sees this) ─────────────────────────────────────
class _SentRequestCard extends StatefulWidget {
  final ServiceRequestModel request;
  final VoidCallback onAction;
  const _SentRequestCard({required this.request, required this.onAction});
  @override
  State<_SentRequestCard> createState() => _SentRequestCardState();
}

class _SentRequestCardState extends State<_SentRequestCard> {
  final _svc = ServiceRequestService();

  void _openChat(String convId) async {
    try {
      final data = await ApiService.get('/messages/conv/$convId');
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.chat,
            arguments: ConversationModel.fromJson(
                data['data'] as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(r.status)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03), blurRadius: 8,
            offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Service icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.handyman_outlined,
                  size: 20, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.service['title'] as String? ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('by ${r.provider['full_name'] as String? ?? ''}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _StatusPill(r.status),
              const SizedBox(height: 4),
              Text(r.timeAgo,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 10),
          Text(r.message,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),

          // If accepted → show Open Chat button
          if (r.status == 'accepted' && r.conversationId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => _openChat(r.conversationId!),
                icon: const Icon(Icons.chat_bubble_outline, size: 15),
                label: const Text('Continue in Chat',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],

          // Pending → allow cancel
          if (r.status == 'pending') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  await _svc.cancelRequest(r.id);
                  widget.onAction();
                },
                child: const Text('Cancel request',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],

          // Completed → prompt review
          if (r.status == 'completed') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle_outline,
                    size: 13, color: AppTheme.success),
                SizedBox(width: 5),
                Text('Work completed',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Color _borderColor(String status) {
    switch (status) {
      case 'pending':   return const Color(0xFFFBBF24).withOpacity(0.4);
      case 'accepted':  return AppTheme.primary.withOpacity(0.3);
      case 'completed': return AppTheme.success.withOpacity(0.3);
      default:          return const Color(0xFFE2E8F0);
    }
  }
}

// ── Status pill ───────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill(this.status);

  @override
  Widget build(BuildContext context) {
    final conf = _conf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: conf.$1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(conf.$2,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: conf.$1,
              letterSpacing: 0.3)),
    );
  }

  (Color, String) _conf(String s) {
    switch (s) {
      case 'pending':   return (const Color(0xFFF59E0B), 'PENDING');
      case 'accepted':  return (AppTheme.primary,        'ACTIVE');
      case 'completed': return (AppTheme.success,        'COMPLETED');
      case 'cancelled': return (Colors.grey,              'CANCELLED');
      default:          return (AppTheme.textSecondary,  s.toUpperCase());
    }
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final int count;
  const _Badge(this.count);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
        color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
    child: Text('$count',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _Empty extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _Empty({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(48),
    child: Center(child: Column(children: [
      Icon(icon, size: 48, color: AppTheme.textSecondary.withOpacity(0.3)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Text(sub, textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
    ])),
  );
}