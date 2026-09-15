import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/device_location_datasource.dart';
import '../../domain/usecases/create_sighting_usecase.dart';
import '../../domain/usecases/get_current_position_usecase.dart';
import '../../domain/usecases/get_report_sightings_usecase.dart';
import 'sighting_event.dart';
import 'sighting_state.dart';

class SightingBloc extends Bloc<SightingEvent, SightingState> {
  final GetCurrentPositionUseCase getCurrentPosition;
  final CreateSightingUseCase createSighting;
  final GetReportSightingsUseCase getReportSightings;
  SightingBloc({
    required this.getCurrentPosition,
    required this.createSighting,
    required this.getReportSightings,
  }) : super(const SightingInitial()) {
    on<LoadReportSightings>((event, emit) async {
      emit(const SightingsLoading());
      final result = await getReportSightings(event.reportId);
      result.fold(
        (failure) =>
            emit(SightingFailure(failure.message, SightingFailureKind.list)),
        (items) => emit(SightingsLoaded(items)),
      );
    });
    on<GetDeviceLocation>((event, emit) async {
      emit(const SightingLocationLoading());
      try {
        emit(SightingLocationReady(await getCurrentPosition()));
      } on DeviceLocationException catch (error) {
        emit(SightingFailure(error.message, SightingFailureKind.location));
      }
    });
    on<ConfirmSighting>((event, emit) async {
      if (state is SightingSubmitting || state is SightingCreated) return;
      emit(const SightingSubmitting());
      final draft = event.draft;
      final result = await createSighting(
        reportId: draft.report.id,
        latitude: draft.latitude!,
        longitude: draft.longitude!,
        locationDescription: draft.locationDescription,
        sightingDateTime: draft.sightingDateTime!,
        description: draft.description,
        photoBytes: draft.photo?.bytes,
        photoName: draft.photo?.name,
      );
      result.fold(
        (failure) =>
            emit(SightingFailure(failure.message, SightingFailureKind.create)),
        (sighting) => emit(SightingCreated(sighting)),
      );
    });
  }
}
