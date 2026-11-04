import 'dart:io';
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.dark);


//profile controller
class ProfileData {
  final namaController = TextEditingController(text: 'Your Name');
  final emailController = TextEditingController(text: 'your@email.com');
  final passwordController = TextEditingController(text: 'password123');

  File? imageProfile;
}

final profileData = ProfileData();