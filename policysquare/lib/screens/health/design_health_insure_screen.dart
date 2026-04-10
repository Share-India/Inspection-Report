import 'package:flutter/material.dart';
import 'package:policysquare/data/models/health_quote_request.dart';
import 'package:policysquare/providers/commercial_provider.dart';
import 'package:policysquare/screens/health/health_quote_results_screen.dart';
import 'package:provider/provider.dart';

class DesignHealthInsureScreen extends StatefulWidget {
  const DesignHealthInsureScreen({super.key});

  @override
  State<DesignHealthInsureScreen> createState() =>
      _DesignHealthInsureScreenState();
}

class _DesignHealthInsureScreenState extends State<DesignHealthInsureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();

  String? _selectedCityTier;
  String? _selectedMembers;
  double? _selectedSumInsured;

  final List<String> _cityTiers = ['Tier 1', 'Tier 2', 'Tier 3'];
  final List<String> _memberOptions = ['1A', '2A', '2A1C', '2A2C'];
  final List<double> _sumInsuredOptions = [500000.0, 1000000.0, 2000000.0];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCityTier == null ||
          _selectedMembers == null ||
          _selectedSumInsured == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all required fields.')),
        );
        return;
      }

      final request = HealthQuoteRequest(
        age: int.parse(_ageController.text),
        cityTier: _selectedCityTier!,
        members: _selectedMembers!,
        selectedSumInsured: _selectedSumInsured!,
      );

      final provider = context.read<CommercialProvider>();
      await provider.calculateHealthQuotes(request);

      if (!mounted) return;

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error computing quotes: ${provider.error}')),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthQuoteResultsScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CommercialProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Design your Health Insure',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Primary Insured Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age (Primary Member)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Age is required';
                  final age = int.tryParse(v);
                  if (age == null || age < 18 || age > 100)
                    return 'Enter valid age (18-100)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCityTier,
                decoration: InputDecoration(
                  labelText: 'City Tier',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                items: _cityTiers.map((tier) {
                  return DropdownMenuItem(value: tier, child: Text(tier));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCityTier = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMembers,
                decoration: InputDecoration(
                  labelText: 'Member Coverage Mix',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.family_restroom),
                ),
                items: _memberOptions.map((mix) {
                  return DropdownMenuItem(value: mix, child: Text(mix));
                }).toList(),
                onChanged: (val) => setState(() => _selectedMembers = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _selectedSumInsured,
                decoration: InputDecoration(
                  labelText: 'Required Sum Insured (₹)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                items: _sumInsuredOptions.map((amount) {
                  return DropdownMenuItem(
                    value: amount,
                    child: Text(
                      '₹${(amount / 100000).toStringAsFixed(0)} Lakhs',
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSumInsured = val),
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calculate Premium Quotes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
