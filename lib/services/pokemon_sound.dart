// Import the audioplayers package - allows us to play audio files
// WHY: We need this to play Pokemon cry sounds from the internet
import 'package:audioplayers/audioplayers.dart';

// This class handles playing Pokemon cry sounds
// WHAT: Manages audio playback for Pokemon sounds (their unique cries/voices)
// WHY: Makes the app more interactive and fun by playing sounds when viewing Pokemon
class AudioService {
  // Private audio player instance - this is the object that actually plays the sounds
  // The underscore (_) makes it private to this class
  // final means once created, we always use this same AudioPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Plays the cry sound for a specific Pokemon
  // WHAT: Downloads and plays the Pokemon's unique sound from the internet
  // WHY: Each Pokemon has a distinct cry that makes them recognizable
  //
  // Parameters:
  //   pokemonId: The ID number of the Pokemon (like 25 for Pikachu)
  //
  // Future<void> means this takes time but doesn't return a value
  // async means we can use 'await' to wait for slow operations
  Future<void> playPokemonCry(int pokemonId) async {
    // try-catch block to handle errors gracefully
    // WHY: If the sound file doesn't exist or internet fails, we don't want the app to crash
    try {
      // First, stop any currently playing sound
      // WHY: We don't want multiple Pokemon cries playing at the same time
      // await means "wait for the current sound to stop before continuing"
      await _audioPlayer.stop();

      // Build the URL for this Pokemon's cry sound
      // Pokemon cries are hosted on GitHub in .ogg format (audio file type)
      // Example: https://raw.githubusercontent.com/PokeAPI/cries/.../25.ogg for Pikachu
      final soundUrl =
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$pokemonId.ogg';

      // Play the sound from the URL
      // UrlSource tells the audio player to stream the sound from the internet
      // await means "wait for the sound to start playing"
      await _audioPlayer.play(UrlSource(soundUrl));
    } catch (e) {
      // If anything goes wrong (no internet, file not found, etc.)
      // Print the error for debugging but don't crash the app
      // WHY: Sound is a nice feature, but the app should still work without it
      print('Error playing Pokemon cry: $e');
    }
  }

  // Stops any currently playing sound
  // WHAT: Immediately stops audio playback
  // WHY: Users might want to stop the sound, or we need to stop it before playing another
  //
  // Future<void> means this takes time but doesn't return a value
  Future<void> stop() async {
    // Tell the audio player to stop playing
    // await means "wait for the sound to stop"
    await _audioPlayer.stop();
  }

  // Cleans up the audio player when we're done with it
  // WHAT: Releases the audio player resources
  // WHY: When we're done using the audio player, we need to properly close it
  //      to free up memory and system resources
  //
  // This should be called when the audio service is no longer needed
  // void means this completes immediately and doesn't return anything
  void dispose() {
    // Release all resources used by the audio player
    // This prevents memory leaks (memory that's no longer needed but not freed)
    _audioPlayer.dispose();
  }
}
