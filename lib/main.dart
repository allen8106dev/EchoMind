import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  await NotificationService.init();

  await NotificationService
      .showPersistentNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EchoMind',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}