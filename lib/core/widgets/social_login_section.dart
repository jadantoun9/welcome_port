import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/providers/social_login_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/loader.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocialLoginProvider(),
      child: _SocialLoginContent(),
    );
  }
}

class _SocialLoginContent extends StatelessWidget {
  const _SocialLoginContent();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = Provider.of<SocialLoginProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Column(
      children: [
        // OR divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.or,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
          ],
        ),

        const SizedBox(height: 20),

        // Social login buttons - wide horizontal buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.signInWithGoogle(context, sharedProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon:
                    provider.isGoogleLoading
                        ? null
                        : SvgPicture.asset(
                          'assets/images/google_logo.svg',
                          width: 22,
                          height: 22,
                        ),
                label:
                    provider.isGoogleLoading
                        ? Loader(color: Colors.black, size: 22)
                        : Text(
                          l.continueWithGoogle,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 15),
            // Apple button - wide
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.signInWithApple(context, sharedProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon:
                    provider.isAppleLoading
                        ? null
                        : const Icon(
                          Icons.apple,
                          color: Colors.white,
                          size: 27,
                        ),
                label:
                    provider.isAppleLoading
                        ? Loader(color: Colors.white, size: 22)
                        : Text(
                          l.continueWithApple,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ],
    );
  }
}
