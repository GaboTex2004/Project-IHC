import '../../../lost_pets/domain/entities/lost_pet_report.dart';
import '../../../lost_pets/presentation/models/report_form_data.dart';

class SightingDraft {
  final LostPetReport report;
  double? latitude;
  double? longitude;
  String locationDescription = '';
  DateTime? sightingDateTime;
  String description = '';
  ReportPhoto? photo;

  SightingDraft(this.report);
}
