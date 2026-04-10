import 'package:flutter/material.dart';
import 'package:policysquare/screens/health/policy_analysis_screen.dart';
import 'package:policysquare/screens/health/design_health_insure_screen.dart';
import 'package:policysquare/screens/commercial/claims_list_screen.dart';
import 'package:policysquare/screens/commercial/underwriting_tips_screen.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Insurance',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              'Policy Analysis',
              Icons.analytics,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PolicyAnalysisScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Design your Health Insure',
              Icons.health_and_safety,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DesignHealthInsureScreen(),
                ),
              ),
            ),
            _buildDashboardCard(
              context,
              'Foot Print of Claim',
              Icons.history_edu,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ClaimsListScreen(category: 'Health'),
                ),
              ),
            ),
            _buildDashboardCard(
              context,
              'Fine Print of Underwriter',
              Icons.menu_book,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const UnderwritingTipsScreen(category: 'Health'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
