class RiskScoringHelper {
  // Mapping of exact answer strings to their score (1-5)
  // 1 = Very Bad / High Risk
  // 5 = Excellent / Low Risk
  static final Map<String, int> _scoringMap = {
    // 1. Human Element
    // Housekeeping
    'No RM, FG and WIP are stored in Haphazard manner. All the stocks are arranged in orderly would avoid delay in fire fighting operation':
        5,
    'Stocks are stored beneath electrical fittings/close to electrical installation/Plant walls.':
        2,
    'Stock inventory is too high which may hampers fire fighting operation':
        4, // User specified 4
    'Stocks are stored in poorly manner/stored till ceiling height/Haphazard manner/no pallets are use for storage':
        2,
    'Very Poor Housekeeping': 1,

    // Fire Training (Frequency)
    'Monthly': 5,
    'Quarterly': 3,
    'Half-yearly': 2,
    'Annually': 1,

    // Fire Protection Availability
    'Fire Hydrant System is installed as per TAC': 4,
    'Fire Extinguishers installed at IS 2190': 3,
    'Non Standard Fire Extinguishers having zero Pressure/Inadequate Maintenance':
        1,
    'Fire brigade located within 2kms': 4,
    'No protection available': 1,

    // Maintenance & Hot Work (Boolean Yes/No)
    'maintenance_Yes': 5,
    'maintenance_No': 1,
    'hotWorkPermit_Yes': 5,
    'hotWorkPermit_No': 1,

    // 2. Occupancy Hazards
    // Combustible Materials
    'combustibleMaterials_No': 4,
    'combustibleMaterials_Yes': 1,

    // Flammable Solvents
    'Yes. Solvent transferring is done from Tankfarm to Reactor/Pressure Vessel directly using Earth Rite System':
        5,
    'Yes. Solvent transferring is done from Metal Drum to Reactor/Process Vessel directly with Static Protection such as Copper Bonding at Pipe Flanges/Crocodile Clamps':
        4,
    'Yes. Solvent transferring is done from HDPE Drum/PCV Pipe to Reactor/Process Vessel':
        4,
    'Yes. Solvent handled and transfer inside reactor using Open Containers': 2,
    'No Solvent is use for processing of Finished Goods':
        1, // User provided [1] for No Solvent? Wait.
    // "No Solvent is use for processing of Finished Goods [1]" -> usually No Solvent is GOOD (5).
    // But user explicitly said [1]. I will follow instructions, but this is suspicious.
    // Re-reading user request:
    // "No Solvent is use for processing of Finished Goods[1]"
    // Maybe they mean "No Solvent used... [1]" is a mistake in request or implies something else?
    // Or maybe "No Solvent" is actually "No Solvent controls"?
    // "No Solvent is use" = "No Solvent is used".
    // If no solvent is used, risk should be low (5).
    // If I look at the pattern:
    // Tankfarm (Best) = 5.
    // Metal Drum (Good) = 4.
    // HDPE Drum (Okay) = 4.
    // Open Containers (Bad) = 2.
    // No Solvent (Best?) -> [1]??
    // Let's assume user might have swapped 1 and 5, OR "No solvent" means "No solvent safety measures"?
    // "No Solvent is use for processing of Finished Goods".
    // I will stick to the USER'S explicit [1] to be safe, but add a comment.
    // WAIT. If no solvent is used, why would it be High Risk (1)?
    // Maybe it's a typo in the user prompt.
    // "Use flammable solvents? No [4], Yes [1]".
    // Then detail list: "... No Solvent ... [1]".
    // Prompt says: "Use flammable solvents? ... No Solvent ... [1]".
    // Prompt ALSO says earlier: "Use combustible raw materials... No [4]".
    // I will confirm if I can or just follow. I'll follow the explicit [1] for the detail option.
    // Actually, looking at "Combustible Materials": No [4].
    // Maybe "No Solvent" option creates a score of 1 because it's N/A?
    // But "No" in Combustible is 4.
    // I will use 1 as requested.

    // Flame Proof Cables
    'flameProofCables_Yes': 4,
    'flameProofCables_No': 1,

    // Electrical Condition
    'Electrical Wiring through Steel Conduit': 4,
    'Electrical wiring through PVC/Plastic Conduit': 3,
    'No Conduit and Cable are dressed properly on Cable Tray': 2,
    'Loose/Tape wiring': 1,

    // 3. Surveillance
    // Smoke Detection
    'smokeDetection_Yes': 4,
    'smokeDetection_No': 1,

    // CCTV
    'cctv_Yes': 5,
    'cctv_No': 1,

    // Boundary Walls
    'Yes with RCC': 3,
    'Yes with Barbed Wire fencing':
        4, // User gave 4 for Barbed Wire, 3 for RCC? (Maybe Barbed is better?)
    'None': 1,

    // Security Team
    'securityTeam_No': 1,
    // Yes -> Ask pattern
    '24x7': 5,
    'Shift-wise': 1,

    // 4. Construction
    // Type
    'Roof - RCC/ Walls - RCC': 5,
    'Roof - RCC/ Walls - Brick with RCC frame.': 5, // User gave 5
    'Roof - AC / Walls - Brick with RCC frame/ outdoor plant': 4,
    'Roof - AC sheet or non-combustible/ Walls - Non combustible/partly open':
        3,
    'Either roof or walls combustible or open sides': 2,
    'Both roof and walls combustible': 1,

    // Separation
    '>21mtrs': 4,
    '16 to 20mtrs': 3,
    '11 to 15mtrs': 3,
    '6 to 10mtrs': 2,
    '0-5mtrs': 1,

    // Basement Risk (Hazard)
    'basementRisk_Yes': 1,
    'basementRisk_No': 4,

    // 5. External Exposure
    // External Occupancies
    'Yes with Storage Risks': 1,
    'Yes with Industrial Risk': 1,
    'Does not share with any other facility': 4,

    // Water Body (Hazard?)
    'waterBody_Yes': 1,
    'waterBody_No': 4,

    // Natural Hazards History
    'naturalHazards_Yes': 1,
    'naturalHazards_No': 5,

    // 6. Fire Protection Systems (Using previous logic as placeholder/defaults if user didn't specify map)
    // User didn't provide Step 6 map in THIS prompt, but I have it from before (or I should assume 1-5 logic).
    // I'll keep the placeholders I wrote previously.
    '< 100': 1,
    '100 - 1000': 3,
    '> 1000': 5,
    '100 - 171': 3,
    '171 - 278': 4,
    '> 278': 5,
    '< 10': 1,
    '10.8': 3,
    '> 10.8': 5,
    '1 - 5': 2,
    '6 - 10': 3,
    '1 - 10': 2,
    '11 - 20': 4,
    '21 - 50': 4,
    '> 20': 5,
    '> 50': 5,
  };

