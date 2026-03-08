import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/cell_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/routes.dart';

class SelectCellScreen extends StatefulWidget {
  const SelectCellScreen({super.key});
  @override
  State<SelectCellScreen> createState() => _SelectCellScreenState();
}

class _SelectCellScreenState extends State<SelectCellScreen> {
  String? _selectedCellId;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  List<CellModel> _cells = [];
  bool _loadingCells = true;
  bool _showRequestForm = false;
  bool _submittingRequest = false;
  String? _requestSuccess;
  final _reqNameCtrl = TextEditingController();
  final _reqDescCtrl = TextEditingController();
  final _reqReasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCells();
  }

  Future<void> _loadCells() async {
    try {
      final data = await ApiService.get('/cells');
      setState(() {
        _cells = (data['data'] as List).map((j) => CellModel.fromJson(j)).toList();
        _loadingCells = false;
      });
    } catch (_) {
      setState(() => _loadingCells = false);
    }
  }

  List<CellModel> get _filtered => _cells
      .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  Future<void> _submitRequest() async {
    final name = _reqNameCtrl.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cell name must be at least 2 characters'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _submittingRequest = true);
    try {
      await ApiService.post('/cell-requests', {
        'cell_name': name,
        'description': _reqDescCtrl.text.trim(),
        'reason': _reqReasonCtrl.text.trim(),
      });
      if (mounted) setState(() {
        _requestSuccess = name;
        _submittingRequest = false;
        _showRequestForm = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _submittingRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirm() async {
    if (_selectedCellId == null) return;
    final success = await context.read<AuthProvider>().selectCell(_selectedCellId!);
    if (success && mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Your Cell', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Choose your professional community. This selection is permanent.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search your Cell...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD93D).withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFB7860B), size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('Cell selection is permanent. Choose carefully.', style: TextStyle(color: Color(0xFFB7860B), fontSize: 12))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loadingCells
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final cell = _filtered[i];
                          final isSelected = _selectedCellId == cell.id;
                          return ListTile(
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(8)),
                              child: Icon(cell.iconData, size: 20, color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
                            ),
                            title: Text(cell.name, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                            subtitle: Text(cell.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                            onTap: () => setState(() => _selectedCellId = cell.id),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                          );
                        },
                      ),
              ),
              if (_selectedCellId != null) ...[
                const SizedBox(height: 12),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.status == AuthStatus.loading ? null : _confirm,
                      child: auth.status == AuthStatus.loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Join Cell'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // ── Request new cell ────────────────────────────────
              if (_requestSuccess != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6FAF0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3))),
                  child: Column(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 32),
                    const SizedBox(height: 8),
                    Text('Request sent for "${_requestSuccess}"!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('You will receive an email once the admin reviews your request.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ]),
                )
              else if (!_showRequestForm)
                GestureDetector(
                  onTap: () => setState(() => _showRequestForm = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Cell doesn\'t exist yet — Request it',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Request a New Cell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      GestureDetector(
                        onTap: () => setState(() => _showRequestForm = false),
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    const Text('The admin will review your request and notify you by email.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _reqNameCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Cell name (e.g. "AI Research")',
                          labelText: 'Cell Name *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reqDescCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'Brief description…',
                          labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reqReasonCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'Why should this cell be created?',
                          labelText: 'Reason'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _submittingRequest ? null : _submitRequest,
                        child: _submittingRequest
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Submit Request'),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}