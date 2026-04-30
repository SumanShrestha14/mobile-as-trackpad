import 'package:flutter/material.dart';

import '../../../shared/constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({
    super.key,
    required this.deviceName,
    required this.statusLabel,
    required this.isConnected,
  });

  final String deviceName;
  final String statusLabel;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isConnected ? theme.colorScheme.primary : theme.colorScheme.secondary;

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
                      deviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: kSpacingUnit),
                    Text(
                      statusLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: isConnected ? 'Connected' : 'Disconnected',
                color: statusColor,
                icon: isConnected ? Icons.link_rounded : Icons.link_off_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
