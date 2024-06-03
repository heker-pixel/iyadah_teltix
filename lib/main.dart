import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/screens/splash_screen.dart';
import 'utils/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: new ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1)),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }
}
