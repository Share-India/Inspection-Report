import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:policysquare/data/models/risk_assessment.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

class PdfGenerator {
  static Future<void> generateAndPrint(
    RiskAssessment assessment,
    Map<String, dynamic> score,
  ) async {
    final pdf = pw.Document();
    final data = jsonDecode(assessment.data ?? '{}') as Map<String, dynamic>;

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // --- COVER PAGE ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'PolicySquare',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'General Insurance',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'RISK RECOMMENDATIONS REPORT',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 22,
                  color: PdfColors.lightBlue,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'FOR',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.lightBlue,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'M/S ${data['insuredName'] ?? "Client Name"}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: PdfColors.blue900,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Spacer(),
              _buildRiskGauge(score['actualPercent'] ?? 0),
              pw.Spacer(),
              pw.Text(
                'PolicySquare - Share India Insurance',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.blue900,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Saki Naka, Mumbai, Maharastra - 400072 (India)',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.blue900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // --- CONTENT PAGES ---
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (pw.Context context) {
            return pw.Container(); // Clean background
          },
        ),
        build: (pw.Context context) {
          return [
            // 1. General Information
            _buildMainSectionHeader('1. General Information', fontBold),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                _buildTableRow(
                  'Client Name',
                  data['insuredName'],
                  fontBold,
                  font,
                ),
                _buildTableRow(
                  'Occupancy',
                  data['occupancyType'],
                  fontBold,
                  font,
                ),
                _buildTableRow(
                  'Address',
                  '${data['addressLine1'] ?? ''} ${data['addressLine2'] ?? ''}'
                      .trim(),
                  fontBold,
                  font,
                ),
                _buildTableRow('City', data['city'], fontBold, font),
                _buildTableRow('State', data['state'], fontBold, font),
                _buildTableRow('Pin Code', data['pincode'], fontBold, font),
                _buildTableRow(
                  'Total Area (sq m)',
                  data['totalArea'],
                  fontBold,
                  font,
                ),
                _buildTableRow(
                  'Sum Insured Range',
                  data['sumInsured'],
                  fontBold,
                  font,
                ),
                _buildTableRow(
                  'PRIME Reference No',
                  assessment.id ?? "N/A",
                  fontBold,
                  font,
                ),
                _buildTableRow(
                  'Risk Survey Done By',
                  data['surveyorName'],
                  fontBold,
                  font,
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // 2. Property Risk Quality Rating
            _buildMainSectionHeader(
              '2. Property Risk Quality Rating',
              fontBold,
            ),
            pw.Text(
              'Overall Site Rating for this Location based on the Information provided.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Actual Site Rating',
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Potential Site Rating',
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Site Actual Score ${score['actualScore']?.toInt() ?? 0}/125',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Site Potential Score ${score['potentialScore']?.toInt() ?? 0}/125',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Site Actual Rating ${score['rating'] ?? 'N/A'}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: _getRatingColor(score['rating'] ?? ''),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Site Potential Rating ${score['potentialRating'] ?? 'N/A'}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: _getRatingColor(
                            score['potentialRating'] ?? '',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // 3. Pictures from the Site
            ...() {
              List<String> allImages = [];
              if (data['plantPhoto'] != null &&
                  data['plantPhoto'].toString().isNotEmpty) {
                allImages.add(data['plantPhoto'].toString());
              }
              if (data['siteImages'] != null) {
                for (var img in (data['siteImages'] as List)) {
                  allImages.add(img.toString());
                }
              }

              if (allImages.isNotEmpty) {
                return [
                  _buildMainSectionHeader(
                    '3. Pictures from the Site',
                    fontBold,
                  ),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allImages.map((String path) {
                      try {
                        final file = File(path);
                        if (file.existsSync()) {
                          return pw.Container(
                            width: 150,
                            height: 150,
                            child: pw.Image(
                              pw.MemoryImage(file.readAsBytesSync()),
                              fit: pw.BoxFit.cover,
                            ),
                          );
                        } else {
                          return pw.Text(
                            'Image not found: $path',
                            style: const pw.TextStyle(
                              color: PdfColors.red,
                              fontSize: 8,
                            ),
                          );
                        }
                      } catch (e) {
                        return pw.Text(
                          'Error loading $path: $e',
                          style: const pw.TextStyle(
                            color: PdfColors.red,
                            fontSize: 8,
                          ),
                        );
                      }
                    }).toList(),
                  ),
                  pw.SizedBox(height: 30),
                ];
              }
              return [pw.SizedBox.shrink()];
            }(),

            // 4. Recommendation
            _buildMainSectionHeader('4. Recommendation', fontBold),
            pw.Text(
              'Risk Element & Recommendations/ Suggestions for Client Reference',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 16),

            // Human Element
            _buildCategoryHeader(
              'Human Element and Manual Fire Protection System',
              fontBold,
            ),
            _buildRecommendationRowVertical(
              1,
              'Housekeeping',
              data['housekeeping'],
              fontBold,
              font,
              photos: data['housekeepingPhotos'],
            ),
            _buildRecommendationRowVertical(
              2,
              'Fire Training',
              _formatBool(data['fireTraining']),
              fontBold,
              font,
              photos: data['fireTrainingPhotos'],
            ),
            _buildRecommendationRowVertical(
              3,
              'Maintenance',
              _formatBool(data['maintenance']),
              fontBold,
              font,
              photos: data['maintenancePhotos'],
            ),
            _buildRecommendationRowVertical(
              4,
              'Hot Work Permit',
              _formatBool(data['hotWorkPermit']),
              fontBold,
              font,
              photos: data['hotWorkPermitPhotos'],
            ),

            // Occupancy
            _buildCategoryHeader('Occupancy Related Hazard', fontBold),
            _buildRecommendationRowVertical(
              1,
              'Combustible Materials',
              _formatBool(data['combustibleMaterials']),
              fontBold,
              font,
              photos: data['combustibleMaterialsPhotos'],
            ),
            _buildRecommendationRowVertical(
              2,
              'Flammable Solvents',
              data['flammableSolvents'],
              fontBold,
              font,
              photos: data['flammableSolventsPhotos'],
            ),

            // Surveillance
            _buildCategoryHeader(
              'Surveillance and Automatic Fire Detection System',
              fontBold,
            ),
            _buildRecommendationRowVertical(
              1,
              'Smoke Detection',
              _formatBool(data['smokeDetection']),
              fontBold,
              font,
              photos: data['smokeDetectionPhotos'],
            ),
            _buildRecommendationRowVertical(
              2,
              'CCTV',
              _formatBool(data['cctv']),
              fontBold,
              font,
              photos: data['cctvPhotos'],
            ),
            _buildRecommendationRowVertical(
              3,
              'Security Team',
              _formatBool(data['securityTeam']),
              fontBold,
              font,
              photos: data['securityTeamPhotos'],
            ),

            // Fire Protection
            _buildCategoryHeader('Fire Protection', fontBold),
            _buildRecommendationRowVertical(
              1,
              'Fire Water Tank',
              _formatBool(data['fireWaterTank']),
              fontBold,
              font,
            ),
            _buildRecommendationRowVertical(
              2,
              'Main Electrical Pump',
              _formatBool(data['mainElectricalPump']),
              fontBold,
              font,
            ),
            _buildRecommendationRowVertical(
              3,
              'Diesel Driven Pump',
              _formatBool(data['dieselDrivenPump']),
              fontBold,
              font,
            ),
            _buildRecommendationRowVertical(
              4,
              'Jockey Pump',
              _formatBool(data['jockeyPump']),
              fontBold,
              font,
            ),
            _buildRecommendationRowVertical(
              5,
              'Hydrant Points',
              _formatBool(data['hydrantPoints']),
              fontBold,
              font,
            ),
            _buildRecommendationRowVertical(
              6,
              'Fire Extinguishers',
              _formatBool(data['fireExtinguishers']),
              fontBold,
              font,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static PdfColor _getRatingColor(String rating) {
    if (rating == 'Poor Risk') return PdfColors.red;
    if (rating == 'Good Risk') return PdfColors.green;
    return PdfColors.orange;
  }

  static pw.Widget _buildMainSectionHeader(String title, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 24, bottom: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildCategoryHeader(String title, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 24, bottom: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  static pw.TableRow _buildTableRow(
    String label,
    dynamic value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    final strValue =
        (value == null ||
            value.toString().isEmpty ||
            value == 'null' ||
            value == 'Select')
        ? 'N/A'
        : value.toString();
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(font: fontBold, fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            strValue,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRecommendationRowVertical(
    int index,
    String label,
    dynamic value,
    pw.Font fontBold,
    pw.Font font, {
    List<dynamic>? photos,
  }) {
    if (value == null || value == 'null' || value == 'Select') {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$index $label',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 10,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value.toString(),
          style: pw.TextStyle(font: font, fontSize: 10, lineSpacing: 1.5),
        ),
        if (photos != null && photos.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: photos.map((path) {
              try {
                final file = File(path.toString());
                if (file.existsSync()) {
                  return pw.Container(
                    width: 150,
                    height: 150,
                    child: pw.Image(
                      pw.MemoryImage(file.readAsBytesSync()),
                      fit: pw.BoxFit.cover,
                    ),
                  );
                } else {
                  return pw.Text(
                    '[File not found: ${path.toString()}]',
                    style: const pw.TextStyle(
                      color: PdfColors.red,
                      fontSize: 8,
                    ),
                  );
                }
              } catch (e) {
                return pw.Text(
                  '[Error: $e]',
                  style: const pw.TextStyle(color: PdfColors.red, fontSize: 8),
                );
              }
            }).toList(),
          ),
        ],
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildRiskGauge(double actualPercent) {
    // Custom painting a gauge
    return pw.Container(
      height: 200,
      width: 300,
      child: pw.CustomPaint(
        size: const PdfPoint(300, 200),
        painter: (PdfGraphics canvas, PdfPoint size) {
          final center = PdfPoint(size.x / 2, size.y - 40); // Shift up
          final radius = size.x / 2.5;
          const thickness = 30.0;

          // Background Arch (Grey)
          // pdf package doesn't have an outer arc, using polygons
          _drawArc(
            canvas,
            center,
            radius,
            thickness,
            0,
            180,
            PdfColors.grey300,
          );

          // Segments
          // Colors: Green (Good > 66%), Yellow (Average 33-66%), Red (Poor < 33%)
          // But gauge usually goes Red -> Yellow -> Green
          _drawArc(canvas, center, radius, thickness, 180, 240, PdfColors.red);
          _drawArc(
            canvas,
            center,
            radius,
            thickness,
            240,
            300,
            PdfColors.yellow,
          );
          _drawArc(
            canvas,
            center,
            radius,
            thickness,
            300,
            360,
            PdfColors.green,
          );

          // Pointer line based on percent. 0% is left (180deg), 100% is right (360deg/0deg)
          // Map 0-100 to 180-360 degrees.
          double angleDeg = 180 + (actualPercent / 100) * 180;
          double angleRad = angleDeg * (3.14159 / 180);

          final pointerLength = radius - 10;

          canvas.saveContext();
          canvas
            ..getTransform().multiply(
              Matrix4.translationValues(center.x, center.y, 0),
            )
            ..getTransform().multiply(Matrix4.rotationZ(angleRad));

          canvas.setStrokeColor(PdfColors.black);
          canvas.setLineWidth(4);
          canvas.drawLine(
            0,
            0,
            pointerLength,
            0,
          ); // draws along X axis which is 0 deg
          canvas.strokePath();

          // Center Circle
          canvas.setFillColor(PdfColors.black);
          canvas.drawEllipse(0, 0, 10, 10);
          canvas.fillPath();
          canvas.restoreContext();
        },
        child: pw.Container(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Text(
            'RISK SCORE',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ),
      ),
    );
  }

  static void _drawArc(
    PdfGraphics canvas,
    PdfPoint center,
    double radius,
    double thickness,
    double startDeg,
    double endDeg,
    PdfColor color,
  ) {
    // A simple approximation. True exact complex arcs might require deeper matrix magic.
    canvas.setStrokeColor(color);
    canvas.setLineWidth(thickness);

    // The math for pdf.dart curve might be complex, so drawing multiple small lines
    bool first = true;
    for (double i = startDeg; i <= endDeg; i += 2) {
      double rad = i * (pi / 180);
      double x = center.x + (radius - thickness / 2) * cos(rad);
      double y = center.y + (radius - thickness / 2) * sin(rad);
      if (first) {
        first = false;
        canvas.moveTo(x, y);
      } else {
        canvas.lineTo(x, y);
      }
    }
    canvas.strokePath();
  }

  static String _formatBool(dynamic val) {
    if (val == true || val == 'true') return 'Yes';
    if (val == false || val == 'false') return 'No';
    if (val == null || val == 'null' || val == 'Select') return 'N/A';
    return val.toString();
  }
}
