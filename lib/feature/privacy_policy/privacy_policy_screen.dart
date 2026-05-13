import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/share/widgets/custom_appbar/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String url;

  const PrivacyPolicyScreen({super.key, required this.url});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
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
      appBar: CustomAppBar(title: 'privacy_policy'.tr),
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
