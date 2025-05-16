import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/Components/BottomNavigator.dart';
import 'package:vakansiya/Profile%20Components/Logine.dart';
import 'package:vakansiya/UpdateProfile/EditExperience.dart';
import 'package:vakansiya/UpdateProfile/UpdateBio.dart';
import 'package:vakansiya/UpdateProfile/updateskills.dart';
import 'package:vakansiya/formsForFirst/education.dart';
import 'package:vakansiya/formsForFirst/jobdata.dart';
import 'package:vakansiya/formsForFirst/userInfoData.dart';

void main() {
  runApp(JobProfilePage());
}

class JobProfilePage extends StatefulWidget {
  @override
  State<JobProfilePage> createState() => _JobProfilePageState();
}

class _JobProfilePageState extends State<JobProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _experiences = [];
  Map<String, dynamic>? _userData;
  List<dynamic> _skills = [];
  int _formDone = 0;
  final List<Color> skillColors = [
    Colors.teal,
    Colors.deepPurple,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.green,
    Colors.blueGrey,
  ];
  Widget buildLogoutCard(BuildContext context) {
    return Center(
      child: Card(
        color: Color(0xFF1E1E1E), // Tungi fon rangi
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 48),
              SizedBox(height: 16),
              Text(
                'Вы действительно хотите выйти?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>LoginPage())); // yo'nalishni moslang
                },
                icon: Icon(Icons.logout),
                label: Text('Выйти'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          await _firestore
              .collection('userdata')
              .doc(_user!.uid) // Use the current user's UID as the document ID
              .get();

      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('formdone')) {
          // If 'formdone' field is present, set its value
          setState(() {
            _formDone = userData['formdone'];
          });
        } else {
          // If 'formdone' field is not present, set it to 5
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

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      final userData =
          await _firestore.collection('userdata').doc(user.uid).get();
      if (userData.exists) {
        final userDataMap = userData.data() as Map<String, dynamic>;

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

        // Fetch the "skills" field from the user's Firestore document
        final skills = userDataMap['skills'] as List<dynamic>;
        setState(() {
          _skills = skills; // Assign the skills to the _skills list
        });

        // Now you can access the 'email' property from userDataMap
        print('User Email: ${userDataMap['email']}');

        // Update your widget with the user data
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
          home: WillPopScope(
            onWillPop: () async {
              // Return true to allow navigation back, return false to prevent it
              return false; // Prevent back navigation
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Color(0xFF1F1F1F),
                title: Text('Профиль', style: TextStyle(color: Colors.white)),
              ),
              backgroundColor: Color(0xFF121212),
              body: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    // Background Gradient
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserDataPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                          ),
                          SizedBox(height: 4),
                          Card(
                            color: Color(0xFF1E1E1E), // Dark card background
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2A2A2A),
                                    Color(0xFF1E1E1E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      '${_userData?['name'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Био: ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${_userData?['bio'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.greenAccent.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 6.0),

                          // EDUCATION CARD
                          // Education Card
                          Card(
                            color: Color(0xFF1E1E1E),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Образование',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditExperience(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.white24),
                                  SizedBox(height: 10),
                                  for (var exp in _experiences)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp['companyName'] ?? 'No company',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.tealAccent,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          _infoText(
                                            'Description',
                                            exp['description'],
                                          ),
                                          _infoText(
                                            'Start Date',
                                            exp['startDate'],
                                          ),
                                          _infoText('End Date', exp['endDate']),
                                          _infoText('Skills', exp['skills']),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Skills Card
                          Card(
                            color: Color(0xFF1E1E1E),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Навыки',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SkillsPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.white24),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        _skills.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final skill = entry.value;
                                          final bgColor =
                                              skillColors[index %
                                                  skillColors.length];
                                          return Chip(
                                            label: Text(skill),
                                            backgroundColor: bgColor,
                                            labelStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                      buildLogoutCard(context)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // bottomNavigationBar: BottomNavigatorExample(),
            ),
          ),
        )
        : _buildPageForFormDoneValue(_formDone);
  }

  Widget _buildPageForFormDoneValue(int formDone) {
    switch (formDone) {
      case 1:
        return AddExperiencePage();
      case 2:
        return AddEducationPage();
      case 3:
        return UserInfoPage();
      case 4:
        return Page4();
      case 5:
        return Page5();
      default:
        return Text('Invalid formdone value: $formDone');
    }
  }

  Widget _infoText(String label, String? value) {
    return Text(
      '$label: ${value ?? 'N/A'}',
      style: TextStyle(color: Colors.white70, fontSize: 14),
    );
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

class Page5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 5')),
      body: Center(child: Text('This is Page 5')),
    );
  }
}
