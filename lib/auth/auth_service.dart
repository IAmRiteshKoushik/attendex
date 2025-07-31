import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendex_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin login with email and password
  Future<UserModel?> signInAdmin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists && doc['role'] == 'admin') {
        UserModel user = UserModel.fromFirestore(doc.data() as Map<String, dynamic>, email);
        await cacheUserRole(email, user.role); // Cache user data
        return user;
      }
      await _auth.signOut(); // Sign out if not an admin
      return null;
    } catch (e) {
      print('Admin sign-in error: $e');
      return null;
    }
  }

  // Staff login with email only
  Future<UserModel?> signInStaff(String email) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists && doc['role'] == 'staff') {
        UserModel user = UserModel.fromFirestore(doc.data() as Map<String, dynamic>, email);
        await cacheUserRole(email, user.role); // Cache user data
        return user;
      }
      return null;
    } catch (e) {
      print('Staff sign-in error: $e');
      return null;
    }
  }

  // Cache user role and email
  Future<void> cacheUserRole(String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_role', role);
  }

  // Retrieve cached user
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final role = prefs.getString('user_role');
    if (email != null && role != null) {
      return UserModel(email: email, role: role);
    }
    return null;
  }

  // Clear cached user data on sign-out
  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearCachedUser(); // Clear cached data on sign-out
  }

  User? get currentUser => _auth.currentUser;
}