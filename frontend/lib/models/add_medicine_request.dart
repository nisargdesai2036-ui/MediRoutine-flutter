import 'medicine_request.dart';
import 'medicine_schedule_request.dart';

class AddMedicineRequest {
  final MedicineRequest medicine;
  final MedicineScheduleRequest schedule;

  AddMedicineRequest({
    required this.medicine,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine.toJson(),
      'schedule': schedule.toJson(),
    };
  }
}