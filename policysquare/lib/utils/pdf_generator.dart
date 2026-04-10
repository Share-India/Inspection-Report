import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:policysquare/data/models/risk_assessment.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' as flutter;

class PdfGenerator {
  static Future<void> generateAndPrint(
    RiskAssessment assessment,
    Map<String, dynamic> score,
  ) async {
    final pdf = pw.Document();
    final data = jsonDecode(assessment.data ?? '{}') as Map<String, dynamic>;

    pw.ImageProvider? locMap, waterMap, fireMap, hospMap, hazMap;

    Future<pw.ImageProvider?> safeNetworkImage(String? urlString) async {
      if (urlString == null || urlString.isEmpty) return null;
      try {
        final cleanUrl = urlString.replaceAll('%7C', '|');
        return await networkImage(cleanUrl);
      } catch (e) {
        print(
          'PDF map fetch error (Google Maps failed, attempting Yandex fallback): $e',
        );
        try {
          final uri = Uri.parse(urlString);
          if (uri.host.contains('maps.googleapis.com')) {
            final center =
                uri.queryParameters['center']?.split(',') ?? ['0', '0'];
            final lat = center[0];
            final lon = center[1];
            final z = uri.queryParameters['zoom'] ?? '14';

            final markers = uri.queryParametersAll['markers'] ?? [];
            List<String> ptList = [];
            for (var m in markers) {
              var mClean = m.replaceAll('%7C', '|');
              var parts = mClean.split('|');
              String color = 'bl';
              String coords = '';
              for (var p in parts) {
                if (p.startsWith('color:')) {
                  var c = p.substring(6);
                  if (c == 'red')
                    color = 'rd';
                  else if (c == 'blue')
                    color = 'bl';
                  else if (c == 'orange')
                    color = 'or';
                  else if (c == 'green')
                    color = 'gn';
                  else if (c == 'purple')
                    color = 'vv';
                } else if (p.contains(',')) {
                  coords = p;
                }
              }
              if (coords.isNotEmpty) {
                final cSplit = coords.split(',');
                if (cSplit.length == 2) {
                  ptList.add('${cSplit[1]},${cSplit[0]},pm2${color}m');
                }
              }
            }

            String ptStr = ptList.join('~');
            final yandexUrl =
                'https://static-maps.yandex.ru/1.x/?ll=$lon,$lat&z=$z&size=400,400&l=map&lang=en_US&pt=$ptStr';
            return await networkImage(yandexUrl);
          }
        } catch (fallbackError) {
          print('PDF map Yandex fallback fetch error: $fallbackError');
        }
        return null; // Gracefully continue if network completely fails
      }
    }

    // Load Maps and Fonts safely and concurrently to reduce generation time
    final futures = await Future.wait([
      safeNetworkImage(data['locationMapUrl']),
      safeNetworkImage(data['waterBodyMapUrl']),
      safeNetworkImage(data['fireStationMapUrl']),
      safeNetworkImage(data['hospitalMapUrl']),
      safeNetworkImage(data['hazardsMapUrl']),
      PdfGoogleFonts.openSansRegular(),
      PdfGoogleFonts.openSansBold(),
      PdfGoogleFonts.notoSansRegular(),
      flutter.rootBundle.load('assets/images/logo_icon.png').then((byteData) => pw.MemoryImage(byteData.buffer.asUint8List())),
    ]);

    locMap = futures[0] as pw.ImageProvider?;
    waterMap = futures[1] as pw.ImageProvider?;
    fireMap = futures[2] as pw.ImageProvider?;
    hospMap = futures[3] as pw.ImageProvider?;
    hazMap = futures[4] as pw.ImageProvider?;

    final font = futures[5] as pw.Font;
    final fontBold = futures[6] as pw.Font;
    // Resolve Helvetica-Bold Unicode Crash by giving a vast multi-language fallback
    final fontFallback1 = futures[7] as pw.Font;
    final logoImage = futures[8] as pw.ImageProvider;

    // Page format
    final pageTheme = pw.PageTheme(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
        italic: font,
        boldItalic: fontBold,
        fontFallback: [fontFallback1],
      ),
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
    );

    final actualPercent = double.parse(
      score['actualPercent']?.toString() ?? '0',
    );
    final potentialPercent = double.parse(
      score['potentialPercent']?.toString() ?? '0',
    );
    final actualRatingStr = score['rating']?.toString() ?? 'N/A';
    final potentialRatingStr = score['potentialRating']?.toString() ?? 'N/A';

