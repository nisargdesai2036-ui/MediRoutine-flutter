class MedicineLog {
  final int id;
  final DateTime scheduledDate;
  final String scheduledTime;
  final DateTime? actionTime;
  final String status;

  MedicineLog({
    required this.id,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.actionTime,
    required this.status,
  });

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: (json['id'] as num).toInt(),

      scheduledDate: DateTime.parse(json['scheduledDate'].toString()),

      scheduledTime: json['scheduledTime'].toString(),

      actionTime: json['actionTime'] != null
          ? DateTime.parse(json['actionTime'].toString())
          : null,

      status: json['status'].toString().toUpperCase(),
    );
  }
}
