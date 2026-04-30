import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/section_header.dart';
import '../../../shared/constants.dart';
import '../bloc/trackpad_cubit.dart';
import '../bloc/trackpad_state.dart';
import '../widgets/trackpad_control_bar.dart';
import '../widgets/trackpad_surface.dart';

class TrackpadPage extends StatelessWidget {
  const TrackpadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackpadCubit(),
      child: BlocBuilder<TrackpadCubit, TrackpadState>(
        builder: (context, state) {
          final cubit = context.read<TrackpadCubit>();

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(kSpacingUnit * 2, kSpacingUnit * 2, kSpacingUnit * 2, 0),
                  child: SectionHeader(
                    title: 'Trackpad',
                    subtitle:
                        'Full-screen touch area with placeholder gesture feedback.',
                  ),
                ),
                const SizedBox(height: kSpacingUnit * 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingUnit * 2),
                    child: TrackpadSurface(
                      status: state.status,
                      feedback: state.feedback,
                      keyboardVisible: state.keyboardVisible,
                      onPointerDown: cubit.markInteraction,
                      onPointerMove: cubit.markInteraction,
                      onPointerUp: cubit.markInteraction,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(kSpacingUnit * 2),
                  child: TrackpadControlBar(
                    keyboardVisible: state.keyboardVisible,
                    onLeftClick: () => cubit.markInteraction(
                      'Left click placeholder triggered',
                    ),
                    onRightClick: () => cubit.markInteraction(
                      'Right click placeholder triggered',
                    ),
                    onKeyboardToggle: cubit.toggleKeyboard,
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
