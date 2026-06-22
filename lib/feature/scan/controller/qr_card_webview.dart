import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QrCardWebView extends StatefulWidget {
  final String htmlContent;
  const QrCardWebView({super.key, required this.htmlContent});

  @override
  State<QrCardWebView> createState() => _QrCardWebViewState();
}

class _QrCardWebViewState extends State<QrCardWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}