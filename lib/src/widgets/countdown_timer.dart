import 'dart:async';

import 'package:flutter/cupertino.dart';

class CountdownTimer {
  CountdownTimer({
    required this.duration,
    required this.onRemainingTimeChanged,
    required this.onTimerFinished,
  }) {
    _resetTimer();
  }

  final Duration duration;
  final void Function(int) onRemainingTimeChanged;
  final VoidCallback onTimerFinished;

  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  void cancel() {
    _timer?.cancel();
    _remainingTime = Duration.zero; // Reset remaining time
    onRemainingTimeChanged(_remainingTime.inSeconds); // Notify listeners
  }

  void _resetTimer() {
    _remainingTime = duration;
    onRemainingTimeChanged(_remainingTime.inSeconds); // Notify listeners

    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        onRemainingTimeChanged(_remainingTime.inSeconds);
      } else {
        _timer?.cancel();
        onTimerFinished();
      }
    });
  }

  // Helper method to get formatted time as a String
  String getFormattedTime() {
    return '${_remainingTime.inMinutes.remainder(60)}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
