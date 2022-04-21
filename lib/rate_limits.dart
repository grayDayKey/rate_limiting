import 'package:rate_limiting/rate_limit.dart';

class RateLimits extends Iterable<RateLimit> {
  RateLimits(List<RateLimit> limits) : _sortedByDurationLimit = limits..sort();

  final List<RateLimit> _sortedByDurationLimit;

  late final List<Duration> _effectiveDurationLimits =
      _sortedByDurationLimit.fold(
    [],
    (previousValue, element) => previousValue.isNotEmpty
        ? [...previousValue, element.duration - previousValue.last]
        : [element.duration],
  );

  int _index = 0;

  @override
  RateLimit elementAt(int index) => _sortedByDurationLimit.elementAt(index);

  Duration get longestEffectiveDurationLimit => _effectiveDurationLimits.last;

  Duration get currentEffectiveDurationLimit =>
      _effectiveDurationLimits[_index];

  int get currentRequestLimit => iterator.current.requestCount;

  @override
  int get length => _sortedByDurationLimit.length;

  @override
  Iterator<RateLimit> get iterator => _CyclingRateLimitsIterator(this);
}

class _CyclingRateLimitsIterator extends Iterator<RateLimit> {
  _CyclingRateLimitsIterator(this._limits);

  final RateLimits _limits;

  Duration get currentEffectiveDuration =>
      _limits._effectiveDurationLimits[_limits._index];

  @override
  RateLimit get current => _limits.elementAt(_limits._index);

  @override
  bool moveNext() {
    _limits._index =
        _limits._index < _limits.length - 1 ? _limits._index + 1 : 0;
    return true;
  }
}
