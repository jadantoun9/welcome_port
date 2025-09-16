import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/info/info_provider.dart';
import 'package:welcome_port/features/info/utils/utils.dart';

class InfoScreen extends StatelessWidget {
  final int infoId;
  const InfoScreen({super.key, required this.infoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InfoProvider(infoId.toString()),
      child: InfoScreenContent(infoId: infoId),
    );
  }
}

class InfoScreenContent extends StatelessWidget {
  final int infoId;
  const InfoScreenContent({super.key, required this.infoId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InfoProvider>(context);

    if (provider.error.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(context: context, message: provider.error).then((_) {
          provider.setError('');
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(getStringFromHtml(provider.info?.title ?? '')),
      ),
      body:
          provider.isLoading
              ? const Center(child: Loader())
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(child: Html(data: provider.decodedHtml)),
                  ),
                ),
              ),
    );
  }
}
