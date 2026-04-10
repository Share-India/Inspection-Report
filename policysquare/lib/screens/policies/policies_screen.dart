import 'package:flutter/material.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Policies'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPolicyCard(
            context,
            policyNumber: 'POL-2023-M-8842',
            insuranceType: 'Motor Insurance',
            expiryDate: '15 Aug 2024',
            status: 'Active',
            premium: '\$450.00',
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          _buildPolicyCard(
            context,
            policyNumber: 'POL-2022-H-1102',
            insuranceType: 'Health Insurance',
            expiryDate: '01 Jan 2024',
            status: 'Expired',
            premium: '\$200.00',
            icon: Icons.favorite,
            color: Colors.red,
          ),
          _buildPolicyCard(
            context,
            policyNumber: 'POL-2023-L-9931',
            insuranceType: 'Life Insurance',
            expiryDate: '20 Dec 2025',
            status: 'Active',
            premium: '\$1200.00',
            icon: Icons.family_restroom,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required String policyNumber,
    required String insuranceType,
    required String expiryDate,
    required String status,
    required String premium,
    required IconData icon,
    required Color color,
  }) {
    final bool isActive = status == 'Active';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insuranceType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policyNumber,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      premium,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expires On',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiryDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isActive ? 'View Details' : 'Renew Policy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
