import 'package:flutter/material.dart';
import 'package:attendex_app/auth/auth_service.dart';
import 'package:attendex_app/screens/upload_csv_screen.dart';
import 'package:attendex_app/screens/staff_management_screen.dart';
import 'package:attendex_app/auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StaffManagementScreen()),
              ),
              child: Text('Manage Staff'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadCsvScreen()),
              ),
              child: Text('Create Event & Upload CSV'),
            ),
          ],
        ),
      ),
    );
  }
}