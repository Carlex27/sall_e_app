import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sall_e_app/firebase_options.dart';
import 'package:sall_e_app/routes/app_router.dart';
import 'package:sall_e_app/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = AppRouter().router;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SALL-E',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}


