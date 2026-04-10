// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:policysquare/data/models/insurance.dart';
import 'package:policysquare/screens/chat/chat_screen.dart';
import 'package:policysquare/widgets/insurance_card.dart';
import 'package:policysquare/screens/commercial/commercial_dashboard_screen.dart';
import 'package:policysquare/screens/health/health_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for insurance categories
    final List<InsuranceCategory> categories = [
      InsuranceCategory(id: 'motor', name: 'Motor', icon: Icons.directions_car),
      InsuranceCategory(
        id: 'commercial',
        name: 'Commercial',
        icon: Icons.business,
      ),
      InsuranceCategory(id: 'health', name: 'Health', icon: Icons.favorite),
      InsuranceCategory(id: 'life', name: 'Life', icon: Icons.family_restroom),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Policy Square'), elevation: 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Policy Square',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your one-stop insurance solution. How can we help you today?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              // Grid view for insurance categories
              GridView.builder(
                shrinkWrap: true, // Important for nesting in a ScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // Disables grid's own scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Makes the cards square
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return InsuranceCard(
                    category: categories[index],
                    onTap: () {
                      if (categories[index].id == 'commercial') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CommercialDashboardScreen(),
                          ),
                        );
                      } else if (categories[index].id == 'health') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthDashboardScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${categories[index].name} Insurance coming soon!',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        tooltip: 'Chat with Advisor',
        child: const Icon(Icons.chat),
      ),
    );
  }
}
