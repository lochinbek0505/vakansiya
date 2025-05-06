import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/Components/BottomNavigator.dart';
import 'package:vakansiya/Jobs/SearchJob.dart';
import 'package:vakansiya/Jobs/ListAllJobs.dart';
import 'package:vakansiya/Jobs/SeeAllJobPostedByCurrentUser.dart';
import 'package:vakansiya/Jobs/PostAJob.dart';
import 'package:vakansiya/UpdateProfile/EditExperience.dart';
import 'package:vakansiya/UpdateProfile/UpdatePersonal.dart';
import 'package:vakansiya/UpdateProfile/updateskills.dart';
import 'package:vakansiya/formsForFirst/education.dart';
import 'package:vakansiya/formsForFirst/jobdata.dart';
import 'package:vakansiya/formsForFirst/userInfoData.dart';

class ApplicantProfile extends StatefulWidget {
  final String documentId;

  ApplicantProfile({required this.documentId});

  @override
  _ApplicantProfileState createState() => _ApplicantProfileState();
}

class _ApplicantProfileState extends State<ApplicantProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _experiences = [];
  Map<String, dynamic>? _userData;
  List<dynamic> _skills = [];
  int _formDone = 0;
  List<Color> skillColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    checkform();
    _getUserData();
  }

  Future<void> checkform() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('userdata').doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('formdone')) {
          setState(() {
            _formDone = userData['formdone'];
          });
        } else {
          _firestore.collection('userdata').doc(widget.documentId).set({
            'formdone': 5,
          }, SetOptions(merge: true));

          setState(() {
            _formDone = 5;
          });
        }
      }
    }
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      final userData =
          await _firestore.collection('userdata').doc(widget.documentId).get();
      if (userData.exists) {
        final userDataMap = userData.data() as Map<String, dynamic>;

        final experiencesData =
            await _firestore
                .collection('userdata')
                .doc(widget.documentId)
                .collection('experiences')
                .get();
        setState(() {
          _experiences =
              experiencesData.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
        });

        final skills = userDataMap['skills'] as List<dynamic>;
        setState(() {
          _skills = skills;
        });

        print('User Email: ${userDataMap['email']}');

        setState(() {
          _userData = userDataMap;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _formDone == 0
        ? MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 3, 53, 41),
              title: Text('Job Profile'),
            ),
            backgroundColor: Color.fromARGB(255, 3, 53, 41),
            body: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/back.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                      Container(height: 4.0, color: Colors.white),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4.0),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage('assets/profile.png'),
                          ),
                        ),
                        SizedBox(height: 4),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_userData?['name'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color.fromARGB(255, 84, 30, 210),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Bio: ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${_userData?['bio'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                              255,
                                              59,
                                              183,
                                              25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(16),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Experience',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        for (var experience in _experiences)
                                          ListTile(
                                            leading: Icon(
                                              Icons.work,
                                              color: Colors.amber,
                                            ),
                                            title: Text(
                                              'Company: ${experience['companyName'] ?? 'N/A'}',
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Company Name: ${experience['companyName'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Description: ${experience['description'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'End Date: ${experience['endDate'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Skills: ${experience['skills'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(16),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Skills',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children:
                                              _skills.asMap().entries.map((
                                                entry,
                                              ) {
                                                final skill = entry.value;
                                                final skillIndex = entry.key;
                                                final skillColor =
                                                    skillColors[skillIndex %
                                                        skillColors.length];

                                                return Chip(
                                                  label: Text(skill),
                                                  backgroundColor: skillColor,
                                                  labelStyle: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(16),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Educations',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        for (var experience in _experiences)
                                          ListTile(
                                            leading: Icon(
                                              Icons.school,
                                              color: Colors.amber,
                                            ),
                                            title: Text(
                                              'Company: ${experience['companyName'] ?? 'N/A'}',
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Company Name: ${experience['companyName'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Description: ${experience['description'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'End Date: ${experience['endDate'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  'Skills: ${experience['skills'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigatorExample(),
          ),
        )
        : _buildPageForFormDoneValue(_formDone);
  }

  Widget _buildPageForFormDoneValue(int formDone) {
    switch (formDone) {
      case 1:
        return UserInfoPage();
      case 2:
        return AddEducationPage();
      case 3:
        return AddExperiencePage();
      case 4:
        return Page4();

      default:
        return Text('Invalid formdone value: $formDone');
    }
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 1')),
      body: Center(child: Text('This is Page 1')),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Center(child: Text('This is Page 2')),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Center(child: Text('This is Page 3')),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 4')),
      body: Center(child: Text('This is Page 4')),
    );
  }
}
