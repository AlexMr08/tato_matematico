import 'dart:math' as math;
import 'package:flutter/material.dart';

/// `lib/fab.dart`
/// Widget reusable que implementa un FAB menu al estilo Material 3.
/// - Corrige overflow de Opacity/scale usando clamp() para garantizar valores en [0,1].

enum FabDirection { up, down, left, right }

class M3FabAction {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  M3FabAction({required this.onPressed, required this.icon, this.label});
}

class M3FabMenu extends StatefulWidget {
  final List<M3FabAction> actions;
  final IconData openIcon;
  final IconData closeIcon;
  final FabDirection direction;
  final double spacing;
  final bool showLabels;
  final Duration duration;

  const M3FabMenu({
    super.key,
    required this.actions,
    this.openIcon = Icons.add,
    this.closeIcon = Icons.close,
    this.direction = FabDirection.up,
    this.spacing = 70.0,
    this.showLabels = true,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<M3FabMenu> createState() => _M3FabMenuState();
}

class _M3FabMenuState extends State<M3FabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconRotation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  Offset _offsetForIndex(int i) {
    final double distance = i == 0
        ? widget.spacing * (i + 1)
        : widget.spacing * (i + 3 / 4);
    switch (widget.direction) {
      case FabDirection.up:
        return Offset(0, -distance);
      case FabDirection.down:
        return Offset(0, distance);
      case FabDirection.left:
        return Offset(-distance, 0);
      case FabDirection.right:
        return Offset(distance, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // El widget se adapta a su contenido; si se usa dentro de floatingActionButton
    // en Scaffold, normalmente solo ocupará el tamaño necesario.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Acciones (staggered)
          ...List.generate(widget.actions.length, (index) {
            final action = widget.actions[index];
            final offset = _offsetForIndex(index);

            final start = (index * 0.05).clamp(0.0, 0.5);
            final end = (start + 0.4).clamp(0.0, 1.0);

            final anim = CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start, end, curve: Curves.easeOutBack),
            );

            return AnimatedBuilder(
              animation: anim,
              builder: (context, child) {
                // proteger valores que pueden overshoot por la curva
                final raw = anim.value;
                final double safeOpacity = (raw).clamp(0.0, 1.0);
                final double safeScale = (raw).clamp(0.0, 1.0);

                final dx = offset.dx * safeScale;
                final dy = offset.dy * safeScale;

                return Positioned(
                  right: 0 - dx,
                  bottom: 0 - dy,
                  child: Opacity(
                    opacity: safeOpacity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_open) _toggle();
                        action.onPressed();
                      },
                      icon: Icon(action.icon, size: 20),
                      label: Text(action.label ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                );
              },
            );
          }).reversed,

          // FAB principal
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _toggle,
              elevation: 8,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: AnimatedSwitcher(
                duration: widget.duration,
                transitionBuilder: (child, animation) {
                  // Usa ScaleTransition (sin fade). Puedes cambiar por SlideTransition, RotationTransition, etc.
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _open
                    ? Icon(widget.closeIcon, key: const ValueKey('fab_close'))
                    : AnimatedBuilder(
                        // Rotar solo el icono de apertura
                        animation: _ctrl,
                        builder: (context, _) {
                          final angle = _iconRotation.value * 2 * math.pi;
                          return Transform.rotate(
                            angle: angle,
                            child: const Icon(
                              // use key distinto para que AnimatedSwitcher reconozca el cambio
                              Icons.add,
                              key: ValueKey('fab_open'),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
