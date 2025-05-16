import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakansiya/Components/BottomNavigator.dart';
import 'package:vakansiya/Jobs/JobDetails.dart';
import 'package:vakansiya/Profile%20Components/AllAPpliedJobs.dart';

import '../shared_pref_helper.dart';

class jobsList extends StatefulWidget {
  @override
  State<jobsList> createState() => _jobsListState();
}

class _jobsListState extends State<jobsList> {
  int _formDone = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    checkform();
  }

  Future<void> checkform() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('userdata').doc(_user!.uid).get();

      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('formdone')) {
          setState(() {
            _formDone = userData['formdone'];
          });
        } else {
          _firestore.collection('userdata').doc(_user!.uid).set({
            'formdone': 3,
          }, SetOptions(merge: true));

          setState(() {
            _formDone = 3;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF2C2C2C),

        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF121212), // Dark background
          title: Text('Jobs', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => JobsPostedPage()),
                );
              },
            ),
          ],
        ),
        body: JobList(),
      ),
    );
  }
}

class JobList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('jobsposted').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> jobDocs = snapshot.data!.docs;

        if (jobDocs.isEmpty) {
          return Center(child: Text('Нет доступных вакансий.'));
        }

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            var job = jobDocs[index].data() as Map<String, dynamic>;
            var jobId = jobDocs[index].id;

            var companyName =
                job['companyName'] as String? ?? 'Название компании не указано';

            var jobTitle =
                job['jobTitle'] as String? ?? 'Название работы не указано';

            var salary = job['salary'] as String? ?? 'Зарплата не указана';
            var postedDate = job['postedDate'] as String? ?? 'нет даты';

            var skills = job['skills'] as List<dynamic>?;

            var skillsText =
                skills != null ? skills.join(', ') : 'Навыки не указаны';

            var imageUrl = job['imageUrl'] as String? ?? '';

            return jobCard(
              context: context,
              jobId: jobId,
              jobTitle: jobTitle,
              companyName: companyName,
              salary: salary,
              skillsText: skillsText,
              postedDate: DateTime.parse(postedDate),
            );
          },
        );
      },
    );
  }

  Widget jobCard({
    required BuildContext context,
    required String jobId,
    required String jobTitle,
    required String companyName,
    required String salary,
    required String skillsText,
    required DateTime postedDate,
  }) {
    // Форматированное время
    String formattedTime = timeAgo(postedDate);

    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailPage(jobId: jobId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Время публикации
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Опубликовано $formattedTime',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Заголовок
              Text(
                jobTitle,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Компания
              Row(
                children: [
                  const Icon(Icons.business, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    companyName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Навыки
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children:
                    skillsText
                        .split(',')
                        .map(
                          (skill) => Chip(
                            label: Text(skill.trim()),
                            backgroundColor: Colors.grey.shade800,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 12),

              // Зарплата + иконка
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    salary,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🕓 Вспомогательная функция для форматирования времени
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} часов назад';
    if (diff.inDays < 7) return '${diff.inDays} дней назад';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} недель назад';

    return DateFormat.yMMMd().format(date);
  }
}
