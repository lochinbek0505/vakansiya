import 'package:flutter/material.dart';
import 'package:vakansiya/Jobs/ListAllJobs.dart';
import 'package:vakansiya/Jobs/SearchJob.dart';
import 'package:vakansiya/Jobs/PostAJob.dart';
import 'package:vakansiya/Profile%20Components/ProfilePage.dart';

class BottomNavigatorExample extends StatefulWidget {
  @override
  _BottomNavigatorExampleState createState() => _BottomNavigatorExampleState();
}

class _BottomNavigatorExampleState extends State<BottomNavigatorExample> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        canvasColor: Color.fromARGB(255, 10, 25, 47), // Tungi fon
        primaryColor: Colors.white,
        unselectedWidgetColor: Colors.grey[400],
      ),
      child: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Разместить',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => jobsList()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobSearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobPostingPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobProfilePage()),
            );
          }
        },
      ),
    );
  }
}
