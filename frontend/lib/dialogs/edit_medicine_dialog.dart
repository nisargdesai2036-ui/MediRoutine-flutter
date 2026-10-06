import 'package:flutter/material.dart';
import '../coreapi/ApiService.dart';
import '../Sessions/UserSession.dart';

class EditMedicineDialog extends StatefulWidget {
  final Map<String, dynamic> routine;

  const EditMedicineDialog({super.key, required this.routine});

  @override
  State<EditMedicineDialog> createState() => _EditMedicineDialogState();
}

class _EditMedicineDialogState extends State<EditMedicineDialog> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // MEDICINE TABLE
  // ============================================================

  late final TextEditingController _medicineNameCtrl;
  late final TextEditingController _descriptionCtrl;

  // ============================================================
  // MEDICINE SCHEDULE TABLE
  // ============================================================

  late final TextEditingController _dosageCtrl;
  late final TextEditingController _quantityCtrl;
  late String _selectedUnit;

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

  late TimeOfDay _selectedTime;

  late String _selectedPeriod;

  final List<Map<String, String>> _periodOptions = [
    {'value': 'MORNING', 'label': 'Morning (06:00 AM - 12:00 PM)'},
    {'value': 'AFTERNOON', 'label': 'Afternoon (12:00 PM - 06:00 PM)'},
    {'value': 'NIGHT', 'label': 'Night (06:00 PM - Midnight)'},
  ];

  late String _selectedFrequencyType;

  final List<Map<String, String>> _frequencyOptions = [
    {'value': 'DAILY', 'label': 'Daily'},
    {'value': 'SPECIFIC_DAYS', 'label': 'Specific Days of Week'},
    {'value': 'EVERY_N_DAYS', 'label': 'Every N Days'},
    {'value': 'AS_NEEDED', 'label': 'As Needed (PRN)'},
  ];

  late final TextEditingController _intervalDaysCtrl;

  late Set<String> _selectedDaysOfWeek;

  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late DateTime _startDate;
  DateTime? _endDate;

  // ============================================================
  // DATABASE IDs
  // ============================================================

  int? _userId;
  int? _medicineId;
  int? _scheduleId;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _medicineNameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _dosageCtrl = TextEditingController();
    _quantityCtrl = TextEditingController();
    _intervalDaysCtrl = TextEditingController();

    _selectedUnit = 'Tablet';
    _selectedPeriod = 'MORNING';
    _selectedFrequencyType = 'DAILY';

    _selectedDaysOfWeek = {'Mon', 'Wed', 'Fri'};

    _selectedTime = const TimeOfDay(hour: 8, minute: 30);

    _startDate = DateTime.now();
    _endDate = null;

    _initializeDialog();
  }

  // ============================================================
  // INITIALIZE DIALOG
  // ============================================================

  Future<void> _initializeDialog() async {
    try {
      /*
       * User ID:
       *
       * First try routine['userId']
       * Then try UserSession.userid
       */
      _userId = _parseInt(
        widget.routine['userId'] ??
            widget.routine['user_id'] ??
            UserSession.userid,
      );

      /*
       * Medicine ID:
       *
       * We need medicineId because:
       *
       * medicine.id == medicine_schedule.medicineId
       */
      _medicineId = _parseInt(
        widget.routine['medicineId'] ??
            widget.routine['medicine_id'] ??
            widget.routine['id'],
      );

      if (_userId == null) {
        throw Exception('User ID not found.');
      }

      if (_medicineId == null) {
        throw Exception('Medicine ID not found.');
      }

      debugPrint('Edit dialog userId = $_userId');

      debugPrint('Edit dialog medicineId = $_medicineId');

      // ========================================================
      // GET MEDICINES
      // ========================================================

      final medicineResponse = await ApiService.get(
        '/api/medicines/user/$_userId',
      );

      // ========================================================
      // GET SCHEDULES
      // ========================================================

      final scheduleResponse = await ApiService.get(
        '/api/schedules/user/$_userId',
      );

      // ========================================================
      // FIND MEDICINE
      // ========================================================

      final medicine = _findMedicine(medicineResponse, _medicineId!, _userId!);

      if (medicine == null) {
        throw Exception('Medicine not found for this user.');
      }

      /*
       * Important:
       *
       * medicine_schedule.medicineId
       * must match
       *
       * medicine.id
       */
      final actualMedicineId = _parseInt(
        medicine['id'] ?? medicine['medicineId'],
      );

      if (actualMedicineId == null) {
        throw Exception('Medicine ID is missing from database response.');
      }

      _medicineId = actualMedicineId;

      // ========================================================
      // FIND MEDICINE SCHEDULE
      // ========================================================

      final schedule = _findSchedule(scheduleResponse, _medicineId!, _userId!);

      if (schedule == null) {
        throw Exception('Medicine schedule not found for this medicine.');
      }

      _scheduleId = _parseInt(schedule['id'] ?? schedule['scheduleId']);

      if (_scheduleId == null) {
        throw Exception('Schedule ID is missing from database response.');
      }

      debugPrint('Found medicine ID = $_medicineId');

      debugPrint('Found schedule ID = $_scheduleId');

      // ========================================================
      // POPULATE MEDICINE DATA
      // ========================================================

      _medicineNameCtrl.text =
          (medicine['name'] ?? medicine['medicineName'] ?? '').toString();

      _descriptionCtrl.text =
          (medicine['description'] ??
                  medicine['instruction'] ??
                  medicine['instructions'] ??
                  '')
              .toString();

      // ========================================================
      // POPULATE SCHEDULE DATA
      // ========================================================

      _dosageCtrl.text = (schedule['dosage'] ?? medicine['dosage'] ?? '1')
          .toString();

      _quantityCtrl.text = (schedule['quantity'] ?? medicine['quantity'] ?? '1')
          .toString();

      final unit = (schedule['unit'] ?? medicine['unit'])?.toString();

      _selectedUnit = _unitOptions.contains(unit) ? unit! : 'Tablet';

      _selectedPeriod = (schedule['period'] ?? 'MORNING')
          .toString()
          .toUpperCase();

      if (!_periodOptions.any((p) => p['value'] == _selectedPeriod)) {
        _selectedPeriod = 'MORNING';
      }

      _selectedFrequencyType = (schedule['frequencyType'] ?? 'DAILY')
          .toString()
          .toUpperCase();

      if (!_frequencyOptions.any((f) => f['value'] == _selectedFrequencyType)) {
        _selectedFrequencyType = 'DAILY';
      }

      _intervalDaysCtrl.text = (schedule['intervalDays'] ?? '2').toString();

      // ========================================================
      // DAYS OF WEEK
      // ========================================================

      _selectedDaysOfWeek = {'Mon', 'Wed', 'Fri'};

      final daysOfWeek = schedule['daysOfWeek'];

      if (daysOfWeek != null && daysOfWeek.toString().trim().isNotEmpty) {
        final days = daysOfWeek.toString().split(',');

        final mapped = days
            .map((day) {
              final clean = day.trim().toLowerCase();

              if (clean.startsWith('mon')) {
                return 'Mon';
              }

              if (clean.startsWith('tue')) {
                return 'Tue';
              }

              if (clean.startsWith('wed')) {
                return 'Wed';
              }

              if (clean.startsWith('thu')) {
                return 'Thu';
              }

              if (clean.startsWith('fri')) {
                return 'Fri';
              }

              if (clean.startsWith('sat')) {
                return 'Sat';
              }

              if (clean.startsWith('sun')) {
                return 'Sun';
              }

              return null;
            })
            .whereType<String>()
            .toSet();

        if (mapped.isNotEmpty) {
          _selectedDaysOfWeek = mapped;
        }
      }

      // ========================================================
      // TIME
      // ========================================================

      _selectedTime = _parseTimeOfDay(
        (schedule['time'] ?? '08:30 AM').toString(),
      );

      // ========================================================
      // START DATE
      // ========================================================

      final startDate = schedule['startDate'];

      if (startDate != null && startDate.toString().trim().isNotEmpty) {
        try {
          _startDate = DateTime.parse(startDate.toString());
        } catch (_) {
          _startDate = DateTime.now();
        }
      }

      // ========================================================
      // END DATE
      // ========================================================

      final endDate = schedule['endDate'];

      if (endDate != null && endDate.toString().trim().isNotEmpty) {
        try {
          _endDate = DateTime.parse(endDate.toString());
        } catch (_) {
          _endDate = null;
        }
      }

      // ========================================================
      // FINISHED LOADING
      // ========================================================

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading medicine details: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ============================================================
  // FIND MEDICINE
  // ============================================================

  Map<String, dynamic>? _findMedicine(
    dynamic response,
    int medicineId,
    int userId,
  ) {
    if (response is! List) {
      return null;
    }

    for (final item in response) {
      if (item is! Map) {
        continue;
      }

      final medicine = Map<String, dynamic>.from(item);

      final id = _parseInt(medicine['id'] ?? medicine['medicineId']);

      final medicineUserId = _parseInt(
        medicine['userId'] ?? medicine['user_id'] ?? medicine['user']?['id'],
      );

      /*
       * Unique identification:
       *
       * userId FK
       * +
       * medicineId
       */
      if (id == medicineId && medicineUserId == userId) {
        return medicine;
      }
    }

    return null;
  }

  // ============================================================
  // FIND SCHEDULE
  // ============================================================

  Map<String, dynamic>? _findSchedule(
    dynamic response,
    int medicineId,
    int userId,
  ) {
    if (response is! List) {
      return null;
    }

    for (final item in response) {
      if (item is! Map) {
        continue;
      }

      final schedule = Map<String, dynamic>.from(item);

      final scheduleMedicineId = _parseInt(
        schedule['medicineId'] ??
            schedule['medicine_id'] ??
            schedule['medicine']?['id'],
      );

      final scheduleUserId = _parseInt(
        schedule['userId'] ?? schedule['user_id'] ?? schedule['user']?['id'],
      );

      /*
       * Main relationship:
       *
       * medicine_schedule.medicineId
       * ==
       * medicine.id
       *
       * We also verify userId when it is
       * available in the schedule response.
       */
      final medicineMatches = scheduleMedicineId == medicineId;

      final userMatches = scheduleUserId == null || scheduleUserId == userId;

      if (medicineMatches && userMatches) {
        return schedule;
      }
    }

    return null;
  }

  // ============================================================
  // INTEGER PARSER
  // ============================================================

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  // ============================================================
  // TIME PARSER
  // ============================================================

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final trimmed = timeStr.trim().toUpperCase();

      final isPm = trimmed.contains('PM');

      final clean = trimmed.replaceAll(RegExp(r'[AP]M'), '').trim();

      final parts = clean.split(':');

      int hour = int.parse(parts[0].trim());

      final minute = parts.length > 1 ? int.parse(parts[1].trim()) : 0;

      if (isPm && hour < 12) {
        hour += 12;
      }

      if (!isPm && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 30);
    }
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '${hour.toString().padLeft(2, '0')}:'
        '$minute $period';
  }

  // ============================================================
  // DATE FORMAT FOR API
  // ============================================================

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // DISPLAY DATE
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

  // ============================================================
  // START DATE
  // ============================================================

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

  // ============================================================
  // END DATE
  // ============================================================

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _handleSave() async {
    //_isLoading==true  means helps some saving is happeing
    //is_Loading==false means u can make request all request are clear
    if (_isLoading) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_medicineId == null) {
      _showError('Medicine ID is missing.');
      return;
    }

    if (_scheduleId == null) {
      _showError('Schedule ID is missing.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedName = _medicineNameCtrl.text.trim();

      final updatedDescription = _descriptionCtrl.text.trim();

      final updatedDosage = _dosageCtrl.text.trim();

      final updatedQuantity = int.tryParse(_quantityCtrl.text.trim()) ?? 1;

      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final formattedStartDate = _formatDateForApi(_startDate);

      String? formattedEndDate;

      if (_endDate != null) {
        formattedEndDate = _formatDateForApi(_endDate!);
      }

      // ========================================================
      // MEDICINE PATCH
      // ========================================================

      final medicinePatch = {
        'name': updatedName,
        'description': updatedDescription,
      };

      debugPrint('PATCH medicine $_medicineId');

      debugPrint('Medicine body: $medicinePatch');

      await ApiService.patch(
        '/api/medicines/update/$_medicineId',
        medicinePatch,
      );

      // ========================================================
      // SCHEDULE PATCH
      // ========================================================

      final schedulePatch = {
        'medicineId': _medicineId,
        'time': formattedTime,
        'period': _selectedPeriod,
        'frequencyType': _selectedFrequencyType,
        'intervalDays': _selectedFrequencyType == 'EVERY_N_DAYS'
            ? int.tryParse(_intervalDaysCtrl.text.trim())
            : null,
        'daysOfWeek': _selectedFrequencyType == 'SPECIFIC_DAYS'
            ? _selectedDaysOfWeek.map((day) => day.toUpperCase()).join(',')
            : null,
        'startDate': formattedStartDate,
        'endDate': formattedEndDate,
        'dosage': updatedDosage,
        'quantity': updatedQuantity,
        'unit': _selectedUnit,
        'instructions': updatedDescription,
        'description': updatedDescription,
      };

      debugPrint('PATCH schedule $_scheduleId');

      debugPrint('Schedule body: $schedulePatch');

      await ApiService.patch(
        '/api/schedules/update/$_scheduleId',
        schedulePatch,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );

      /*
       * Return true.
       *
       * ClientDashboard will receive this
       * and call _loadMedicines().
       */
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Error saving medicine: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $_errorMessage')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    const borderColor = Color(0xFFE2E8F0);

    const cardBg = Color(0xFFF8FAFC);

    const primaryBlue = Color(0xFF0077B6);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: primaryBlue)
          : null,
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.8),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: textColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0077B6);

    const slateDark = Color(0xFF1E293B);

    const borderColor = Color(0xFFE2E8F0);

    const cardBg = Color(0xFFF8FAFC);

    final screenSize = MediaQuery.of(context).size;

    final dialogWidth = (screenSize.width * 0.92).clamp(320.0, 680.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: screenSize.height * 0.90,
        ),
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Medicine Routine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: slateDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Update medicine details and schedule routine',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // ====================================================
            // LOADING
            // ====================================================
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // ====================================================
            // ERROR
            // ====================================================
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeDialog,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // ====================================================
            // FORM
            // ====================================================
            else
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // MEDICINE
                        // ==================================================
                        _buildSectionHeader(
                          icon: Icons.medication_rounded,
                          title: 'Medicine Details',
                          badgeText: 'medicines',
                          badgeColor: Colors.blue.shade50,
                          textColor: primaryBlue,
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _medicineNameCtrl,
                          decoration: _inputDecoration(
                            label: 'Medicine Name *',
                            icon: Icons.healing_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter medicine name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _descriptionCtrl,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            label: 'Description',
                            icon: Icons.description_outlined,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // SCHEDULE
                        // ==================================================
                        _buildSectionHeader(
                          icon: Icons.alarm_rounded,
                          title: 'Schedule & Timing',
                          badgeText: 'medicine_schedules',
                          badgeColor: Colors.teal.shade50,
                          textColor: const Color(0xFF0F766E),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _dosageCtrl,
                          decoration: _inputDecoration(
                            label: 'Dosage / Instructions *',
                            icon: Icons.medical_services_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  label: 'Quantity',
                                  icon: Icons.format_list_numbered_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                isExpanded: true,
                                decoration: _inputDecoration(
                                  label: 'Unit',
                                  icon: Icons.scale_outlined,
                                ),
                                items: _unitOptions
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedUnit = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        InkWell(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: primaryBlue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Scheduled Time',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      Text(
                                        _formatTimeOfDay(_selectedTime),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Change Time',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedPeriod,
                                isExpanded: true,
                                decoration: _inputDecoration(
                                  label: 'Period',
                                  icon: Icons.wb_sunny_outlined,
                                ),
                                items: _periodOptions
                                    .map(
                                      (option) => DropdownMenuItem(
                                        value: option['value'],
                                        child: Text(
                                          option['label']!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedPeriod = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedFrequencyType,
                                isExpanded: true,
                                decoration: _inputDecoration(
                                  label: 'Frequency',
                                  icon: Icons.repeat_rounded,
                                ),
                                items: _frequencyOptions
                                    .map(
                                      (option) => DropdownMenuItem(
                                        value: option['value'],
                                        child: Text(
                                          option['label']!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _selectedFrequencyType = value,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (_selectedFrequencyType == 'EVERY_N_DAYS')
                          TextFormField(
                            controller: _intervalDaysCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              label: 'Interval Days',
                              icon: Icons.calendar_view_day_rounded,
                            ),
                          ),

                        if (_selectedFrequencyType == 'SPECIFIC_DAYS')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Wrap(
                              spacing: 8,
                              children: _weekDays.map((day) {
                                final selected = _selectedDaysOfWeek.contains(
                                  day,
                                );

                                return FilterChip(
                                  label: Text(day),
                                  selected: selected,
                                  onSelected: (value) {
                                    setState(() {
                                      if (value) {
                                        _selectedDaysOfWeek.add(day);
                                      } else if (_selectedDaysOfWeek.length >
                                          1) {
                                        _selectedDaysOfWeek.remove(day);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickStartDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Start Date'),
                                      const SizedBox(height: 4),
                                      Text(_formatDate(_startDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _pickEndDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('End Date'),
                                      const SizedBox(height: 4),
                                      Text(
                                        _endDate != null
                                            ? _formatDate(_endDate!)
                                            : 'Ongoing',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ====================================================
            // FOOTER
            // ====================================================
            if (!_isLoading && _errorMessage == null)
              Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
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

  @override
  void dispose() {
    _medicineNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _dosageCtrl.dispose();
    _quantityCtrl.dispose();
    _intervalDaysCtrl.dispose();

    super.dispose();
  }
}
