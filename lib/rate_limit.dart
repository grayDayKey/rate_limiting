const _kTimeMsKey = 'timeMs';
const _kRequestCountKey = 'requestCount';

class RateLimit implements Comparable<RateLimit> {

  final Duration duration;
  final int requestCount;

  RateLimit({required this.duration, required this.requestCount,});

  factory RateLimit.fromJson(Map<String, int> json) {
    return RateLimit(
      duration: Duration(milliseconds: json[_kTimeMsKey] as int),
      requestCount: json[_kRequestCountKey] as int,
    );
  }

  @override
  int compareTo(other) {
    return duration.compareTo(other.duration);
  }
}


