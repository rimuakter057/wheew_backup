import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static bool _openExternalScheme(Uri uri) {
    final s = uri.scheme.toLowerCase();
    return s == 'mailto' ||
        s == 'tel' ||
        s == 'sms' ||
        s == 'smsto' ||
        s == 'whatsapp' ||
        s == 'wtai' ||
        s == 'geo';
  }

  void _launchExternal(Uri uri) {
    Future<void> run() async {
      try {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && mounted) {
            Get.snackbar(
              'Error',
              'Could not open link',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else if (mounted) {
          Get.snackbar(
            'Error',
            'No app can open this link',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (_) {
        if (mounted) {
          Get.snackbar(
            'Error',
            'Could not open link',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }

    run();
  }

  @override
  void initState() {
    super.initState();

    debugPrint('🌐 [Terms] loading URL: ${widget.url}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('🌐 [Terms] page started: $url');
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('🟢 [Terms] page finished: $url');
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint(
              '🔴 [Terms] web resource error: code=${error.errorCode} '
              'desc=${error.description} url=${error.url}',
            );
            if (mounted) setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🌐 [Terms] navigation request: ${request.url}');
            final uri = Uri.tryParse(request.url);
            if (uri != null && _openExternalScheme(uri)) {
              _launchExternal(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.termsAndConditions.tr),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
