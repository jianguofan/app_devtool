import 'package:flutter/material.dart';

import 'weak_network_controller.dart';

/// Weak-network controls: enable/offline, presets and custom parameters.
class WeakNetworkPage extends StatelessWidget {
  const WeakNetworkPage({super.key, required this.controller});

  final WeakNetworkController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模拟弱网')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _) {
          return ListView(
            children: <Widget>[
              SwitchListTile(
                title: const Text('启用弱网'),
                value: controller.enabled,
                onChanged: controller.setEnabled,
              ),
              if (controller.enabled) ...<Widget>[
                SwitchListTile(
                  title: const Text('临时断网'),
                  value: controller.offline,
                  onChanged: controller.setOffline,
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('预设场景'),
                ),
                for (final WeakNetworkProfile p in WeakNetworkController.presets)
                  ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      '延迟 ${p.delayMs}ms · 抖动 ${p.jitterMs}ms · 丢包 ${(p.lossRate * 100).round()}%',
                    ),
                    onTap: () => controller.apply(p),
                  ),
                const Divider(),
                _Slider(
                  label: '固定延迟',
                  value: controller.delayMs.toDouble(),
                  max: 2000,
                  onChanged: (double v) => controller.setDelay(v.round()),
                ),
                _Slider(
                  label: '随机抖动',
                  value: controller.jitterMs.toDouble(),
                  max: 1000,
                  onChanged: (double v) => controller.setJitter(v.round()),
                ),
                _Slider(
                  label: '丢包率',
                  value: controller.lossRate * 100,
                  max: 100,
                  onChanged: (double v) => controller.setLossRate(v / 100),
                ),
                _Slider(
                  label: '超时(ms)',
                  value: controller.timeoutMs.toDouble(),
                  max: 10000,
                  onChanged: (double v) => controller.setTimeout(v.round()),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: controller.reset,
                    child: const Text('重置'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 200,
        child: Slider(value: value.clamp(0, max), max: max, onChanged: onChanged),
      ),
    );
  }
}
