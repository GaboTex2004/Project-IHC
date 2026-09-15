import 'package:equatable/equatable.dart';
import '../models/sighting_draft.dart';

abstract class SightingEvent extends Equatable {
  const SightingEvent();
  @override
  List<Object> get props => [];
}

class GetDeviceLocation extends SightingEvent {
  const GetDeviceLocation();
}

class LoadReportSightings extends SightingEvent {
  final int reportId;
  const LoadReportSightings(this.reportId);
  @override
  List<Object> get props => [reportId];
}

class ConfirmSighting extends SightingEvent {
  final SightingDraft draft;
  const ConfirmSighting(this.draft);
  @override
  List<Object> get props => [draft];
}
