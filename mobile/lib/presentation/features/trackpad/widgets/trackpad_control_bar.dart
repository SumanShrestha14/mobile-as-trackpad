import 'package:flutter/material.dart';
import '../../../shared/constants.dart';

class TrackpadControlBar extends StatelessWidget {
  const TrackpadControlBar({
    super.key,
    required this.keyboardVisible,
    required this.onLeftClick,
    required this.onRightClick,
    required this.onKeyboardToggle,
  });

  final bool keyboardVisible;
  final VoidCallback onLeftClick;
  final VoidCallback onRightClick;
  final VoidCallback onKeyboardToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(kSpacingUnit),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withAlpha((0.12 * 255).round()),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: onLeftClick,
              icon: const Icon(Icons.mouse_rounded),
              label: const Text('Left click'),
            ),
          ),
          const SizedBox(width: kSpacingUnit),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: onRightClick,
              icon: const Icon(Icons.ads_click_rounded),
              label: const Text('Right click'),
            ),
          ),
          const SizedBox(width: kSpacingUnit),
          Expanded(
            child: FilledButton.icon(
              onPressed: onKeyboardToggle,
              icon: Icon(
                keyboardVisible ? Icons.keyboard_hide_rounded : Icons.keyboard_rounded,
              ),
              label: Text(keyboardVisible ? 'Keyboard' : 'Keyboard'),
            ),
          ),
        ],
      ),
    );
  }
}