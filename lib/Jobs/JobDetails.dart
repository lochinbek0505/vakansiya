import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakansiya/Jobs/ApplicationFormPage.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;

  JobDetailPage({required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  bool hasApplied = false;

  @override
  void initState() {
    super.initState();
    checkApplicationStatus();
  }

  void checkApplicationStatus() async {
    if (user != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('jobsposted')
              .doc(widget.jobId)
              .collection('applications')
              .doc(user!.uid)
              .get();

      setState(() {
        hasApplied = snapshot.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // dark background
      appBar: AppBar(
        title: const Text(
          'Детали вакансии',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('jobsposted')
                .doc(widget.jobId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var jobData = snapshot.data!.data() as Map<String, dynamic>;
          var jobTitle = jobData['jobTitle'] ?? 'Заголовок вакансии не указан';
          var companyName =
              jobData['companyName'] ?? 'Название компании не указано';
          var jobDescription =
              jobData['jobDescription'] ?? 'Описание вакансии не указано';
          var salary = jobData['salary'] ?? 'Зарплата не указана';
          var companyImageURL = jobData['companyImageURL'] ?? '';
          var skills = jobData['skills'] as List<dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // JOB TITLE
                Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 40,
                          color: Colors.cyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            jobTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // COMPANY INFO
                Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.business,
                      color: Colors.greenAccent,
                    ),
                    title: Text(
                      companyName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SALARY
                Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.orangeAccent,
                    ),
                    title: Text(
                      "\$$salary",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // JOB DESCRIPTION
                Text(
                  "Описание вакансии",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    jobDescription,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 20),

                // SKILLS
                if (skills != null && skills.isNotEmpty) ...[
                  Text(
                    "Требуемые навыки",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: -8,
                    children:
                        skills.map((skill) {
                          return Chip(
                            label: Text(
                              skill,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.purple.shade700,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // IMAGE (optional)
                if (companyImageURL.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          companyImageURL,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                // APPLY BUTTON
                Center(
                  child: ElevatedButton.icon(
                    onPressed:
                        hasApplied
                            ? null
                            : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (builder) => ApplicationFormPage(
                                        jobId: widget.jobId,
                                        currentUser: user,
                                      ),
                                ),
                              );
                            },
                    icon: Icon(
                      hasApplied ? Icons.check_circle : Icons.send,
                      color: Colors.white,
                    ),
                    label: Text(
                      hasApplied ? "Вы уже подали заявку" : "Подать заявку",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasApplied ? Colors.grey : Colors.cyan[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} часов назад';
    if (diff.inDays < 7) return '${diff.inDays} дней назад';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} недель назад';

    return DateFormat.yMMMd().format(date);
  }
}
