import 'package:flutter/material.dart';

import '../core/devtool.dart';
import '../core/devtool_entry.dart';
import '../core/devtool_host.dart';

/// Default debug center: renders registered [DevtoolEntry]s grouped by
/// `group`, each with an enable/disable switch and navigation to its page.
class DevtoolShell extends StatelessWidget {
  const DevtoolShell(
      {super.key,
      required this.devtool,
      this.entries = const <DevtoolEntry>[]});

  final Devtool devtool;
  final List<DevtoolEntry> entries;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<DevtoolEntry>> grouped =
        <String, List<DevtoolEntry>>{};
    for (final DevtoolEntry entry in entries) {
      grouped.putIfAbsent(entry.group, () => <DevtoolEntry>[]).add(entry);
    }
    final List<String> groups = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('开发者工具')),
      body: AnimatedBuilder(
        animation: devtool,
        builder: (BuildContext context, Widget? _) {
          if (entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('未注册任何调试能力')),
            );
          }
          return ListView(
            children: <Widget>[
              for (final String group in groups) ...[
                _GroupHeader(title: group),
                for (final DevtoolEntry entry in grouped[group]!)
                  _buildEntryTile(context, entry),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEntryTile(BuildContext context, DevtoolEntry entry) {
    final bool enabled = devtool.isEnabled(entry.id);
    final bool hotSwappable = devtool.isHotSwappable(entry.id);
    final DevtoolHost? host = devtool.host;

    final Widget? subtitle = !hotSwappable
        ? const Text('需重启生效')
        : (entry.settingsTile != null ? entry.settingsTile!(context) : null);

    return ListTile(
      title: Text(entry.name),
      subtitle: subtitle,
      trailing: Switch(
        value: enabled,
        onChanged: (bool value) {
          devtool.setEnabled(entry.id, value);
        },
      ),
      onTap: () {
        final DevtoolPageBuilder? page = entry.pageBuilder;
        if (page != null && host != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (BuildContext _) => page(context, host)),
          );
        }
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
