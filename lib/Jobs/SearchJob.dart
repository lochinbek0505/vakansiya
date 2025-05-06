import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakansiya/Components/BottomNavigator.dart';
import 'package:vakansiya/Jobs/JobDetails.dart';
import 'package:lottie/lottie.dart';

class JobSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xFF121212), // Темный фон
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Поиск вакансий', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1F1F1F),
        ),
        body: JobList(),
        bottomNavigationBar: BottomNavigatorExample(),
      ),
    );
  }
}

class JobList extends StatefulWidget {
  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> jobDocs = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Поиск вакансий',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              contentPadding: EdgeInsets.all(10),
              filled: true,
              fillColor: Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _searchJobs,
          ),
        ),
        Expanded(
          child:
              jobDocs.isEmpty
                  ? Center(
                    child: Lottie.asset(
                      'assets/animation_lmm6bvuc.json',
                      width: 300,
                      repeat: true,
                    ),
                  )
                  : ListView.builder(
                    itemCount: jobDocs.length,
                    itemBuilder: (context, index) {
                      var job = jobDocs[index].data() as Map<String, dynamic>;
                      var jobId = jobDocs[index].id;

                      var jobTitle =
                          job['jobTitle'] as String? ??
                          'Заголовок вакансии не указан';
                      var companyName =
                          job['companyName'] as String? ??
                          'Название компании не указано';
                      var salary =
                          job['salary'] as String? ?? 'Зарплата не указана';
                      var postedDate =
                          job['postedDate'] as String? ?? 'нет даты';
                      var skills = job['skills'] as List<dynamic>?;
                      var skillsText =
                          skills != null ? skills.join(', ') : 'Не указаны';

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
                  ),
        ),
      ],
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

  // 🕓 Функция для форматирования времени
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дней назад';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} недель назад';

    return DateFormat.yMMMd().format(date);
  }

  void _searchJobs(String query) {
    final CollectionReference jobsCollection = FirebaseFirestore.instance
        .collection('jobsposted');

    jobsCollection
        .where('jobTitle', isGreaterThanOrEqualTo: query)
        .where('jobTitle', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
          setState(() {
            jobDocs = querySnapshot.docs;
          });
        })
        .catchError((error) {
          print("Ошибка при получении вакансий: $error");
        });
  }
}
