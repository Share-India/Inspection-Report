import 'package:json_annotation/json_annotation.dart';

part 'risk_assessment.g.dart';

@JsonSerializable()
class RiskAssessment {
  String? id;
  String? mobileNumber;
  String? status;
  String? data; // JSON String
  dynamic createdAt;

  // Helper properties (not in JSON)
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> get parsedData {
    if (data == null || data!.isEmpty) return {};
    // Start with empty map
    // We will parse it when needed using dart:convert
    return {};
  }

  RiskAssessment({
    this.id,
    this.mobileNumber,
    this.status,
    this.data,
    this.createdAt,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$RiskAssessmentToJson(this);
}
