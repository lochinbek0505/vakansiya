import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SkillsPage(),
    );
  }
}

class SkillsPage extends StatefulWidget {
  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<String> _userSkills = [];

  final List<Color> _itemColors = [
    Colors.teal,
    Colors.deepPurple,
    Colors.orange,
    Colors.indigo,
    Colors.green,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      _getUserSkills(user.uid);
    }
  }

  Future<void> _getUserSkills(String uid) async {
    final userData = await _firestore.collection('userdata').doc(uid).get();
    if (userData.exists) {
      final skills = userData['skills'] as List<dynamic>;
      setState(() {
        _userSkills = skills.cast<String>();
      });
    }
  }

  Future<void> _deleteSkill(int index) async {
    final uid = _currentUser!.uid;
    final skills = List<String>.from(_userSkills);
    skills.removeAt(index);

    await _firestore.collection('userdata').doc(uid).update({'skills': skills});

    setState(() {
      _userSkills = skills;
    });
  }

  Future<void> _addSkill(String newSkill) async {
    final uid = _currentUser!.uid;
    final skills = List<String>.from(_userSkills);
    skills.add(newSkill);

    await _firestore.collection('userdata').doc(uid).update({'skills': skills});

    setState(() {
      _userSkills = skills;
    });
  }

  void _showAddSkillDialog(BuildContext context) {
    String newSkill = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1F1F1F),
          title: Text('Добавить навык', style: TextStyle(color: Colors.white)),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Название навыка',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Отмена', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                if (newSkill.trim().isNotEmpty) {
                  _addSkill(newSkill.trim());
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Добавить',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Мои навыки', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body:
          _currentUser == null
              ? Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
              : _userSkills.isEmpty
              ? Center(
                child: Text(
                  'Навыки не найдены.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _userSkills.length,
                itemBuilder: (context, index) {
                  final color = _itemColors[index % _itemColors.length];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        _userSkills[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteSkill(index),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSkillDialog(context),
        backgroundColor: Colors.black,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Добавить', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
