import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:project11/NowPlayingPage.dart';

class AlbumDetailPage extends StatefulWidget {
  final Map album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  List songs = [];
  bool isLoading = true;

  // AudioPlayer untuk memutar lagu dan playlist
  final AudioPlayer player = AudioService.player;

  @override
  void initState() {
    super.initState();
    getAlbumSongs();
  }

  Future<void> getAlbumSongs() async {
    final url = Uri.https('itunes.apple.com', '/lookup', {
      'id': widget.album['collectionId'].toString(),
      'entity': 'song',
    });

    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          songs = (data['results'] as List).where((item) => item['wrapperType'] == 'track').toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  //Memutar semua lagu secara berurutan
  // Membuat playlist album dan memulai dari lagu tertentu
  // Membuat playlist album, mulai dari index tertentu, lalu buka Now Playing
  // Mengembalikan false kalau tidak ada lagu yang bisa diputar
  Future<bool> playAlbum(int initialIndex) async {
    final List playableSongs = songs.where((item) => item['previewUrl'] != null &&
        item['previewUrl'].toString().isNotEmpty).toList();

    if (playableSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada lagu yang bisa diputar')),
      );
      return false;
    }

    final playlist = playableSongs.map((item){
      return AudioSource.uri(Uri.parse(item['previewUrl']),
        tag: item, //penyimpanan identitas/metadata dari lagu yg sedang di-play
      );
    }).toList();

    await player.stop();

    //membuat kumpulan sumber audio
    await player.setAudioSources(
      playlist,
      initialIndex: initialIndex,
    );

    player.play();
    return true;
  }

  // Putar semua lagu dari awal
  //dia bisa lanjut ke next lagu karna di playAlbum itu ada penyimpanan list, dan antrian ini bakal diputer satu2
  Future<void> playAll() async {
    await playAlbum(0);
  }

  // Putar dari lagu yang dipilih
  Future<void> openSong(Map song) async {
    if (song['previewUrl'] == null || song['previewUrl'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview lagu tidak tersedia')),
      );
      return;
    }

    final List playableSongs = songs.where((item) => item['previewUrl'] != null && item['previewUrl'].toString().isNotEmpty).toList();

    // Index dihitung dari daftar yang bisa diputar, bukan dari `songs`
    final int selectedIndex = playableSongs.indexWhere((item) => item['trackId'] == song['trackId']);

    await playAlbum(selectedIndex);

    final ok = await playAlbum(selectedIndex);

    if (!ok || !mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlayingPage(song: song, preloaded: true,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album['collectionName'] ?? 'Album'),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()):
      SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                (widget.album['artworkUrl100'] ?? '').replaceAll('100x100bb', '600x600bb'),
                height: 280,
                width: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: 280,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: songs.isEmpty ? null : playAll,
              icon: Icon(Icons.play_arrow),
              label: Text('Play All'),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(18),
              child:  ListView.builder(
                itemCount: songs.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: (){
                      openSong(songs[index]);
                    },
                    title: Text(songs[index]['trackName'] ?? '-'),
                    subtitle: Text(songs[index]['artistName'] ?? '-'),
                    trailing: Icon(Icons.play_arrow),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}