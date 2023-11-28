import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_amazink/pages/login_page.dart';
// import 'package:pos_amazink/pages/home_page.dart';

import 'theme/style.dart';
import 'utils/setting_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  await SettingSharedPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Amazink POS',
      theme: appTheme,
      home: const LoginPage(),
    );
  }
}
