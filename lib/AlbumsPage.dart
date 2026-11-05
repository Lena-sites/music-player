import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project11/AlbumDetailPage.dart';
import 'package:project11/main.dart';
import 'package:http/http.dart' as http;
import 'package:project11/NowPlayingPage.dart';
import 'package:project11/profile.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage>{
  final searchController = TextEditingController();
  List albums = [];
  bool isSearching = false;

  Future<void> cariAlbum() async {
    final url = Uri.https('itunes.apple.com','/search',
        <String, String> {
          'term': searchController.text,
          'entity': 'album',
          'limit': '10'
        }
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        albums = data['results'] ?? [];
        isSearching = true;
      });
    } else {
      setState(() {
        albums = [];
        isSearching = true;
      });
    }
    debugPrint('HTTP Error: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
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
                  hintText: "Search your favorite album",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              onSubmitted: (value){
                cariAlbum();
              },
            ),
            SizedBox(height: 18,),
            Expanded(
                child: isSearching ?
                  albums.isEmpty ? Center(child: Text('Pencarian tidak ditemukan', style: TextStyle(color: Colors.grey, fontSize: 14,))):
                  GridView.builder(
                    itemCount: albums.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 230,
                    ),
                    itemBuilder: (context, index){
                      return GestureDetector(
                        onTap: () async{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumDetailPage(album: albums[index])));
                        },
                        child:  Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //cover album
                                Image.network(
                                  (albums[index]['artworkUrl100'] ?? '').replaceAll('100x100bb', '600x600bb'),
                                  height: 140,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 140,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.music_note, size: 50,),
                                    );
                                  },
                                ),
                                SizedBox(height: 8,),
                                // Nama Album
                                Text(
                                  albums[index]['collectionName'] ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                // Artist name
                                Text(
                                  (albums[index]['releaseDate'] ?? '-').toString().substring(0, 4),
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
                    }
                ): //kondisi belom di search
              Center(
                child: Icon(Icons.library_books, color: Colors.grey[200], size: 150),
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
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if(index == 0){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SongsPage()),
                  );
                } else if (index == 2){
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