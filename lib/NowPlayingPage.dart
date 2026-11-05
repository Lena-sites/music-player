import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingPage extends StatefulWidget {
  final Map song;
  final bool preloaded;

  const NowPlayingPage({
    super.key,
    required this.song,
    this.preloaded = false,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  bool showLyrics = false;
  bool isLoading = true;

  String lyrics = '';
  bool isLoadingLyrics = false;

  double? _dragPosition;

  late Map _currentSong;
  StreamSubscription? _indexSub;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;

    // memantau pergantian lagu (saat lagu otomatis lanjut / next)
    _indexSub = AudioService.player.currentIndexStream.listen((_) {
      if (isLoading) return; //abaikan event dari lagu lama selama loading
      final tag = AudioService.player.sequenceState.currentSource?.tag;
      if (tag is Map && tag['trackId'] != _currentSong['trackId']) {
        if (!mounted) return;
        setState(() {
          _currentSong = tag;
          lyrics = '';
        });
        if (showLyrics) getLyrics();
      }
    });

    if (widget.preloaded) {
      isLoading = false; // playlist sudah dimuat dari AlbumDetailPage
    } else {
      // Tunda sampai frame selesai dibangun, supaya MiniPlayer
      // tidak di-setState saat proses build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) playSong();
      });
    }
  }

  Future<void> playSong() async {
    try {
      // Hentikan lagu sebelumnya terlebih dahulu
      await AudioService.player.stop();

      final previewUrl = widget.song['previewUrl'];

      if (previewUrl == null) return;

      // Memasang audio source dari lagu yang baru dipilih
      await AudioService.player.setAudioSource(
        AudioSource.uri(
          Uri.parse(previewUrl),
          tag: widget.song,
        ),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      // Memutar lagu yang baru dipilih
      AudioService.player.play();

    } catch (e) {
      debugPrint('Gagal memutar lagu: $e');
    } finally {
      if (mounted && isLoading) {
        setState(() => isLoading = false);
      }
    }
  }

  String formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString();
    String seconds =
    (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  Future<void> getLyrics() async {
    try {
      setState(() {
        isLoadingLyrics = true;
        lyrics = '';
      });

      //encodeComponent digunakan untuk memastikan nama artis dan judul lagu dapat dimasukkan ke URL API Lyrics.ovh
      final artist = Uri.encodeComponent(
        _currentSong['artistName'] ?? '',
      );

      final title = Uri.encodeComponent(
        _currentSong['trackName'] ?? '',
      );

      final url = Uri.parse(
        'https://api.lyrics.ovh/v1/$artist/$title',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          lyrics = data['lyrics'] ?? 'Lirik tidak ditemukan.';
        });
      } else if (response.statusCode == 404) { //404 Error (Not Found)
        setState(() {
          lyrics = 'Lirik tidak ditemukan untuk lagu ini.';
        });
      } else {
        setState(() {
          lyrics = 'Gagal mengambil lirik.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        lyrics = 'Tidak dapat mengambil lirik.';
      });
      debugPrint('Lyrics Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLyrics = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong;
    final cs = Theme.of(context).colorScheme;
    final artwork = song['artworkUrl100'] ?? '';
    final highQualityArtwork = artwork.replaceAll('100x100bb', '1200x1200bb');

    return Scaffold(
      appBar: AppBar(
        foregroundColor: cs.onSurface,
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            // Cover lagu
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                highQualityArtwork,
                height: 280,
                width: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: 280,
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.music_note,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            // Judul dan artis
            Text(
              song['trackName'] ?? '-',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              song['artistName'] ?? '-',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            // Progress lagu
            StreamBuilder<Duration?>(
              //mengambil data durasi lagu yang sedang dimainkan
              stream: AudioService.player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? AudioService.player.duration;
                final maxDuration = duration != null && duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                return StreamBuilder<Duration>(
                  //informasi posisi pemutaran lagu yang sedang berlangsung secara berkala
                  stream: AudioService.player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final currentPosition = (_dragPosition ?? position.inMilliseconds.toDouble()).clamp(0.0, maxDuration);
                    return Column(
                      children: [
                        Slider(
                          value: currentPosition,
                          min: 0,
                          max: maxDuration,
                          activeColor: const Color(0xFF10B981),
                          inactiveColor: Colors.grey[700],
                          // Posisi sementara saat slider digeser
                          onChanged: duration == null ? null : (value) {
                            setState(() {
                              _dragPosition = value;
                            });
                          },
                          // Pindah ke posisi yang dipilih
                          // setelah pengguna selesai menggeser
                          onChangeEnd: (value) async {
                            await AudioService.player.seek(
                              Duration(
                                milliseconds: value.toInt(),
                              ),
                            );
                            if (mounted) {
                              setState(() {
                                _dragPosition = null;
                              });
                            }
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12,),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(
                                  Duration(
                                    milliseconds:
                                    currentPosition.toInt(),
                                  ),
                                ),
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                formatDuration(duration ?? Duration.zero,),
                                style: TextStyle(color: Colors.grey,),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(height: 15),
            // Kontrol musik
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    AudioService.player.seek(Duration.zero);
                  },
                  icon: Icon(
                    Icons.replay,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 25),
                StreamBuilder<PlayerState>(
                  stream: AudioService.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;
                    final isBuffering = playerState?.processingState == ProcessingState.loading || playerState?.processingState == ProcessingState.buffering;

                    if (isLoading || isBuffering) {
                      return const SizedBox(
                        width: 65,
                        height: 65,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10B981),
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await AudioService.player.pause();
                        } else {
                          await AudioService.player.play();
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Color(0xFF10B981), size: 65),
                    );
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  onPressed: () {
                    AudioService.player.seek(Duration.zero);
                    AudioService.player.play();
                  },
                  icon: Icon(
                    Icons.restart_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            // Tombol Lyrics
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    showLyrics = !showLyrics;
                  });
                  if (showLyrics) {
                    getLyrics();
                  }
                },
                icon: Icon(showLyrics ? Icons.keyboard_arrow_up : Icons.lyrics_outlined),
                label: Text(showLyrics ? 'Hide Lyrics' : 'Show Lyrics',),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF10B981),
                  side: BorderSide(
                    color: Color(0xFF10B981),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Bagian lirik
            if (showLyrics)
              Container(
                width: double.infinity,
                height: 300,
                margin: EdgeInsets.only(top: 15),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoadingLyrics ? Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                    : SingleChildScrollView(
                  child: Text(
                    lyrics.isEmpty ? 'Lirik tidak tersedia.' : lyrics,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



// Satu instance player untuk seluruh aplikasi
class AudioService {
  static final AudioPlayer player = AudioPlayer();
}

// Mini player dan bakal tampil di atas navigation bar saat ada lagu yang sedang diputar
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = AudioService.player;

    return StreamBuilder<SequenceState?>(
      initialData: player.sequenceState,
      stream: player.sequenceStateStream.asyncMap((e) => e),
      builder: (context, snapshot) {
        final tag = snapshot.data?.currentSource?.tag;

        // Belum ada lagu, tampilannya disembunyikan
        if (tag is! Map) return const SizedBox.shrink();
        final song = tag;

        return Material(
          color: Color(0xFF1E1E1E),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlayingPage(song: song, preloaded: true),),);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress tipis di bagian atas
                StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, durSnap) {
                    final total = durSnap.data?.inMilliseconds ?? 0;
                    return StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, posSnap) {
                        final pos = posSnap.data?.inMilliseconds ?? 0;
                        return LinearProgressIndicator(
                          value: total > 0 ? (pos / total).clamp(0.0, 1.0) : 0,
                          minHeight: 2,
                          color: const Color(0xFF10B981),
                          backgroundColor: Colors.grey[800],
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song['artworkUrl100'] ?? '',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song['trackName'] ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              song['artistName'] ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol play / pause
                      StreamBuilder<PlayerState>(
                        initialData: player.playerState,
                        stream: player.playerStateStream.asyncMap((e) => e),
                        builder: (context, stateSnap) {
                          final state = stateSnap.data;
                          final playing = state?.playing ?? false;
                          final processing = state?.processingState;

                          if (processing == ProcessingState.loading || processing == ProcessingState.buffering) {
                            return SizedBox(
                              width: 40,
                              height: 40,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            );
                          }
                          return IconButton(
                            icon: Icon(
                              playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: Color(0xFF10B981),
                              size: 40,
                            ),
                            onPressed: () async {
                              if (playing) {
                                await player.pause();
                              } else if (processing ==
                                  ProcessingState.completed) {
                                // Playlist sudah habis, ulang dari awal
                                await player.seek(Duration.zero, index: 0);
                                player.play();
                              } else {
                                player.play();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}