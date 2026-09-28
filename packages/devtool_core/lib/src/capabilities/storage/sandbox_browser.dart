import 'dart:convert';
import 'dart:io';

/// A single file-system entry in the sandbox.
class SandboxEntry {
  const SandboxEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;
}

/// Lists sandbox directories and reads/export files. Pure `dart:io`, testable.
class SandboxBrowser {
  static List<SandboxEntry> list(String path) {
    final Directory dir = Directory(path);
    if (!dir.existsSync()) return const <SandboxEntry>[];

    final List<SandboxEntry> result = <SandboxEntry>[];
    for (final FileSystemEntity entity in dir.listSync(followLinks: false)) {
      final bool isDirectory = entity is Directory;
      int size = 0;
      DateTime modified = DateTime.fromMillisecondsSinceEpoch(0);
      try {
        final FileStat stat = entity.statSync();
        size = stat.size;
        modified = stat.modified;
      } catch (_) {
        // Ignore stat failures (broken links).
      }
      result.add(SandboxEntry(
        name: _basename(entity.path),
        path: entity.path,
        isDirectory: isDirectory,
        size: size,
        modified: modified,
      ));
    }
    result.sort((SandboxEntry a, SandboxEntry b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return result;
  }

  static String readText(String path, {int maxBytes = 64 * 1024}) {
    final File file = File(path);
    final int length = file.lengthSync();
    if (length <= maxBytes) {
      return file.readAsStringSync();
    }
    final RandomAccessFile raf = file.openSync();
    try {
      return '${utf8.decode(raf.readSync(maxBytes))}…<truncated>';
    } finally {
      raf.closeSync();
    }
  }

  /// Exports [path] to a temp file and returns its path (e.g. for sharing).
  static String exportToTemp(String path) {
    final File source = File(path);
    final File target = File('${Directory.systemTemp.path}/${source.uri.pathSegments.last}');
    source.copySync(target.path);
    return target.path;
  }

  static const Set<String> _imageExtensions = <String>{'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif'};
  static const Set<String> _textExtensions = <String>{'txt', 'json', 'xml', 'yaml', 'yml', 'log', 'md', 'csv', 'html', 'dart', 'kt', 'swift', 'js', 'css'};

  static bool isImage(String path) => _imageExtensions.contains(_ext(path));
  static bool isText(String path) => _textExtensions.contains(_ext(path));

  /// Reads the first [maxBytes] bytes and formats them as a hex header.
  static String readHex(String path, {int maxBytes = 64}) {
    final RandomAccessFile raf = File(path).openSync();
    try {
      final List<int> bytes = raf.readSync(maxBytes);
      final StringBuffer sb = StringBuffer();
      for (final int b in bytes) {
        sb.write(b.toRadixString(16).padLeft(2, '0'));
        sb.write(' ');
      }
      return sb.toString().trim();
    } finally {
      raf.closeSync();
    }
  }

  static String _ext(String path) {
    final int idx = path.lastIndexOf('.');
    return idx < 0 ? '' : path.substring(idx + 1).toLowerCase();
  }

  static String _basename(String path) {
    final List<String> parts = path.split(RegExp(r'[/\\]'));
    for (int i = parts.length - 1; i >= 0; i--) {
      if (parts[i].isNotEmpty) return parts[i];
    }
    return path;
  }
}
