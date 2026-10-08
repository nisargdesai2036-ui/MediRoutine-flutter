import 'package:flutter/material.dart';

import 'profile_page.dart';
import '../dialogs/add_medicine_dialog.dart';
import '../dialogs/edit_medicine_dialog.dart';
import '../dialogs/logs_data_dialog.dart';
import '../Sessions/UserSession.dart';
import '../coreapi/ApiService.dart';

class ClientDashboard extends StatefulWidget {
  final int? userId;
  final String clientName;
  final int clientAge;
  final String clientEmail;
  final String clientPassword;

  const ClientDashboard({
    super.key,
    this.userId,
    required this.clientName,
    required this.clientAge,
    this.clientEmail = '',
    this.clientPassword = '',
  });

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final List<Map<String, dynamic>> _routines = [];

  bool _isLoading = false;
  String? _errorMessage;

  final Set<String> _takenKeys = {};

  int? get _currentUserId => widget.userId ?? UserSession.userid;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Future<void> _loadMedicines() async {
    if (_currentUserId == null &&
        (widget.clientEmail.isNotEmpty || UserSession.email != null)) {
      final emailToLookup = widget.clientEmail.isNotEmpty
          ? widget.clientEmail
          : UserSession.email!;

      try {
        final encodedEmail = Uri.encodeComponent(emailToLookup);

        final userData = await ApiService.get('/api/users/email/$encodedEmail');

        final userMap = _toMap(userData);

        if (userMap != null && userMap['id'] != null) {
          final parsedId = _toInt(userMap['id']);

          if (parsedId != null) {
            UserSession.userid = parsedId;
          }
        }
      } catch (e) {
        debugPrint('Could not resolve user by email: $e');
      }
    }

    final userId = _currentUserId;

    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID is not available';
        });
      }

      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ============================================================
      // GET MEDICINES
      // ============================================================

      List<dynamic> medicineList = [];

      try {
        final response = await ApiService.get('/api/medicines/user/$userId');

        if (response is List) {
          medicineList = response;
        }

        debugPrint(
          'Medicine API returned '
          '${medicineList.length} medicines',
        );
      } catch (e) {
        debugPrint('Error fetching medicines: $e');
      }

      // ============================================================
      // CREATE MEDICINE MAP
      // ============================================================

      final Map<int, Map<String, dynamic>> medicinesMap = {};

      for (final entry in medicineList) {
        final medicineMap = _toMap(entry);

        if (medicineMap == null) {
          continue;
        }

        final medicineId = _toInt(medicineMap['id']);

        if (medicineId == null) {
          continue;
        }

        medicinesMap[medicineId] = medicineMap;
      }

      // ============================================================
      // GET SCHEDULES
      // ============================================================

      List<dynamic> scheduleList = [];

      try {
        final response = await ApiService.get('/api/schedules/user/$userId');

        if (response is List) {
          scheduleList = response;
        }

        debugPrint(
          'Schedule API returned '
          '${scheduleList.length} schedules',
        );
      } catch (e) {
        debugPrint('Error fetching schedules: $e');
      }

      // ============================================================
      // PARSED ROUTINES
      // ============================================================

      final List<Map<String, dynamic>> parsedRoutines = [];

      // ============================================================
      // PARSE SCHEDULES
      // ============================================================

      for (final entry in scheduleList) {
        final scheduleMap = _toMap(entry);

        if (scheduleMap == null) {
          continue;
        }

        final scheduleId = _toInt(scheduleMap['id']);

        int? medicineId = _toInt(scheduleMap['medicineId']);

        if (medicineId == null) {
          final medicineObject = _toMap(scheduleMap['medicine']);

          if (medicineObject != null) {
            medicineId = _toInt(medicineObject['id']);
          }
        }

        if (medicineId == null) {
          debugPrint(
            'Skipping schedule because '
            'medicineId is missing: $scheduleMap',
          );

          continue;
        }

        final medicineMap = medicinesMap[medicineId];

        if (medicineMap == null) {
          debugPrint(
            'Medicine $medicineId not found '
            'for schedule $scheduleId',
          );

          continue;
        }

        final medicineName =
            (medicineMap['name'] ?? medicineMap['medicineName'] ?? 'Medicine')
                .toString();

        final medicineDescription = medicineMap['description']?.toString();

        final dosage = scheduleMap['dosage']?.toString();

        final quantity = scheduleMap['quantity'] ?? 1;

        final unit = scheduleMap['unit']?.toString() ?? 'Tablet';

        final timeStr = _formatTime(scheduleMap['time']?.toString());

        final periodStr = scheduleMap['period']?.toString() ?? 'MORNING';

        final frequencyType =
            scheduleMap['frequencyType']?.toString() ?? 'DAILY';

        final intervalDays = scheduleMap['intervalDays'];

        final daysOfWeek = scheduleMap['daysOfWeek']?.toString();

        final startDate = scheduleMap['startDate']?.toString();

        final endDate = scheduleMap['endDate']?.toString();

        String instruction = 'Take as prescribed';

        if (dosage != null && dosage.trim().isNotEmpty) {
          instruction = 'Take $dosage';
        }

        final routineKey = '${medicineId}_${scheduleId ?? ''}_$timeStr';

        final isTaken = _takenKeys.contains(routineKey);

        parsedRoutines.add({
          'userId': userId,

          'id': medicineId,
          'medicineId': medicineId,
          'scheduleId': scheduleId,

          'name': medicineName,
          'description': medicineDescription,

          'dosage': dosage,
          'quantity': quantity,
          'unit': unit,

          'time': timeStr,
          'period': periodStr,
          'frequencyType': frequencyType,
          'intervalDays': intervalDays,
          'daysOfWeek': daysOfWeek,
          'startDate': startDate,
          'endDate': endDate,

          'instruction': instruction,
          'taken': isTaken,
          'routineKey': routineKey,

          'color': _getColorForPeriod(periodStr, timeStr),

          'tag': _getTagForPeriod(periodStr, timeStr),
        });
      }

      // ============================================================
      // FALLBACK
      // ============================================================

      if (parsedRoutines.isEmpty && medicineList.isNotEmpty) {
        for (final entry in medicineList) {
          final medicineMap = _toMap(entry);

          if (medicineMap == null) {
            continue;
          }

          final medicineId = _toInt(medicineMap['id']);

          if (medicineId == null) {
            continue;
          }

          final medicineName =
              (medicineMap['name'] ?? medicineMap['medicineName'] ?? 'Medicine')
                  .toString();

          final medicineDescription = medicineMap['description']?.toString();

          dynamic schedules = medicineMap['schedules'];

          if (schedules is! List) {
            schedules = medicineMap['medicineSchedules'];
          }

          if (schedules is! List) {
            continue;
          }

          for (final scheduleEntry in schedules) {
            final scheduleMap = _toMap(scheduleEntry);

            if (scheduleMap == null) {
              continue;
            }

            final scheduleId = _toInt(scheduleMap['id']);

            final dosage = scheduleMap['dosage']?.toString();

            final quantity = scheduleMap['quantity'] ?? 1;

            final unit = scheduleMap['unit']?.toString() ?? 'Tablet';

            final timeStr = _formatTime(scheduleMap['time']?.toString());

            final periodStr = scheduleMap['period']?.toString() ?? 'MORNING';

            final frequencyType =
                scheduleMap['frequencyType']?.toString() ?? 'DAILY';

            final routineKey = '${medicineId}_${scheduleId ?? ''}_$timeStr';

            final isTaken = _takenKeys.contains(routineKey);

            String instruction = 'Take as prescribed';

            if (dosage != null && dosage.trim().isNotEmpty) {
              instruction = 'Take $dosage';
            }

            parsedRoutines.add({
              'userId': userId,

              'id': medicineId,
              'medicineId': medicineId,
              'scheduleId': scheduleId,

              'name': medicineName,
              'description': medicineDescription,

              'dosage': dosage,
              'quantity': quantity,
              'unit': unit,

              'time': timeStr,
              'period': periodStr,
              'frequencyType': frequencyType,
              'intervalDays': scheduleMap['intervalDays'],
              'daysOfWeek': scheduleMap['daysOfWeek']?.toString(),
              'startDate': scheduleMap['startDate']?.toString(),
              'endDate': scheduleMap['endDate']?.toString(),

              'instruction': instruction,

              'taken': isTaken,

              'routineKey': routineKey,

              'color': _getColorForPeriod(periodStr, timeStr),

              'tag': _getTagForPeriod(periodStr, timeStr),
            });
          }
        }
      }

      // ============================================================
      // SORT ROUTINES
      // ============================================================

      parsedRoutines.sort((a, b) {
        final timeA = _convertTimeToMinutes(a['time']?.toString());

        final timeB = _convertTimeToMinutes(b['time']?.toString());

        return timeA.compareTo(timeB);
      });

      // ============================================================
      // UPDATE UI
      // ============================================================

      if (mounted) {
        setState(() {
          _routines.clear();
          _routines.addAll(parsedRoutines);

          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading medicine dashboard: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;

          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return '08:30 AM';
    }

    final trimmed = timeStr.trim();

    if (trimmed.toUpperCase().contains('AM') ||
        trimmed.toUpperCase().contains('PM')) {
      return trimmed;
    }

    final parts = trimmed.split(':');

    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 8;

      final minute = int.tryParse(parts[1]) ?? 0;

      final period = hour >= 12 ? 'PM' : 'AM';

      final hour12 = hour % 12 == 0 ? 12 : hour % 12;

      return '${hour12.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')} '
          '$period';
    }

    return trimmed;
  }

  // ============================================================
  // CONVERT TIME
  // ============================================================

  int _convertTimeToMinutes(String? time) {
    if (time == null || time.trim().isEmpty) {
      return 0;
    }

    final value = time.trim().toUpperCase();

    try {
      final isPM = value.contains('PM');

      final cleanValue = value.replaceAll('AM', '').replaceAll('PM', '').trim();

      final parts = cleanValue.split(':');

      if (parts.length < 2) {
        return 0;
      }

      int hour = int.tryParse(parts[0]) ?? 0;

      final minute = int.tryParse(parts[1]) ?? 0;

      if (isPM && hour != 12) {
        hour += 12;
      }

      if (!isPM && value.contains('AM') && hour == 12) {
        hour = 0;
      }

      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  // ============================================================
  // COLOR
  // ============================================================

  int _getColorForPeriod(String period, String timeStr) {
    final p = period.toUpperCase();

    if (p.contains('MORN')) {
      return 0xFF4CAF50;
    }

    if (p.contains('AFTER') || p.contains('NOON')) {
      return 0xFF2196F3;
    }

    if (p.contains('NIGHT') || p.contains('EVE')) {
      return 0xFF9C27B0;
    }

    return 0xFF4CAF50;
  }

  // ============================================================
  // TAG
  // ============================================================

  String _getTagForPeriod(String period, String timeStr) {
    final p = period.toUpperCase();

    if (p.contains('MORN')) {
      return 'Morning';
    }

    if (p.contains('AFTER') || p.contains('NOON')) {
      return 'Afternoon';
    }

    if (p.contains('NIGHT') || p.contains('EVE')) {
      return 'Night';
    }

    return 'Daily';
  }

  // ============================================================
  // EDIT MEDICINE
  // ============================================================

  Future<void> _onMedicineClicked(Map<String, dynamic> routine) async {
    if (routine['medicineId'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Medicine ID is missing')));

      return;
    }

    if (routine['scheduleId'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule ID is missing')));

      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditMedicineDialog(routine: routine);
      },
    );

    if (result == true && mounted) {
      await _loadMedicines();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine routine updated')),
        );
      }
    }
  }

  // ============================================================
  // OPEN LOGS DIALOG
  // ============================================================
  void _openLogsDialog(
      Map<String, dynamic> routine,
      ) {
    final scheduleId =
    _toInt(routine['scheduleId']);

    debugPrint('================================');
    debugPrint('OPENING MEDICINE LOGS');
    debugPrint('Medicine Name: ${routine['name']}');
    debugPrint('Medicine ID: ${routine['medicineId']}');
    debugPrint('Schedule ID: $scheduleId');
    debugPrint('Routine: $routine');
    debugPrint('================================');

    if (scheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule ID is missing'),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return LogsDataDialog(
          routine: routine,
          scheduleId: scheduleId,
        );
      },
    );
  }
  // ============================================================
  // TOGGLE TAKEN
  // ============================================================

  void _toggleTaken(int index) {
    if (index < 0 || index >= _routines.length) {
      return;
    }

    setState(() {
      final routine = _routines[index];

      final current = routine['taken'] == true;

      final updated = !current;

      routine['taken'] = updated;

      final key =
          routine['routineKey']?.toString() ??
          '${routine['medicineId']}_'
              '${routine['scheduleId']}_'
              '${routine['time']}';

      if (updated) {
        _takenKeys.add(key);
      } else {
        _takenKeys.remove(key);
      }
    });
  }

  // ============================================================
  // ADD MEDICINE
  // ============================================================

  Future<void> _showAddMedicineDialog() async {
    final uid = _currentUserId;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not available')));

      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AddMedicineDialog(userId: uid);
      },
    );

    if (result == null || !mounted) {
      return;
    }

    await _loadMedicines();

    if (!mounted) {
      return;
    }

    final medName = (result['medicineName'] ?? result['name'] ?? 'Medicine')
        .toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "$medName" '
                'to routine schedule',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProfilePage(
            name: widget.clientName,
            email: widget.clientEmail,
            password: widget.clientPassword,
          );
        },
      ),
    );

    if (mounted) {
      await _loadMedicines();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final takenCount = _routines.where((r) => r['taken'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: primaryColor),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  widget.clientName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: Icon(Icons.account_circle, color: primaryColor, size: 32),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMedicines,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // WELCOME CARD
                // ==================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Hello, ${widget.clientName}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Age: ${widget.clientAge} yrs',
                              style: const TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              '$takenCount/${_routines.length} Medicines taken today',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // TITLE
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "Today's Medicine Routine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),

                    Text(
                      '${_routines.length} Doses',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // ERROR
                // ==================================================
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(12),

                    margin: const EdgeInsets.only(bottom: 12),

                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                // ==================================================
                // LOADING
                // ==================================================
                if (_isLoading && _routines.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // ==================================================
                // EMPTY
                // ==================================================
                else if (_routines.isEmpty)
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'No medicines scheduled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Tap "Add Medicine" to create your routine.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                // ==================================================
                // MEDICINE LIST
                // ==================================================
                else
                  ListView.separated(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: _routines.length,

                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },

                    itemBuilder: (context, index) {
                      final routine = _routines[index];

                      final isTaken = routine['taken'] == true;

                      final colorValue = routine['color'] is int
                          ? routine['color']
                          : 0xFF4CAF50;

                      final medicineName =
                          routine['name']?.toString() ?? 'Medicine';

                      final instruction =
                          routine['instruction']?.toString() ??
                          'Take as prescribed';

                      final time = routine['time']?.toString() ?? '08:30 AM';

                      return InkWell(
                        onTap: () {
                          _onMedicineClicked(routine);
                        },

                        borderRadius: BorderRadius.circular(16),

                        child: Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,

                                decoration: BoxDecoration(
                                  color: Color(
                                    colorValue,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Icon(
                                  Icons.medication,
                                  color: Color(colorValue),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      medicineName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: isTaken
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      instruction,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14),

                                        const SizedBox(width: 4),

                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),

                                          decoration: BoxDecoration(
                                            color: Color(
                                              colorValue,
                                            ).withValues(alpha: 0.10),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Text(
                                            routine['tag']?.toString() ??
                                                'Daily',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(colorValue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // =================================================
                              // LOGS BUTTON
                              // =================================================
                              OutlinedButton.icon(
                                key: Key('logs_routine_button_$index'),

                                onPressed: () {
                                  _openLogsDialog(routine);
                                },

                                icon: const Icon(
                                  Icons.bar_chart_rounded,
                                  size: 15,
                                ),

                                label: const Text(
                                  'Logs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0077B6),

                                  backgroundColor: const Color(
                                    0xFF0077B6,
                                  ).withValues(alpha: 0.06),

                                  side: BorderSide(
                                    color: const Color(
                                      0xFF0077B6,
                                    ).withValues(alpha: 0.28),
                                  ),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  minimumSize: Size.zero,

                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 4),

                              // =================================================
                              // EDIT BUTTON
                              // =================================================
                              IconButton(
                                key: Key('edit_routine_button_$index'),

                                onPressed: () {
                                  _onMedicineClicked(routine);
                                },

                                tooltip: 'Edit Medicine & Schedule',

                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blueGrey.shade400,
                                  size: 20,
                                ),
                              ),

                              // =================================================
                              // TAKEN BUTTON
                              // =================================================
                              IconButton(
                                onPressed: () {
                                  _toggleTaken(index);
                                },

                                tooltip: isTaken
                                    ? 'Mark as not taken'
                                    : 'Mark as taken',

                                icon: Icon(
                                  isTaken
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isTaken ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),

      // ==========================================================
      // ADD MEDICINE
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicineDialog,

        backgroundColor: primaryColor,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text('Add Medicine'),
      ),
    );
  }
}

// ============================================================================
// MEDICINE DETAILS DIALOG
// ============================================================================

class MedicineDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> routine;

  const MedicineDetailsDialog({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return EditMedicineDialog(routine: routine);
  }
}
