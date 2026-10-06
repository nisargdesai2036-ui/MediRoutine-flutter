import 'package:flutter/material.dart';
import 'edit_medicine_dialog.dart';

class MedicineDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> routine;

  const MedicineDetailsDialog({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return EditMedicineDialog(routine: routine);
  }
}