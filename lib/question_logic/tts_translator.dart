import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmath_kids/screens/settings_screen.dart'; 
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  Future<void> speak(String text, WidgetRef ref) async {
    final double volume = ref.read(volumeProvider);
    final double pitch = ref.read(pitchProvider);
    final double speechRate = ref.read(speechRateProvider);
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.speak(text);
  }
}

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService(); 
});