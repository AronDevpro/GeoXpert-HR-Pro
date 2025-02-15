import 'package:flutter/material.dart';
import 'package:geoxpert_hr_pro/src/providers/auth_notifier.dart';
import 'package:geoxpert_hr_pro/src/services/app_routes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("3503abf7-8a75-4ae3-af4a-5da9b88afd01");

  OneSignal.Notifications.requestPermission(true);
  runApp(
    ChangeNotifierProvider(create: (context)=>AuthNotifier(),
    child: MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(fontFamily: 'Monda'),
      debugShowCheckedModeBanner: false,
      title: 'SHRMS - Attendance',
      routerConfig: _appRouter.config(),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const LoginScreen(),
      //   '/forget-password': (context) => const ForgetPasswordScreen(),
      //   '/verify-otp': (context) => const VerifyOtp(),
      //   '/change-password': (context) => const ChangePasswordScreen(),
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}
