import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uni_app/constants/sizes.dart';
import 'package:uni_app/screens/calendar_screen.dart';
// import 'package:uni_app/screens/calendar2.dart';
import 'package:uni_app/screens/ibeacon_scanner.dart';
import 'package:uni_app/services/api_service.dart';
import 'package:uni_app/widgets/snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String logo = 'assets/images/logo_transparent.png';

  final ApiService _apiService = ApiService();

  int _selectedIndex = 0;

  void _onSelectTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('확인'),
          content: Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout();
              },
              child: Text('네'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // 비동기 작업 중 context가 변경되면 문제가 되므로, 비동기 작업 전에 필요한 데이터를 미리 캡쳐
    final currentContext = context;
    await _apiService.logout();

    // BuildContext가 여전히 유효한지 확인
    if (!currentContext.mounted) return;
    Navigator.pushReplacementNamed(currentContext, '/');
    showSnackBar(
      currentContext,
      "로그아웃 되었습니다.",
      Theme.of(currentContext).colorScheme.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        toolbarHeight: Sizes.size96,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logo,
              width: 133,
              height: 50,
            ),
            Text(
              "근태관리",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            onPressed: () => _showConfirmationDialog(context),
          ),
        ],
      ),
      // body: screens[_selectedIndex],
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child: Center(
              child: IBeaconScanner(),
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child: Center(
              child: CalendarScreen(),
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 2,
            child: Center(
              child: Text("사용자 정보"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 1,
        currentIndex: _selectedIndex,
        onTap: _onSelectTap,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.personRunning),
            label: '출퇴근',
            tooltip: '출퇴근 등록',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clock),
            label: '근태기록',
            tooltip: '출퇴근 이력 확인',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: '마이페이지',
            tooltip: '마이페이지',
          ),
        ],
      ),
    );
  }
}
