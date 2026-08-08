import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/language/app_string.dart';
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



            CustomSnackbar.error(
              context: context,
              message: AppStrings.couldNotOpenLink.tr,
            );


          }
        } else if (mounted) {


          CustomSnackbar.error(
            context: context,
            message: AppStrings.noAppCanOpenThisLink.tr,
          );

        }
      } catch (_) {
        if (mounted) {


          CustomSnackbar.error(
            context: context,
            message: AppStrings.couldNotOpenLink.tr,
          );

        }
      }
    }

    run();
  }

  @override
  void initState() {
    super.initState();

    debugPrint('🌐 [Privacy] loading URL: ${widget.url}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('🌐 [Privacy] page started: $url');
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('🟢 [Privacy] page finished: $url');
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint(
              '🔴 [Privacy] web resource error: code=${error.errorCode} '
              'desc=${error.description} url=${error.url}',
            );
            if (mounted) setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🌐 [Privacy] navigation request: ${request.url}');
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
      appBar: CustomAppBar(title: AppStrings.privacyPolicy.tr),
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
