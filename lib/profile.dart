import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project11/controller_theme_dan_profile.dart';
import 'package:project11/AlbumsPage.dart';
import 'package:project11/NowPlayingPage.dart';
import 'package:project11/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // pengaturan foto profile
  // Mengambil foto dari galeri menggunakan ImagePicker
  Uint8List? imageBytes;
  Future<void> _pilihFoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        profileData.imageBytes = bytes;
      });
    }
  }
  // Menghapus foto profil yang sedang digunakan
  void _hapusFoto() {
    setState(() {
      profileData.imageBytes = null;
    });
    _snack('Foto profil dihapus');
  }

  // Menampilkan pilihan untuk memilih atau menghapus foto
  void _showFotoOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(ctx); // Menutup bottom sheet
                _pilihFoto();
              },
            ),
            // Pilihan hapus foto hanya muncul jika sudah ada foto
            if (profileData.imageBytes != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Hapus foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _hapusFoto();
                },
              ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Menampilkan pesan sementara menggunakan SnackBar
  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  // Menampilkan bottom sheet dan menangani hasil setelah ditutup
  Future<void> _openSheet(Widget sheet, String successMsg) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Memungkinkan bottom sheet menyesuaikan keyboard
      showDragHandle: true,
      builder: (_) => sheet,
    );
    // jikaa data berhasil disimpan, perbarui tampilan dan tampilkan pesan
    if (ok == true && mounted) {
      setState(() {});
      _snack(successMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil warna berdasarkan theme aplikasi
    final cs = Theme.of(context).colorScheme;
    // Mengambil nama dan email dari controller
    final nama = profileData.namaController.text.trim();
    final email = profileData.emailController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          // HEADER
          Center(
            child: GestureDetector(
              onTap: _showFotoOptions, // Ketika foto ditekan, tampilkan pilihan foto
              child: Stack(
                children: [
                  // Menampilkan foto profil berbentuk lingkaran
                  ClipOval(
                    child: profileData.imageBytes != null ? Image.memory(
                      profileData.imageBytes!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                        : Container( // Menampilkan ikon default jika belum ada foto
                      width: 120,
                      height: 120,
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 70, color: cs.onSurfaceVariant),
                    ),
                  ),
                  // Ikon kamera di pojok kanan bawah foto profil
                   Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            nama.isEmpty ? 'Pengguna' : nama,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            email.isEmpty ? 'Email belum diisi' : email,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: 28),

          // pengaturan AKUN
          _SectionLabel('AKUN'),
          _SectionCard(
            children: [
              // Membuka form untuk mengubah nama
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Nama',
                value: nama.isEmpty ? 'Belum diisi' : nama,
                onTap: () =>
                    _openSheet(const _EditNameSheet(), 'Nama diperbarui'),
              ),
              // Membuka form untuk mengubah email
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email.isEmpty ? 'Belum diisi' : email,
                onTap: () =>
                    _openSheet(const _EditEmailSheet(), 'Email diperbarui'),
              ),
              // Membuka form untuk mengubah password
              _InfoTile(
                icon: Icons.lock_outline,
                label: 'Password',
                value: '••••••••', // untuk menyamarkan passwordnya (tampilannya titik2 nnti)
                onTap: () => _openSheet(const _ChangePasswordSheet(), 'Password berhasil diubah'),
              ),
            ],
          ),
          SizedBox(height: 24),

          // pengaturan TAMPILAN (dark mode)
          _SectionLabel('TAMPILAN'),
          _SectionCard(
            children: [
              // ValueListenableBuilder dipakai untuk mendengarkan perubahan themeNotifier
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentTheme, child) {
                  return ListTile(
                    leading: Icon(Icons.dark_mode_outlined),
                    title: Text('Dark Mode'),
                    trailing: Switch(
                      // Switch aktif jika theme menggunakan Dark Mode
                      value: currentTheme == ThemeMode.dark,
                      // Menghilangkan efek warna saat switch ditekan
                      overlayColor:
                      WidgetStateProperty.all(Colors.transparent),
                      // Mengatur warna tombol switch
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        return states.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.grey.shade600;
                      }),
                      // Mengatur warna background switch
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        return states.contains(WidgetState.selected)
                            ? Colors.green
                            : Colors.grey.shade300;
                      }),
                      // Mengubah theme aplikasi ketika switch ditekan
                      onChanged: (value) {
                        themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      //ini navigasi yg bagian bawah
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          BottomNavigationBar(
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SongsPage()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AlbumsPage()),
                );
              }
              // index 2 = halaman ini, tidak perlu pindah
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Songs'),
              BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Albums'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}

// KOMPONEN UI
// Widget untuk menampilkan judul setiap bagian pengaturan
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// Card untuk mengelompokkan beberapa pengaturan
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(const Divider(height: 1, indent: 56));
      }
    }
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: items),
    );
  }
}

