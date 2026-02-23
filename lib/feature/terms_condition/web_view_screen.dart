import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Controller init
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JS enable
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              isLoading = false; // loading complete
            });
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'terms_and_conditions'.tr),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller), // Display WebView
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ), // loading indicator
        ],
      ),
    );
  }
}
