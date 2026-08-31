import 'package:flutter/material.dart';

import '../features/tracker/domain/habit.dart';

/// A swipeable card that displays a [Habit] summary.
/// Swiping left reveals the delete button.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final int committedCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.committedCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 72.0;

  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slideAnim = Tween<double>(begin: 0.0, end: _actionWidth).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _open() {
    _animCtrl.forward();
    setState(() => _revealed = true);
  }

  void _close() {
    _animCtrl.reverse();
    setState(() => _revealed = false);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _animCtrl.value -= details.primaryDelta! / _actionWidth;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200 || _animCtrl.value >= 0.5) {
      _open();
    } else if (velocity > 200 || _animCtrl.value < 0.5) {
      _close();
    }
  }

  // ── Subtitle text ──────────────────────────────────────────────────────────

  String _subtitle() {
    final count = widget.committedCount;
    final days = widget.habit.challengeDays;

    if (widget.habit.challengeEnabled && days != null) {
      return '$count / $days days committed';
    }
    return count == 1 ? '1 day committed' : '$count days committed';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onSecondaryTap: () {
        if (_revealed) {
          _close();
        } else {
          _open();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _slideAnim,
            builder: (context, child) {
              return Stack(
                children: [
                  // ── Delete button ──────────────────────────────────────────
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: _slideAnim.value,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _slideAnim.value > 20
                            ? Icon(Icons.delete_outline, color: cs.onErrorContainer)
                            : null,
                      ),
                    ),
                  ),

                  // ── Main card ──────────────────────────────────────────────
                  Transform.translate(
                    offset: Offset(-_slideAnim.value, 0),
                    child: child,
                  ),
                ],
              );
            },
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.track_changes, color: cs.onPrimaryContainer),
                ),
                title: Text(
                  widget.habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_subtitle()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (_revealed) {
                    _close();
                  } else {
                    widget.onTap();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
