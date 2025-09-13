import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    // HomeScreen(),
    // CartScreen(),
    // MoreScreen(),
    SizedBox(),
    SizedBox(),
    SizedBox(),
    SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(sharedProvider.selectedIndex),
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
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              iconPath: 'assets/icons/home.svg',
              label: 'Home',
              icon: null,
            ),
            _buildNavItem(
              index: 1,
              iconPath: 'assets/icons/cart.svg',
              label: 'Cart',
              icon: null,
            ),
            _buildNavItem(index: 2, label: 'More', icon: Icons.menu),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    String? iconPath,
    String? note,
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
                  width: 40,
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
                                    ? selectedIndex == 2
                                        ? Colors.black
                                        : AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            )
                          else if (icon != null)
                            Icon(
                              icon,
                              color:
                                  isSelected
                                      ? selectedIndex == 2
                                          ? Colors.black
                                          : AppColors.primaryColor
                                      : Colors.grey,
                              size: 24,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? selectedIndex == 2
                                          ? Colors.black
                                          : AppColors.primaryColor
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
                      if (note != null)
                        Positioned(
                          top: 2,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Center(
                              child: Text(
                                note,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
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
