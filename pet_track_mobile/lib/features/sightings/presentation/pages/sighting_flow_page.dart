import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/injection.dart';
import '../../../../theme/app_colors.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../lost_pets/domain/entities/lost_pet_report.dart';
import '../bloc/sighting_bloc.dart';
import '../bloc/sighting_state.dart';
import '../models/sighting_draft.dart';
import 'sighting_information_page.dart';
import 'sighting_location_page.dart';
import 'sighting_review_page.dart';
import 'sighting_success_page.dart';

class SightingFlowPage extends StatelessWidget {
  final LostPetReport report;
  const SightingFlowPage({super.key, required this.report});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<SightingBloc>()),
      BlocProvider(create: (_) => sl<ChatBloc>()),
    ],
    child: _SightingFlowView(report: report),
  );
}

class _SightingFlowView extends StatefulWidget {
  final LostPetReport report;
  const _SightingFlowView({required this.report});
  @override
  State<_SightingFlowView> createState() => _SightingFlowViewState();
}

class _SightingFlowViewState extends State<_SightingFlowView> {
  late final SightingDraft draft = SightingDraft(widget.report);
  int step = 0;
  void _next() => setState(() => step++);
  void _back() {
    if (step == 2 && context.read<SightingBloc>().state is SightingSubmitting) {
      return;
    }
    if (step == 3) {
      _home();
    } else if (step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => step--);
    }
  }

  void _home() => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<SightingBloc, SightingState>(
        listener: (context, state) {
          if (state is SightingCreated) setState(() => step = 3);
          if (state is SightingFailure &&
              state.kind == SightingFailureKind.create &&
              step == 2) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
      BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ConversationOpened) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(conversation: state.conversation),
              ),
            );
          }
          if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
    ],
    child: PopScope(
      canPop: step == 0 || step == 3,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: step == 3 ? _home : _back,
            icon: Icon(step == 3 ? Icons.close : Icons.arrow_back),
          ),
          title: Text(
            [
              'Ubicación',
              'Información',
              'Revisar',
              'Avistamiento enviado',
            ][step],
          ),
        ),
        body: switch (step) {
          0 => SightingLocationPage(draft: draft, onContinue: _next),
          1 => SightingInformationPage(draft: draft, onContinue: _next),
          2 => SightingReviewPage(draft: draft, onEdit: _back),
          _ => SightingSuccessPage(draft: draft, onHome: _home),
        },
      ),
    ),
  );
}
