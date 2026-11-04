import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project11/controller_theme_dan_profile.dart';

import 'AlbumsPage.dart';
import 'NowPlayingPage.dart';
import 'main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  // Controller untuk mengedit data
  final namaController = profileData.namaController;
  final emailController = profileData.emailController;
  final passwordController = profileData.passwordController;

  File? imageProfile;

  bool showPassword = false;

  // Mengambil foto dari galeri
  Future<void> pilihFoto() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        profileData.imageProfile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),
            // FOTO PROFILE
            GestureDetector(
              onTap: pilihFoto,
              child: Stack(
                children: [
                  ClipOval(
                    child: profileData.imageProfile != null
                        ? Image.file(
                      profileData.imageProfile!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey,
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF10B981),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // NAMA
            TextField(
              controller: namaController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your name',
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // EMAIL
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 30),

            // THEME MODE
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: currentTheme == ThemeMode.dark,
                  activeTrackColor: const Color(0xFF10B981),
                  onChanged: (value) {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MiniPlayer(),
            BottomNavigationBar(
              currentIndex: 2,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if(index == 0){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SongsPage()),
                  );
                } else if (index == 1){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AlbumsPage()),
                  );
                }else if (index == 2){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profile()),
                  );
                }
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Songs'),
                BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Albums'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ],
        )
    );
  }
}
