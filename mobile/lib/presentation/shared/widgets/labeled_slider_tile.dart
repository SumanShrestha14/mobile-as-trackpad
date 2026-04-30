import 'package:flutter/material.dart';

import '../constants.dart';
import 'app_card.dart';

class LabeledSliderTile extends StatelessWidget {
  const LabeledSliderTile({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.min = 0,
    this.max = 10,
  });

  final String title;
  final String valueLabel;
  final String? subtitle;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: kSpacingUnit),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                valueLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(value: value, onChanged: onChanged, min: min, max: max),
        ],
      ),
    );
  }
}
