# 🎵 Music App

Aplikasi pemutar musik berbasis Flutter yang memungkinkan pengguna mencari lagu, menjelajahi album, memutar preview musik, dan melihat lirik lagu. Aplikasi ini menggunakan **iTunes Search API** untuk mengambil informasi lagu, album, artis, artwork, dan audio preview, serta **Lyrics.ovh API** untuk mengambil lirik lagu.

## ✨ Features

### 1. Songs
- Menampilkan daftar lagu berdasarkan hasil pencarian.
- Mencari lagu berdasarkan judul atau nama artis.
- Memutar lagu yang dipilih.
- Menampilkan informasi lagu seperti judul, artis.

### 2. Albums
- Menampilkan daftar album berdasarkan hasil pencarian.
- Mencari album berdasarkan nama album, judul atau nama artis.
- Menyediakan filter genre untuk membantu pengguna menemukan album sesuai kategori musik.
- Menampilkan detail album beserta daftar lagu di dalamnya.
- Memutar lagu individual atau seluruh lagu dalam album melalui fitur **Play All**.

### 3. Music Player
- Memutar dan menjeda lagu.
- Menampilkan informasi lagu yang sedang diputar.
- Mengatur posisi pemutaran melalui progress bar.
- Melakukan skip ke lagu sebelumnya atau berikutnya.
- Menampilkan mini player untuk mengakses pemutaran musik dari halaman lain.
- Menampilkan lirik lagu melalui fitur Lyrics.

### 4. Profile
- Mengubah nama pengguna.
- Mengubah alamat email.
- Mengubah password.
- Mengunggah dan menghapus foto profil.
- Menyimpan informasi profil selama aplikasi berjalan.

### 5. Theme Settings
- Mendukung Light Mode dan Dark Mode.
- Mengubah tema aplikasi melalui pengaturan profil.

## 🛠️ Technologies

Technologies and packages used in this project:

- **Flutter** – Framework for building the mobile application.
- **Dart** – Programming language used for application development.
- **iTunes Search API** – Retrieves song, album, artist, and artwork information, including 30-second audio previews.
- **Lyrics.ovh API** – Retrieves song lyrics.
- **HTTP** – Handles HTTP requests to retrieve data from external APIs.
- **just_audio** – Handles audio playback and music player controls.
- **image_picker** – Allows users to select profile pictures from their device gallery.

## 📂 Project Structure

Struktur folder utama project:

```text
lib/
├── main.dart
├── AlbumsPage.dart
├── AlbumDetailPage.dart
├── NowPlayingPage.dart
├── profile.dart
└── controller_theme_dan_profile.dart
```

| File | Description                                                                       |
|---|-----------------------------------------------------------------------------------|
| `main.dart` | Entry point dan konfigurasi utama aplikasi dan halaman pencarian dan daftar lagu. |
| `AlbumsPage.dart` | Halaman pencarian dan daftar album.                                               |
| `AlbumDetailPage.dart` | Menampilkan detail album dan daftar lagu.                                         |
| `NowPlayingPage.dart` | Halaman pemutar musik dan lirik.                                                  |
| `profile.dart` | Halaman profil dan pengaturan pengguna.                                           |
| `controller_theme_dan_profile.dart` | Mengelola data profil dan tema aplikasi.                                          |

## 🌐 APIs

This application uses two external APIs to provide music information and lyrics.

### 1. iTunes Search API
[https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html)

Used to retrieve:
- Song information.
- Album information.
- Artist names and album artwork.
- Song preview URLs.

### 2. Lyrics.ovh API
[https://api.lyrics.ovh](https://api.lyrics.ovh)

Used to retrieve song lyrics based on the artist's name and song title.

## ⚠️ Limitations & Notes

- **Music Playback:** Songs can only be played for 30 seconds using the preview URLs provided by the iTunes API. Full-length music playback requires a paid API or service.
- **Lyrics:** Lyrics are retrieved from the free Lyrics.ovh API. Since timestamp information is not available, lyrics are displayed in full text and do not synchronize with the song's playback duration.
- **Data Availability:** Song previews and lyrics depend on the availability of data from their respective APIs.
- **Profile Data:** Profile information and profile pictures are currently stored during the application session and are not permanently saved to a database.
---

**Developed with Flutter & Dart.**