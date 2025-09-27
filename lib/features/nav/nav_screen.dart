import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/features/book/home/home_screen.dart';
import 'package:welcome_port/features/more/more_screen.dart';
import 'package:welcome_port/features/orders/orders_screen.dart';
import 'package:welcome_port/features/wallet/wallet_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  getWidgetOptions(SharedProvider sharedProv) {
    if (sharedProv.customer?.type == CustomerType.agent) {
      return [HomeScreen(), OrdersScreen(), WalletScreen(), MoreScreen()];
    }
    return [HomeScreen(), OrdersScreen(), MoreScreen()];
  }

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      body: Center(
        child: getWidgetOptions(
          sharedProvider,
        ).elementAt(sharedProvider.selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: sharedProvider.selectedIndex,
            onItemTapped: (index) {
              sharedProvider.setSelectedIndex(index);
            },
          ),
        ),
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          spacing: 3,
          children: [
            _buildNavItem(index: 0, label: 'Home', icon: Icons.home),
            _buildNavItem(index: 1, label: 'Orders', icon: Icons.receipt),
            if (sharedProvider.customer?.type == CustomerType.agent)
              _buildNavItem(index: 2, label: 'Wallet', icon: Icons.wallet),
            _buildNavItem(
              index:
                  sharedProvider.customer?.type == CustomerType.agent ? 3 : 2,
              label: 'More',
              icon: Icons.menu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    String? iconPath,
    IconData? icon,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkwellWithOpacity(
        clickedOpacity: 0.6,
        onTap: () {
          HapticFeedback.mediumImpact();
          onItemTapped(index);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (iconPath != null)
                            SvgPicture.asset(
                              iconPath,
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            )
                          else if (icon != null)
                            Icon(
                              icon,
                              color:
                                  isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                              size: 24,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                              fontSize: 12,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
