import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  Future<void> _enableNotifications(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', enable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turn on Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get the most out of the app by staying up to date with what’s happening.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: darkNeutralColor,
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                _enableNotifications(true);
                Navigator.pushNamed(context, '/profile_picture');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Allow notifications',
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
                _enableNotifications(false);
                Navigator.pushNamed(context, '/profile_picture');
              },
              child: Text(
                "Don't allow",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}