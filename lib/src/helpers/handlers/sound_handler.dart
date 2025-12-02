import 'package:audioplayers/audioplayers.dart';

class SoundHandler {
  static String response = '';
  static Future<void> playSuccessSound({AudioPlayer? audioPlayer}) async {
    try {
      await audioPlayer?.play(AssetSource('sounds/applepay.mp3'));
    } catch (e) {
      response = 'Error playing sound: $e';
    }
  }
}