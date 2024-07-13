import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String logo = 'assets/images/logo_transparent.png';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          leading: Image.asset(
            logo,
            width: 133,
            height: 50,
            alignment: Alignment.center,
          ),
          title: const Text('근태관리'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: const Center(
          child: Column(
            children: [Text('출근하기')],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.run_circle_outlined),
              label: '출퇴근',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm_outlined),
              label: '근태기록',
            ),
          ],
        ),
      ),
    );
  }
}
