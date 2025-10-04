import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/analytics/facebook_analytics_engine.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/features/order_details/order_details_screen.dart';

class PaymentWebview extends StatefulWidget {
  final String url;
  final double? amount;
  final String? currency;

  const PaymentWebview({
    super.key,
    required this.url,
    this.amount,
    this.currency,
  });

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
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

                if (url.contains('success=1') &&
                    url.contains('reference') &&
                    url.contains('email')) {
                  final reference = url.split('reference=')[1].split('&')[0];
                  final email = url.split('email=')[1].split('&')[0];
                  handleSuccess(reference: reference, email: email);
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

  void handleSuccess({required String reference, required String email}) {
    if (_isDisposed || !mounted) return;

    // Track booking purchase
    if (widget.amount != null && widget.currency != null) {
      FacebookAnalyticsEngine.logPurchase(
        amount: widget.amount!,
        currency: widget.currency!,
        orderReference: reference,
        contentType: 'booking',
      );
    }

    NavigationUtils.clearAndPush(context, NavScreen());
    NavigationUtils.push(
      context,
      OrderDetailsScreen(orderReference: reference, email: email),
    );
  }

  void handleFailure() async {
    if (_isDisposed || !mounted) return;

    final l = AppLocalizations.of(context)!;
    NavigationUtils.pop(context);

    await showErrorDialog(
      context: context,
      title: l.error,
      message: l.paymentFailed,
    );
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
          title: Text(l.pay, style: const TextStyle(color: Colors.white)),
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
