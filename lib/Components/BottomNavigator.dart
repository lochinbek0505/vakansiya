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
  int _selectedIndex = 0;

  // Sahifalarni bir marta yaratamiz va IndexedStack ichida saqlaymiz
  final List<Widget> _pages = [
    jobsList(),
    JobSearchPage(),
    JobPostingPage(),
    JobProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          canvasColor: Color.fromARGB(255, 10, 25, 47),
          primaryColor: Colors.white,
          unselectedWidgetColor: Colors.grey[400],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
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
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
