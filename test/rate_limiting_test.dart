import 'package:flutter_test/flutter_test.dart';
import 'package:rate_limiting/rate_limit.dart';

import 'package:rate_limiting/rate_limiter.dart';

void main() {
  test('can call request', () {
    int calls = 0;
    const int shouldBe = 1;

    final rateLimiter = RateLimiter(limits: [
      RateLimit(duration: const Duration(milliseconds: 100), requestCount: 1),
    ]);

    rateLimiter.call(() => calls++);
    expect(calls, shouldBe);
    rateLimiter.cancel();
  });

  test(
      'do not call requests if exceeded limit of requests for current RateLimit',
      () {
    int calls = 0;
    const int shouldBe = 1;

    final rateLimiter = RateLimiter(limits: [
      RateLimit(duration: const Duration(milliseconds: 100), requestCount: 1),
    ]);

    rateLimiter.call(() => calls++);
    rateLimiter.call(() => calls++);
    expect(calls, shouldBe);
    rateLimiter.cancel();
  });

  test(
      'continue to call requests if there are unfulfilled requests and current RateLimit countdown is over',
      () async {
    int calls = 0;
    const int shouldBe = 2;

    final rateLimiter = RateLimiter(limits: [
      RateLimit(duration: const Duration(milliseconds: 100), requestCount: 1),
    ]);

    rateLimiter.call(() => calls++);
    rateLimiter.call(() => calls++);
    await Future.delayed(const Duration(milliseconds: 110));

    expect(calls, shouldBe);
    rateLimiter.cancel();
  });

  test('can call requests according to list of RateLimit', () async {
    int calls = 0;
    const int shouldBe = 2;

    final rateLimiter = RateLimiter(limits: [
      RateLimit(duration: const Duration(milliseconds: 100), requestCount: 1),
      RateLimit(duration: const Duration(milliseconds: 300), requestCount: 2),
    ]);

    rateLimiter.call(() => calls++);
    await Future.delayed(const Duration(milliseconds: 100));
    rateLimiter.call(() => calls++);

    expect(calls, shouldBe);
    rateLimiter.cancel();
  });
}
