// lib/widgets/insurance_card.dart
import 'package:flutter/material.dart';
import 'package:policysquare/data/models/insurance.dart';

class InsuranceCard extends StatelessWidget {
  final InsuranceCategory category;
  final VoidCallback? onTap;

  const InsuranceCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Ensures the InkWell ripple effect is contained
      child: InkWell(
        onTap:
            onTap ??
            () {
              print('${category.name} Insurance Tapped');
            },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon_${category.id}',
              child: Icon(
                category.icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${category.name} Insurance',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