  static Map<String, dynamic> calculateScore(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return {
        'actualScore': 0.0,
        'potentialScore': 0.0,
        'rating': 'N/A',
        'actualPercent': 0.0,
        'potentialPercent': 0.0,
      };
    }

    double totalPossible = 0;
    double actualPoints = 0;

    // Category tracking
    double cat1Actual = 0, cat1Possible = 0; // Human Element
    double cat2Actual = 0, cat2Possible = 0; // Occupancy
    double cat3Actual = 0, cat3Possible = 0; // Surveillance
    double cat4Actual = 0, cat4Possible = 0; // Construction
    double cat5Actual = 0, cat5Possible = 0; // External
    double cat6Actual = 0, cat6Possible = 0; // Fire Protection

    // Helper block to add to category specific variables
    void addScoreToCategory(int catIndex, double points, double possible) {
      actualPoints += points;
      totalPossible += possible;
      switch (catIndex) {
        case 1:
          cat1Actual += points;
          cat1Possible += possible;
          break;
        case 2:
          cat2Actual += points;
          cat2Possible += possible;
          break;
        case 3:
          cat3Actual += points;
          cat3Possible += possible;
          break;
        case 4:
          cat4Actual += points;
          cat4Possible += possible;
          break;
        case 5:
          cat5Actual += points;
          cat5Possible += possible;
          break;
        case 6:
          cat6Actual += points;
          cat6Possible += possible;
          break;
      }
    }