    // Common Header for every page
    pw.Widget buildPageHeader() {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 4,
                width: 60,
                color: PdfColor.fromHex('#0D47A1'),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Image(logoImage, height: 26),
              pw.SizedBox(height: 4),
              pw.Text(
                'PolicySquare',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                  color: PdfColor.fromHex('#0D47A1'),
                ),
              ),
              pw.Text(
                'Share India',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex('#546E7A'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // --- Page 1: Cover Page ---
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildPageHeader(),

              pw.Spacer(),

              // Title
              pw.Text(
                'RISK RECOMMENDATIONS REPORT',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                  color: PdfColor.fromHex('#29B6F6'),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'FOR',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  color: PdfColor.fromHex('#29B6F6'),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                '${data['insuredName'] ?? 'Client'}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                  color: PdfColor.fromHex('#29B6F6'),
                ),
              ),

              pw.SizedBox(height: 40),

              // PolicySquare Risk Score Gauge Visual Logo
              pw.SizedBox(
                width: 250,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SvgImage(
                      svg: '''
<svg width="220" height="110" viewBox="0 0 220 110" xmlns="http://www.w3.org/2000/svg">
  <path d="M 10 110 A 100 100 0 0 1 60 23.398" stroke="#4CAF50" stroke-width="20" fill="none" />
  <path d="M 60 23.398 A 100 100 0 0 1 160 23.398" stroke="#F44336" stroke-width="20" fill="none" />
  <path d="M 160 23.398 A 100 100 0 0 1 210 110" stroke="#FFEB3B" stroke-width="20" fill="none" />
  <path d="M 40 110 A 70 70 0 0 1 180 110" stroke="#E0E0E0" stroke-width="1" fill="#F5F5F5" />
  <path d="M 70 110 A 40 40 0 0 1 150 110" stroke="#E0E0E0" stroke-width="1" fill="#EEEEEE" />
  <line x1="110" y1="110" x2="160" y2="40" stroke="#212121" stroke-width="4" stroke-linecap="round" />
  <circle cx="110" cy="110" r="10" fill="#212121" />
  <text x="110" y="80" font-family="sans-serif" font-size="20" font-weight="bold" fill="#0D47A1" text-anchor="middle"></text>
</svg>
''',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'RISK SCORE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                        color: PdfColor.fromHex('#0D47A1'),
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Text(
                'Share India Insurance Limited.',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                  color: PdfColor.fromHex('#0D47A1'),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Share India Insurance,',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#1565C0'),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Saki Naka, Mumbai, Maharastra - 400072 (India)',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#1565C0'),
                ),
              ),
            ],
          );
        },
      ),
    );

    // --- Page 2: General Information ---
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          String? plantPhotoPath;
          if (data['plantPhoto'] != null &&
              data['plantPhoto'].toString().isNotEmpty) {
            plantPhotoPath = data['plantPhoto'].toString();
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildPageHeader(),
              pw.SizedBox(height: 30),
              pw.Text(
                '1. General Information',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  color: PdfColor.fromHex('#2196F3'),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  _buildGeneralRow(
                    'Client Name',
                    data['insuredName'],
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'Occupancy',
                    data['occupancyType'],
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'Address',
                    '${data['addressLine1'] ?? ''} ${data['addressLine2'] ?? ''}'
                        .trim(),
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow('State', data['state'], fontBold, font),
                  _buildGeneralRow('City', data['city'], fontBold, font),
                  _buildGeneralRow('Pin code', data['pincode'], fontBold, font),
                  _buildGeneralRow(
                    'PolicySquare Reference No',
                    assessment.id,
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'SI Range',
                    data['sumInsured'],
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'Risk Survey Done By',
                    data['surveyorName'],
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'Mobile No',
                    assessment.mobileNumber,
                    fontBold,
                    font,
                  ),
                  _buildGeneralRow(
                    'Date of Survey',
                    DateFormat('dd MMM yyyy hh:mm:ss a').format(
                      DateTime.tryParse(assessment.createdAt ?? '') ??
                          DateTime.now(),
                    ),
                    fontBold,
                    font,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              if (plantPhotoPath != null)
                pw.Center(
                  child: _buildImageFromBase64(
                    plantPhotoPath,
                    width: 250,
                    height: 250,
                  ),
                ),
              pw.Spacer(),
              pw.Text(
                'Property Risk Inspection,\nManagement and Evaluation',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.lightBlue,
                ),
              ),
            ],
          );
        },
      ),
    );

    // --- Page 2: Map & Remote Sensing References ---
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          final mapItems = <pw.Widget>[];

          mapItems.add(buildPageHeader());
          mapItems.add(pw.SizedBox(height: 30));
          mapItems.add(
            pw.Text(
              '2. Map & Remote Sensing References',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
          );
          mapItems.add(pw.SizedBox(height: 15));

          pw.Widget buildMapCard(
            String title,
            pw.ImageProvider? img, {
            double width = 350,
            double height = 250,
          }) {
            if (img == null) return pw.SizedBox();
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    height: height,
                    width: width,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.ClipRect(
                      child: pw.Image(img, fit: pw.BoxFit.cover),
                    ),
                  ),
                ],
              ),
            );
          }

          if (locMap != null) {
            mapItems.add(
              pw.Center(
                child: buildMapCard(
                  'Location',
                  locMap,
                  width: 480,
                  height: 280,
                ),
              ),
            );
            mapItems.add(pw.SizedBox(height: 15));
          }

          final gridItems = <pw.Widget>[];
          if (waterMap != null)
            gridItems.add(
              buildMapCard(
                'Water Body Proximity',
                waterMap,
                width: 230,
                height: 160,
              ),
            );
          if (fireMap != null)
            gridItems.add(
              buildMapCard(
                'Fire Station Proximity',
                fireMap,
                width: 230,
                height: 160,
              ),
            );
          if (hospMap != null)
            gridItems.add(
              buildMapCard(
                'Hospital Proximity',
                hospMap,
                width: 230,
                height: 160,
              ),
            );
          if (hazMap != null)
            gridItems.add(
              buildMapCard(
                'Hazardous Proximity',
                hazMap,
                width: 230,
                height: 160,
              ),
            );

          if (gridItems.isNotEmpty) {
            mapItems.add(
              pw.Center(
                child: pw.Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  crossAxisAlignment: pw.WrapCrossAlignment.center,
                  children: gridItems,
                ),
              ),
            );
          }

          return mapItems;
        },
      ),
    );

    // --- Page 3: Property Risk Quality Rating ---
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildPageHeader(),
              pw.SizedBox(height: 30),
              pw.Text(
                '3. Property Risk Quality Rating',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  color: PdfColor.fromHex('#2196F3'),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Overall Site Rating for this Location based on the Information provided.',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Actual / Potential Score Tables
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Center(
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Actual Site Rating',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildScoreRow(
                          'Site Actual Score',
                          actualPercent.toStringAsFixed(2),
                          fontBold,
                          font,
                        ),
                        _buildScoreRow(
                          'Site Actual Rating',
                          actualRatingStr,
                          fontBold,
                          font,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 200,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Center(
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Potential Site Rating',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildScoreRow(
                          'Site Potential Score',
                          potentialPercent.toStringAsFixed(2),
                          fontBold,
                          font,
                        ),
                        _buildScoreRow(
                          'Site Potential Rating',
                          potentialRatingStr,
                          fontBold,
                          font,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Risk Meter Bar
              pw.Row(
                children: [
                  pw.Container(
                    width: 80,
                    child: pw.Text(
                      'Risk Meter',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Expanded(child: _buildRiskGradientBar(fontBold)),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  'Overall Actual and Potential Rating for Occupancy',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Horizontal Score Bars
              pw.Row(
                children: [
                  pw.Container(
                    width: 120,
                    child: pw.Text(
                      'Site Actual Rating',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Stack(
                      children: [
                        pw.Container(
                          height: 20,
                          width:
                              350, // Added background bounding box to prevent stretching anomalies
                          color: PdfColors.white,
                        ),
                        pw.Container(
                          height: 20,
                          width:
                              (actualPercent.clamp(0, 100) / 100) *
                              350, // Clamped binding
                          color: _getBajajRatingColor(actualRatingStr),
                          child: pw.Center(
                            child: pw.Text(
                              actualPercent.toStringAsFixed(2),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Container(
                    width: 120,
                    child: pw.Text(
                      'Site Potential Rating',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Stack(
                      children: [
                        pw.Container(
                          height: 20,
                          width: 350,
                          color: PdfColors.white,
                        ),
                        pw.Container(
                          height: 20,
                          width: (potentialPercent.clamp(0, 100) / 100) * 350,
                          color: PdfColors.orange,
                          child: pw.Center(
                            child: pw.Text(
                              potentialPercent.toStringAsFixed(2),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Bands Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Risk Score Band',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '0-60',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '61-70',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '71-80',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '>80',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Explanations
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Site Actual Rating: ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#455A64'),
                      ),
                    ),
                    pw.TextSpan(
                      text: 'Indicates Current Rating/Position of the Risk.',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Site Potential Rating: ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#455A64'),
                      ),
                    ),
                    pw.TextSpan(
                      text:
                          'Indicates Future Rating of the Risk after implementation of Risk Recommendations suggested in this Report.',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // --- Page 4: Risk Rating Element Profile ---
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildPageHeader(),
              pw.SizedBox(height: 30),
              pw.Text(
                '4. Risk Rating Element Profile',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  color: PdfColor.fromHex('#2196F3'),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'For arriving at the Risk Engineering Rating, Share India Risk Engineering Services and Property Underwriting Team have considered the following Important Risk Elements',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 20),

              _buildProfileItem(
                '1.Automatic Fire Protection System:',
                'Signifies the presence of Automatic Sprinkler Protection/Gas Extinguishing System at Process area, Raw Material (RM), Finished Goods (FG) and Other Hazardous area in Plant/Facility/Warehouse area.',
                fontBold,
                font,
              ),
              _buildProfileItem(
                '2.Human Element & Manual Protection System:',
                'Indicates the availability of Fire Hydrant, Fire Extinguishers, Fire Fighting/Mock Drill Training, Adequate Housekeeping and Emergency Plan provided at the Site.',
                fontBold,
                font,
              ),
              _buildProfileItem(
                '3.Occupancy Related Hazard:',
                'Indicates Process Hazard, Combustibility/Flammability of RM/FG used in the plant and Flame Proof Electrical Fittings provided in the Plant.',
                fontBold,
                font,
              ),
              _buildProfileItem(
                '4.Surveillance and Automatic Fire Detection System:',
                'Presence of Smoke Detection System/Gas Detection System, CCTV Camera, Security Guards and Boundary Wall.',
                fontBold,
                font,
              ),
              _buildProfileItem(
                '5.Construction:',
                'Indicates Type of Plant Building Construction, Single Block Exposure, Separation between each Block and any Basement Exposure.',
                fontBold,
                font,
              ),
              _buildProfileItem(
                '6.External Exposure:',
                'Indicates surrounding exposure such as Nala/Water Body/River Crossing, Plant Exposure having common boundary Wall and any claim related to AOG Peril.',
                fontBold,
                font,
              ),
            ],
          );
        },
      ),
    );

    // --- Page 5: Block Charts ---
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildPageHeader(),
              pw.SizedBox(height: 15),
              pw.Text(
                'Below Graph indicates Current Risk Features(Actual) against total point allocated(Weightage) to each element.\nPotential Rating indicate rating after implementation of Recommendations.',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColor.fromHex('#2196F3'),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniChart(
                    'Automatic Fire Protection System',
                    score['cat6Possible']?.toDouble() ??
                        30, // Default to 30 if null
                    score['cat6Actual']?.toDouble() ?? 0,
                    score['cat6Actual']?.toDouble() ??
                        0, // Potential same as actual unless AI specifies otherwise
                    font,
                  ),
                  _buildMiniChart(
                    'Human Element and Manual Protection',
                    score['cat1Possible']?.toDouble() ?? 25,
                    score['cat1Actual']?.toDouble() ?? 0,
                    score['cat1Possible']?.toDouble() ??
                        25, // Assume potential gets full points via recs
                    font,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniChart(
                    'Occupancy Related Hazard',
                    score['cat2Possible']?.toDouble() ?? 20,
                    score['cat2Actual']?.toDouble() ?? 0,
                    score['cat2Possible']?.toDouble() ?? 20,
                    font,
                  ),
                  _buildMiniChart(
                    'Surveillance and Automatic Fire Detection System',
                    score['cat3Possible']?.toDouble() ?? 20,
                    score['cat3Actual']?.toDouble() ?? 0,
                    score['cat3Possible']?.toDouble() ?? 20,
                    font,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniChart(
                    'Construction',
                    score['cat4Possible']?.toDouble() ?? 15,
                    score['cat4Actual']?.toDouble() ?? 0,
                    score['cat4Possible']?.toDouble() ?? 15,
                    font,
                  ),
                  _buildMiniChart(
                    'External Exposure',
                    score['cat5Possible']?.toDouble() ?? 15,
                    score['cat5Actual']?.toDouble() ?? 0,
                    score['cat5Possible']?.toDouble() ?? 15,
                    font,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // --- Page 6: Report Table ---
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          int count = 1;

          List<pw.TableRow> rows = [];

          void addQA(String question, dynamic answer, {List<dynamic>? photos}) {
            if (answer == null ||
                answer.toString() == 'null' ||
                answer.toString().isEmpty) {
              return;
            }

            // Question Row
            rows.add(
              pw.TableRow(
                children: [
                  pw.Container(
                    color: PdfColor.fromHex('#F5F5F5'),
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${count++}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#1E88E5'),
                      ),
                    ),
                  ),
                  pw.Container(
                    color: PdfColor.fromHex('#F5F5F5'),
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      question,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#1E88E5'),
                      ),
                    ),
                  ),
                ],
              ),
            );

            // Explanation Row
            rows.add(
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Explanation',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          answer.toString(),
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.black,
                          ),
                        ),
                        if (photos != null && photos.isNotEmpty) ...[
                          pw.SizedBox(height: 8),
                          pw.Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: photos.map((p) {
                              return _buildImageFromBase64(
                                p.toString(),
                                width: 120,
                                height: 120,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          addQA(
            'Overall Housekeeping practice followed at the premises?',
            data['housekeeping'],
            photos: data['housekeepingPhotos'],
          );
          addQA(
            'Fire Fighting Training and Mock Drill are provided to employee?',
            data['fireTraining'],
            photos: data['fireTrainingPhotos'],
          );

          // Custom build for Fire Protection Facilities Table
          pw.Widget fireProtectionInnerTable = pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Sr No',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Details',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Capacity',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Flow Units/HP',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('1', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Fire Water Tank',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        data['fireWaterTank'] == true ? '130' : '0',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('m3', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('2', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Main Electrical Pump',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        data['mainElectricalPump'] == true ? '96' : '0',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('m3/Hr', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('3', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        'Diesel Driven Pump',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text(
                        data['dieselDrivenPump'] == true ? '171' : '0',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(
                      child: pw.Text('m3/Hr', style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                ],
              ),
            ],
          );

          rows.add(
            pw.TableRow(
              children: [
                pw.Container(
                  color: PdfColor.fromHex('#F5F5F5'),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    '${count++}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: PdfColor.fromHex('#1E88E5'),
                    ),
                  ),
                ),
                pw.Container(
                  color: PdfColor.fromHex('#F5F5F5'),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'What are the fire protection facilities available for your premises?',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: PdfColor.fromHex('#1E88E5'),
                    ),
                  ),
                ),
              ],
            ),
          );
          rows.add(
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Explanation',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'For fire protection, site is protected with hydrant system, fire extinguishers & nearest fire brigade would help to minimize property damage.',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(width: 300, child: fireProtectionInnerTable),
                      pw.SizedBox(height: 10),
                      if (data['siteImages'] != null &&
                          (data['siteImages'] as List).isNotEmpty) ...[
                        pw.Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (data['siteImages'] as List)
                              .map(
                                (p) => _buildImageFromBase64(
                                  p.toString(),
                                  width: 140,
                                  height: 140,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );

          addQA(
            'Are all the fire protection equipment maintenance being done by inhouse team / Third Party Annual Maintenance Contract (AMC)?',
            data['maintenance'],
            photos: data['maintenancePhotos'],
          );
          addQA(
            'Does the facility use Flame proof/Industrial Type Electrical Cables and fittings in hazardous areas?',
            data['flameProofCables'],
            photos: data['flameProofPhotos'],
          );
          addQA(
            'What is the condition of electrical fittings/wiring installed at the site',
            data['electricalCondition'],
            photos: data['electricalConditionPhotos'],
          );
          addQA(
            'Is the facility equipped with Automatic Smoke Detection System in all the important areas?',
            data['smokeDetection'],
            photos: data['smokeDetectionPhotos'],
          );
          addQA(
            'Does the facility have functional CCTV cameras installed in the premises?',
            data['cctv'],
            photos: data['cctvPhotos'],
          );
          addQA(
            'Is the facility protected by boundary walls or fence?',
            data['boundaryWalls'],
            photos: data['boundaryWallsPhotos'],
          );
          addQA(
            'Does the facility have a dedicated security team?',
            data['securityTeam'],
            photos: data['securityTeamPhotos'],
          );
          addQA(
            'What is the type of building construction of the site?',
            data['constructionType'],
          );
          addQA(
            'What is the separation distance between storage/process/utility areas?',
            data['separationDistance'],
          );
          addQA(
            'Is your risk located in the basement/below the ground level/below the road level?',
            data['basementRisk'],
          );
          addQA(
            'What external occupancies surround the facility sharing common boundary wall?',
            data['externalOccupancies'],
          );
          addQA(
            'Is the facility surrounded by any water body (Nalah, Canal, River and Sea) within a distance of 1km?',
            data['waterBody'],
          );
          addQA(
            'Has this location been affected by Flood/ Cyclone/Inundation/any other AOG peril in past 3 years?',
            data['naturalHazards'],
          );

          return [
            buildPageHeader(),
            pw.SizedBox(height: 30),
            pw.Text(
              '4.Risk Assessment Report',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(8),
              },
              children: rows,
            ),

            // Site Pictures Section
            if (data['siteImages'] != null &&
                (data['siteImages'] as List).isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text(
                '5. Pictures from the Site',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  color: PdfColor.fromHex('#2196F3'),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: (data['siteImages'] as List)
                      .map(
                        (p) => _buildImageFromBase64(
                          p.toString(),
                          width: 220,
                          height: 220,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ];
        },
      ),
    );

    // --- Page 7: Recommendations ---
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return [
            buildPageHeader(),
            // Recommendations Section
            pw.SizedBox(height: 30),
            pw.Text(
              '6.Recommendation',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(12),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.SizedBox.shrink(),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Risk Element & Recommendations/ Suggestions for Client Reference',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox.shrink(),
                    pw.Container(
                      color: PdfColor.fromHex('#FCE4D6'), // Light orange
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Human Element and Manual Fire Protection System',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.brown900,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '1',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#C65911'),
                          ),
                        ),
                      ), // Orange text
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Fire Fighting Training and Mock Drills',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Provision of Fire Fighting Training to in house employees would help to extinguish at incipient stage and minimize the property damage to a great extent. Mock Drills training help to evacuate the employee/staff and necessary action can be taken at the time of emergency/fire incident in the site.',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox.shrink(),
                    pw.Container(
                      color: PdfColor.fromHex('#FCE4D6'),
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Occupancy Related Hazard',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.brown900,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '1',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#C65911'),
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Flame Proof Electrical Installation',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Share India Insurance Company strongly recommend to use Flame Proof Electrical Fittings in following Hazardous area for avoiding electrical short circuit/Static Electricity fire accident in Warehouse/Plant premises:\n1. Hydrogenation Reactor(Chemical Reactor/Autoclave)\n2. Hydrogen Cylinder Storage Shed\n3. Solvent Storage area(Class A,B and C)\n4. LPG Bank and Bullet area\n5. High Speed Diesel and Furnace Oil Storage area\n6. Paint Booth\n7. Solvent Dispensing area\n8. Tank farm during Solvent Transferring\n9. Warehouse/Storage area having flammable storage\n10. Dust Explosion possible area\n11. Underground Hydraulic Cellar\n12. Flammable Mixing area',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            color: PdfColors.yellow,
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              'Image is only for Representation. (Not from client premises.)',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '2',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#C65911'),
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Maintenance of Electrical System',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Replace Loose and Tapered Electrical Fittings on priority. Use metal conduit for all cable routed inside the Process /Warehouse area',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox.shrink(),
                    pw.Container(
                      color: PdfColor.fromHex('#FCE4D6'),
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Surveillance and Automatic Fire Detection System',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.brown900,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '1',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#C65911'),
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Fire Detection System',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Installation of Automatic Fire Detection helps to locate the fire at incipient stage and take necessary action to minimize the fire to a great extent.\n\nManual alarm call points are designed for the purpose of raising an alarm manually once verification of a fire or emergency condition exists, by operating the push button or break glass the alarm signal can be raised.\n\nWe recommend to install Automatic Fire Detection and Manual Call point in the following areas as per IS-2189(Installation and Maintenance of Automatic Fire-Detection and Alarm System--Code of Practice) or NFPA-72(National Fire Alarm and Signalling Code):\n\n1.&Raw Material Storage area\n2.&Finished Good Storage area\n3.&Utility area\n4.&Electrical Room(HT/LT) and Electrical Shaft area\n5.&Office Building\n6.&Basement area including Car Parking\n7.&Server Room(Above Ceiling and Below Ceiling area)\n8.&Process area(if the temperature is less than 30 Degrees)\n9.&Linear Heat Sensing Cables on Cable Galleries and Coal Conveyors',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            color: PdfColors.yellow,
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              'Image is only for Representation. Fire Detection System & Manual Call. (Not from client premises.)',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Empty spacer row simulating the end of table in screenshot
                pw.TableRow(
                  children: [
                    pw.Container(height: 15),
                    pw.Container(height: 15),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              '7.Reference Standard followed for Risk Engineering Application',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'Following are the Reference Standard would be use for Generating Risk Rating and Recommendation\n\n1.&Tariff Advisory Committee\n\n2. Indian Standard\n  •&IS-15105 : Standard for the Installation of Automatic Sprinkler Protection System\n  •&IS-2190 : Standard for the Installation of Automatic Fire Detection System\n  •&IS-2189 : Standard for the Installation of Fire Extinguishers\n  •&IS-13039: External Hydrant System – Provision & Maintenance\n\n3.&National Fire Protection Association (NFPA)&\n  •&NFPA -13: (Installation of Automatic Sprinkler Protection System)&\n  •&NFPA- 25 (Standard for the Inspection, Testing, and Maintenance of Water-Based Fire Protection Systems\n  •&NFPA -20 (Standard for the Installation of Stationary Pumps for Fire Protection\n\n4.&FM Global Standards\n  •&FM DS 0200 ( (Installation Guidelines on Automatic Sprinkler Protection System&\n  •&FM DS 0326 (Fire Water Demand Calculations) and Etc.\n\n5.&XL Catlin (XL Gaps Guidelines)\n\n6.&Nat Cat Estimation\n  •&Munich Re -Nathan Tool\n  •&Swiss Re Flood Map Tool\n  •&Internal Flooding Mapping',
              style: pw.TextStyle(fontSize: 9, lineSpacing: 2),
            ),
          ];
        },
      ),
    );

    // --- Page 8: Share India Risk Engineering Services ---
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return [
            buildPageHeader(),
            pw.SizedBox(height: 30),
            pw.Text(
              '8.Share India Risk Engineering Services',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'Share India Insurance Company Risk Engineering Department solely a support function for Property Underwriting Department.  Share India Risk Engineering Department has an experienced Risk Engineer worked in Power Plant, Integrated Steel Plant, Textile, Chemical Plant and Engineering Project with over more than 12 to 15years in their Respective Fields.\n\nRisk Engineer performs Technical Risk Assessment for our Internal and External Client pre and post policy booking which is helpful for Underwriter to Quote Policy in term of Good Coverage benefits for Client.\n\nShare India Risk Engineering Department conduct Risk Assessment of Industrial sector considering Local and Multinational Fire Protection Standards such as NFPA, FM and AXA XL, Indian Standard and TAC. We suggest Risk Recommendation and Best Industrial practice across all the Industry which will really helpful for improving Client Risk.\n\nRisk Engineering Survey would assess following aspects of the Risk present at the client premises and suggest possible recommendations. Detailed Risk Engineering Report would contain technical content, Risk Summary and Recommendations.\n\n  1.Automatic Fire Protection System\n  2.Passive Protection System(PPS+Construction )\n  3.Human Element\n  4.Surveillance(Surveillance +Automatic Fire Detection System)\n  5.Neighbouring Exposure\n  6.Occupancy Related Hazards\n  7.Risk Management\n  8.BI Exposure\n  9.Probable Maximum Loss\n  10.Industrial Best Practices/Benchmarking Standards.',
              style: pw.TextStyle(fontSize: 9, lineSpacing: 2),
            ),

            pw.SizedBox(height: 40),
            pw.Text(
              '9.Disclaimer',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColor.fromHex('#2196F3'),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'This report is merely a risk assessment at the location where the property/risk cover to be insured, as of date of this report, and any advice in the report is merely for the purpose to reduce the probability of risk/loss. Hence this report is not dealing with assessment of value of property/risk to be insured and as to whether the proposer\'s declared property/risk to be insured and quantum thereof exists or not for which the principle of Uberrima fide applies for the proposal of proposer/proposal through intermediary or RFQ and accordingly the proposer\'s/intermediary/RFQ declared value of property/risk to be insured is the basis of underwriting decision of Share India Insurance Limited ["Share India" or "Our Company"]. Also this report and advise therein shall not be construed as (i) complete with all possible hazards are identified by Share India, (ii) there are no other hazards, (iii) recommending to compulsorily underwrite and issue policy to proposer, (iv) basis for proposer to insist for policy issuance, Share India making any promises nor certifying the operations of proposer/proposed property/risk are fully safe and or compliant with all the health and other standards of safety and precautions under various applicable Laws [Act, Rules, Regulations, Schemes, notifications] for which proposer shall ensure to duly take care and itself comply with all applicable laws and health and other standards of safety.',
              style: pw.TextStyle(fontSize: 9, lineSpacing: 2),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper Widget Builders
  static pw.TableRow _buildGeneralRow(
    String label,
    dynamic value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            (value == null || value.toString().isEmpty)
                ? 'NA'
                : value.toString(),
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildScoreRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _buildRiskGradientBar(pw.Font fontBold) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            color: PdfColors.red,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Center(
              child: pw.Text(
                'Poor Risk',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            color: PdfColors.yellow,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Center(
              child: pw.Text(
                'Adequate Risk',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            color: PdfColors.lightBlue,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Center(
              child: pw.Text(
                'Favourable Risk',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            color: PdfColors.green,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Center(
              child: pw.Text(
                'Good Risk',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static PdfColor _getBajajRatingColor(String rating) {
    if (rating.contains('Poor Risk')) return PdfColors.red;
    if (rating.contains('Adequate Risk')) return PdfColors.yellow;
    if (rating.contains('Favourable Risk')) return PdfColors.lightBlue;
    return PdfColors.green;
  }

  static pw.Widget _buildProfileItem(
    String title,
    String desc,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColor.fromHex('#1E88E5'),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, top: 4),
            child: pw.Text(
              desc,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#424242'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMiniChart(
    String title,
    double maxVal,
    double actual,
    double potential,
    pw.Font font,
  ) {
    const double chartHeight = 80;
    actual = actual > maxVal ? maxVal : actual;
    potential = potential > maxVal ? maxVal : potential;

    return pw.Container(
      width: 200,
      color: PdfColor.fromHex('#F5F5F5'),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 10),
          pw.Container(
            height: chartHeight,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.grey),
                bottom: pw.BorderSide(color: PdfColors.grey),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildBar(
                  maxVal,
                  maxVal,
                  PdfColor.fromHex('#90CAF9'),
                ), // Weightage
                _buildBar(
                  actual,
                  maxVal,
                  PdfColor.fromHex('#3949AB'),
                ), // Actual
                _buildBar(
                  potential,
                  maxVal,
                  PdfColor.fromHex('#3949AB'),
                ), // Potential
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Text('Weightage', style: const pw.TextStyle(fontSize: 5)),
              pw.Text('Actual Rating', style: const pw.TextStyle(fontSize: 5)),
              pw.Text(
                'Potential Rating',
                style: const pw.TextStyle(fontSize: 5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBar(double val, double maxVal, PdfColor color) {
    double h = (val / maxVal) * 80;
    if (h.isNaN || h < 0) h = 0;
    return pw.Container(width: 20, height: h, color: color);
  }

  // Renders a base-64 encoded image string seamlessly into the PDF Report layout
  static pw.Widget _buildImageFromBase64(
    String base64Str, {
    double width = 150,
    double height = 150,
  }) {
    try {
      if (base64Str.isEmpty || base64Str == 'null') {
        return pw.Text(
          '[No Image]',
          style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
        );
      }

      final bytes = base64Decode(base64Str);
      return pw.Container(
        width: width,
        height: height,
        child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
      );
    } catch (_) {
      return pw.Text(
        '[Error Loading Image]',
        style: const pw.TextStyle(color: PdfColors.red, fontSize: 8),
      );
    }
  }
}
