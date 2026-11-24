import 'package:flutter/material.dart';

import 'package:pharmadex/screens/home_page.dart';
import 'package:pharmadex/screens/search_page.dart';
import 'package:pharmadex/screens/profile_page.dart';
import 'package:pharmadex/screens/task_list_page.dart';
import 'package:pharmadex/services/notification_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), SearchPage(), TaskListPage(), ProfilePage()];
  
  @override
  void initState() {
    super.initState();
    NotificationService.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