    // Helper to get score
    int getScore(dynamic answerRaw, {String? keyBoolPrefix}) {
      if (answerRaw == null) return 0;

      String answer = '';
      if (answerRaw is String) {
        answer = answerRaw;
      } else {
        // Safe fallback for unexpected types (like Lists)
        answer = answerRaw.toString();
        print(
          'Warning: getScore received unexpected type \${answerRaw.runtimeType} -> \$answer',
        );
      }

      // Try direct match
      if (_scoringMap.containsKey(answer)) {
        return _scoringMap[answer]!;
      }

      // Try Boolean prefix match (e.g. key_Yes)
      if (keyBoolPrefix != null) {
        String boolKey = '${keyBoolPrefix}_$answer';
        if (_scoringMap.containsKey(boolKey)) {
          return _scoringMap[boolKey]!;
        }
      }

      return 0; // Default to 0 if not found
    }

    // Helper for Boolean conversion
    String toYesNo(dynamic val) {
      if (val == true || val == 'true') return 'Yes';
      if (val == false || val == 'false') return 'No';
      return 'No'; // Default strict
    }

    // --- Step 1: Human Element ---
    // 1. Housekeeping
    if (data['housekeeping'] != null) {
      addScoreToCategory(1, getScore(data['housekeeping']).toDouble(), 5);
    }

    // 2. Fire Training
    if (data['fireTraining'] == true) {
      if (data['trainingFrequency'] != null) {
        addScoreToCategory(
          1,
          getScore(data['trainingFrequency']).toDouble(),
          5,
        );
      } else {
        addScoreToCategory(1, 0, 5); // Missing data
      }
    } else {
      addScoreToCategory(1, 1, 5); // No training
    }

    // 3. Fire Protection (Dropdown)
    if (data['fireProtection'] != null) {
      addScoreToCategory(1, getScore(data['fireProtection']).toDouble(), 5);
    }

    // 4. Maintenance (Yes/No)
    addScoreToCategory(
      1,
      getScore(
        toYesNo(data['maintenance']),
        keyBoolPrefix: 'maintenance',
      ).toDouble(),
      5,
    );

    // 5. Hot Work (Yes/No)
    addScoreToCategory(
      1,
      getScore(
        toYesNo(data['hotWorkPermit']),
        keyBoolPrefix: 'hotWorkPermit',
      ).toDouble(),
      5,
    );

    // --- Step 2: Occupancy ---
    // 6. Combustible Materials
    addScoreToCategory(
      2,
      getScore(
        toYesNo(data['combustibleMaterials']),
        keyBoolPrefix: 'combustibleMaterials',
      ).toDouble(),
      5,
    );

    // 7. Flammable Solvents
    if (data['flammableSolvents'] != null) {
      addScoreToCategory(2, getScore(data['flammableSolvents']).toDouble(), 5);
    }

    // 8. Flame Proof Cables
    addScoreToCategory(
      2,
      getScore(
        toYesNo(data['flameProofCables']),
        keyBoolPrefix: 'flameProofCables',
      ).toDouble(),
      5,
    );

    // 9. Electrical Condition
    if (data['electricalCondition'] != null) {
      addScoreToCategory(
        2,
        getScore(data['electricalCondition']).toDouble(),
        5,
      );
    }

    // --- Step 3: Surveillance ---
    // 10. Smoke Detection
    addScoreToCategory(
      3,
      getScore(
        toYesNo(data['smokeDetection']),
        keyBoolPrefix: 'smokeDetection',
      ).toDouble(),
      5,
    );

    // 11. CCTV
    addScoreToCategory(
      3,
      getScore(toYesNo(data['cctv']), keyBoolPrefix: 'cctv').toDouble(),
      5,
    );

    // 12. Boundary Walls
    if (data['boundaryWalls'] != null) {
      addScoreToCategory(3, getScore(data['boundaryWalls']).toDouble(), 5);
    }

    // 13. Security Team
    if (data['securityTeam'] == true) {
      if (data['securityCoverage'] != null) {
        addScoreToCategory(3, getScore(data['securityCoverage']).toDouble(), 5);
      } else {
        addScoreToCategory(3, 1, 5);
      }
    } else {
      addScoreToCategory(3, 1, 5);
    }

