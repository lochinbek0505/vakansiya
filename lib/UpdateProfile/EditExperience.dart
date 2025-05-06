import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditExperience extends StatefulWidget {
  @override
  State<EditExperience> createState() => _EditExperienceState();
}

class _EditExperienceState extends State<EditExperience> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _experiences = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });

      final experiencesData =
          await _firestore
              .collection('userdata')
              .doc(user.uid)
              .collection('experiences')
              .get();

      setState(() {
        _experiences =
            experiencesData.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      });
    }
  }

  void _openAddExperienceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExperienceDialog(
          onAddExperience: (newExperience) {
            _addExperience(newExperience);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _addExperience(Map<String, dynamic> newExperience) async {
    if (_user != null) {
      await _firestore
          .collection('userdata')
          .doc(_user!.uid)
          .collection('experiences')
          .add(newExperience);

      setState(() {
        _experiences.add(newExperience);
      });
    }
  }

  void _deleteExperience(Map<String, dynamic> experienceToDelete) async {
    if (_user != null) {
      final experiencesData =
          await _firestore
              .collection('userdata')
              .doc(_user!.uid)
              .collection('experiences')
              .where(
                'companyName',
                isEqualTo: experienceToDelete['companyName'],
              )
              .where(
                'description',
                isEqualTo: experienceToDelete['description'],
              )
              .get();

      if (experiencesData.docs.isNotEmpty) {
        await experiencesData.docs.first.reference.delete();
      }

      setState(() {
        _experiences.remove(experienceToDelete);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        title: Text('Профиль работы', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _openAddExperienceDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _experiences.length,
        itemBuilder: (context, index) {
          final experience = _experiences[index];
          return Card(
            color: Colors.grey.shade900,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Опыт работы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.work, color: Colors.tealAccent),
                    title: Text(
                      'Компания: ${experience['companyName'] ?? 'Не указано'}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Описание: ${experience['description'] ?? 'Нет'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Дата начала: ${experience['startDate'] ?? 'Нет'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Дата окончания: ${experience['endDate'] ?? 'Нет'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Навыки: ${experience['skills'] ?? 'Нет'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteExperience(experience),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddExperienceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddExperience;

  AddExperienceDialog({required this.onAddExperience});

  @override
  _AddExperienceDialogState createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        "Добавить опыт",
        style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTextField(_companyNameController, "Название компании"),
            _buildTextField(_descriptionController, "Описание"),
            _buildTextField(_startDateController, "Дата начала"),
            _buildTextField(_endDateController, "Дата окончания"),
            _buildTextField(_skillsController, "Навыки"),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Отмена", style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: () {
            final newExperience = {
              'companyName': _companyNameController.text,
              'description': _descriptionController.text,
              'startDate': _startDateController.text,
              'endDate': _endDateController.text,
              'skills': _skillsController.text,
            };
            widget.onAddExperience(newExperience);
          },
          child: Text("Добавить"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.tealAccent),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
