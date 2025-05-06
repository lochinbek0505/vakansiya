import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/Components/ChatWithRecruiter.dart';

class ChatWithRecruiterPage extends StatelessWidget {
  final String jobId;
  final String userId;

  ChatWithRecruiterPage({required this.jobId, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Используйте jobId и userId для настройки чата с рекрутером.
    return Scaffold(
      appBar: AppBar(title: Text('Чат с рекрутером')),
      body: Center(
        child: Text('ID вакансии: $jobId\nID пользователя: $userId'),
      ),
    );
  }
}

class JobsPostedPage extends StatefulWidget {
  @override
  _JobsPostedPageState createState() => _JobsPostedPageState();
}

class _JobsPostedPageState extends State<JobsPostedPage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Color(0xff121212),
        appBar: AppBar(
          title: Text(
            'Все поданные вакансии',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black, // темный фон
        ),
        body: Center(child: Text("Пользователь не вошел в систему")),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xff121212),

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Все поданные вакансии',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // темный фон
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobsposted').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final jobDocs = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: jobDocs.length,
            itemBuilder: (context, index) {
              final jobDoc = jobDocs[index];
              final jobId = jobDoc.id;

              return FutureBuilder<DocumentSnapshot>(
                future:
                    jobDoc.reference
                        .collection('applications')
                        .doc(currentUser!.uid)
                        .get(),
                builder: (context, appSnapshot) {
                  if (appSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox();
                  }

                  if (appSnapshot.hasData && appSnapshot.data!.exists) {
                    final jobData = jobDoc.data() as Map<String, dynamic>;
                    final companyName =
                        jobData['companyName'] ?? 'Неизвестная компания';
                    final jobTitle =
                        jobData['jobTitle'] ?? 'Неизвестная вакансия';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatPage(
                                  jobId: jobId,
                                  applicationId: currentUser!.uid,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF171918), Color(0xFF000000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.work, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    jobTitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              );
            },
          );
        },
      ),
    );
  }
}
