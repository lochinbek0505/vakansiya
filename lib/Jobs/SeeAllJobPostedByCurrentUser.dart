import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakansiya/Jobs/seeSpecificJobByCurrentUser.dart';

class JobsPostedPage extends StatefulWidget {
  @override
  _JobsPostedPageState createState() => _JobsPostedPageState();
}

class _JobsPostedPageState extends State<JobsPostedPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // темный фон
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Опубликованные вакансии',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _auth.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final currentUser = snapshot.data;

            if (currentUser == null) {
              return Center(
                child: Text(
                  "Пользователь не авторизован",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('jobsposted')
                      .where('postedBy', isEqualTo: currentUser.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      'Ошибка: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет опубликованных вакансий.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    final jobTitle = document['jobTitle'];
                    final rawPostedDate = document['postedDate'];
                    final documentId = document.id;

                    DateTime? postedDateTime;
                    String formattedDate = 'Неизвестная дата';

                    try {
                      postedDateTime = DateTime.parse(rawPostedDate);
                      formattedDate = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(postedDateTime);
                    } catch (e) {
                      // fallback если формат не удается
                      formattedDate = rawPostedDate.toString();
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        title: Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Опубликовано: $formattedDate',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.amber,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SeeSpecificJobApplicants(
                                    documentId: documentId,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
