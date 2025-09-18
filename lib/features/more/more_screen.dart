import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/become_an_agent/become_an_agent_screen.dart';
import 'package:welcome_port/features/info/info_screen.dart';
import 'package:welcome_port/features/login/login_screen.dart';
import 'package:welcome_port/features/more/more_provider.dart';
import 'package:welcome_port/features/more/widgets/menu_button.dart';
import 'package:welcome_port/features/more/widgets/menu_section.dart';
import 'package:welcome_port/features/profile/profile_screen.dart';
import 'package:welcome_port/features/register/register_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MoreProvider(),
      child: MoreContent(),
    );
  }
}

class MoreContent extends StatelessWidget {
  const MoreContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<MoreProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    final isLoggedIn = sharedProvider.customer != null;
    final isAgent = sharedProvider.customer?.type == CustomerType.agent;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with teal background
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.more,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Welcome Card
            Transform.translate(
              offset: const Offset(0, -32),
              child: GestureDetector(
                onTap: () => provider.onTopBoxTap(context, sharedProvider),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFF0F0F0),
                        child: SvgPicture.asset(
                          'assets/icons/profile.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoggedIn
                                  ? l10n.welcomeUser(
                                    sharedProvider.customer?.firstName ??
                                        'User',
                                  )
                                  : l10n.welcomeGuest,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoggedIn
                                  ? l10n.manageAccountPreferences
                                  : l10n.pleaseLoginAccessFeatures,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ACCOUNT Section
                  MenuSection(
                    title: l10n.account,
                    children: [
                      if (!isLoggedIn) ...[
                        MenuButton(
                          icon: Icons.login,
                          title: l10n.login,
                          onTap:
                              () =>
                                  NavigationUtils.push(context, LoginScreen()),
                        ),
                        MenuButton(
                          icon: Icons.person_add,
                          title: l10n.signUp,
                          onTap:
                              () => NavigationUtils.push(
                                context,
                                RegisterScreen(),
                              ),
                        ),
                      ],
                      if (isLoggedIn) ...[
                        MenuButton(
                          icon: Icons.person,
                          title: l10n.myAccount,
                          onTap:
                              () => NavigationUtils.push(
                                context,
                                ProfileScreen(),
                              ),
                        ),
                      ],
                      if (!isLoggedIn || !isAgent) ...[
                        MenuButton(
                          svgPath: 'assets/icons/handshake4.svg',
                          iconPadding: 9,
                          title: l10n.becomeAgent,
                          onTap: () {
                            NavigationUtils.push(
                              context,
                              BecomeAnAgentScreen(),
                            );
                          },
                        ),
                      ],
                      if (isLoggedIn) ...[
                        MenuButton(
                          icon: Icons.logout,
                          title: l10n.logout,
                          onTap:
                              () => provider.onConfirmLogout(
                                context,
                                sharedProvider,
                              ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 35),

                  // PREFERENCES Section
                  MenuSection(
                    title: l10n.preferences,
                    children: [
                      MenuButton(
                        svgPath: 'assets/icons/language.svg',
                        iconPadding: 10,
                        title: l10n.language,
                        subtitle:
                            sharedProvider.locale.languageCode == 'en'
                                ? 'English'
                                : 'العربية',
                        onTap:
                            () => provider.showLanguageDialog(
                              context,
                              sharedProvider,
                            ),
                      ),
                      MenuButton(
                        icon: Icons.attach_money,
                        title: l10n.currency,
                        subtitle: sharedProvider.currency,
                        onTap:
                            () => provider.showCurrencyDialog(
                              context,
                              sharedProvider,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // INFORMATION Section
                  if (sharedProvider.setting?.information.isNotEmpty ==
                      true) ...[
                    MenuSection(
                      title: l10n.information,
                      children: [
                        ...sharedProvider.setting?.information
                                .map(
                                  (e) => MenuButton(
                                    networkImagePath: e.image,
                                    title: e.title,
                                    onTap:
                                        () => NavigationUtils.push(
                                          context,
                                          InfoScreen(infoId: e.informationId),
                                        ),
                                  ),
                                )
                                .toList() ??
                            [],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
