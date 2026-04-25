// ============================================================================
// lib/features/more/presentation/web_document_screen.dart
// ============================================================================
//
// [역할]
// 웹뷰 문서 표시 화면 (개인정보처리방침, 이용약관 등).
//
// [레이어]
// Presentation Layer - View
// ============================================================================

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 웹 문서 표시 화면.
class WebDocumentScreen extends StatefulWidget {
  const WebDocumentScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<WebDocumentScreen> createState() => _WebDocumentScreenState();
}

class _WebDocumentScreenState extends State<WebDocumentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            LinearProgressIndicator(
              minHeight: 2,
              color: cs.primary,
              backgroundColor: cs.surfaceContainerHighest,
            ),
        ],
      ),
    );
  }
}
