import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/connection/network_controller.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/notification/notification_handler.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/features/splash/splash_provider.dart';
import 'package:welcome_port/features/splash/splash_screen.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'dart:io' as io;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Singletons.init();
  await NotificationHandler.initialize();

  WidgetsFlutterBinding.ensureInitialized();

  if (io.Platform.isIOS || io.Platform.isAndroid) {
    String appKey;
    String accessKey;
    if (io.Platform.isIOS) {
      appKey =
          "tvoUCdhhr23ZvhAlkvEfn32slPJjbvMz2Wy81%2FmQT8Wf98K32XDKRe4xcWd8h4fn_eu";
      accessKey =
          "HBRrVVdbx%2BWg9mXldFvHn4QEttKMdZMw751f3aoDv3XjLaa%2B4B1Ufh4LnJc4Umytp%2FwLYiY1wGuKNuwMfnZ%2BZeA3%2F8GGHY0Z9JJTwWZEu559p58iZmMA1FL6qDdPT%2BPw";
    } else {
      appKey = "INSERT_ANDROID_APP_KEY";
      accessKey = "INSERT_ANDROID_ACCESS_KEY";
    }

    ZohoSalesIQ.eventChannel.listen((event) {
      switch (event["eventName"]) {
        case SIQEvent.visitorRegistrationFailure:
          {
            // event("code") - Gives the error code
            // event("message") - Gives the error message
            // if (isLoggedInUser) {
            //   ZohoSalesIQ.sendEvent(SIQSendEvent.visitorRegistrationFailure, [
            //     SalesIQUser(userId: "test"),
            //   ]);
            // } else {
            ZohoSalesIQ.sendEvent(SIQSendEvent.visitorRegistrationFailure, [
              SalesIQGuestUser(),
            ]);

            // ZohoSalesIQ.setVisitorName("John Doe");
            // ZohoSalesIQ.setVisitorEmail("john.doe@email.com");
            // ZohoSalesIQ.setVisitorContactNumber("+1234567890");

            // }
            break;
          }
      }
    });

    SalesIQConfiguration configuration = SalesIQConfiguration(
      appKey: appKey,
      accessKey: accessKey,
    );
    ZohoSalesIQ.initialize(configuration)
        .then((_) {
          ZohoSalesIQ.launcher.show(
            VisibilityMode.never,
          ); // Invoking Launcher.show() is optional.
        })
        .catchError((error) {
          // initialization failed
          debugPrint(error);
        });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SharedProvider()),
        ChangeNotifierProvider(create: (context) => SplashProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final networkController = Get.find<NetworkController>();
      networkController.setAppReady();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SharedProvider>(context);

    return GetMaterialApp(
      key: ValueKey(provider.locale.languageCode),
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Welcome Port',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primaryColor),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