    // --- Step 4: Construction ---
    // 14. Type
    if (data['constructionType'] != null) {
      addScoreToCategory(4, getScore(data['constructionType']).toDouble(), 5);
    }

    // 15. Separation
    if (data['separationDistance'] != null) {
      addScoreToCategory(4, getScore(data['separationDistance']).toDouble(), 5);
    }

    // 16. Basement
    addScoreToCategory(
      4,
      getScore(
        toYesNo(data['basementRisk']),
        keyBoolPrefix: 'basementRisk',
      ).toDouble(),
      5,
    );

    // --- Step 5: External ---
    // 17. External Occupancies
    if (data['externalOccupancies'] != null) {
      addScoreToCategory(
        5,
        getScore(data['externalOccupancies']).toDouble(),
        5,
      );
    }

    // 18. Water Body
    addScoreToCategory(
      5,
      getScore(
        toYesNo(data['waterBody']),
        keyBoolPrefix: 'waterBody',
      ).toDouble(),
      5,
    );

    // 19. Natural Hazards
    addScoreToCategory(
      5,
      getScore(
        toYesNo(data['naturalHazards']),
        keyBoolPrefix: 'naturalHazards',
      ).toDouble(),
      5,
    );

    // --- Step 6: Fire Protection Systems (Calculated Capacities) ---
    void addStep6Score(String key) {
      if (data[key] != null) {
        if (data[key] == true || data[key] == 'true') {
          addScoreToCategory(6, 5, 5);
        } else {
          addScoreToCategory(6, 1, 5);
        }
      }
    }

    addStep6Score('fireWaterTank');
    addStep6Score('mainElectricalPump');
    addStep6Score('dieselDrivenPump');
    addStep6Score('jockeyPump');
    addStep6Score('hydrantPoints');
    addStep6Score('fireExtinguishers');

    // Calculations
    totalPossible = 125.0; // Enforce constant max possible value regardless of missing fields
    double actualPercent = totalPossible > 0
        ? (actualPoints / totalPossible) * 100
        : 0;

    // Recoverable Points: Points lost in highly actionable categories (1, 2, 3, 6)
    // Categories 4 (Construction) and 5 (External/Natural Hazards) are considered permanent/inherent risks.
    double recoverablePoints = (cat1Possible - cat1Actual) +
        (cat2Possible - cat2Actual) +
        (cat3Possible - cat3Actual) +
        (cat6Possible - cat6Actual);

    // Potential Score = Actual Score + points recovered from actionable mitigations + 5 bonus points
    double potentialScore = actualPoints + recoverablePoints + 5.0;
    if (potentialScore > totalPossible) potentialScore = totalPossible;

    double potentialPercent = totalPossible > 0 ? (potentialScore / totalPossible) * 100 : 0.0;

    String getRating(double percent) {
      if (percent <= 60.0) return 'Poor Risk';
      if (percent <= 70.0) return 'Adequate Risk';
      if (percent <= 80.0) return 'Favourable Risk';
      return 'Excellent Risk';
    }

    return {
      'actualScore': actualPoints.toInt(),
      'potentialScore': potentialScore.toInt(),
      'maxScore': 125, // Explicit maximum allowed score used for UI denominators
      'rating': getRating(actualPercent),
      'potentialRating': getRating(potentialPercent),
      'actualPercent': double.parse(actualPercent.toStringAsFixed(2)),
      'potentialPercent': double.parse(potentialPercent.toStringAsFixed(2)),
      // Category 1: Human Element
      'cat1Actual': cat1Actual,
      'cat1Possible': cat1Possible,
      // Category 2: Occupancy hazard
      'cat2Actual': cat2Actual,
      'cat2Possible': cat2Possible,
      // Category 3: Surveillance
      'cat3Actual': cat3Actual,
      'cat3Possible': cat3Possible,
      // Category 4: Construction
      'cat4Actual': cat4Actual,
      'cat4Possible': cat4Possible,
      // Category 5: External
      'cat5Actual': cat5Actual,
      'cat5Possible': cat5Possible,
      // Category 6: Auto Fire Protection
      'cat6Actual': cat6Actual,
      'cat6Possible': cat6Possible,
    };
  }
}
