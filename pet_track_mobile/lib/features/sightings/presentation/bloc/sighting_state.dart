import 'package:equatable/equatable.dart';
import '../../domain/entities/device_position.dart';
import '../../domain/entities/sighting.dart';

abstract class SightingState extends Equatable {
  const SightingState();
  @override
  List<Object> get props => [];
}

class SightingInitial extends SightingState {
  const SightingInitial();
}

class SightingLocationLoading extends SightingState {
  const SightingLocationLoading();
}

class SightingsLoading extends SightingState {
  const SightingsLoading();
}

class SightingsLoaded extends SightingState {
  final List<Sighting> sightings;
  const SightingsLoaded(this.sightings);
  @override
  List<Object> get props => [sightings];
}

class SightingLocationReady extends SightingState {
  final DevicePosition position;
  const SightingLocationReady(this.position);
  @override
  List<Object> get props => [position];
}

class SightingSubmitting extends SightingState {
  const SightingSubmitting();
}

class SightingCreated extends SightingState {
  final Sighting sighting;
  const SightingCreated(this.sighting);
  @override
  List<Object> get props => [sighting];
}

class SightingFailure extends SightingState {
  final String message;
  final SightingFailureKind kind;
  const SightingFailure(this.message, this.kind);
  @override
  List<Object> get props => [message, kind];
}

enum SightingFailureKind { location, create, list }
