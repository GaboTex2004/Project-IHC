import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/list_reports_usecase.dart';
import '../../domain/usecases/create_report_usecase.dart';
import '../../domain/usecases/get_report_detail_usecase.dart';
import '../../domain/usecases/get_my_reports_usecase.dart';
import '../../domain/usecases/resolve_report_usecase.dart';
import '../../../../core/errors/failures.dart';
import 'lost_pet_event.dart';
import 'lost_pet_state.dart';
import '../../domain/usecases/analyze_report_usecase.dart';
import '../../domain/usecases/find_report_matches_usecase.dart';
import '../../domain/entities/lost_pet_report.dart';

class LostPetBloc extends Bloc<LostPetEvent, LostPetState> {
  final ListReportsUseCase listReportsUseCase;
  final CreateReportUseCase createReportUseCase;
  final GetReportDetailUseCase getReportDetailUseCase;
  final GetMyReportsUseCase getMyReportsUseCase;
  final ResolveReportUseCase resolveReportUseCase;
  final AnalyzeReportUseCase analyzeReportUseCase;
  final FindReportMatchesUseCase findReportMatchesUseCase;
  LostPetBloc({
    required this.listReportsUseCase,
    required this.createReportUseCase,
    required this.getReportDetailUseCase,
    required this.getMyReportsUseCase,
    required this.resolveReportUseCase,
    required this.analyzeReportUseCase,
    required this.findReportMatchesUseCase,
  }) : super(const LostPetInitial()) {
    on<LoadReports>(_onLoadReports);
    on<LoadReportDetail>(_onLoadReportDetail);
    on<LoadMyReports>(_onLoadMyReports);
    on<ResolveReport>(_onResolveReport);
    on<CreateReport>(_onCreateReport);
    on<AnalyzeReport>(_onAnalyzeReport);
    on<FindReportMatches>(_onFindReportMatches);
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<LostPetState> emit,
  ) async {
    emit(const LostPetLoading());

    final result = await listReportsUseCase();

    result.fold(
      (failure) => emit(LostPetError(message: failure.message)),
      (reports) => emit(LostPetLoaded(reports: reports)),
    );
  }

  Future<void> _onLoadReportDetail(
    LoadReportDetail event,
    Emitter<LostPetState> emit,
  ) async {
    emit(const LostPetDetailLoading());

    final result = await getReportDetailUseCase(event.reportId);

    result.fold(
      (failure) => failure is NotFoundFailure
          ? emit(LostPetDetailNotFound(message: failure.message))
          : emit(LostPetError(message: failure.message)),
      (report) => emit(LostPetDetailLoaded(report: report)),
    );
  }

  Future<void> _onLoadMyReports(
    LoadMyReports event,
    Emitter<LostPetState> emit,
  ) async {
    emit(const MyReportsLoading());
    final result = await getMyReportsUseCase();
    result.fold(
      (failure) => emit(LostPetError(message: failure.message)),
      (reports) => emit(MyReportsLoaded(reports: reports)),
    );
  }

  Future<void> _onResolveReport(
    ResolveReport event,
    Emitter<LostPetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MyReportsLoaded) return;

    emit(
      MyReportsUpdating(
        reports: currentState.reports,
        reportId: event.reportId,
      ),
    );
    final result = await resolveReportUseCase(event.reportId);
    result.fold((failure) => emit(LostPetError(message: failure.message)), (
      updatedReport,
    ) {
      final reports = currentState.reports
          .map(
            (report) => report.id == updatedReport.id ? updatedReport : report,
          )
          .toList();
      emit(MyReportsLoaded(reports: reports));
    });
  }

  Future<void> _onCreateReport(
    CreateReport event,
    Emitter<LostPetState> emit,
  ) async {
    emit(const LostPetLoading());

    final result = await createReportUseCase(
      CreateReportParams(
        name: event.name,
        photoBytes: event.photoBytes,
        photoName: event.photoName,
        characteristics: event.characteristics,
        lastLocation: event.lastLocation,
        dateLost: event.dateLost,
        contactInfo: event.contactInfo,
        reportType: event.reportType,
      ),
    );

    result.fold(
      (failure) => emit(LostPetError(message: failure.message)),
      (report) => emit(LostPetCreated(report: report)),
    );
  }

  Future<void> _onAnalyzeReport(
    AnalyzeReport event,
    Emitter<LostPetState> emit,
  ) async {
    final currentState = state;

    // Conservamos los reportes que ya aparecen en pantalla.
    final reports = switch (currentState) {
      MyReportsLoaded() => currentState.reports,
      ReportAnalysisLoaded() => currentState.reports,
      ReportAnalysisError() => currentState.reports,
      ReportMatchesLoading() => currentState.reports,
      ReportMatchesLoaded() => currentState.reports,
      ReportMatchesError() => currentState.reports,
      _ => null,
    };

    if (reports == null) return;

    // Evitamos analizar un reporte que no está en la lista válida.
    final canAnalyze = reports.any(
      (report) =>
          report.id == event.reportId &&
          const {'LOST', 'FOUND', 'HOMELESS'}.contains(report.reportType) &&
          report.isActive,
    );

    if (!canAnalyze) return;

    emit(
      ReportAnalysisLoading(
        reports: reports,
        reportId: event.reportId,
      ),
    );

    final result = await analyzeReportUseCase(event.reportId);

    result.fold(
      (failure) => emit(
        ReportAnalysisError(
          reports: reports,
          reportId: event.reportId,
          message: failure.message,
        ),
      ),
      (analysis) => emit(
        ReportAnalysisLoaded(
          reports: reports,
          reportId: event.reportId,
          analysis: analysis,
        ),
      ),
    );
  }

  Future<void> _onFindReportMatches(
    FindReportMatches event,
    Emitter<LostPetState> emit,
  ) async {
    final currentState = state;

    final List<LostPetReport> reports;
    final Map<String, dynamic> analysis;

    if (currentState is ReportAnalysisLoaded &&
        currentState.reportId == event.reportId) {
      reports = currentState.reports;
      analysis = currentState.analysis;
    } else if (currentState is ReportMatchesError &&
        currentState.reportId == event.reportId) {
      reports = currentState.reports;
      analysis = currentState.analysis;
    } else if (currentState is ReportMatchesLoaded &&
        currentState.reportId == event.reportId) {
      reports = currentState.reports;
      analysis = currentState.analysis;
    } else {
      return;
    }

    emit(
      ReportMatchesLoading(
        reports: reports,
        reportId: event.reportId,
        analysis: analysis,
      ),
    );

    final result = await findReportMatchesUseCase(event.reportId);

    result.fold(
      (failure) => emit(
        ReportMatchesError(
          reports: reports,
          reportId: event.reportId,
          analysis: analysis,
          message: failure.message,
        ),
      ),
      (matches) => emit(
        ReportMatchesLoaded(
          reports: reports,
          reportId: event.reportId,
          analysis: analysis,
          matches: matches,
        ),
      ),
    );
  }
}
