import 'package:flutter/material.dart';

class AdaptiveCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isCompleted;
  /// When true (Today / Week pages) the card shows a checkbox and
  /// applies strikethrough on completed items.
  /// When false (Notes / Tracker pages) it renders a plain ListTile.
  final bool showCheckbox;

  const AdaptiveCard({
    super.key,
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    this.showCheckbox = false,
    this.onTap,
    this.onDelete,
  });

  @override
  State<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard>
    with SingleTickerProviderStateMixin {
  // Width of the delete action button revealed on swipe
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

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    // Swipe left to reveal, swipe right to hide
    if (!_revealed && velocity < -300) {
      _open();
    } else if (_revealed && velocity > 300) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        // ClipRect prevents the card from visually overflowing while sliding
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _slideAnim,
            builder: (context, child) {
              return Stack(
                children: [
                  // ── Delete button (behind) ───────────────────────────────
                  // Grows from the right edge as the card slides left
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
                            ? Icon(
                                Icons.delete_outline,
                                color: cs.onErrorContainer,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // ── Main card (shifted left to reveal the button) ────────
                  Transform.translate(
                    offset: Offset(-_slideAnim.value, 0),
                    child: child,
                  ),
                ],
              );
            },
            child: Card(
              margin: EdgeInsets.zero,
              child: widget.showCheckbox
                  // ── Task pages (Today / Week): checkbox + strikethrough ──
                  ? CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      value: widget.isCompleted,
                      onChanged: (_) {
                        if (_revealed) _close();
                        widget.onTap?.call();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        widget.title,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        style: widget.isCompleted
                            ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                // ignore: deprecated_member_use
                                color: cs.onSurface.withOpacity(0.45),
                              )
                            : null,
                      ),
                      subtitle: widget.subtitle == null
                          ? null
                          : Text(
                              widget.subtitle!,
                              maxLines: null,
                              overflow: TextOverflow.visible,
                            ),
                    )
                  // ── Other pages (Notes / Tracker): plain ListTile ────────
                  : ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        widget.title,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                      subtitle: widget.subtitle == null
                          ? null
                          : Text(
                              widget.subtitle!,
                              maxLines: null,
                              overflow: TextOverflow.visible,
                            ),
                      onTap: () {
                        if (_revealed) _close();
                        widget.onTap?.call();
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
