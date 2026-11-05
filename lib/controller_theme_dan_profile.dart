import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.dark);


//profile controller
class ProfileData {
  final namaController = TextEditingController(text: 'Your Name');
  final emailController = TextEditingController(text: 'your@email.com');
  final passwordController = TextEditingController(text: 'cath123'); //ini nnti jadi password awal buat ubah profile

  File? imageProfile;
  Uint8List? imageBytes;
}

final profileData = ProfileData();