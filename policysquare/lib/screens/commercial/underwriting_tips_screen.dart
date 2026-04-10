import 'package:flutter/material.dart';
import 'package:policysquare/providers/commercial_provider.dart';
import 'package:provider/provider.dart';

class UnderwritingTipsScreen extends StatefulWidget {
  final String? category;

  const UnderwritingTipsScreen({super.key, this.category});

  @override
  State<UnderwritingTipsScreen> createState() => _UnderwritingTipsScreenState();
}

class _UnderwritingTipsScreenState extends State<UnderwritingTipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommercialProvider>().fetchTips(category: widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fine Prints of Underwriting',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CommercialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.tips.isEmpty) {
            return const Center(child: Text('No underwriting tips found.'));
          }

          return Container(
            color: const Color(0xFFF5F7FA),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.tips.length,
              itemBuilder: (context, index) {
                final tip = provider.tips[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showTipDetails(context, tip),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tip.imagePath != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              'http://10.0.2.2:8081${tip.imagePath}',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 150,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tip.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tip.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tip.description ?? 'No description',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7F8C8D),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  Text(
                                    'Read Detailed Tip',
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Color(0xFF1565C0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showTipDetails(BuildContext context, dynamic tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(bottom: 20),
                ),
              ),
              Text(
                tip.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (tip.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://10.0.2.2:8081${tip.imagePath}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                tip.description ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 24),
              if (tip.example != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6F3), // Green/Teal Light
                    border: const Border(
                      left: BorderSide(color: Color(0xFF1ABC9C), width: 4),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A085),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip.example!,
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
              if (tip.keyTakeaway != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1), // Yellow Light
                    border: const Border(
                      left: BorderSide(color: Color(0xFFF1C40F), width: 4),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Key Takeaway',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF39C12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip.keyTakeaway!,
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
