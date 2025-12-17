import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

// Preference keys
const String _soundEnabledKey = 'sound_enabled';
const String _vibrationEnabledKey = 'vibration_enabled';

// Audio Service Provider - singleton instance
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Settings providers with persistence
final soundEnabledProvider = StateNotifierProvider<SettingNotifier, bool>((ref) {
  return SettingNotifier(_soundEnabledKey, false);
});

final vibrationEnabledProvider = StateNotifierProvider<SettingNotifier, bool>((ref) {
  return SettingNotifier(_vibrationEnabledKey, false);
});

class SettingNotifier extends StateNotifier<bool> {
  final String key;

  SettingNotifier(this.key, bool defaultValue) : super(defaultValue) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(key) ?? state;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, state);
  }

  Future<void> setValue(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, state);
  }
}

class AudioService {
  final AudioPlayer _tapPlayer = AudioPlayer();
  bool _hasVibrator = false;
  bool _isInitialized = false;

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Check if device has vibrator
    _hasVibrator = await Vibration.hasVibrator();

    // Configure tap player
    await _tapPlayer.setVolume(0.7); // Tap sound at 70% volume
  }

  // Play tap sound (for UI interactions)
  Future<void> playTapSound({required bool enabled}) async {
    if (!enabled) return;

    try {
      await _tapPlayer.stop();
      await _tapPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      // Fallback to haptic feedback if audio fails
      await HapticFeedback.lightImpact();
    }
  }

  // Vibrate
  Future<void> vibrate({required bool enabled, int duration = 50}) async {
    if (!enabled) return;

    try {
      if (_hasVibrator) {
        await Vibration.vibrate(duration: duration);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }

  // Light vibration for UI feedback
  Future<void> lightVibrate({required bool enabled}) async {
    if (!enabled) return;

    try {
      if (_hasVibrator) {
        await Vibration.vibrate(duration: 25, amplitude: 64);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      await HapticFeedback.lightImpact();
    }
  }

  // Heavy vibration for wins
  Future<void> heavyVibrate({required bool enabled}) async {
    if (!enabled) return;

    try {
      if (_hasVibrator) {
        await Vibration.vibrate(duration: 100, amplitude: 255);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      await HapticFeedback.heavyImpact();
    }
  }

  // Dispose resources
  void dispose() {
    _tapPlayer.dispose();
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
