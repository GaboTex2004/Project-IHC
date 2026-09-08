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

class LostPetDetailLoading extends LostPetState {
  const LostPetDetailLoading();
}

class LostPetDetailLoaded extends LostPetState {
  final LostPetReport report;

  const LostPetDetailLoaded({required this.report});

  @override
  List<Object> get props => [report];
}

class LostPetDetailNotFound extends LostPetState {
  final String message;

  const LostPetDetailNotFound({required this.message});

  @override
  List<Object> get props => [message];
}

class MyReportsLoading extends LostPetState {
  const MyReportsLoading();
}

class MyReportsLoaded extends LostPetState {
  final List<LostPetReport> reports;

  const MyReportsLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
}

class MyReportsUpdating extends LostPetState {
  final List<LostPetReport> reports;
  final int reportId;

  const MyReportsUpdating({required this.reports, required this.reportId});

  @override
  List<Object> get props => [reports, reportId];
}

class LostPetCreated extends LostPetState {
  final LostPetReport report;

  const LostPetCreated({required this.report});

  @override
  List<Object> get props => [report];
}

class LostPetError extends LostPetState {
  final String message;

  const LostPetError({required this.message});

  @override
  List<Object> get props => [message];
}
