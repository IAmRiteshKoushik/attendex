import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io' show File, Platform;

class UploadCsvScreen extends StatefulWidget {
  const UploadCsvScreen({Key? key}) : super(key: key);

  @override
  _UploadCsvScreenState createState() => _UploadCsvScreenState();
}

class _UploadCsvScreenState extends State<UploadCsvScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Normalize event name to a valid Firestore document ID
  String _normalizeEventName(String eventName) {
    return eventName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  // Normalize CSV headers
  String _normalizeHeader(String h) {
    return h.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Validate headers with synonyms
  bool _isValidHeader(List<String> headers, String target) {
    return headers.contains(target) ||
        headers.contains(target.replaceAll('no', 'number'));
  }

  // Commit batches in chunks
  Future<void> _commitInChunks(List<WriteBatch> batches) async {
    for (var i = 0; i < batches.length; i++) {
      await batches[i].commit();
      if (mounted) {
        setState(() {
          _uploadProgress = (i + 1) / batches.length;
        });
      }
    }
  }

  // Confirm overwrite dialog
  Future<bool> _confirmOverwrite(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Overwrite Participants'),
        content: Text('This event already exists. Uploading a new CSV will replace all existing participants. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Overwrite'),
          ),
        ],
      ),
    ) ??
        false;
  }

  // Request media permissions for Android 13+
  Future<bool> _requestPermissions() async {
    if (!kIsWeb && Platform.isAndroid) {
      String? version = await Platform.version;
      int? majorVersion = int.tryParse(version.split('.').first);
      if (majorVersion != null && majorVersion >= 33) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        bool allGranted = statuses.values.every((status) => status.isGranted);
        if (!allGranted) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Permission Required'),
                content: Text('Media permissions are needed to access files. Please enable Photos and Videos in app settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
          return false;
        }
      }
      return true;
    }
    return true;
  }

  Future<void> uploadCsv() async {
    String eventName = _eventNameController.text.trim();
    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an event name')),
      );
      return;
    }

    String formId = _normalizeEventName(eventName);
    if (formId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid event name after normalization')),
      );
      return;
    }

    // Request permissions for Android 13+
    if (!await _requestPermissions()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Uploading CSV'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: _uploadProgress),
            SizedBox(height: 10),
            Text('Processing... (${(_uploadProgress * 100).toStringAsFixed(0)}%)'),
          ],
        ),
      ),
    );

    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Relaxed to test Google Drive compatibility
        allowMultiple: false,
        withData: true, // Ensure bytes are available
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No file selected. If the file is in Google Drive, download it to your Downloads folder and try again.'),
            ),
          );
        }
        return;
      }

      // Log file details
      PlatformFile file = result.files.first;
      String inferredMimeType = file.extension?.toLowerCase() == 'csv' ? 'text/csv' : 'unknown';
      debugPrint('Selected file: name=${file.name}, extension=${file.extension}, path=${file.path}, size=${file.size}, bytes_available=${file.bytes != null}, inferred_mime_type=$inferredMimeType');

      // Validate file extension
      if (file.extension?.toLowerCase() != 'csv') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected file is not a CSV. Please select a .csv file or download it to your Downloads folder.'),
            ),
          );
        }
        return;
      }

      // Read CSV data
      String csvData;
      if (kIsWeb || file.bytes != null) {
        if (file.bytes == null) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected file is empty or inaccessible. Download it to your Downloads folder and try again.'),
              ),
            );
          }
          return;
        }
        csvData = String.fromCharCodes(file.bytes!);
        debugPrint('Raw CSV data (web/bytes): $csvData');
      } else {
        if (file.path == null) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected file path is inaccessible. Download it to your Downloads folder and try again.'),
              ),
            );
          }
          return;
        }
        try {
          csvData = await File(file.path!).readAsString();
          debugPrint('Raw CSV data (mobile/path): $csvData');
        } catch (e, stack) {
          debugPrint('Failed to read file on mobile: $e\n$stack');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to read file: $e. Download the CSV to your Downloads folder and try again.'),
              ),
            );
          }
          return;
        }
      }

      // Parse CSV data using csv package
      List<List<dynamic>> csvRows = const CsvToListConverter().convert(csvData, eol: '\n');
      if (csvRows.isEmpty || csvRows[0].isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CSV file is empty or has no valid headers')),
          );
        }
        return;
      }

      // Normalize and validate headers
      List<String> headers = csvRows[0].map((h) => _normalizeHeader(h.toString())).toList();
      debugPrint('Parsed headers: $headers');
      if (!_isValidHeader(headers, 'name') || !_isValidHeader(headers, 'rollno')) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CSV must contain "Name" and "Roll No" (or "Roll Number") columns')),
          );
        }
        return;
      }

      // Check if event exists
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance.collection('formMetadata').doc(formId).get();
      if (eventDoc.exists) {
        bool overwrite = await _confirmOverwrite(context);
        if (!overwrite) {
          if (mounted) Navigator.pop(context);
          return;
        }
      }

      // Prepare batches
      List<WriteBatch> batches = [];
      WriteBatch currentBatch = FirebaseFirestore.instance.batch();
      int batchOperations = 0;
      const int batchLimit = 500;

      if (eventDoc.exists) {
        QuerySnapshot participants = await FirebaseFirestore.instance
            .collection('formMetadata')
            .doc(formId)
            .collection('participants')
            .get();
        for (var doc in participants.docs) {
          if (batchOperations >= batchLimit) {
            batches.add(currentBatch);
            currentBatch = FirebaseFirestore.instance.batch();
            batchOperations = 0;
          }
          currentBatch.delete(doc.reference);
          batchOperations++;
        }
      }

      // Create or update event metadata
      if (!eventDoc.exists) {
        currentBatch.set(
          FirebaseFirestore.instance.collection('formMetadata').doc(formId),
          {
            'eventName': eventName,
            'fields': headers,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
        batchOperations++;
      } else {
        currentBatch.set(
          FirebaseFirestore.instance.collection('formMetadata').doc(formId),
          {
            'eventName': eventName,
            'fields': headers,
          },
          SetOptions(merge: true),
        );
        batchOperations++;
      }

      // Write new participants
      int validRows = 0;
      Set<String> seenRollNos = {};
      int rollNoIndex = headers.indexWhere((h) => h == _normalizeHeader('Roll No') || h == _normalizeHeader('Roll Number'));
      int nameIndex = headers.indexWhere((h) => h == _normalizeHeader('Name'));
      for (var i = 1; i < csvRows.length; i++) {
        List<dynamic> values = csvRows[i].map((v) => v.toString().trim()).toList();
        if (values.length >= headers.length && values[nameIndex].isNotEmpty && values[rollNoIndex].isNotEmpty) {
          String rollNo = values[rollNoIndex].toUpperCase();
          if (seenRollNos.contains(rollNo)) {
            debugPrint('Warning: Duplicate roll number $rollNo skipped');
            continue;
          }
          seenRollNos.add(rollNo);
          Map<String, dynamic> participantData = {};
          for (int j = 0; j < headers.length; j++) {
            participantData[headers[j]] = headers[j] == _normalizeHeader('Roll No') || headers[j] == _normalizeHeader('Roll Number') ? rollNo : values[j];
          }
          if (batchOperations >= batchLimit) {
            batches.add(currentBatch);
            currentBatch = FirebaseFirestore.instance.batch();
            batchOperations = 0;
          }
          var docRef = FirebaseFirestore.instance
              .collection('formMetadata')
              .doc(formId)
              .collection('participants')
              .doc(rollNo);
          currentBatch.set(docRef, participantData);
          batchOperations++;
          validRows++;
        }
      }

      if (batchOperations > 0) {
        batches.add(currentBatch);
      }

      // Commit batches
      await _commitInChunks(batches);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded $validRows participants for $eventName')),
        );
        _eventNameController.clear();
      }
    } catch (e, stack) {
      debugPrint('Error uploading CSV: $e\n$stack');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading CSV: $e. Download the CSV to your Downloads folder and try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event & Upload CSV')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                hintText: 'e.g., Annual Tech Fest 2025',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : uploadCsv,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : Theme.of(context).primaryColor,
              ),
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Upload CSV'),
            ),
          ],
        ),
      ),
    );
  }
}