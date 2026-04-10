import 'package:flutter/material.dart';
import 'package:policysquare/data/models/insurance.dart';

class InsuranceDetailsScreen extends StatelessWidget {
  final InsuranceCategory category;

  const InsuranceDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${category.name} Insurance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero animation for the icon transition
            Center(
              child: Hero(
                tag: 'icon_${category.id}',
                child: Icon(
                  category.icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What would you like to do?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Get a Quote',
              subtitle:
                  'Get an instant quote for your ${category.name.toLowerCase()} insurance',
              icon: Icons.request_quote,
              onTap: () {
                // TODO: Navigate to quote flow
              },
            ),
            _buildActionCard(
              context,
              title: 'Compare Policies',
              subtitle: 'Compare plans from top insurers',
              icon: Icons.compare_arrows,
              onTap: () {
                // TODO: Navigate to comparison flow
              },
            ),
            _buildActionCard(
              context,
              title: 'Buy / Renew',
              subtitle: 'Purchase a new policy or renew existing',
              icon: Icons.shopping_cart_checkout,
              onTap: () {
                // TODO: Navigate to purchase flow
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
