import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../models/sighting_draft.dart';

class SightingSuccessPage extends StatelessWidget {
  final SightingDraft draft;
  final VoidCallback onHome;
  const SightingSuccessPage({
    super.key,
    required this.draft,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingToken.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: AppColors.success,
          ),
          const SizedBox(height: SpacingToken.m),
          const Text(
            'Avistamiento reportado',
            style: AppTextStyle.boldSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingToken.s),
          Text(
            'Tu información sobre ${draft.report.displayName} quedó registrada.',
            style: AppTextStyle.regularCaption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingToken.xL),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state is ChatLoading
                    ? null
                    : () => context.read<ChatBloc>().add(
                        OpenConversation(draft.report.id),
                      ),
                icon: state is ChatLoading
                    ? const SizedBox.square(
                        dimension: SpacingToken.m,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                label: Text(
                  state is ChatLoading
                      ? 'Abriendo conversación...'
                      : 'Contactar al dueño',
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingToken.s),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onHome,
              child: const Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    ),
  );
}
