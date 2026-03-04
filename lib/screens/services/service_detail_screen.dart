import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../services/service_service.dart';
import '../../services/service_request_service.dart';
import '../../providers/auth_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<ServiceReviewModel> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await ServiceService().getReviews(widget.service.id);
      setState(() { _reviews = reviews; _loadingReviews = false; });
    } catch (_) {
      setState(() => _loadingReviews = false);
    }
  }

  Color get _cellColor {
    const map = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6), 'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6), 'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981), 'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444), 'Photography': Color(0xFFF97316),
    };
    return map[widget.service.cell] ?? AppTheme.primary;
  }

  void _contactProvider() => _showHireSheet();

  void _showHireSheet() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;
    if (currentUser.id == widget.service.provider.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("That's your own service!"), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HireSheet(service: widget.service),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(serviceId: widget.service.id, onSubmitted: _loadReviews),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _cellColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (s.isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () {},
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_cellColor.withOpacity(0.8), _cellColor],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (s.cell != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s.cell!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        const SizedBox(height: 10),
                        Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            s.rating > 0 ? s.rating.toStringAsFixed(1) : 'New',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (s.reviewsCount > 0) ...[
                            Text(' · ${s.reviewsCount} reviews',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Price + CTA card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Starting from', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text('\$${s.price.toInt()}',
                            style: TextStyle(color: _cellColor, fontSize: 28, fontWeight: FontWeight.w900)),
                      ]),
                      const Spacer(),
                      Column(children: [
                        SizedBox(
                          width: 140,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _contactProvider,
                            icon: const Icon(Icons.chat_bubble_outline, size: 17),
                            label: const Text('Hire Now', style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _cellColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // Provider card
                _Section(
                  child: Row(
                    children: [
                      Stack(children: [
                        AvatarWidget(initials: s.provider.initials, size: 54, avatarUrl: s.provider.avatarUrl),
                        Positioned(right: 0, bottom: 0, child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        )),
                      ]),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.provider.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (s.provider.title.isNotEmpty)
                          Text(s.provider.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        if (s.cell != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: _cellColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(s.cell!, style: TextStyle(color: _cellColor, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ])),
                      IconButton(
                        icon: Icon(Icons.message_outlined, color: _cellColor),
                        onPressed: _contactProvider,
                      ),
                    ],
                  ),
                ),

                // Description
                _Section(
                  title: 'About this service',
                  child: Text(s.description,
                      style: const TextStyle(fontSize: 14, height: 1.7, color: AppTheme.textSecondary)),
                ),

                // What's included
                _Section(
                  title: "What's included",
                  child: Column(children: [
                    _IncludedItem(icon: Icons.check_circle_outline, text: 'Professional delivery'),
                    _IncludedItem(icon: Icons.check_circle_outline, text: 'Direct communication via Mina'),
                    _IncludedItem(icon: Icons.check_circle_outline, text: 'Revisions on request'),
                    _IncludedItem(icon: Icons.check_circle_outline, text: '100% satisfaction focus'),
                  ]),
                ),

                // Reviews
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Reviews (${s.reviewsCount})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (!s.isOwner)
                        GestureDetector(
                          onTap: _showReviewSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: _cellColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('+ Write Review', style: TextStyle(color: _cellColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ]),

                    if (s.rating > 0) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Text(s.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: List.generate(5, (i) => Icon(
                            i < s.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber, size: 20,
                          ))),
                          Text('Based on ${s.reviewsCount} review${s.reviewsCount > 1 ? 's' : ''}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ]),
                      ]),
                    ],

                    const SizedBox(height: 14),
                    if (_loadingReviews)
                      const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                    else if (_reviews.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No reviews yet. Be the first!',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ))
                    else
                      ..._reviews.map((r) => _ReviewTile(review: r)),
                  ]),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Section({this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[
        Text(title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
      ],
      child,
    ]),
  );
}

class _IncludedItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IncludedItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
    ]),
  );
}

class _ReviewTile extends StatelessWidget {
  final ServiceReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        AvatarWidget(initials: review.reviewer.initials, size: 36),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(review.reviewer.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber, size: 13,
          ))),
        ])),
        Text(_timeAgo(review.createdAt), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
      if (review.comment != null && review.comment!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(review.comment!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
      ],
      const SizedBox(height: 8),
      const Divider(height: 1),
    ]),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).round()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

// ─── Review Bottom Sheet ─────────────────────────────────────────────────────
class _ReviewSheet extends StatefulWidget {
  final String serviceId;
  final VoidCallback onSubmitted;
  const _ReviewSheet({required this.serviceId, required this.onSubmitted});
  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ServiceService().addReview(widget.serviceId, _rating, _commentCtrl.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmitted();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Review submitted, thank you!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Text('Leave a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('How was your experience?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        // Star picker
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber, size: 38,
                ),
              ),
            )),
          ),
        ),
        Center(child: Text(
          ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][_rating],
          style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.w600, fontSize: 14),
        )),
        const SizedBox(height: 20),
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share details about your experience...',
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ─── Hire Sheet ──────────────────────────────────────────────────────────────
class _HireSheet extends StatefulWidget {
  final ServiceModel service;
  const _HireSheet({required this.service});
  @override
  State<_HireSheet> createState() => _HireSheetState();
}

class _HireSheetState extends State<_HireSheet> {
  final _msgCtrl    = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _submitting  = false;
  bool _showBudget  = false;

  @override
  void dispose() { _msgCtrl.dispose(); _budgetCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final msg = _msgCtrl.text.trim();
    if (msg.length < 10) {
      _snack('Please describe your project (at least 10 characters)', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final budget = _showBudget && _budgetCtrl.text.isNotEmpty
          ? double.tryParse(_budgetCtrl.text)
          : null;
      await ServiceRequestService().sendRequest(
          widget.service.id, msg, budget: budget);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✅ Request sent! The provider will review it shortly.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
    } catch (e) {
      if (mounted) _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

  Color get _color {
    const m = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[widget.service.cell] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Drag handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),

          // Service summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.handyman_outlined, size: 22, color: _color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('by ${s.provider.fullName}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ])),
              Text('\$${s.price.toInt()}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: _color)),
            ]),
          ),
          const SizedBox(height: 20),

          // Title
          const Text('Send a Hire Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Describe your project and the provider will review it.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 18),

          // Message field
          const Text('Project description *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _msgCtrl,
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText:
                  'Describe what you need:\n• What is the project about?\n• Timeline expectations\n• Any specific requirements',
              hintStyle: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _color, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),

          // Optional budget toggle
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _showBudget = !_showBudget),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: _showBudget ? _color : Colors.transparent,
                    border: Border.all(
                        color: _showBudget ? _color : const Color(0xFFCBD5E1),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _showBudget
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text('I have a specific budget',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),

          // Budget field
          if (_showBudget) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _budgetCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your budget (\$)',
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _color, width: 1.5)),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Send Hire Request',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
            ),
          ),
        ]),
      ),
    );
  }
}