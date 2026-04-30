import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/section_header.dart';
import '../../../shared/constants.dart';
import '../bloc/trackpad_cubit.dart';
import '../bloc/trackpad_state.dart';
import '../widgets/trackpad_control_bar.dart';
import '../widgets/trackpad_surface.dart';
import '../../../../injection/injection.dart';
import '../../../../domain/entities/gesture.dart' as domain_gesture;
import '../../../../domain/usecases/send_gesture.dart';

class TrackpadPage extends StatelessWidget {
  const TrackpadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackpadCubit(sendGestureUseCase: sl<SendGesture>()),
      child: BlocBuilder<TrackpadCubit, TrackpadState>(
        builder: (context, state) {
          final cubit = context.read<TrackpadCubit>();

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    kSpacingUnit * 2,
                    kSpacingUnit * 2,
                    kSpacingUnit * 2,
                    0,
                  ),
                  child: SectionHeader(
                    title: 'Trackpad',
                    subtitle:
                        'Full-screen touch area with placeholder gesture feedback.',
                  ),
                ),
                const SizedBox(height: kSpacingUnit * 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingUnit * 2,
                    ),
                    child: TrackpadSurface(
                      status: state.status,
                      feedback: state.feedback,
                      keyboardVisible: state.keyboardVisible,
                      onPointerDown: (ev) {
                        cubit.markInteraction('Pointer down received');
                        cubit.sendGesture(
                          domain_gesture.Gesture(
                            type: domain_gesture.GestureType.tap,
                          ),
                        );
                      },
                      onPointerMove: (ev) {
                        cubit.markInteraction('Pointer move received');
                        cubit.sendGesture(
                          domain_gesture.Gesture(
                            type: domain_gesture.GestureType.move,
                            deltaX: ev.delta.dx,
                            deltaY: ev.delta.dy,
                          ),
                        );
                      },
                      onPointerUp: (ev) {
                        cubit.markInteraction('Pointer up received');
                        cubit.sendGesture(
                          domain_gesture.Gesture(
                            type: domain_gesture.GestureType.tap,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(kSpacingUnit * 2),
                  child: TrackpadControlBar(
                    keyboardVisible: state.keyboardVisible,
                    onLeftClick: () async {
                      await cubit.sendLeftClick();
                    },
                    onRightClick: () async {
                      await cubit.sendRightClick();
                    },
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
