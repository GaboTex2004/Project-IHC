import 'package:equatable/equatable.dart';
import '../../domain/entities/lost_pet_report.dart';

abstract class LostPetState extends Equatable {
  const LostPetState();

  @override
  List<Object> get props => [];
}

class LostPetInitial extends LostPetState {
  const LostPetInitial();
}

class LostPetLoading extends LostPetState {
  const LostPetLoading();
}

class LostPetLoaded extends LostPetState {
  final List<LostPetReport> reports;

  const LostPetLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
}

class LostPetError extends LostPetState {
  final String message;

  const LostPetError({required this.message});

  @override
  List<Object> get props => [message];
}
