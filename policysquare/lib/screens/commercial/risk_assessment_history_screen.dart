import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:policysquare/providers/commercial_provider.dart';
import 'package:policysquare/data/models/risk_assessment.dart';
import 'package:policysquare/utils/risk_scoring_helper.dart';
import 'package:policysquare/utils/pdf_generator.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RiskAssessmentHistoryScreen extends StatefulWidget {
  const RiskAssessmentHistoryScreen({super.key});

  @override
  State<RiskAssessmentHistoryScreen> createState() =>
      _RiskAssessmentHistoryScreenState();
}

class _RiskAssessmentHistoryScreenState
    extends State<RiskAssessmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommercialProvider>().loadMobileNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Risk Assessment'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CommercialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.assessmentHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No assessments found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.assessmentHistory.length,
            itemBuilder: (context, index) {
              final assessment = provider.assessmentHistory[index];
              return _buildAssessmentCard(context, assessment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, RiskAssessment assessment) {
    // Parse data to get details
    final data = jsonDecode(assessment.data ?? '{}') as Map<String, dynamic>;

    // Formatting Date
    String dateStr = 'N/A';
    if (assessment.createdAt != null) {
      try {
        // Assuming ISO string from backend, formatted for display
        // If backend sends array [2024, 2, 20...], might need strict parsing
        // For now assuming standard ISO string or similar
        // User screenshot shows: 09-FEB-26
        // We'll try to parse whatever we get or standard display
        dateStr = assessment.createdAt.toString();
      } catch (e) {
        dateStr = assessment.createdAt ?? 'N/A';
      }
    }

    // Calculate Score for Display if needed, or just for PDF
    // Screenshot shows "Rating Report : 57.29"
    // We need to calculate this.
    final score = RiskScoringHelper.calculateScore(data);
    final ratingScore = score['actualScore'] ?? 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['insuredName']?.toString() ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                Text(
                  _formatDate(assessment.createdAt), // Helper needed
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['occupancyType']?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Sum Insured : ${data['sumInsured']?.toString() ?? 'N/A'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      'Rating Report : $ratingScore',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ref No : ${assessment.id ?? 'N/A'}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Address : ${_buildAddressString(data)}',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Footer / Action
          const Divider(height: 1),
          InkWell(
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              try {
                // Direct PDF generation since AI Payload is saved to database during initial calculations
                await PdfGenerator.generateAndPrint(assessment, score);
              } finally {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text(
                'Download Assessment Report',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildAddressString(Map<String, dynamic> data) {
    if (data.isEmpty) return 'N/A';

    // Sometimes older forms might have just 'riskLocation'
    if (data.containsKey('riskLocation') &&
        data['riskLocation'] != null &&
        data['riskLocation'].toString().isNotEmpty) {
      return data['riskLocation'].toString();
    }

    List<String> parts = [];
    if (data['addressLine1'] != null &&
        data['addressLine1'].toString().isNotEmpty) {
      parts.add(data['addressLine1'].toString());
    }
    if (data['addressLine2'] != null &&
        data['addressLine2'].toString().isNotEmpty) {
      parts.add(data['addressLine2'].toString());
    }
    if (data['city'] != null && data['city'].toString().isNotEmpty) {
      parts.add(data['city'].toString());
    }
    if (data['state'] != null && data['state'].toString().isNotEmpty) {
      parts.add(data['state'].toString());
    }

    if (parts.isEmpty) return 'N/A';
    return parts.join(', ');
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'N/A';

    try {
      if (rawDate is List && rawDate.length >= 3) {
        // Backend sent raw [2026, 2, 23, 15, 30]
        DateTime date = DateTime(
          rawDate[0] as int,
          rawDate[1] as int,
          rawDate[2] as int,
        );
        return DateFormat('dd-MMM-yy').format(date).toUpperCase();
      }

      String dateStr = rawDate.toString();
      if (dateStr.isEmpty || dateStr == 'null') return 'N/A';

      DateTime? date;
      // Check if backend sent an array string like "[2024, 2, 20, 14, 30]"
      if (dateStr.startsWith('[') && dateStr.endsWith(']')) {
        final parts = dateStr
            .substring(1, dateStr.length - 1)
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .toList();
        if (parts.length >= 3) {
          date = DateTime(parts[0], parts[1], parts[2]);
        }
      } else {
        // Strict ISO Parsing or normal parsing
        date = DateTime.tryParse(dateStr);
      }

      if (date != null) {
        return DateFormat('dd-MMM-yy').format(date).toUpperCase();
      }
      return dateStr;
    } catch (e) {
      return rawDate.toString();
    }
  }
}
