import 'dart:async';
import 'dart:collection';

import 'package:rate_limiting/rate_limiter.dart';
import 'package:rate_limiting/rate_limits.dart';

class RequestScheduler {
  RequestScheduler(this.limits);

  final RateLimits limits;

  final Queue<Request> _scheduledRequests = Queue<Request>();

  Timer? _timer;
  int _requests = 0;

  FutureOr<void> schedule(Request request) async {
    _tryStartTimer();
    _tryCall(request);
  }

  void cancel() {
    _requests = 0;
    _scheduledRequests.clear();
    _cancelTimer();
  }

  void _tryCall(Request request) async {
    if (_canCall) {
      try {
        _requests++;
        await request();
      } catch (_) {}
    } else {
      _scheduledRequests.addLast(request);
    }
  }

  void _startTimer() {
    _timer = Timer(limits.currentEffectiveDurationLimit, () {
      _tryResetRequests();
      limits.iterator.moveNext();
      _restartTimer();
      _reschedule();
    });
  }

  void _tryStartTimer() {
    if (!_timerIsActive) {
      _startTimer();
    }
  }

  void _tryResetRequests() {
    if (limits.currentEffectiveDurationLimit ==
        limits.longestEffectiveDurationLimit) _requests = 0;
  }

  void _restartTimer() {
    _cancelTimer();
    _startTimer();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _reschedule() {
    while (_scheduledRequests.isNotEmpty && _canCall) {
      schedule(_scheduledRequests.removeFirst());
    }
  }

  bool get _timerIsActive => _timer?.isActive == true;

  bool get _canCall => _timerIsActive && _requests < limits.currentRequestLimit;
}
