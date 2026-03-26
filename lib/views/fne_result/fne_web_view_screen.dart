import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class FneWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  const FneWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Facture certifiée FNE',
  });

  @override
  State<FneWebViewScreen> createState() => _FneWebViewScreenState();
}

class _FneWebViewScreenState extends State<FneWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(fontSize: R.fs(context, 16))),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: R.icon(context, 22)),
            onPressed: () => _controller.reload(),
            tooltip: 'Actualiser',
          ),
          SizedBox(width: R.hPad(context) - 16),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
        ],
      ),
    );
  }
}
