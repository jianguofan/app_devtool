import 'dart:io';

import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PathGuard', () {
    test('allows root and nested paths', () {
      expect(PathGuard.isWithin('/root', '/root'), isTrue);
      expect(PathGuard.isWithin('/root', '/root/a/b'), isTrue);
    });

    test('rejects siblings and traversal escapes', () {
      expect(PathGuard.isWithin('/root', '/other'), isFalse);
      expect(PathGuard.isWithin('/root', '/root/../etc'), isFalse);
      expect(PathGuard.isWithin('/root', '/root/../../etc'), isFalse);
    });

    test('isAllowed checks all roots', () {
      const PathGuard guard = PathGuard(roots: <String>['/a', '/b']);
      expect(guard.isAllowed('/a/x'), isTrue);
      expect(guard.isAllowed('/b/y'), isTrue);
      expect(guard.isAllowed('/c'), isFalse);
    });
  });

  group('SharedPreferencesViewer', () {
    const SharedPreferencesViewer viewer = SharedPreferencesViewer();

    Future<SharedPreferences> mockPrefs() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'auth_token': 'secret-token',
        'user_name': 'alice',
        'count': 42,
        'enabled': true,
      });
      return SharedPreferences.getInstance();
    }

    test('reads entries with types', () async {
      final SharedPreferences prefs = await mockPrefs();
      final List<PrefEntry> entries = viewer.read(prefs);
      final Map<String, String> types = <String, String>{for (final PrefEntry e in entries) e.key: e.type};

      expect(types['count'], 'int');
      expect(types['enabled'], 'bool');
      expect(types['user_name'], 'String');
    });

    test('masks sensitive values unless revealed', () async {
      final SharedPreferences prefs = await mockPrefs();
      final PrefEntry token = viewer.read(prefs).firstWhere((PrefEntry e) => e.key == 'auth_token');

      expect(viewer.display(token, false), '***');
      expect(viewer.display(token, true), 'secret-token');
      expect(viewer.display(viewer.read(prefs).firstWhere((PrefEntry e) => e.key == 'user_name'), false), 'alice');
    });

    test('type-aware edit', () async {
      final SharedPreferences prefs = await mockPrefs();
      await viewer.edit(prefs, 'count', '99');
      await viewer.edit(prefs, 'enabled', 'false');
      await viewer.edit(prefs, 'user_name', 'bob');

      expect(prefs.getInt('count'), 99);
      expect(prefs.getBool('enabled'), isFalse);
      expect(prefs.getString('user_name'), 'bob');
    });

    test('pretty-prints JSON values', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'config': '{"a":1,"b":[1,2]}'});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PrefEntry config = viewer.read(prefs).first;

      expect(viewer.display(config, true), contains('\n')); // indented JSON
    });

    test('rawDump serializes all entries', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'a': 1, 'b': 'x'});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String dump = viewer.rawDump(prefs);

      expect(dump, contains('"a"'));
      expect(dump, contains('"b"'));
      expect(dump, contains('1'));
    });
  });

  group('SandboxBrowser', () {
    test('lists files with metadata', () {
      final Directory dir = Directory.systemTemp.createTempSync('sandbox_test');
      addTearDown(() => dir.deleteSync(recursive: true));

      Directory('${dir.path}/sub').createSync();
      File('${dir.path}/a.txt').writeAsStringSync('hello');

      final List<SandboxEntry> entries = SandboxBrowser.list(dir.path);
      final Set<String> names = entries.map((SandboxEntry e) => e.name).toSet();

      expect(names, containsAll(<String>['sub', 'a.txt']));
      expect(entries.firstWhere((SandboxEntry e) => e.name == 'a.txt').size, 5);
      expect(entries.firstWhere((SandboxEntry e) => e.name == 'sub').isDirectory, isTrue);
    });

    test('exports a file to temp', () {
      final Directory dir = Directory.systemTemp.createTempSync('sandbox_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final File file = File('${dir.path}/b.txt')..writeAsStringSync('data');

      final String exported = SandboxBrowser.exportToTemp(file.path);
      addTearDown(() => File(exported).deleteSync());
      expect(File(exported).existsSync(), isTrue);
      expect(File(exported).readAsStringSync(), 'data');
    });

    test('returns empty for missing directory', () {
      expect(SandboxBrowser.list('/no/such/dir'), isEmpty);
    });

    test('reads hex header for binary and detects image/text', () {
      final Directory dir = Directory.systemTemp.createTempSync('sandbox_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final File binary = File('${dir.path}/data.bin')..writeAsBytesSync(<int>[0x00, 0x1f, 0xff]);

      final String hex = SandboxBrowser.readHex(binary.path);
      expect(hex, startsWith('00 1f ff'));

      expect(SandboxBrowser.isImage('${dir.path}/a.png'), isTrue);
      expect(SandboxBrowser.isText('${dir.path}/b.txt'), isTrue);
      expect(SandboxBrowser.isText('${dir.path}/data.bin'), isFalse);
    });
  });
}
