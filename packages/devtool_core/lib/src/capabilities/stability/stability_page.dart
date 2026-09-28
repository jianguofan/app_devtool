import 'package:flutter/material.dart';

import 'stability_probe_capability.dart';
import 'stability_reporter.dart';

/// Stability probe page: a list of crash/error triggers with warnings.
class StabilityPage extends StatelessWidget {
  const StabilityPage({super.key, required this.capability});

  final StabilityProbeCapability capability;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('稳定性探针')),
      body: ListView(
        children: <Widget>[
          _MonitoringCard(info: capability.info),
          const Divider(),
          _ProbeTile(label: 'Dart 未捕获异常', destructive: true, onTap: () => capability.throwDartException()),
          _ProbeTile(label: 'Flutter Framework 异常', destructive: true, onTap: () => capability.throwFlutterException()),
          _ProbeTile(label: 'Isolate 异常', destructive: true, onTap: () => capability.throwIsolateException()),
          _ProbeTile(label: '非致命错误上报', destructive: false, onTap: () => capability.captureNonFatal()),
          _ProbeTile(label: '自定义事件 / Breadcrumb', destructive: false, onTap: () => capability.captureCustomEvent()),
          _ProbeTile(label: 'OOM 内存压力', destructive: true, onTap: () => _oomDialog(context)),
          _ProbeTile(label: '原生崩溃', destructive: true, onTap: () => capability.triggerNativeCrash()),
        ],
      ),
    );
  }

  Future<void> _oomDialog(BuildContext context) async {
    final int? mb = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('选择内存压力档位'),
        children: <Widget>[
          for (final int size in const <int>[64, 128, 256])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, size),
              child: Text('$size MB'),
            ),
        ],
      ),
    );
    if (mb != null) capability.triggerOom(megabytes: mb);
  }
}

class _MonitoringCard extends StatelessWidget {
  const _MonitoringCard({required this.info});

  final MonitoringInfo info;

  @override
  Widget build(BuildContext context) {
    String consent = '未知';
    if (info.userConsent == true) consent = '已授权';
    if (info.userConsent == false) consent = '未授权';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('监控环境', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('服务：${info.provider ?? '-'}'),
            Text('环境：${info.environment ?? '-'}'),
            Text('用户授权：$consent'),
            Text('监控状态：${info.isEnabled ? '已启用' : '未启用'}'),
          ],
        ),
      ),
    );
  }
}

class _ProbeTile extends StatelessWidget {
  const _ProbeTile({required this.label, required this.destructive, required this.onTap});

  final String label;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: destructive ? const Icon(Icons.warning_amber, color: Colors.red) : null,
      onTap: () {
        if (destructive) {
          _confirmDestructive(context, label, onTap);
        } else {
          onTap();
        }
      },
    );
  }

  Future<void> _confirmDestructive(BuildContext context, String label, VoidCallback action) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('危险操作'),
        content: Text('即将触发「$label」，可能导致应用崩溃。确认继续？'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    if (ok == true) action();
  }
}
