import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'models/user_model.dart';
import 'screens/admin_dashboard.dart';
import 'screens/staff/staff_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AttendExApp());

}

class AttendExApp extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendEx',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: _authService.getCachedUser(),
        builder: (context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            // Navigate to appropriate dashboard based on cached role
            return snapshot.data!.role == 'admin' ? AdminDashboard() : StaffLandingScreen();
          }
          // No cached user, show login screen
          return LoginScreen();
        },
      ),
    );
  }
}