import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/tracker/presentation/tracker_provider.dart';

void showTrackerBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _TrackerBottomSheet(ref: ref),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _TrackerBottomSheet extends StatefulWidget {
  final WidgetRef ref;
  const _TrackerBottomSheet({required this.ref});

  @override
  State<_TrackerBottomSheet> createState() => _TrackerBottomSheetState();
}

class _TrackerBottomSheetState extends State<_TrackerBottomSheet> {
  final _nameController = TextEditingController();
  bool _challengeEnabled = true;
  bool _saving = false;
  String? _validationError;

  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _startDate = today;
    _endDate = today.add(const Duration(days: 6));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Strips the time component so only the date matters.
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int get _durationDays => _endDate.difference(_startDate).inDays + 1;

  String get _durationLabel {
    final n = _durationDays;
    return n == 1 ? '1 day challenge' : '$n day challenge';
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _startDate = _dateOnly(picked);
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
      _validationError = null;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _endDate = _dateOnly(picked);
      _validationError = null;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_challengeEnabled && _endDate.isBefore(_startDate)) {
      setState(() => _validationError = 'End date must be on or after start date.');
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.ref.read(habitsProvider.notifier).addHabit(
            name: name,
            challengeEnabled: _challengeEnabled,
            startDate: _challengeEnabled ? _startDate : null,
            endDate: _challengeEnabled ? _endDate : null,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.track_changes, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Text('New Habit', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 24),

              // ── Habit name field ──────────────────────────────────────────
              TextField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'Habit name',
                  prefixIcon: const Icon(Icons.track_changes),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Challenge card ────────────────────────────────────────────
              // Using Material (not Container) so ListTile ink splashes are
              // rendered on the correct surface and remain visible.
              Material(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Switch row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set Challenge Duration',
                                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Add a time-based challenge',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _challengeEnabled,
                            onChanged: (v) => setState(() {
                              _challengeEnabled = v;
                              _validationError = null;
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Animated date controls
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: _challengeEnabled
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          Divider(
                            height: 1,
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),

                          // Start date
                          ListTile(
                            leading: Icon(Icons.calendar_today_outlined, color: cs.primary),
                            title: const Text('Start Date'),
                            trailing: Text(
                              _formatDate(_startDate),
                              style: tt.bodyMedium?.copyWith(color: cs.primary),
                            ),
                            onTap: _pickStartDate,
                          ),

                          Divider(
                            height: 1,
                            indent: 56,
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),

                          // End date
                          ListTile(
                            leading: Icon(Icons.event_outlined, color: cs.primary),
                            title: const Text('End Date'),
                            trailing: Text(
                              _formatDate(_endDate),
                              style: tt.bodyMedium?.copyWith(color: cs.primary),
                            ),
                            onTap: _pickEndDate,
                          ),

                          // Validation error
                          if (_validationError != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                _validationError!,
                                style: tt.bodySmall?.copyWith(color: cs.error),
                              ),
                            ),

                          // Duration CTA
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: FilledButton(
                              onPressed: null, // Informational only
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: cs.onSurface,
                                foregroundColor: cs.surface,
                                disabledBackgroundColor: cs.onSurface,
                                disabledForegroundColor: cs.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _durationLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Save button ───────────────────────────────────────────────
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Habit',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
