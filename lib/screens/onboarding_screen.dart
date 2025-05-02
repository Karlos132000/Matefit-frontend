import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final List<String> onboardingPages = [
    'Get ready to meet new people',
    'Make your own sport body with your friends',
    'Organize your workouts and join different activities',
    'Track your activity and go to your goal',
  ];

  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (currentPage < onboardingPages.length - 1) {
        setState(() {
          currentPage++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // جعل الخلفية بيضاء
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/onboarding_illustration.png', // المسار الصحيح للصورة
              width: 150,
              height: 200,
            ),

            const SizedBox(height: 32),

            Text(
              onboardingPages[currentPage],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black, // لون النص أسود
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sign_up');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF655CD1),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // التنقل إلى شاشة تسجيل الدخول
              },
              child: Text(
                'I already have an account',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF655CD1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}