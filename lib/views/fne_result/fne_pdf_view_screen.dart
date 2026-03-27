import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../home/home_screen.dart';

class FnePdfViewScreen extends StatefulWidget {
  final String path;
  final String title;

  const FnePdfViewScreen({
    super.key,
    required this.path,
    this.title = 'Facture certifiée FNE',
  });

  @override
  State<FnePdfViewScreen> createState() => _FnePdfViewScreenState();
}

class _FnePdfViewScreenState extends State<FnePdfViewScreen> {
  late final PdfControllerPinch _pdfCtrl;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfCtrl = PdfControllerPinch(
      document: PdfDocument.openFile(widget.path),
    );
  }

  @override
  void dispose() {
    _pdfCtrl.dispose();
    super.dispose();
  }

  void _goHome() => Get.offAll(() => const HomeScreen());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(),
      child: Scaffold(
        backgroundColor: const Color(0xFF2A2A2A),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goHome,
          ),
          title: Text(widget.title,
              style: TextStyle(fontSize: R.fs(context, 16))),
          actions: [
            IconButton(
              icon: Icon(Icons.share_rounded, size: R.icon(context, 22)),
              tooltip: 'Partager',
              onPressed: () => Share.shareXFiles(
                [XFile(widget.path)],
                subject: 'Facture FNE',
              ),
            ),
            SizedBox(width: R.hPad(context) - 16),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: PdfViewPinch(
                  controller: _pdfCtrl,
                  onDocumentLoaded: (doc) =>
                      setState(() => _totalPages = doc.pagesCount),
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    documentLoaderBuilder: (_) => const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                    pageLoaderBuilder: (_) => const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
              if (_totalPages > 1)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  child: Text(
                    'Page $_currentPage / $_totalPages',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
