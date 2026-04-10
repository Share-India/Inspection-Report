import 'package:flutter/material.dart';
import 'package:policysquare/data/models/rfq.dart';
import 'package:policysquare/providers/commercial_provider.dart';
import 'package:policysquare/screens/commercial/my_quotes_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class RfqScreen extends StatefulWidget {
  const RfqScreen({super.key});

  @override
  State<RfqScreen> createState() => _RfqScreenState();
}

class _RfqScreenState extends State<RfqScreen> {
  final _formKey = GlobalKey<FormState>();

  // 0: Product Selection, 1: Flat Form
  int _screenState = 0;
  String _selectedProduct = '';

  final List<Map<String, dynamic>> _productCategories = [
    {'name': 'Property', 'icon': Icons.business, 'color': Colors.blue},
    {
      'name': 'Marine Engineering',
      'icon': Icons.directions_boat,
      'color': Colors.teal,
    },
    {'name': 'Liability', 'icon': Icons.gavel, 'color': Colors.red},
    {'name': 'Employee Benefits', 'icon': Icons.groups, 'color': Colors.orange},
    {'name': 'Industry Package', 'icon': Icons.factory, 'color': Colors.brown},
    {
      'name': 'Motor Fleet',
      'icon': Icons.local_shipping,
      'color': Colors.indigo,
    },
    {'name': 'Specialty', 'icon': Icons.star, 'color': Colors.purple},
  ];

  // ==========================================
  // 10-SECTION DATA MODEL TRACKING
  // ==========================================

  // 1. Proposer / Company Information
  final Map<String, dynamic> _section1 = {
    'entityName': '',
    'constitution': 'Pvt Ltd',
    'panGst': '',
    'cin': '',
    'registeredAddress': '',
    'contactPerson': '',
    'industryType': '',
    'yearOfIncorporation': '',
    'annualTurnover': '',
    'website': '',
    'mobileNumber': '',
    'email': '',
  };

  // 2. Risk Location & Occupancy
  final Map<String, dynamic> _section2 = {
    'riskAddress': '',
    'numLocations': '1',
    'ownership': 'Owned',
    'constructionType': 'RCC',
    'occupancyType': '',
    'floorDetails': '',
    'adjoiningRisk': '',
    'distanceFromFireStation': '',
  };

  // 3. Asset Details (Sum Insured Breakup)
  final Map<String, dynamic> _section3 = {
    'building': '',
    'plantMachinery': '',
    'furniture': '',
    'electrical': '',
    'stock': '',
    'electronic': '',
    'computers': '',
    'highValue': '',
    'valuationBasis': 'Market Value',
    'stockFluctuation': 'No',
  };

  // 4. Coverage Required (Multi-select mapped to booleans)
  final Map<String, bool> _section4 = {
    'Standard Fire & Special Perils': false,
    'Burglary': false,
    'Machinery Breakdown': false,
    'Marine Transit': false,
    'Contractor All Risk': false,
    'Public Liability': false,
    'Workmen Compensation': false,
    'Group Health': false,
    'Cyber Insurance': false,
    'D&O': false,
  };

  // 5. Add-on Covers
  final Map<String, bool> _section5 = {
    'Earthquake': false,
    'STFI': false,
    'Terrorism': false,
    'Escalation Clause': false,
    'Loss of Profit': false,
    'Declaration Policy': false,
    'Floater Policy': false,
  };

  // 6. Risk Protection Measures
  final Map<String, bool> _section6 = {
    'Fire Extinguishers': false,
    'Fire Hydrant System': false,
    'Sprinkler System': false,
    'CCTV': false,
    '24x7 Security': false,
    'Alarm System': false,
    'Smoke Detectors': false,
    'AMC for Machinery': false,
    'Fire NOC Available': false,
  };

  // 7. Claims History (Last 3-5 Years)
  final Map<String, dynamic> _section7 = {
    'numClaims': '0',
    'claimAmount': '',
    'natureOfLoss': '',
    'yearOfLoss': '',
    'outstandingClaims': '',
  };

  // 8. Existing Insurance Details
  final Map<String, dynamic> _section8 = {
    'currentInsurer': '',
    'policyNumber': '',
    'expiryDate': '',
    'premiumPaid': '',
    'specialTerms': '',
  };

