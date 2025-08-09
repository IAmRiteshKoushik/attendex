import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample student data based on Test.csv
    final Map<String, String> studentData = {
      'CB.SC.U4CSE23517': 'Harish',
      'CB.SC.U4CSE23507': 'Anuj',
      'CB.SC.U4CSE23562': 'Kirla siva sai karthik',
    };

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: ScannerScreen(studentData: studentData),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  final Map<String, String> studentData; // Student data passed from admin

  const ScannerScreen({Key? key, required this.studentData}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  Set<String> markedRolls = {};
  List<Map<String, String>> attendanceHistory = [];
  String name = '';
  String roll = '';
  bool torchOn = false;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation for button press
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void handleScan(String scannedCode) {
    if (markedRolls.contains(scannedCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance already marked for $scannedCode'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    setState(() {
      roll = scannedCode;
      name = widget.studentData[scannedCode] ?? '';
    });
  }

  void markAttendance() {
    if (name.isNotEmpty) {
      markedRolls.add(roll);
      attendanceHistory.add({'roll': roll, 'name': name});

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.teal[50],
          title: const Text('Attendance Marked', style: TextStyle(color: Colors.teal)),
          content: Text('Successfully marked attendance for $name', style: const TextStyle(color: Colors.black87)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  name = '';
                  roll = '';
                });
              },
              child: const Text('OK', style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for contrast
      appBar: AppBar(
        title: const Text(
          'Scanner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(torchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            onPressed: () {
              setState(() => torchOn = !torchOn);
              controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android, color: Colors.white),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final scannedCode = barcodes.first.rawValue ?? '';
                      handleScan(scannedCode);
                    }
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Align the barcode within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom panel with student info and attendance button
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.tealAccent, Colors.cyan],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isNotEmpty) ...[
                    Text(
                      'Name: $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll: $roll',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ] else if (roll.isNotEmpty) ...[
                    const Text(
                      'Roll number not found',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                  ] else
                    const Text(
                      'Waiting for scan...',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: (name.isNotEmpty && !markedRolls.contains(roll))
                          ? () {
                        _animationController.forward().then((_) => _animationController.reverse());
                        markAttendance();
                      }
                          : null,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Mark Attendance',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Attendance history list
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: attendanceHistory.length,
                itemBuilder: (context, index) {
                  final entry = attendanceHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: index % 2 == 0 ? Colors.teal[50] : Colors.blue[50],
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.teal),
                      title: Text(
                        entry['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(entry['roll'] ?? ''),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}