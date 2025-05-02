import 'package:flutter/material.dart';
import 'package:matefit_frontend/screens/NutritionTipsScreen.dart';
import 'screens/add_challenge_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_details_screen.dart';
import 'screens/challenges_screen.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MateFit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/home': (context) => MainScreen(),
        '/add_challenge': (context) => AddChallengeScreen(),
        '/challenges': (context) => ChallengesScreen(),
        '/nutrition_tips': (context) => NutritionTipsTab(),

        '/profile': (context) => ProfileDetailsScreen(),
      },
    );
  }
}
