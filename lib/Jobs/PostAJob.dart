import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/Components/BottomNavigator.dart';
import 'package:vakansiya/Jobs/SeeAllJobPostedByCurrentUser.dart';

class JobPostingPage extends StatefulWidget {
  @override
  _JobPostingPageState createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _profileLinkController = TextEditingController();
  final _salaryController = TextEditingController();
  final _skillsController = TextEditingController();

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF1C1C1C),
          title: Text(
            'Разместить вакансию',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => JobsPostedPage()));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Название вакансии'),
              SizedBox(height: 6),
              TextField(
                controller: _jobTitleController,
                decoration: _inputDecoration('Введите название вакансии'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              _label('Описание вакансии'),
              SizedBox(height: 6),
              TextField(
                controller: _jobDescriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Введите описание вакансии'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              _label('Название компании'),
              SizedBox(height: 6),
              TextField(
                controller: _companyNameController,
                decoration: _inputDecoration('Введите название компании'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              _label('Ссылка на профиль'),
              SizedBox(height: 6),
              TextField(
                controller: _profileLinkController,
                decoration: _inputDecoration('Введите ссылку на профиль'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              _label('Зарплата'),
              SizedBox(height: 6),
              TextField(
                controller: _salaryController,
                decoration: _inputDecoration('Введите зарплату'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              _label('Навыки'),
              SizedBox(height: 6),
              TextField(
                controller: _skillsController,
                decoration: _inputDecoration(
                  'Введите необходимые навыки (через запятую)',
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _postJobToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007F5F),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Разместить вакансию',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postJobToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final jobData = {
      'jobTitle': _jobTitleController.text,
      'jobDescription': _jobDescriptionController.text,
      'companyName': _companyNameController.text,
      'profileLink': _profileLinkController.text,
      'salary': _salaryController.text,
      'skills': _skillsController.text.split(','),
      'postedBy': user.uid,
      'postedDate': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('jobsposted').add(jobData);
      _showSuccessMessage();
      _clearTextFields();
    } catch (e) {
      print('Ошибка при размещении вакансии: $e');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Вакансия успешно размещена!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearTextFields() {
    _jobTitleController.clear();
    _jobDescriptionController.clear();
    _companyNameController.clear();
    _profileLinkController.clear();
    _salaryController.clear();
    _skillsController.clear();
  }
}
