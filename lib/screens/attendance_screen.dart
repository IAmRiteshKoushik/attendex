import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:convert';

class AttendanceScreen extends StatefulWidget {
  final String formId; // Event/form ID from Firestore
  const AttendanceScreen({Key? key, required this.formId}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _rollNoController = TextEditingController();
  String scanResult = '';
  Color resultColor = Colors.black;
  IconData? resultIcon;
  String rollNo = '';
  int totalScanned = 0;
  int totalPresent = 0;

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      await _processRollNo(result.rawContent);
    } catch (e) {
      setState(() {
        scanResult = 'Scan error: $e';
        resultColor = Colors.red;
        resultIcon = Icons.error;
      });
    }
  }

  Future<void> manualEntry() async {
    String rollNo = _rollNoController.text.trim();
    if (rollNo.isEmpty) {
      setState(() {
        scanResult = 'Enter a valid roll number';
        resultColor = Colors.red;
        resultIcon = Icons.error;
      });
      return;
    }
    await _processRollNo(rollNo);
    _rollNoController.clear();
  }

  Future<void> _processRollNo(String rollNo) async {
    setState(() {
      this.rollNo = rollNo;
      scanResult = rollNo;
      resultIcon = null;
    });

    // Check Firestore for roll number
    var doc = await FirebaseFirestore.instance
        .collection('formMetadata')
        .doc(widget.formId)
        .collection('participants')
        .doc(rollNo)
        .get();

    if (doc.exists) {
      // Mark attendance
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.formId)
          .collection('records')
          .doc(rollNo)
          .set({
        'status': 'present',
        'timestamp': FieldValue.serverTimestamp(),
        'name': doc['name'] ?? 'Unknown', // Include name for better reporting
      });
      setState(() {
        scanResult = '${doc['name'] ?? rollNo} - Present';
        resultColor = Colors.green;
        resultIcon = Icons.check_circle;
        totalScanned++;
        totalPresent++;
      });
    } else {
      setState(() {
        scanResult = 'Unregistered: $rollNo';
        resultColor = Colors.red;
        resultIcon = Icons.error;
        totalScanned++;
      });
    }
  }

  Future<void> downloadAttendance() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.formId)
          .collection('records')
          .get();

      String csv = 'Roll No,Name,Status,Timestamp\n';
      for (var doc in snapshot.docs) {
        csv += '${doc.id},${doc['name'] ?? 'Unknown'},${doc['status']},${doc['timestamp']?.toDate() ?? ''}\n';
      }

      await FileSaver.instance.saveFile(
        name: 'attendance_${widget.formId}.csv',
        bytes: utf8.encode(csv),
        mimeType: MimeType.csv,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance downloaded as CSV')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Stats
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Total Scanned: $totalScanned'),
                    Text('Total Present: $totalPresent'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Result Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (resultIcon != null) Icon(resultIcon, color: resultColor, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scanResult.isEmpty ? 'Scan or enter roll number' : scanResult,
                    style: TextStyle(color: resultColor, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Input Section
            TextField(
              controller: _rollNoController,
              decoration: InputDecoration(
                labelText: 'Enter Roll Number',
                hintText: 'e.g., 12345',
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: scanBarcode,
                  child: Text('Scan Barcode'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: manualEntry,
                  child: Text('Submit Roll No'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: downloadAttendance,
              child: Text('Download Attendance'),
            ),
            SizedBox(height: 20),
            // Scanned Students List
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('attendance')
                    .doc(widget.formId)
                    .collection('records')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text('${doc['name'] ?? 'Unknown'} (${doc.id})'),
                        subtitle: Text('Status: ${doc['status']}, Time: ${doc['timestamp']?.toDate() ?? ''}'),
                        leading: Icon(
                          doc['status'] == 'present' ? Icons.check_circle : Icons.error,
                          color: doc['status'] == 'present' ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}