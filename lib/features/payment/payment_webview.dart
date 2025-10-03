import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/features/order_details/order_details_screen.dart';

class PaymentWebview extends StatefulWidget {
  final String url;

  const PaymentWebview({super.key, required this.url});

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  bool isLoading = true;
  String currentUrl = '';
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;

    // Initialize the WebViewController
    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() {
                  isLoading = false;
                });
              },
              onPageFinished: (url) async {
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
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  void handleSuccess({required String reference, required String email}) {
    NavigationUtils.clearAndPush(context, NavScreen());
    NavigationUtils.push(
      context,
      OrderDetailsScreen(orderReference: reference, email: email),
    );
  }

  void handleFailure() async {
    final l = AppLocalizations.of(context)!;
    await showErrorDialog(
      context: context,
      title: l.error,
      message: l.paymentFailed,
    );
    if (mounted) {
      NavigationUtils.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.pay, style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: webViewController),
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
    );
  }
}
