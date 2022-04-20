library rate_limiting;

import 'dart:async';

import 'dart:collection';

typedef Routine = FutureOr<void> Function();

/// RateLimiting
class RateLimiting {
  
  RateLimiting({ required this.maxCalls, required this.duration,});

  factory RateLimiting.fromArray(List<int> arr) {
    assert(arr.length == 2);
    final timeMs = arr.first;
    final requestCount = arr.last;

    return RateLimiting(
      maxCalls: requestCount,
      duration: Duration(milliseconds: timeMs));
  }
  
  final Duration duration;
  final int maxCalls;
  
  Timer? _timer;
  
  int _calls = 0;
  
  final Queue<Routine> _queue = Queue<Routine>();
  
  /// Process routine
  FutureOr<void> process(Routine routine) async {
    _tryRunTimer();
    _runProcess(routine);
  }
  
  FutureOr<void> _runProcess(Routine routine) async {
    if (_canProcess) {
      try {
        _calls++;
        await routine();
      } catch (_) {
        
      }
    } else {
      _queue.addLast(routine);
    }
  }
  
  void cancel() {
    _calls = 0;
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
  
  bool get _timerIsActive => _timer?.isActive == true;
  
  bool get _canProcess => _timerIsActive && _calls < maxCalls;
}
