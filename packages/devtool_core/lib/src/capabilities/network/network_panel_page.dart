import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'network_log_entry.dart';
import 'network_log_store.dart';

/// Network panel: list, filter, search, detail, copy-cURL and clear.
class NetworkPanelPage extends StatefulWidget {
  const NetworkPanelPage({super.key, required this.store});

  final NetworkLogStore store;

  @override
  State<NetworkPanelPage> createState() => _NetworkPanelPageState();
}

class _NetworkPanelPageState extends State<NetworkPanelPage> {
  String _query = '';
  String? _method;
  bool? _onlySuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络请求'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空记录',
            onPressed: widget.store.clear,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _FilterBar(
            query: _query,
            method: _method,
            onlySuccess: _onlySuccess,
            onQueryChanged: (String value) => setState(() => _query = value),
            onMethodChanged: (String? value) => setState(() => _method = value),
            onStatusChanged: (bool? value) =>
                setState(() => _onlySuccess = value),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (BuildContext context, Widget? _) {
                final List<NetworkLogEntry> entries =
                    _filter(widget.store.entries);
                if (entries.isEmpty) {
                  return const Center(child: Text('暂无请求记录'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _EntryTile(entry: entries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<NetworkLogEntry> _filter(List<NetworkLogEntry> all) {
    final String query = _query.trim().toLowerCase();
    final List<NetworkLogEntry> filtered = all.where((NetworkLogEntry e) {
      if (_method != null && e.method != _method) return false;
      if (_onlySuccess != null && e.isSuccess != _onlySuccess) return false;
      if (query.isNotEmpty && !e.url.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
    // Newest first.
    return filtered.reversed.toList();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.query,
    required this.method,
    required this.onlySuccess,
    required this.onQueryChanged,
    required this.onMethodChanged,
    required this.onStatusChanged,
  });

  final String query;
  final String? method;
  final bool? onlySuccess;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onMethodChanged;
  final ValueChanged<bool?> onStatusChanged;

  static const List<String> _methods = <String>[
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '搜索 URL',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              DropdownButton<String?>(
                value: method,
                hint: const Text('方法'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('全部方法')),
                  for (final String m in _methods)
                    DropdownMenuItem<String?>(value: m, child: Text(m)),
                ],
                onChanged: onMethodChanged,
              ),
              const SizedBox(width: 16),
              DropdownButton<bool?>(
                value: onlySuccess,
                hint: const Text('状态'),
                items: const <DropdownMenuItem<bool?>>[
                  DropdownMenuItem<bool?>(value: null, child: Text('全部状态')),
                  DropdownMenuItem<bool?>(value: true, child: Text('成功')),
                  DropdownMenuItem<bool?>(value: false, child: Text('失败')),
                ],
                onChanged: onStatusChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _MethodBadge(method: entry.method),
      title: Text(entry.url, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        entry.error == null
            ? '${entry.statusCode ?? '-'} · ${entry.duration.inMilliseconds}ms'
            : '${entry.statusCode ?? '-'} · ${entry.error}',
      ),
      trailing: _StatusBadge(entry: entry),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext _) => _DetailPage(entry: entry)),
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  static const Map<String, Color> _colors = <String, Color>{
    'GET': Colors.blue,
    'POST': Colors.green,
    'PUT': Colors.orange,
    'PATCH': Colors.teal,
    'DELETE': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final Color color = _colors[method] ?? Colors.grey;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final int? status = entry.statusCode;
    final Color color;
    if (status == null) {
      color = Colors.red;
    } else if (status >= 500) {
      color = Colors.red;
    } else if (status >= 400) {
      color = Colors.orange;
    } else if (status >= 300) {
      color = Colors.teal;
    } else {
      color = Colors.green;
    }
    return Text(
      '${status ?? 'ERR'}',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.method),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制 cURL',
            onPressed: () => _copy(context, entry.toCurl()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _kv('URL', entry.url),
          _kv('状态码', '${entry.statusCode ?? '-'}'),
          _kv('耗时', '${entry.duration.inMilliseconds}ms'),
          _kv('Trace ID', entry.traceId ?? '-'),
          if (entry.error != null) _kv('失败原因', entry.error!),
          const Divider(),
          _headerSection(context, '请求 Header', entry.requestHeaders),
          _bodySection(context, '请求 Body', entry.requestBody, copyable: true),
          const Divider(),
          _headerSection(context, '响应 Header', entry.responseHeaders),
          _bodySection(context, '响应 Body', entry.responseBody, copyable: true),
        ],
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
                text: '$key：',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(
      BuildContext context, String title, Map<String, String> headers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        for (final MapEntry<String, String> e in headers.entries)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text('${e.key}: ${e.value}',
                style: const TextStyle(fontSize: 12)),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _bodySection(BuildContext context, String title, String? body,
      {bool copyable = false}) {
    final String text = _pretty(body);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (copyable && text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => _copy(context, text),
              ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(text.isEmpty ? '(空)' : text,
              style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _pretty(String? body) {
    if (body == null) return '';
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map || decoded is List) {
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {
      // Not JSON; show as-is.
    }
    return body;
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }
}
