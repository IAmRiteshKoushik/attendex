import 'package:flutter/material.dart';
import 'package:attendex_app/auth/auth_service.dart';
import 'package:attendex_app/screens/admin_dashboard.dart';
import 'package:attendex_app/screens/staff/staff_dashboard.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isAdminLogin = true;

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });

    UserModel? user;
    if (_isAdminLogin) {
      // Admin login with email and password
      user = await _authService.signInAdmin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user == null) {
        setState(() {
          _errorMessage = 'Invalid admin credentials';
        });
        return;
      }
    } else {
      // Staff login with email only
      user = await _authService.signInStaff(_emailController.text.trim());
      if (user == null) {
        setState(() {
          _errorMessage = 'Invalid or unauthorized staff email';
        });
        return;
      }
    }

    // Navigate based on role
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user?.role == 'admin' ? AdminDashboard() : StaffLandingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AttendEx Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isAdminLogin = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAdminLogin ? Colors.blue : Colors.grey,
                  ),
                  child: Text('Admin Login'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _isAdminLogin = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isAdminLogin ? Colors.blue : Colors.grey,
                  ),
                  child: Text('Staff Login'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // Password input (only for admin)
            if (_isAdminLogin)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(_isAdminLogin ? 'Admin Login' : 'Staff Login'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}