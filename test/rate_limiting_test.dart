import 'package:flutter_test/flutter_test.dart';

import 'package:rate_limiting/rate_limiting.dart';

void main() {

  test('RateLimiting can process routines without exceeding max attempts in period of time', () async {
    int callsCount = 0;
    const maxAttempts = 2;
    const duration = Duration(milliseconds: 100);
    final rateLimiting = RateLimiting(maxAttempts: maxAttempts, duration: duration);
    
    for (int i = 0; i < maxAttempts + 1; i++) {
      rateLimiting.process(() {
        callsCount++;
      });
    }
    expect(callsCount, maxAttempts);
    await Future.delayed(duration);
    expect(callsCount, maxAttempts + 1);
    rateLimiting.cancel();
  });
}
