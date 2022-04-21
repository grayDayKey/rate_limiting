library rate_limiting;

import 'dart:async';

import 'package:rate_limiting/rate_limit.dart';
import 'package:rate_limiting/rate_limits.dart';
import 'package:rate_limiting/reuest_scheduler.dart';

typedef Request = FutureOr<void> Function();

/// RateLimiting
class RateLimiter {
  RateLimiter({required List<RateLimit> limits})
      : assert(limits.isNotEmpty),
        _scheduler = RequestScheduler(RateLimits(limits));

  final RequestScheduler _scheduler;

  /// Process routine
  FutureOr<void> call(Request request) async {
    await _scheduler.schedule(request);
  }

  void cancel() {
    _scheduler.cancel();
  }
}
