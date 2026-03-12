import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/tontine_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/distribution_provider.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/welcome/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not configured: $e');
  }

  final apiClient = ApiClient();
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient)..tryAutoLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) => TontineProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => DistributionProvider(apiClient),
        ),
      ],
      child: const AurumApp(),
    ),
  );
}

class AurumApp extends StatelessWidget {
  const AurumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURUM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
