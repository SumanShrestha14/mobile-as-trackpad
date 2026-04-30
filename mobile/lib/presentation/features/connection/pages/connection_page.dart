import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/view_status.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/constants.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/section_header.dart';
import '../bloc/connection_cubit.dart';
import '../widgets/connection_status_card.dart';
import '../../../../injection/injection.dart';
import '../../../../domain/usecases/connect_device.dart';
import '../../../../domain/usecases/disconnect_device.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectionCubit(
        connectDevice: sl<ConnectDevice>(),
        disconnectDevice: sl<DisconnectDevice>(),
      ),
      child: BlocBuilder<ConnectionCubit, dynamic>(
        builder: (context, _) {
          final state = context.read<ConnectionCubit>().state;
          final isConnecting = state.status == ViewStatus.loading;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                  title: 'Connection',
                  subtitle: 'Pair your phone with the desktop companion.',
                ),
                const SizedBox(height: kSpacingUnit * 2),
                ConnectionStatusCard(
                  deviceName: state.deviceName,
                  statusLabel: state.message,
                  isConnected: state.isConnected,
                ),
                const SizedBox(height: kSpacingUnit * 2),
                if (state.status == ViewStatus.error)
                  ErrorStateView(
                    message: state.message,
                    onRetry: context.read<ConnectionCubit>().resetError,
                  ),
                if (state.status == ViewStatus.initial)
                  const EmptyStateView(
                    title: 'No device connected yet',
                    message:
                        'Add an IP address below to start the connection flow.',
                    icon: Icons.devices_other_rounded,
                  ),
                const SizedBox(height: kSpacingUnit * 2),
                AppTextField(
                  label: 'IP address',
                  hintText: 'Auto-detect placeholder',
                  prefixIcon: Icons.lan_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: context.read<ConnectionCubit>().updateIpAddress,
                  enabled: !isConnecting,
                ),
                const SizedBox(height: kSpacingUnit * 2),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Connect',
                        icon: Icons.wifi_tethering_rounded,
                        isBusy: isConnecting,
                        expanded: true,
                        onPressed: context.read<ConnectionCubit>().connect,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingUnit * 1.5),
                Text(
                  'Connection status and persistence are active; loading/error states remain for network edge cases.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
