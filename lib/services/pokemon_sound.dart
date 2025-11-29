import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  Future<void> playPokemonSound(int pokemonId) async {
    try {
      await _audioPlayer.stop();

      final soundUrl =
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$pokemonId.ogg';

      await _audioPlayer.play(UrlSource(soundUrl));
    } catch (e) {
      debugPrint('Error playing Pokemon sound: $e');
    }
  }

  Future<void> playThemeSong() async {
    try {
      
      const themeSongUrl =
          'https://dn710602.ca.archive.org/0/items/pokemon-theme-song-collection/Poke%CC%81mon%20English%20Theme%20Song%20Collection/01%20-%20Poke%CC%81mon%20Theme.mp3';

      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(0.3);
      await _backgroundMusicPlayer.play(UrlSource(themeSongUrl));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('Error playing theme song: $e');
    }
  }

  Future<void> pauseThemeSong() async {
    await _backgroundMusicPlayer.pause();
    _isMusicPlaying = false;
  }

  Future<void> resumeThemeSong() async {
    await _backgroundMusicPlayer.resume();
    _isMusicPlaying = true;
  }

  Future<void> stopThemeSong() async {
    await _backgroundMusicPlayer.stop();
    _isMusicPlaying = false;
  }

  bool get isMusicPlaying => _isMusicPlaying;

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
    _backgroundMusicPlayer.dispose();
  }
}