  // 9. Financial & Compliance (Placeholder for file uploads/checks)
  final Map<String, bool> _section9 = {
    'Audited Balance Sheet': false,
    'GST Certificate': false,
    'PAN Card': false,
    'COI / MOA / AOA': false,
    'Board Resolution': false,
    'Bank Details': false,
  };

  // 10. Special Risk Information
  final Map<String, dynamic> _section10 = {
    'hazardousMaterial': '',
    'chemicalStorage': '',
    'pastFireIncidents': '',
    'loadShedding': '',
    'subcontracting': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request for Quote',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyQuotesScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: const Text(
              'My Quotes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: _screenState == 0 ? _buildProductSelection() : _buildWizard(),
      ),
    );
  }

  Widget _buildProductSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Select Category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _productCategories.length,
            itemBuilder: (context, index) {
              final product = _productCategories[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedProduct = product['name'];
                      _screenState = 1;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (product['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product['icon'] as IconData,
                          size: 40,
                          color: product['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIZARD FRAMEWORK
  // ==========================================

  bool _shouldShowStep(int stepIndex) {
    // 0: Proposer Info (All)
    // 1: Risk Location (All)
    // 2: Asset Details (Property, Marine, Industry Package)
    // 3: Coverage Required (All)
    // 4: Add-on Covers (Property, Marine, Industry Package, Motor)
    // 5: Risk Protection (Property, Marine, Industry Package)
    // 6: Claims History (All)
    // 7: Existing Insurance (All)
    // 8: Compliance (All)
    // 9: Special Risks (Liability, Specialty, Industry Package)

    switch (stepIndex) {
      case 2: // Asset Details
      case 5: // Risk Protection
        return [
          'Property',
          'Marine Engineering',
          'Industry Package',
        ].contains(_selectedProduct);
      case 4: // Add-on Covers
        return [
          'Property',
          'Marine Engineering',
          'Industry Package',
          'Motor Fleet',
        ].contains(_selectedProduct);
      case 9: // Special Risks
        return [
          'Liability',
          'Specialty',
          'Industry Package',
        ].contains(_selectedProduct);
      default:
        return true;
    }
  }

  Widget _buildTextInput(
    String label,
    String mapKey,
    Map<String, dynamic> section, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: section[mapKey],
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (val) => setState(() => section[mapKey] = val),
      ),
    );
  }

  Widget _buildCheckboxGrid(Map<String, bool> section) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: section.length,
      itemBuilder: (context, index) {
        String key = section.keys.elementAt(index);
        return Theme(
          data: ThemeData(unselectedWidgetColor: Colors.grey),
          child: CheckboxListTile(
            title: Text(key, style: const TextStyle(fontSize: 12)),
            value: section[key],
            activeColor: const Color(0xFF1565C0),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => section[key] = val ?? false),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: Color(0xFF1565C0), width: 4),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormSections() {
    return [
      _buildSectionHeader('1. Proposer Info'),
      _buildTextInput('Entity Name', 'entityName', _section1),
      _buildTextInput('Nature of Business', 'industryType', _section1),
      _buildTextInput('PAN & GST Number', 'panGst', _section1),
      _buildTextInput('Contact Person', 'contactPerson', _section1),
      _buildTextInput(
        'Mobile Number',
        'mobileNumber',
        _section1,
        isNumber: true,
      ),
      _buildTextInput('Email', 'email', _section1),
      _buildTextInput(
        'Annual Turnover (Last 3 Yrs)',
        'annualTurnover',
        _section1,
      ),

      if (_shouldShowStep(1)) ...[
        _buildSectionHeader('2. Risk Location'),
        _buildTextInput('Complete Risk Address', 'riskAddress', _section2),
        _buildTextInput(
          'Number of Locations',
          'numLocations',
          _section2,
          isNumber: true,
        ),
        _buildTextInput('Occupancy Type', 'occupancyType', _section2),
        _buildTextInput(
          'Adjoining Risk (Chemical, Godown etc)',
          'adjoiningRisk',
          _section2,
        ),
        _buildTextInput(
          'Distance to Fire Station',
          'distanceFromFireStation',
          _section2,
        ),
      ],

      if (_shouldShowStep(2)) ...[
        _buildSectionHeader('3. Asset Details'),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Enter Value Breakup (₹)',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        _buildTextInput(
          'Building Value',
          'building',
          _section3,
          isNumber: true,
        ),
        _buildTextInput(
          'Plant & Machinery',
          'plantMachinery',
          _section3,
          isNumber: true,
        ),
        _buildTextInput(
          'Furniture & Fixtures',
          'furniture',
          _section3,
          isNumber: true,
        ),
        _buildTextInput(
          'Stock (Raw/Finished)',
          'stock',
          _section3,
          isNumber: true,
        ),
        _buildTextInput(
          'Electronic Equipment',
          'electronic',
          _section3,
          isNumber: true,
        ),
      ],

      if (_shouldShowStep(3)) ...[
        _buildSectionHeader('4. Coverage Req'),
        _buildCheckboxGrid(_section4),
      ],

      if (_shouldShowStep(4)) ...[
        _buildSectionHeader('5. Add-on Covers'),
        _buildCheckboxGrid(_section5),
      ],

      if (_shouldShowStep(5)) ...[
        _buildSectionHeader('6. Risk Protection'),
        _buildCheckboxGrid(_section6),
      ],

      if (_shouldShowStep(6)) ...[
        _buildSectionHeader('7. Claims History'),
        _buildTextInput(
          'Number of Claims',
          'numClaims',
          _section7,
          isNumber: true,
        ),
        _buildTextInput(
          'Total Claim Amount',
          'claimAmount',
          _section7,
          isNumber: true,
        ),
        _buildTextInput('Nature of Loss', 'natureOfLoss', _section7),
        _buildTextInput('Year of Loss', 'yearOfLoss', _section7),
      ],

      if (_shouldShowStep(7)) ...[
        _buildSectionHeader('8. Existing Ins'),
        _buildTextInput('Current Insurer', 'currentInsurer', _section8),
        _buildTextInput('Policy Number', 'policyNumber', _section8),
        _buildTextInput('Expiry Date', 'expiryDate', _section8),
        _buildTextInput(
          'Premium Paid',
          'premiumPaid',
          _section8,
          isNumber: true,
        ),
      ],

      if (_shouldShowStep(8)) ...[
        _buildSectionHeader('9. Compliance'),
        _buildCheckboxGrid(_section9),
      ],

      if (_shouldShowStep(9)) ...[
        _buildSectionHeader('10. Special Risks'),
        _buildTextInput(
          'Hazardous Material Handling',
          'hazardousMaterial',
          _section10,
        ),
        _buildTextInput(
          'Chemical Storage Details',
          'chemicalStorage',
          _section10,
        ),
        _buildTextInput('Past Fire Incidents', 'pastFireIncidents', _section10),
        _buildTextInput('Subcontracting Details', 'subcontracting', _section10),
      ],

      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitRfq,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit Request for Quote',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(height: 48),
    ];
  }

  Widget _buildWizard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _screenState = 0),
              ),
              Expanded(
                child: Text(
                  _selectedProduct,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFormSections(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRfq() async {
    // Generate the nested dictionary tree payload
    final detailsMap = {
      'proposerInformation': _section1,
      'riskLocationDetails': _section2,
      'assetDetails': _section3,
      'coverageRequired': _section4,
      'addonCovers': _section5,
      'riskProtectionMeasures': _section6,
      'claimsHistory': _section7,
      'existingInsurance': _section8,
      'financialCompliance': _section9,
      'specialRiskInformation': _section10,
    };

    final rfq = Rfq(
      companyName: _section1['entityName'],
      contactPerson: _section1['contactPerson'],
      mobileNumber: _section1['mobileNumber'],
      email: _section1['email'],
      product: _selectedProduct,
      details: jsonEncode(detailsMap),
      status: 'PENDING',
    );

    final provider = context.read<CommercialProvider>();
    final success = await provider.submitRfq(rfq);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text(
            'Your Advanced Request for Quote has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${provider.error}')));
    }
  }
}
