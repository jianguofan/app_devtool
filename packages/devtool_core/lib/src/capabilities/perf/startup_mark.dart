/// Lightweight startup timing: records named milestones and computes intervals
/// between them (main entry → first frame → home interactive).
class StartupMark {
  final Map<String, Duration> _marks = <String, Duration>{};
  final Stopwatch _watch = Stopwatch();

  void start() {
    _watch.start();
  }

  void mark(String name) {
    _marks[name] = _watch.elapsed;
  }

  Duration? elapsed(String name) => _marks[name];

  Duration? between(String from, String to) {
    final Duration? a = _marks[from];
    final Duration? b = _marks[to];
    if (a == null || b == null) return null;
    return b - a;
  }

  Map<String, Duration> get marks => Map<String, Duration>.unmodifiable(_marks);
}
