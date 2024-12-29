import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uni_app/screens/login_screen.dart';
import 'package:uni_app/screens/home_screen.dart';
import 'package:uni_app/services/api_service.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 2, 179, 187),
    primary: const Color.fromARGB(255, 2, 179, 187),
  ),
  // textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  runApp(App());
}

// void main() async {
//   // Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize locale data for the application
//   await initializeDateFormatting('ko_KR', null);

//   runApp(App());
// }

class App extends StatelessWidget {
  App({super.key});

  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _apiService.validateAutoLogIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.data == true) {
                  return HomeScreen();
                } else {
                  return LoginScreen();
                }
              },
            ),
      },
    );
  }
}
