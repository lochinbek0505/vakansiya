import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUserDataPage extends StatefulWidget {
  @override
  _EditUserDataPageState createState() => _EditUserDataPageState();
}

class _EditUserDataPageState extends State<EditUserDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDataSnapshot =
          await _firestore.collection('userdata').doc(user.uid).get();

      if (userDataSnapshot.exists) {
        final data = userDataSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
        });
      }
    }
  }

  Future<void> saveUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      Map<String, dynamic> updatedData = {
        'name': _nameController.text,
        'bio': _bioController.text,
      };

      await _firestore.collection('userdata').doc(user.uid).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Данные пользователя успешно обновлены!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Редактировать имя / био',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F1F1F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Имя',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Введите ваше имя',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Биография',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Расскажите о себе',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: Text(
                'Сохранить изменения',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
