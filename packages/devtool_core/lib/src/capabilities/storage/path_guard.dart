/// Guards sandbox access to a set of allowed root directories, rejecting path
/// traversal escapes (`..`).
class PathGuard {
  const PathGuard({required this.roots});

  final List<String> roots;

  /// Whether [candidate] is equal to or nested under one of the [roots].
  bool isAllowed(String candidate) {
    for (final String root in roots) {
      if (isWithin(root, candidate)) return true;
    }
    return false;
  }

  /// Pure check: candidate must be the root itself or a child of it, with no
  /// `..` traversal segments.
  static bool isWithin(String root, String candidate) {
    final String normalizedRoot = _normalize(root);
    final String normalized = _normalize(candidate);
    if (normalized.split('/').contains('..')) return false;
    if (normalized == normalizedRoot) return true;
    return normalized.startsWith('$normalizedRoot/');
  }

  static String _normalize(String path) {
    String result = path.replaceAll('\\', '/');
    while (result.endsWith('/') && result.length > 1) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
