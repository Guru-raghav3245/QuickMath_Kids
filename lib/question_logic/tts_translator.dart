import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmath_kids/screens/settings_screen.dart'; 
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _iosConfigured = false;

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // The default iOS audio category is silenced by the ring/silent switch.
  Future<void> _configureIOS() async {
    if (!_isIOS || _iosConfigured) return;
    _iosConfigured = true;
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP],
    );
  }

  Future<void> speak(String text, WidgetRef ref) async {
    final double volume = ref.read(volumeProvider);
    final double pitch = ref.read(pitchProvider);
    final double speechRate = ref.read(speechRateProvider);
    await _configureIOS();
    await _flutterTts.setLanguage('en-US');
    // iOS pitch is limited to 0.5-2.0.
    await _flutterTts.setPitch(_isIOS ? pitch.clamp(0.5, 2.0) : pitch);
    // Android: 1.0 is normal speed; iOS: 0.5 is normal speed, 1.0 is the max.
    await _flutterTts.setSpeechRate(_isIOS ? speechRate / 2 : speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.speak(text);
  }
}

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService(); 
});
