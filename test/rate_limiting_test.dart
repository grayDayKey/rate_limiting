import 'package:flutter_test/flutter_test.dart';

import 'package:rate_limiting/rate_limiting.dart';

void main() {
  test('can process routines added during timer loop', () async {
    int callsCount = 0;
    const maxCalls = 2;
    const duration = Duration(milliseconds: 200);
    final rateLimiting = RateLimiting(maxCalls: maxCalls, duration: duration);

    rateLimiting.process(() {
      callsCount++;
    });
    await Future.delayed(const Duration(milliseconds: 100));

    rateLimiting.process(() {
      callsCount++;
    });
    expect(callsCount, maxCalls);
    rateLimiting.cancel();
  });

  test('can process routines added between timer cycles', () async {
    int callsCount = 0;
    const maxCalls = 2;
    const duration = Duration(milliseconds: 200);
    final rateLimiting = RateLimiting(maxCalls: maxCalls, duration: duration);

    rateLimiting.process(() {
      callsCount++;
    });
    await Future.delayed(const Duration(milliseconds: 100));

    rateLimiting.process(() {
      callsCount++;
    });
    rateLimiting.process(() {
      callsCount++;
    });

    await Future.delayed(const Duration(milliseconds: 150));

    rateLimiting.process(() {
      callsCount++;
    });

    expect(callsCount, maxCalls * 2);
    rateLimiting.cancel();
  });

  test('can process routines without exceeding max calls during timer loop, and complete them during next timer cycles', () async {
    int callsCount = 0;
    const maxCalls = 2;
    const duration = Duration(milliseconds: 100);
    final rateLimiting = RateLimiting(maxCalls: maxCalls, duration: duration);
    
    for (int i = 0; i <= maxCalls; i++) {
      rateLimiting.process(() {
        callsCount++;
      });
    }
    expect(callsCount, maxCalls);
    await Future.delayed(duration);
    expect(callsCount, maxCalls + 1);
    rateLimiting.cancel();
  });
}
