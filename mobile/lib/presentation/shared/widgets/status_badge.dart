import 'package:flutter/material.dart';
import '../constants.dart';
// color_extensions removed; using standard Color.withOpacity instead

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingUnit, vertical: kSpacingUnit),
      decoration: BoxDecoration(
        color: color.withAlpha((0.16 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha((0.35 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: kSpacingUnit),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
