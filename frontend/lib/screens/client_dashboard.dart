import 'package:flutter/material.dart';

class ClientDashboard extends StatefulWidget {
  final String clientName;
  final int clientAge;

  const ClientDashboard({
    super.key,
    required this.clientName,
    required this.clientAge,
  });

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  // Sample routine items for demonstration
  final List<Map<String, dynamic>> _routines = [
    {
      'name': 'Amoxicillin 500mg',
      'instruction': 'Take 1 tablet after breakfast',
      'time': '08:30 AM',
      'taken': true,
      'color': 0xFF4CAF50,
      'tag': 'Morning',
    },
    {
      'name': 'Vitamin D3 & Calcium',
      'instruction': 'Take 1 capsule with water',
      'time': '01:00 PM',
      'taken': false,
      'color': 0xFF2196F3,
      'tag': 'Afternoon',
    },
    {
      'name': 'Paracetamol 650mg',
      'instruction': 'Take 1 tablet before sleeping',
      'time': '09:00 PM',
      'taken': false,
      'color': 0xFF9C27B0,
      'tag': 'Night',
    },
  ];

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/user_avatar.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.clientName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Age: ${widget.clientAge} years',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Colors.blueAccent),
                title: const Text('Notifications'),
                subtitle: const Text('Sound & alerts enabled'),
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


  // the new medicine
  void _showAddMedicineDialog() {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Add Medicine Routine'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g. Aspirin 100mg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage / Instructions',
                  hintText: 'e.g. Take 1 tablet with water',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'e.g. 08:00 AM',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _routines.add({
                    'name': nameCtrl.text.trim(),
                    'instruction': dosageCtrl.text.trim().isEmpty
                        ? 'Take as prescribed'
                        : dosageCtrl.text.trim(),
                    'time': timeCtrl.text.trim().isEmpty ? '12:00 PM' : timeCtrl.text.trim(),
                    'taken': false,
                    'color': 0xFF2196F3,
                    'tag': 'Daily',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        automaticallyImplyLeading: false,
        // Left side of AppBar: User Name
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
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
        // Right side of AppBar: Button having image given
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showProfileModal,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/user_avatar.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: primaryColor, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                            'Age: ${widget.clientAge} yrs  •  Stay healthy & on time',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_routines.where((r) => r['taken'] == true).length}/${_routines.length} Medicines taken today',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm_on_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Routine Title
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
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Routine List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _routines.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final routine = _routines[index];
                  final isTaken = routine['taken'] as bool;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTaken ? Colors.green.shade200 : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(routine['color'] as int).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: Color(routine['color'] as int),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine['name'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isTaken ? Colors.grey : Colors.blueGrey.shade900,
                                  decoration: isTaken ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                routine['instruction'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: Colors.blueGrey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    routine['time'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isTaken ? Colors.green : Colors.grey.shade400,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              routine['taken'] = !isTaken;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Raised button on Right bottom corner
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: _showAddMedicineDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          'Add Medicine',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
