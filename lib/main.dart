import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project11/AlbumsPage.dart';
import 'package:project11/NowPlayingPage.dart';
import 'package:project11/profile.dart';
import 'package:project11/controller_theme_dan_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              surface: Color(0xFF1E1E1E),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF10B981),
              unselectedItemColor: Colors.grey,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.grey),
              prefixIconColor: Colors.grey,
            ),
          ),
          home: SongsPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class SongsPage extends StatefulWidget{

  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage>{
  final searchController = TextEditingController();
  List songs = [];
  bool isSearching = false;

  // late final bool isDarkMode;
  // late final Function(bool) onThemeChanged;

  Future<void> cariLagu() async {
    if (searchController.text.isEmpty) {
      setState(() {
        songs = [];
      });
      return;
    }
    final url = Uri.https('itunes.apple.com','/search',
        <String, String> {
          'term': searchController.text,
          'entity': 'song',
          'limit': '10'
        }
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        songs = data['results'] ?? [];
        isSearching = true;
      });
    } else {
      setState(() {
        songs = [];
        isSearching = true;
      });
    }
    debugPrint('HTTP Error: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined),
                  hintText: "What do you want to listen to?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    isSearching = false;
                    songs = [];
                  });
                }
              },
              onSubmitted: (value){
                cariLagu();
              },
            ),
            SizedBox(height: 8,),
            Expanded(
                child: isSearching ?
                songs.isEmpty ? Center(child: Text('Pencarian tidak ditemukan', style: TextStyle(color: Colors.grey, fontSize: 14,))):
                GridView.builder(
                  itemCount: songs.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 230,
                  ),
                  itemBuilder: (context, index) {
                    // Menentukan data yang ditampilkan
                    final song = songs[index];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlayingPage(song: song)));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover album
                              Image.network(
                                (song['artworkUrl100'] ?? '').replaceAll('100x100bb', '1200x1200bb'),
                                height: 140,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Container(
                                      height: 140,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.music_note, size: 50),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              // Judul lagu
                              Text(
                                song['trackName'] ?? song['name'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              // Nama artis
                              Text(
                                song['artistName'] ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ): //kondisi klo belum ada yang di search
                Center(
                  child: Icon(Icons.queue_music_outlined, color: Colors.grey[200], size: 150,),
                )
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          BottomNavigationBar(
            currentIndex: 0,
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