import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  _StaffManagementScreenState createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> addStaff() async {
    String email = _emailController.text.trim();

    if (email.isNotEmpty) {
      // Check if the email already exists and its role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists && userDoc['role'] == 'admin') {
        // Prevent converting an admin to staff
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot convert admin ($email) to staff')),
        );
        return;
      }

      // Add or update the user as staff
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'role': 'staff',
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $email as staff')),
      );
      _emailController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email')),
      );
    }
  }

  Future<void> removeStaff(String email) async {
    // Check the user's role before deletion
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get();

    if (userDoc.exists && userDoc['role'] == 'admin') {
      // Prevent removing an admin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot remove admin ($email)')),
      );
      return;
    }

    // Remove the user if not an admin
    await FirebaseFirestore.instance.collection('users').doc(email).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Staff')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Staff Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addStaff,
              child: Text('Add Staff'),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text(doc.id),
                        subtitle: Text('Role: ${doc['role']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeStaff(doc.id),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}