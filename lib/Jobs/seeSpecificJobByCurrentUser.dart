import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/chats/chatByRecruiter.dart';

class SeeSpecificJobApplicants extends StatelessWidget {
  final String documentId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SeeSpecificJobApplicants({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Все кандидаты',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<User?>(
        future: _auth.authStateChanges().first,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.done) {
            if (userSnapshot.hasError) {
              return Center(
                child: Text(
                  'Ошибка: ${userSnapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final currentUser = userSnapshot.data;

            return StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore
                      .collection('jobsposted')
                      .doc(documentId)
                      .snapshots(),
              builder: (context, jobSnapshot) {
                if (jobSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (jobSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Ошибка: ${jobSnapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'Вакансия не найдена.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('jobsposted')
                          .doc(documentId)
                          .collection('applications')
                          .snapshots(),
                  builder: (context, appSnapshot) {
                    if (appSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (appSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${appSnapshot.error}',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!appSnapshot.hasData ||
                        appSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Заявки не найдены.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final applicationDocs = appSnapshot.data!.docs;
                    return ListView.builder(
                      itemCount: applicationDocs.length,
                      itemBuilder: (context, index) {
                        final applicationData =
                            applicationDocs[index].data()
                                as Map<String, dynamic>;
                        final availability =
                            applicationData['availability'] ?? 'Не указано';
                        final experience =
                            applicationData['experience'] ?? 'Не указано';
                        final projects =
                            applicationData['projects'] ?? 'Не указано';
                        final salaryExpectation =
                            applicationData['salaryExpectation'] ??
                            'Не указано';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatRecruiter(
                                      jobId: documentId,
                                      applicationId: applicationDocs[index].id,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            color: const Color(0xFF1E1E1E),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                'Доступность: $availability',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chat,
                                color: Colors.cyanAccent,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Опыт: $experience',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Проекты: $projects',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Ожидания по зарплате: $salaryExpectation',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
