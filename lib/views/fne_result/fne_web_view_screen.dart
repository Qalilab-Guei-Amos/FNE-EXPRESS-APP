import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../controllers/history_controller.dart';
import '../../services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'fne_pdf_view_screen.dart';
import '../home/home_screen.dart';

class FneWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? recordId; // pour sauvegarder le chemin PDF sur l'article

  const FneWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Facture certifiée FNE',
    this.recordId,
  });

  @override
  State<FneWebViewScreen> createState() => _FneWebViewScreenState();
}

class _FneWebViewScreenState extends State<FneWebViewScreen> {
  static const _nativeChannel = MethodChannel('com.example.fne_app/webview');

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'BlobDownload',
        onMessageReceived: (msg) => _handleBlobData(msg.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) async {
            if (request.url == widget.url) return NavigationDecision.navigate;

            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            if (uri.scheme == 'blob') {
              _extractBlob(request.url);
            } else if (uri.scheme == 'http' || uri.scheme == 'https') {
              _downloadHttp(request.url);
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // ── Blob URL ──────────────────────────────────────────────────────────────

  void _extractBlob(String blobUrl) {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    final safeUrl = blobUrl.replaceAll("'", r"\'");
    _controller.runJavaScript('''
      (async () => {
        try {
          const r = await fetch('$safeUrl');
          const blob = await r.blob();
          const reader = new FileReader();
          reader.onloadend = () => BlobDownload.postMessage(reader.result);
          reader.onerror   = () => BlobDownload.postMessage('error:lecture impossible');
          reader.readAsDataURL(blob);
        } catch(e) { BlobDownload.postMessage('error:' + e.toString()); }
      })();
    ''');
  }

  Future<void> _handleBlobData(String data) async {
    if (data.startsWith('error:')) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showError('Impossible de lire la facture : ${data.substring(6)}');
      }
      return;
    }
    try {
      final commaIdx = data.indexOf(',');
      if (commaIdx == -1) throw Exception('format data URL invalide');

      final header = data.substring(0, commaIdx);
      final b64 = data.substring(commaIdx + 1);

      String ext = 'pdf';
      if (header.contains('png')) {
        ext = 'png';
      } else if (header.contains('jpeg') || header.contains('jpg')) {
        ext = 'jpg';
      } else if (header.contains('html')) {
        ext = 'html';
      }

      final bytes = base64Decode(b64);
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/facture_fne_$timestamp.$ext';
      await File(path).writeAsBytes(bytes);

      if (mounted) {
        setState(() => _isDownloading = false);
        await _openPdfViewer(path);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showError('Erreur de décodage : $e');
      }
    }
  }

  // ── URL HTTP ──────────────────────────────────────────────────────────────

  Future<void> _downloadHttp(String url) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    try {
      String cookies = '';
      try {
        cookies =
            await _nativeChannel.invokeMethod<String>('getCookies', {
              'url': url,
            }) ??
            '';
      } catch (_) {}

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${dir.path}/fne_$timestamp.tmp';

      final response = await dio.download(
        url,
        tempPath,
        options: Options(
          headers: {
            if (cookies.isNotEmpty) 'Cookie': cookies,
            'Referer': widget.url,
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
          },
          receiveTimeout: const Duration(minutes: 3),
          followRedirects: true,
          maxRedirects: 5,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      String filename = 'facture_fne_$timestamp.pdf';
      final cd = response.headers.value('content-disposition');
      if (cd != null) {
        final match = RegExp(
          r'filename[^=]*=\s*"?([^";\r\n]+)"?',
        ).firstMatch(cd);
        if (match != null) filename = match.group(1)?.trim() ?? filename;
      }

      final finalPath = '${dir.path}/$filename';
      await File(tempPath).rename(finalPath);

      if (mounted) {
        setState(() => _isDownloading = false);
        await _openPdfViewer(finalPath);
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        final code = e.response?.statusCode;
        _showError(
          code != null
              ? 'Erreur serveur : code $code'
              : 'Erreur réseau (${e.type.name})',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showError('Erreur inattendue : $e');
      }
    }
  }

  // ── Ouvre la visionneuse et persiste le chemin ────────────────────────────

  Future<void> _openPdfViewer(String path) async {
    // Sauvegarder le chemin local sur l'article FNE
    if (widget.recordId != null) {
      await Get.find<StorageService>().updateFnePdfPath(widget.recordId!, path);
      // Rafraîchir l'historique si le contrôleur est actif
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadRecords();
      }
    }
    // Remplacer le WebView par la visionneuse PDF
    Get.off(() => FnePdfViewScreen(path: path, title: widget.title));
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────

  void _showError(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: const Text('Erreur de téléchargement'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void _goHome() => Get.offAll(() => const HomeScreen());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goHome,
          ),
          title: Text(
            widget.title,
            style: TextStyle(fontSize: R.fs(context, 16)),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, size: R.icon(context, 22)),
              onPressed: () => _controller.reload(),
              tooltip: 'Actualiser',
            ),
            SizedBox(width: R.hPad(context) - 16),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isDownloading) _DownloadOverlay(progress: _downloadProgress),
              if (_isLoading && !_isDownloading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overlay de téléchargement ────────────────────────────────────────────────
class _DownloadOverlay extends StatelessWidget {
  final double progress;
  const _DownloadOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.download_rounded,
                color: AppTheme.primary,
                size: 44,
              ),
              const SizedBox(height: 16),
              const Text(
                'Téléchargement en cours…',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 6,
                  color: AppTheme.primary,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              if (progress > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)} %',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
