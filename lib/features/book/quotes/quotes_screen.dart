import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/models/quote.dart';
import 'package:welcome_port/features/book/home/models/get_quotes_response.dart';
import 'package:welcome_port/features/book/quotes/quotes_provider.dart';
import 'package:welcome_port/features/book/quotes/widgets/quote_box.dart';

class QuotesScreen extends StatelessWidget {
  final GetQuotesResponse quotesResponse;
  const QuotesScreen({super.key, required this.quotesResponse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuotesProvider(quotesResponse),
      child: _QuotesContent(),
    );
  }
}

class _QuotesContent extends StatelessWidget {
  const _QuotesContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuotesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with buttons and title
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Custom back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF666666),
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                const Text(
                  'Available Vehicles',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                // Filter button
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Color(0xFF666666),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quote count section
          if (provider.sortedQuotes.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Color(0xFF666666),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${provider.quotesResponse.quotes.length} options found',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  provider.quotesResponse.quotes.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Session Expired Overlay
          if (provider.isSessionExpired)
            SliverFillRemaining(child: _buildSessionExpiredState(context))
          // Quotes List or Empty State
          else if (provider.sortedQuotes.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: QuoteBox(
                      quote: provider.sortedQuotes[index],
                      onBookNow: (Quote quote) async {
                        return await provider.bookNow(quote, context);
                      },
                    ),
                  );
                }, childCount: provider.sortedQuotes.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionExpiredState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Session expired icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_filled,
                size: 60,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Session Expired',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Your search session has expired. Please search again to see the most up-to-date vehicle availability and pricing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Action button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Icon(
                Icons.directions_car_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'No Vehicles Available',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'We couldn\'t find any vehicles for your selected route and time. Please try adjusting your search criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Action button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final provider = Provider.of<QuotesProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Row(
                    children: [
                      const Text(
                        'Sort by Price',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  // Sort options
                  _buildSortOption(
                    context,
                    'High to Low',
                    'high_to_low',
                    Icons.arrow_downward,
                    provider,
                  ),
                  _buildSortOption(
                    context,
                    'Low to High',
                    'low_to_high',
                    Icons.arrow_upward,
                    provider,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    QuotesProvider provider,
  ) {
    final isSelected = provider.currentSort == value;

    return GestureDetector(
      onTap: () {
        // Toggle selection - if already selected, deselect (go to default)
        if (isSelected) {
          provider.sortQuotes('none');
        } else {
          provider.sortQuotes(value);
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
