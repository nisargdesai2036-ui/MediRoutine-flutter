class MedicineScheduleRequest {
  final String? dosage;
  final int? quantity;
  final String? unit;
  final String time;
  final String period;
  final String frequencyType;
  final int? intervalDays;
  final String? daysOfWeek;
  final String startDate;
  final String? endDate;

  MedicineScheduleRequest({
    this.dosage,
    this.quantity,
    this.unit,
    required this.time,
    required this.period,
    required this.frequencyType,  //same property name as in springboot
    this.intervalDays,
    this.daysOfWeek,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'dosage': dosage,
      'quantity': quantity,
      'unit': unit,
      'time': time,
      'period': period,
      'frequencyType': frequencyType,
      'intervalDays': intervalDays,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}