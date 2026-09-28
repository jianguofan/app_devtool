import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'h5_utils.dart';

/// Builds the web view widget. Overridable in tests to avoid the platform view.
typedef WebViewFactory = Widget Function(void Function(InAppWebViewController) onCreated);

/// H5 portal + restricted JS console.
class H5ConsolePage extends StatefulWidget {
  const H5ConsolePage({super.key, this.webViewFactory});

  /// Override for tests; defaults to a real [InAppWebView].
  final WebViewFactory? webViewFactory;

  @override
  State<H5ConsolePage> createState() => _H5ConsolePageState();
}

class _H5ConsolePageState extends State<H5ConsolePage> {
  final TextEditingController _urlController = TextEditingController(text: 'https://example.com');
  final TextEditingController _jsController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _uaController = TextEditingController();

  InAppWebViewController? _controller;
  final List<String> _logs = <String>[];
  String _jsResult = '';
  String _userAgent = '';

  @override
  void dispose() {
    _urlController.dispose();
    _jsController.dispose();
    _headersController.dispose();
    _uaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('H5 任意门'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.cookie_outlined), tooltip: '查看 Cookie', onPressed: _viewCookies),
          IconButton(icon: const Icon(Icons.delete_sweep), tooltip: '清除 Cookie', onPressed: _clearCookies),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'URL', isDense: true))),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _load, child: const Text('打开')),
                  ],
                ),
                TextField(
                  controller: _headersController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Header（每行 Key: Value）', isDense: true),
                ),
                TextField(
                  controller: _uaController,
                  decoration: const InputDecoration(labelText: 'User-Agent（留空用默认）', isDense: true),
                  onSubmitted: (_) => setState(() => _userAgent = _uaController.text.trim()),
                ),
              ],
            ),
          ),
          Expanded(child: _buildWebView()),
          _ConsolePanel(
            logs: _logs,
            jsController: _jsController,
            result: _jsResult,
            onRun: _runJs,
            onClear: () => setState(() {
              _logs.clear();
              _jsResult = '';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    final InAppWebViewSettings settings = InAppWebViewSettings(
      javaScriptEnabled: true,
      userAgent: _userAgent.isEmpty ? null : _userAgent,
    );
    if (widget.webViewFactory != null) {
      return widget.webViewFactory!(_onWebViewCreated);
    }
    return InAppWebView(
      key: ValueKey<String>(_userAgent),
      initialUrlRequest: buildRequest(_urlController.text, _headersController.text),
      initialSettings: settings,
      onWebViewCreated: _onWebViewCreated,
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage message) {
        _log('console.${message.messageLevel}: ${message.message}');
      },
      onReceivedError: (InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
        _log('load error: ${error.description}');
      },
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
    controller.addJavaScriptHandler(
      handlerName: 'devtoolBridge',
      callback: (List<dynamic> args) {
        _log('JS Bridge: ${args.join(', ')}');
      },
    );
  }

  void _load() {
    setState(() => _userAgent = _uaController.text.trim());
    final InAppWebViewController? controller = _controller;
    if (controller == null) return;
    controller.loadUrl(
      urlRequest: buildRequest(_urlController.text, _headersController.text),
    );
  }

  Future<void> _runJs() async {
    final InAppWebViewController? controller = _controller;
    if (controller == null) return;
    try {
      final dynamic result = await controller.evaluateJavascript(source: _jsController.text);
      setState(() => _jsResult = formatJsResult(result));
    } catch (e) {
      setState(() => _jsResult = 'Error: $e');
    }
  }

  Future<void> _viewCookies() async {
    final CookieManager cookieManager = CookieManager.instance();
    final List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(_urlController.text));
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cookie'),
        content: SizedBox(
          width: double.maxFinite,
          child: cookies.isEmpty
              ? const Text('(无)')
              : ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final Cookie c in cookies) Text('${c.name} = ${c.value}'),
                  ],
                ),
        ),
        actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }

  Future<void> _clearCookies() async {
    await CookieManager.instance().deleteAllCookies();
    _log('Cookies cleared');
  }

  void _log(String line) {
    setState(() => _logs.add(line));
  }
}

class _ConsolePanel extends StatelessWidget {
  const _ConsolePanel({
    required this.logs,
    required this.jsController,
    required this.result,
    required this.onRun,
    required this.onClear,
  });

  final List<String> logs;
  final TextEditingController jsController;
  final String result;
  final VoidCallback onRun;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: TextField(controller: jsController, decoration: const InputDecoration(labelText: 'JavaScript', isDense: true))),
              IconButton(icon: const Icon(Icons.play_arrow), onPressed: onRun),
              IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
            ],
          ),
          if (result.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('=> $result', style: const TextStyle(fontFamily: 'monospace')),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (BuildContext context, int index) => Text(logs[index], style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
