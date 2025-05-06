import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplicationFormPage extends StatelessWidget {
  final String jobId;
  final User? currentUser;

  ApplicationFormPage({required this.jobId, required this.currentUser});

  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _salaryExpectationController =
      TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.greenAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF121212); // Черный фон
    final Color textColor = Colors.white;
    final Color labelColor = Colors.greenAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Подать заявку на работу',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 3, 53, 41),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Почему я должен вас нанять?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _experienceController,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Сколько лет опыта...'),
            ),
            const SizedBox(height: 20),

            Text(
              'Работали ли вы над проектами?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _projectController,
              maxLines: 4,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Введите детали проекта...'),
            ),
            const SizedBox(height: 20),

            Text(
              'Ожидания по зарплате',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _salaryExpectationController,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration(
                'Введите ожидания по зарплате...',
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Вы можете начать сразу?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _availabilityController,
              style: TextStyle(color: textColor),
              decoration: _buildInputDecoration('Да или Нет'),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  String experience = _experienceController.text.trim();
                  String projects = _projectController.text.trim();
                  String salary = _salaryExpectationController.text.trim();
                  String availability = _availabilityController.text.trim();

                  if (experience.isNotEmpty &&
                      projects.isNotEmpty &&
                      salary.isNotEmpty &&
                      availability.isNotEmpty) {
                    String uid = currentUser?.uid ?? '';
                    FirebaseFirestore.instance
                        .collection('jobsposted')
                        .doc(jobId)
                        .collection('applications')
                        .doc(uid)
                        .set({
                          'experience': experience,
                          'projects': projects,
                          'salaryExpectation': salary,
                          'availability': availability,
                        })
                        .then((_) {
                          Navigator.pop(context, true);
                        })
                        .catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Не удалось отправить: $error'),
                            ),
                          );
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Отправить заявку', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