// Widget untuk menampilkan informasi akun yang dapat ditekan
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
      subtitle: Text(value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          )),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// Kerangka bottom sheet yang digunakan kembali untuk setiap form
class _SheetScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String buttonLabel;
  final VoidCallback onSubmit;

  const _SheetScaffold({
    required this.title,
    this.subtitle,
    required this.children,
    required this.buttonLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Memberikan ruang agar form tidak tertutup keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              // Subtitle hanya ditampilkan jika memiliki nilai
              if (subtitle != null) ...[
                SizedBox(height: 6),
                Text(subtitle!,style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
              SizedBox(height: 20),
              ...children,  // Menampilkan field form yang dikirimkan
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Field password dengan tombol lihat/sembunyikan sendiri-sendiri.
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction action;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
    this.action = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true; // Kondisi awal password disembunyikan

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure, // Menyembunyikan karakter password
      autofocus: widget.autofocus,
      textInputAction: widget.action,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(Icons.lock_outline),
        // Tombol untuk melihat atau menyembunyikan password
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// SHEET untuk UBAH NAMA
class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet();

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  // Mengisi field dengan nama yang sudah tersimpan sebelumnya
  late final TextEditingController _nama = TextEditingController(text: profileData.namaController.text);

  @override
  void dispose() {
    _nama.dispose(); // Membersihkan controller setelah widget ditutup
    super.dispose();
  }

  // Memvalidasi dan menyimpan nama baru
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    profileData.namaController.text = _nama.text.trim();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Ubah nama',
      buttonLabel: 'Simpan',
      onSubmit: _save,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _nama,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
            // Memastikan nama tidak kosong
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
            decoration: InputDecoration(
              labelText: 'Nama',
              prefixIcon: const Icon(Icons.badge_outlined),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// SHEET untuk UBAH EMAIL
class _EditEmailSheet extends StatefulWidget {
  const _EditEmailSheet();

  @override
  State<_EditEmailSheet> createState() => _EditEmailSheetState();
}

class _EditEmailSheetState extends State<_EditEmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  // kalau belum ada password tersimpan, tidak perlu konfirmasi
  bool get _needPassword => profileData.passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Memvalidasi dan menyimpan email baru
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    profileData.emailController.text = _email.text.trim();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final current = profileData.emailController.text.trim();

    return _SheetScaffold(
      title: 'Ubah email',
      subtitle: current.isEmpty ? null : 'Email saat ini: $current',
      buttonLabel: 'Simpan email',
      onSubmit: _save,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction:
                _needPassword ? TextInputAction.next : TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_needPassword) _save();
                },
                // Memvalidasi format email sebelum disimpan
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Email tidak boleh kosong';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value); //memeriksa apakah format email yang dimasukkan pengguna valid atau tidak
                  if (!ok) return 'Format email tidak valid';
                  if (value.toLowerCase() == current.toLowerCase()) {
                    return 'Email sama dengan yang sekarang';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email baru',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              // Konfirmasi password hanya muncul jika diperlukan
              if (_needPassword) ...[
                SizedBox(height: 16),
                _PasswordField(
                  controller: _password,
                  label: 'Password saat ini',
                  action: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  // Memeriksa apakah password yang dimasukkan benar
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Masukkan password untuk konfirmasi';
                    }
                    if (v != profileData.passwordController.text) {
                      return 'Password salah';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// SHEET untuk UBAH PASSWORD
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();

  // Menentukan apakah pengguna harus memasukkan password lama
  bool get _needCurrent => profileData.passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    super.dispose();
  }
  // Memvalidasi password dan menyimpan password baru
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    profileData.passwordController.text = _new.text;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Ubah password',
      buttonLabel: 'Simpan password',
      onSubmit: _save,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Field password lama hanya muncul jika password sudah tersedia
              if (_needCurrent) ...[
                _PasswordField(
                  controller: _current,
                  label: 'Password lama',
                  autofocus: true,
                  validator: (v) =>
                  v != profileData.passwordController.text ? 'Password lama salah' : null,
                ),
                SizedBox(height: 16),
              ],
              // Field untuk memasukkan password baru
              _PasswordField(
                controller: _new,
                label: 'Password baru',
                autofocus: !_needCurrent,
                action: TextInputAction.done,
                onSubmitted: (_) => _save(),
                //cek panjang pass nya mininal 6
                validator: (v) =>
                (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}