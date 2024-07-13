import 'package:flutter/material.dart';
import 'package:uni_app/screens/login_screen.dart';

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
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  final String logo = 'assets/images/logo_transparent.png';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: LoginScreen(logo: logo),
    );
  }
}
