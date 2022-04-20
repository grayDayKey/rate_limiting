library rate_limiting;

import 'dart:async';

import 'dart:collection';

typedef Routine = FutureOr<void> Function();

/// RateLimiting
class RateLimiting {
  
  RateLimiting({ required this.maxAttempts, required this.duration,});
  
  final Duration duration;
  final int maxAttempts;
  
  Timer? _timer;
  
  int _attempts = 0;
  
  final Queue<Routine> _queue = Queue<Routine>();
  
  /// Process routine
  FutureOr<void> process(Routine routine) async {
    _tryRunTimer();
    _runProcess(routine);
  }
  
  FutureOr<void> _runProcess(Routine routine) async {
    if (_canProcess) {
      try {
        _attempts++;
        await routine();
      } catch (_) {
        
      }
    } else {
      _queue.addLast(routine);
    }
  }
  
  void cancel() {
    _queue.clear();
    _attempts = 0;
    _timer?.cancel();
    _timer = null;
  }
  
  
  void _startTimer() {
    _timer = Timer(duration, () {
      cancel();      
      _rescheduleProcessing();
    });
  }
  
  void _tryRunTimer() {
    if (!_timerIsActive) {
      _startTimer();
    }
  }
  
  void _rescheduleProcessing() {
    if (_queue.isNotEmpty) {
      _tryRunTimer();
      while (_queue.isNotEmpty && _canProcess) {
        _runProcess(_queue.removeFirst());
      }
    }
  }
  
  bool get _timerIsActive => _timer != null && _timer?.isActive == true;
  
  bool get _canProcess => _timerIsActive && _attempts < maxAttempts;
}
