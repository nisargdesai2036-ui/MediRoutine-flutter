import 'package:flutter/material.dart';

import '../coreapi/ApiService.dart';

class LogsDataDialog extends StatefulWidget {
  final Map<String, dynamic> routine;
  final int scheduleId;

  const LogsDataDialog({
    super.key,
    required this.routine,
    required this.scheduleId,
  });

  @override
  State<LogsDataDialog> createState() => _LogsDataDialogState();
}

class _LogsDataDialogState extends State<LogsDataDialog> {
  // ============================================================
  // API DATA
  // ============================================================

  List<Map<String, dynamic>> _logs = [];

  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadLogs();
  }

  // ============================================================
  // LOAD LOGS FROM BACKEND
  // ============================================================

  Future<void> _loadLogs() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url =
          '/api/logs/schedule/${widget.scheduleId}';

      debugPrint('================================');
      debugPrint('MEDICINE LOG REQUEST');
      debugPrint('Schedule ID: ${widget.scheduleId}');
      debugPrint('URL: $url');
      debugPrint('================================');

      final response =
      await ApiService.get(url);

      debugPrint('LOG RESPONSE: $response');
      debugPrint(
        'RESPONSE TYPE: ${response.runtimeType}',
      );

      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>>
      parsedLogs = [];

      if (response is List) {
        for (final item in response) {
          if (item is Map) {
            parsedLogs.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      debugPrint(
        'NUMBER OF LOGS: ${parsedLogs.length}',
      );

      setState(() {
        _logs = parsedLogs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('================================');
      debugPrint('MEDICINE LOG ERROR');
      debugPrint('$e');
      debugPrint('================================');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Failed to load medicine logs.\n$e';
      });
    }
  }
  // ============================================================
  // SAFE STRING
  // ============================================================

  String _getString(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = '',
  ]) {
    final value = data[key];

    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  // ============================================================
  // CALCULATED DATA
  // ============================================================

  int get totalCount {
    return _logs.length;
  }

  int get takenCount {
    return _logs.where((log) {
      final status = _getString(log, 'status').toUpperCase();

      return status == 'TAKEN';
    }).length;
  }

  int get missedCount {
    return _logs.where((log) {
      final status = _getString(log, 'status').toUpperCase();

      return status == 'MISSED';
    }).length;
  }

  double get adherenceRate {
    if (totalCount == 0) {
      return 0;
    }

    return takenCount / totalCount;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final dialogWidth = (screenSize.width * 0.92).clamp(340.0, 720.0);

    final medicineName =
        (widget.routine['name'] ?? widget.routine['medicineName'] ?? 'Medicine')
            .toString();

    final timeStr = (widget.routine['time'] ?? '08:30 AM').toString();

    final instruction =
        (widget.routine['instruction'] ??
                widget.routine['dosage'] ??
                'Take as prescribed')
            .toString();

    final period =
        (widget.routine['period'] ?? widget.routine['tag'] ?? 'Daily')
            .toString();

    final frequencyType = (widget.routine['frequencyType'] ?? 'DAILY')
        .toString()
        .replaceAll('_', ' ');

    final colorValue = widget.routine['color'] is int
        ? widget.routine['color'] as int
        : 0xFF4CAF50;

    final themeColor = Color(colorValue);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: screenSize.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF0077B6),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Medicine Routine Adherence & Logs',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // ==========================================================
            // BODY
            // ==========================================================
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // LOADING
                    // ==================================================
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    // ==================================================
                    // ERROR
                    // ==================================================
                    else if (_errorMessage != null)
                      _buildErrorView()
                    // ==================================================
                    // DATA
                    // ==================================================
                    else ...[
                      _buildSummaryCard(
                        medicineName: medicineName,
                        instruction: instruction,
                        timeStr: timeStr,
                        period: period,
                        frequencyType: frequencyType,
                        themeColor: themeColor,
                      ),

                      const SizedBox(height: 20),

                      _buildAdherenceCard(),

                      const SizedBox(height: 20),

                      _buildHistorySection(),
                    ],
                  ],
                ),
              ),
            ),

            // ==========================================================
            // FOOTER
            // ==========================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String medicineName,
    required String instruction,
    required String timeStr,
    required String period,
    required String frequencyType,
    required Color themeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          final leftSection = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: themeColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      instruction,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 15,
                          color: Color(0xFF0077B6),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077B6),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Frequency: $frequencyType',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final rightSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatBox(
                title: 'TOTAL',
                value: totalCount.toString(),
                subtitle: 'Doses',
                color: const Color(0xFF0077B6),
              ),

              const SizedBox(width: 10),

              _buildStatBox(
                title: 'TAKEN',
                value: takenCount.toString(),
                subtitle: 'Taken',
                color: const Color(0xFF2E7D32),
              ),

              const SizedBox(width: 10),

              _buildStatBox(
                title: 'MISSED',
                value: missedCount.toString(),
                subtitle: 'Missed',
                color: const Color(0xFFD32F2F),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftSection,

                const SizedBox(height: 16),

                const Divider(height: 1),

                const SizedBox(height: 16),

                Center(child: rightSection),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: leftSection),

              const SizedBox(width: 16),

              rightSection,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ADHERENCE CARD
  // ============================================================

  Widget _buildAdherenceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adherence Rate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(adherenceRate * 100).toStringAsFixed(1)}% Compliant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: adherenceRate,
              minHeight: 8,
              backgroundColor: Colors.red.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY SECTION
  // ============================================================

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Log History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),

            Text(
              '${_logs.length} Records',
              style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (_logs.isEmpty)
          _buildEmptyHistory()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildHistoryItem(_logs[index]);
            },
          ),
      ],
    );
  }

  // ============================================================
  // HISTORY ITEM
  // ============================================================

  Widget _buildHistoryItem(Map<String, dynamic> log) {
    final status = _getString(log, 'status').toUpperCase();

    final isTaken = status == 'TAKEN';

    final scheduledDate = _parseDate(log['scheduledDate']);

    final actionTime = _parseDate(log['actionTime']);

    final scheduledTime = _getString(log, 'scheduledTime', '--');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isTaken ? Colors.green.shade50 : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isTaken ? Colors.green.shade700 : Colors.red.shade700,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheduledDate == null
                      ? 'Unknown date'
                      : _getRelativeDate(scheduledDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),

                Text(
                  isTaken
                      ? 'Logged at ${_formatActionTime(actionTime, scheduledTime)}'
                      : 'Dose skipped',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isTaken
                  ? Colors.green.shade100.withValues(alpha: 0.6)
                  : Colors.red.shade100.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.isEmpty ? 'UNKNOWN' : status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isTaken ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  // ============================================================
  // RELATIVE DATE
  // ============================================================

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final logDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(logDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference > 1) {
      return '$difference days ago';
    }

    return _formatDate(date);
  }

  // ============================================================
  // ACTION TIME
  // ============================================================

  String _formatActionTime(DateTime? actionTime, String scheduledTime) {
    if (actionTime == null) {
      return scheduledTime;
    }

    final hour = actionTime.hour;

    final minute = actionTime.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade400),

          const SizedBox(height: 8),

          Text(
            'No medicine logs found.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildErrorView() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 12),

            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT BOX
  // ============================================================

  Widget _buildStatBox({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3.5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1,
                    ),
                  ),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
