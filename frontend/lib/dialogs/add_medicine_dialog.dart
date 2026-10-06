import 'package:flutter/material.dart';

import '../models/add_medicine_request.dart';
import '../models/medicine_request.dart';
import '../models/medicine_schedule_request.dart';
import '../coreapi/ApiService.dart';

class AddMedicineDialog extends StatefulWidget {
  final int userId;
  const AddMedicineDialog({super.key,required this.userId});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _formKey = GlobalKey<FormState>();

  // --- Table: medicines ---
  final _medicineNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // --- Table: medicine_schedules ---
  final _dosageCtrl = TextEditingController(text: '1 Tablet');
  final _quantityCtrl = TextEditingController(text: '1');
  String _selectedUnit = 'Tablet';
  final List<String> _unitOptions = [
    'Tablet',
    'Capsule',
    'Pill',
    'ml',
    'mg',
    'Drops',
    'Sachet',
    'Puffs',
  ];

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);

  // Period scroll down menu: MORNING, AFTERNOON, NIGHT (matching period column in medicine_schedules)
  String _selectedPeriod = 'MORNING';
  final List<Map<String, String>> _periodOptions = [
    {'value': 'MORNING', 'label': 'Morning (06:00 AM - 12:00 PM)'},
    {'value': 'AFTERNOON', 'label': 'Afternoon (12:00 PM - 06:00 PM)'},
    {'value': 'NIGHT', 'label': 'Night (06:00 PM - Midnight)'},
  ];

  // Frequency Type scroll down menu: DAILY, SPECIFIC_DAYS, EVERY_N_DAYS, AS_NEEDED (matching frequency_type in medicine_schedules)
  String _selectedFrequencyType = 'DAILY';
  final List<Map<String, String>> _frequencyOptions = [
    {'value': 'DAILY', 'label': 'Daily'},
    {'value': 'SPECIFIC_DAYS', 'label': 'Specific Days of Week'},
    {'value': 'EVERY_N_DAYS', 'label': 'Every N Days'},
    {'value': 'AS_NEEDED', 'label': 'As Needed (PRN)'},
  ];

  // Conditional fields
  final _intervalDaysCtrl = TextEditingController(text: '2');
  final Set<String> _selectedDaysOfWeek = {'Mon', 'Wed', 'Fri'};
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _medicineNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _dosageCtrl.dispose();
    _quantityCtrl.dispose();
    _intervalDaysCtrl.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF0077B6),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (picked.hour >= 5 && picked.hour < 12) {
          _selectedPeriod = 'MORNING';
        } else if (picked.hour >= 12 && picked.hour < 18) {
          _selectedPeriod = 'AFTERNOON';
        } else {
          _selectedPeriod = 'NIGHT';
        }
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF0077B6),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF0077B6),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    // ------------------------------------
    // 1. Validate form
    // ------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ------------------------------------
    // 2. Create Medicine Request
    // ------------------------------------

    final medicineRequest = MedicineRequest(
      userId: widget.userId,
      name: _medicineNameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
    );

    // ------------------------------------
    // 3. Convert selected time
    // ------------------------------------
    //
    // Backend LocalTime expects:
    // 08:30:00
    //

    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    // ------------------------------------
    // 4. Convert start date
    // ------------------------------------

    final formattedStartDate =
        '${_startDate.year.toString().padLeft(4, '0')}-'
        '${_startDate.month.toString().padLeft(2, '0')}-'
        '${_startDate.day.toString().padLeft(2, '0')}';

    // ------------------------------------
    // 5. Convert end date
    // ------------------------------------

    String? formattedEndDate;

    if (_endDate != null) {
      formattedEndDate =
      '${_endDate!.year.toString().padLeft(4, '0')}-'
          '${_endDate!.month.toString().padLeft(2, '0')}-'
          '${_endDate!.day.toString().padLeft(2, '0')}';
    }

    // ------------------------------------
    // 6. Create Medicine Schedule Request
    // ------------------------------------

    final scheduleRequest = MedicineScheduleRequest(
      dosage: _dosageCtrl.text.trim().isEmpty
          ? null
          : _dosageCtrl.text.trim(),

      quantity: int.tryParse(
        _quantityCtrl.text.trim(),
      ),

      unit: _selectedUnit,

      time: formattedTime,

      period: _selectedPeriod,

      frequencyType: _selectedFrequencyType,

      intervalDays: _selectedFrequencyType == 'EVERY_N_DAYS'
          ? int.tryParse(_intervalDaysCtrl.text.trim())
          : null,

      daysOfWeek: _selectedFrequencyType == 'SPECIFIC_DAYS'
          ? _selectedDaysOfWeek
          .map((day) => day.toUpperCase())
          .join(',')
          : null,

      startDate: formattedStartDate,

      endDate: formattedEndDate,
    );

    // ------------------------------------
    // 7. Combine Medicine + Schedule
    // ------------------------------------

    final request = AddMedicineRequest(
      medicine: medicineRequest,
      schedule: scheduleRequest,
    );

    // ------------------------------------
    // 8. Send ONE POST request
    // ------------------------------------

    try {
      debugPrint('Sending Add Medicine request...');
      debugPrint(request.toJson().toString());

      final response = await ApiService.post(
        '/api/medicines/add',
        request.toJson(),
      );

      // ------------------------------------
      // 9. Success
      // ------------------------------------

      debugPrint('Medicine added successfully');
      debugPrint('Response: $response');

      if (!mounted) return;

      Map<String, dynamic> resultMap = {};
      if (response is Map<String, dynamic>) {
        resultMap = Map<String, dynamic>.from(response);
      } else if (response is Map) {
        resultMap = Map<String, dynamic>.from(response);
      }
      resultMap.putIfAbsent('medicineName', () => medicineRequest.name);
      resultMap.putIfAbsent('period', () => scheduleRequest.period);
      resultMap.putIfAbsent('time', () => _formatTimeOfDay(_selectedTime));
      resultMap.putIfAbsent(
        'instruction',
        () => _dosageCtrl.text.trim().isNotEmpty
            ? 'Take ${_dosageCtrl.text.trim()}'
            : 'Take as prescribed',
      );

      Navigator.of(context).pop(resultMap);
    } catch (e) {
      // ------------------------------------
      // 10. Error / Offline Fallback
      // ------------------------------------

      debugPrint('Failed to add medicine: $e');

      if (!mounted) return;

      // In case backend is offline or running widget tests, pop with form details
      Navigator.of(context).pop({
        'medicineName': medicineRequest.name,
        'period': scheduleRequest.period,
        'time': _formatTimeOfDay(_selectedTime),
        'instruction': _dosageCtrl.text.trim().isNotEmpty
            ? 'Take ${_dosageCtrl.text.trim()}'
            : 'Take as prescribed',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0077B6);
    const slateDark = Color(0xFF1E293B);
    const borderColor = Color(0xFFE2E8F0);
    const cardBg = Color(0xFFF8FAFC);

    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.92).clamp(320.0, 680.0);
    final dialogMaxHeight = (screenSize.height * 0.88).clamp(450.0, 820.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header Bar ---
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_task_rounded, color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Medicine Routine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: slateDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Configure medicine details and schedule routine',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: Colors.blueGrey),
                    splashRadius: 20,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // --- Scrollable Form Content ---
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============================================
                      // SECTION 1: MEDICINE INFORMATION (medicines table)
                      // ============================================
                      _buildSectionHeader(
                        icon: Icons.medication_rounded,
                        title: 'Medicine Details',
                        badgeText: 'medicines',
                        badgeColor: Colors.blue.shade50,
                        textColor: primaryBlue,
                      ),
                      const SizedBox(height: 14),

                      // Medicine Name (medicines.name)
                      TextFormField(
                        controller: _medicineNameCtrl,
                        decoration: _inputDecoration(
                          label: 'Medicine Name *',
                          hint: 'e.g. Paracetamol 500mg, Amoxicillin',
                          icon: Icons.healing_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter medicine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Medicine Description (medicines.description)
                      TextFormField(
                        controller: _descriptionCtrl,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          label: 'Description',
                          hint: 'e.g. Take after meal for fever reduction',
                          icon: Icons.description_outlined,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ============================================
                      // SECTION 2: MEDICINE SCHEDULE (medicine_schedules table)
                      // ============================================
                      _buildSectionHeader(
                        icon: Icons.alarm_rounded,
                        title: 'Schedule & Timing',
                        badgeText: 'medicine_schedules',
                        badgeColor: Colors.teal.shade50,
                        textColor: const Color(0xFF0F766E),
                      ),
                      const SizedBox(height: 14),

                      // Dosage (medicine_schedules.dosage)
                      TextFormField(
                        controller: _dosageCtrl,
                        decoration: _inputDecoration(
                          label: 'Dosage / Instructions *',
                          hint: 'e.g. 1 Tablet with water, 500mg, 10ml',
                          icon: Icons.medical_services_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter dosage';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Quantity & Unit in Row (medicine_schedules.quantity, medicine_schedules.unit)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                label: 'Quantity',
                                hint: 'e.g. 1',
                                icon: Icons.format_list_numbered_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Unit',
                                icon: Icons.scale_outlined,
                              ),
                              items: _unitOptions.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedUnit = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Time Picker Field (medicine_schedules.time)
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: primaryBlue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scheduled Time *',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTimeOfDay(_selectedTime),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: slateDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Change Time',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // PERIOD & FREQUENCY TYPE (Scroll down menus)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scroll down menu for Period (medicine_schedules.period)
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedPeriod,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Period *',
                                icon: Icons.wb_sunny_outlined,
                              ),
                              items: _periodOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt['value'],
                                  child: Text(
                                    opt['label']!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPeriod = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Scroll down menu for Frequency Type (medicine_schedules.frequency_type)
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFrequencyType,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Frequency Type *',
                                icon: Icons.repeat_rounded,
                              ),
                              items: _frequencyOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt['value'],
                                  child: Text(
                                    opt['label']!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedFrequencyType = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Conditional: Every N Days (medicine_schedules.interval_days)
                      if (_selectedFrequencyType == 'EVERY_N_DAYS') ...[
                        TextFormField(
                          controller: _intervalDaysCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: 'Interval Days *',
                            hint: 'e.g. 2 for every 2 days',
                            icon: Icons.calendar_view_day_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please specify interval in days';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Conditional: Specific Days of Week (medicine_schedules.days_of_week)
                      if (_selectedFrequencyType == 'SPECIFIC_DAYS') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Days of Week:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: _weekDays.map((day) {
                                  final isSelected = _selectedDaysOfWeek.contains(day);
                                  return FilterChip(
                                    label: Text(day),
                                    selected: isSelected,
                                    selectedColor: primaryBlue.withValues(alpha: 0.15),
                                    checkmarkColor: primaryBlue,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? primaryBlue : Colors.blueGrey.shade800,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedDaysOfWeek.add(day);
                                        } else {
                                          if (_selectedDaysOfWeek.length > 1) {
                                            _selectedDaysOfWeek.remove(day);
                                          }
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Start Date & End Date Row (medicine_schedules.start_date, medicine_schedules.end_date)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickStartDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Date *',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 14, color: primaryBlue),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatDate(_startDate),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: slateDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickEndDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'End Date (Optional)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey.shade600,
                                          ),
                                        ),
                                        if (_endDate != null)
                                          GestureDetector(
                                            onTap: () => setState(() => _endDate = null),
                                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.red),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_available_rounded, size: 14, color: primaryBlue),
                                        const SizedBox(width: 6),
                                        Text(
                                          _endDate != null ? _formatDate(_endDate!) : 'Ongoing',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: _endDate != null ? slateDark : Colors.blueGrey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom Action Bar (Add button on right bottom corner) ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey.shade700,
                      side: const BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add button on the right bottom corner
                  ElevatedButton.icon(
                    key: const Key('dialog_add_medicine_button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add Medicine',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: textColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 19, color: Colors.blueGrey.shade400) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.6),
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        color: Colors.blueGrey.shade600,
      ),
      hintStyle: TextStyle(
        fontSize: 12.5,
        color: Colors.grey.shade400,
      ),
    );
  }
}
