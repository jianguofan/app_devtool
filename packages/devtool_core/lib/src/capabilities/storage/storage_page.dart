import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'path_guard.dart';
import 'prefs_viewer.dart';
import 'sandbox_browser.dart';

/// Storage page: SharedPreferences viewer + sandbox browser.
class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数据工具'),
          bottom: const TabBar(tabs: <Widget>[Tab(text: 'SharedPreferences'), Tab(text: '沙盒')]),
        ),
        body: const TabBarView(
          children: <Widget>[_PrefsTab(), _SandboxTab()],
        ),
      ),
    );
  }
}

class _PrefsTab extends StatefulWidget {
  const _PrefsTab();

  @override
  State<_PrefsTab> createState() => _PrefsTabState();
}

class _PrefsTabState extends State<_PrefsTab> {
  static const SharedPreferencesViewer _viewer = SharedPreferencesViewer();

  late final Future<SharedPreferences> _future = SharedPreferences.getInstance();
  String _query = '';
  bool _reveal = false;
  final List<PrefEntry> _undoStack = <PrefEntry>[];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final SharedPreferences prefs = snapshot.data!;
        final String query = _query.trim().toLowerCase();
        final List<PrefEntry> entries = _viewer.read(prefs).where((PrefEntry e) {
          return query.isEmpty || e.key.toLowerCase().contains(query);
        }).toList();

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '搜索 key',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (String v) => setState(() => _query = v),
              ),
            ),
            SwitchListTile(
              title: const Text('显示原文（敏感字段）'),
              value: _reveal,
              onChanged: (bool v) => setState(() => _reveal = v),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.data_object),
              title: const Text('查看原始数据'),
              onTap: () => _showRaw(context, prefs),
            ),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('无匹配条目'))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (BuildContext context, int index) {
                        final PrefEntry e = entries[index];
                        return ListTile(
                          dense: true,
                          title: Text(e.key),
                          subtitle: Text('${_viewer.display(e, _reveal)} (${e.type})'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _edit(context, prefs, e),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () => _delete(context, prefs, e),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRaw(BuildContext context, SharedPreferences prefs) async {
    final String dump = _viewer.rawDump(prefs);
    final String? rawFile = await _readRawStorageFile();
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('原始数据'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(rawFile ?? dump, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }

  /// Best-effort read of the underlying storage file (Android XML). Returns
  /// null when it cannot be located (e.g. iOS / non-Android).
  Future<String?> _readRawStorageFile() async {
    try {
      final Directory support = await getApplicationSupportDirectory();
      final Directory dataDir = support.parent;
      final Directory prefsDir = Directory('${dataDir.path}/shared_prefs');
      if (prefsDir.existsSync()) {
        for (final FileSystemEntity e in prefsDir.listSync()) {
          if (e.path.endsWith('.xml')) return File(e.path).readAsStringSync();
        }
      }
    } catch (_) {
      // Fall through to the JSON dump.
    }
    return null;
  }

  Future<void> _edit(BuildContext context, SharedPreferences prefs, PrefEntry entry) async {
    final TextEditingController controller = TextEditingController(text: entry.value?.toString() ?? '');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('编辑 ${entry.key}'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '值')),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _viewer.edit(prefs, entry.key, controller.text);
        setState(() {});
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('编辑失败：$e')));
        }
      }
    }
  }

  Future<void> _delete(BuildContext context, SharedPreferences prefs, PrefEntry entry) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确认删除 "${entry.key}"？'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await prefs.remove(entry.key);
      _undoStack.add(entry);
      setState(() {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除 ${entry.key}'),
            action: SnackBarAction(label: '撤销', onPressed: () => _undo(prefs)),
          ),
        );
      }
    }
  }

  Future<void> _undo(SharedPreferences prefs) async {
    if (_undoStack.isEmpty) return;
    final PrefEntry entry = _undoStack.removeLast();
    await _viewer.edit(prefs, entry.key, entry.value?.toString() ?? '');
    setState(() {});
  }
}

class _SandboxTab extends StatefulWidget {
  const _SandboxTab();

  @override
  State<_SandboxTab> createState() => _SandboxTabState();
}

class _SandboxTabState extends State<_SandboxTab> {
  PathGuard? _guard;
  String? _current;
  List<SandboxEntry> _entries = const <SandboxEntry>[];

  @override
  void initState() {
    super.initState();
    _loadRoots();
  }

  Future<void> _loadRoots() async {
    final List<String> roots = <String>[
      (await getApplicationDocumentsDirectory()).path,
      (await getApplicationSupportDirectory()).path,
      (await getTemporaryDirectory()).path,
    ];
    setState(() {
      _guard = PathGuard(roots: roots);
      _current = roots.first;
      _entries = SandboxBrowser.list(roots.first);
    });
  }

  void _open(String path, bool isDirectory) {
    if (_guard != null && !_guard!.isAllowed(path)) {
      return; // Reject path traversal escapes.
    }
    if (!isDirectory) {
      _previewFile(path);
      return;
    }
    setState(() {
      _current = path;
      _entries = SandboxBrowser.list(path);
    });
  }

  void _previewFile(String path) {
    final String name = path.split(RegExp(r'[/\\]')).last;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(name),
        content: SizedBox(width: double.maxFinite, child: _fileContent(path)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }

  Widget _fileContent(String path) {
    if (SandboxBrowser.isImage(path)) {
      return Image.file(File(path), height: 240, fit: BoxFit.contain);
    }
    if (SandboxBrowser.isText(path)) {
      return SingleChildScrollView(
        child: Text(SandboxBrowser.readText(path), style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
      );
    }
    final int size = File(path).lengthSync();
    return SingleChildScrollView(
      child: Text(
        '${SandboxBrowser.readHex(path)}\n\n($size bytes)',
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }

  void _export(String path) {
    final String exported = SandboxBrowser.exportToTemp(path);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导出到 $exported')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (_current != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_current!, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (BuildContext context, int index) {
              final SandboxEntry e = _entries[index];
              return ListTile(
                dense: true,
                leading: Icon(e.isDirectory ? Icons.folder : Icons.insert_drive_file),
                title: Text(e.name),
                subtitle: Text(e.isDirectory ? '目录 · ${_fmt(e.modified)}' : '${e.size} bytes · ${_fmt(e.modified)}'),
                trailing: e.isDirectory ? null : IconButton(
                  icon: const Icon(Icons.ios_share, size: 18),
                  onPressed: () => _export(e.path),
                ),
                onTap: () => _open(e.path, e.isDirectory),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _fmt(DateTime time) {
    final DateTime t = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}
