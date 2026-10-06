class MedicineRequest {
  final int userId;
  final String name;
  final String? description;

  MedicineRequest({
    required this.userId,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
    };
  }
}