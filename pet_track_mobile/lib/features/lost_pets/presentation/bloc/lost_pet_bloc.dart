import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/list_reports_usecase.dart';
import '../../domain/usecases/create_report_usecase.dart';
import 'lost_pet_event.dart';
import 'lost_pet_state.dart';

class LostPetBloc extends Bloc<LostPetEvent, LostPetState> {
  final ListReportsUseCase listReportsUseCase;
  final CreateReportUseCase createReportUseCase;

  LostPetBloc({
    required this.listReportsUseCase,
    required this.createReportUseCase,
  }) : super(const LostPetInitial()) {
    on<LoadReports>(_onLoadReports);
    on<CreateReport>(_onCreateReport);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<LostPetState> emit) async {
    emit(const LostPetLoading());
    
    final result = await listReportsUseCase();
    
    result.fold(
      (failure) => emit(LostPetError(message: failure.message)),
      (reports) => emit(LostPetLoaded(reports: reports)),
    );
  }

  Future<void> _onCreateReport(CreateReport event, Emitter<LostPetState> emit) async {
    emit(const LostPetLoading());
    
    final result = await createReportUseCase(CreateReportParams(
      name: event.name,
      photoBytes: event.photoBytes,
      photoName: event.photoName,
      characteristics: event.characteristics,
      lastLocation: event.lastLocation,
      dateLost: event.dateLost,
      contactInfo: event.contactInfo,
    ));
    
    result.fold(
      (failure) => emit(LostPetError(message: failure.message)),
      (_) => add(const LoadReports()),
    );
  }
}
