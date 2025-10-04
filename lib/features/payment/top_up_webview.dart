import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/core/widgets/success_message.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';

class TopUpWebview extends StatefulWidget {
  final String url;

  const TopUpWebview({super.key, required this.url});

  @override
  State<TopUpWebview> createState() => _TopUpWebviewState();
}

class _TopUpWebviewState extends State<TopUpWebview> {
  bool isLoading = true;
  String currentUrl = '';
  late WebViewController webViewController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
    _initializeWebView();
  }

  void _initializeWebView() {
    // Initialize the WebViewController
    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                if (!_isDisposed && mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              onPageFinished: (url) async {
                if (_isDisposed || !mounted) return;

                if (url.contains('success=1')) {
                  handleSuccess();
                } else if (url.contains('success=0')) {
                  handleFailure();
                }
              },
              onWebResourceError: (error) {
                // Handle web resource errors silently
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void handleSuccess() {
    if (_isDisposed || !mounted) return;

    final l = AppLocalizations.of(context)!;
    NavigationUtils.clearAndPush(context, NavScreen());
    showSuccessMessage(context: context, message: l.topUpSuccessfully);
  }

  void handleFailure() {
    if (_isDisposed || !mounted) return;

    final l = AppLocalizations.of(context)!;
    NavigationUtils.pop(context);
    showErrorDialog(context: context, title: l.error, message: l.topUpFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _isDisposed = true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            l.topUpWallet,
            style: const TextStyle(color: Colors.white, fontSize: 21),
          ),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(
                controller: webViewController,
                key: ValueKey(widget.url),
              ),
              if (isLoading)
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: const Loader(color: AppColors.primaryColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
