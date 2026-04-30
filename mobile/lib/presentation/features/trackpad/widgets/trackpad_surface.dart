import 'package:flutter/material.dart';

import '../../../shared/constants.dart';
import '../../../shared/models/view_status.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

class TrackpadSurface extends StatelessWidget {
  const TrackpadSurface({
    super.key,
    required this.status,
    required this.feedback,
    required this.keyboardVisible,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
  });

  final ViewStatus status;
  final String feedback;
  final bool keyboardVisible;
  final ValueChanged<PointerEvent> onPointerDown;
  final ValueChanged<PointerEvent> onPointerMove;
  final ValueChanged<PointerEvent> onPointerUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
          child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (ev) => onPointerDown(ev),
          onPointerMove: (ev) => onPointerMove(ev),
          onPointerUp: (ev) => onPointerUp(ev),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 420),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surfaceContainerHighest.withAlpha((0.7 * 255).round()),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingUnit * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(
                    label: keyboardVisible ? 'Keyboard ready' : 'Gesture mode',
                    color: theme.colorScheme.primary,
                    icon: keyboardVisible
                        ? Icons.keyboard_rounded
                        : Icons.touch_app_rounded,
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gesture_rounded,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: kSpacingUnit * 1.5),
                        Text(
                          'Trackpad surface',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingUnit),
                        Text(
                          feedback,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingUnit * 1.5,
                        vertical: kSpacingUnit,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha((0.12 * 255).round()),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status == ViewStatus.empty
                            ? 'Waiting for touch input'
                            : 'Gesture placeholder active',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
