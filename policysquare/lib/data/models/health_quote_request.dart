import 'package:json_annotation/json_annotation.dart';

part 'health_quote_request.g.dart';

@JsonSerializable()
class HealthQuoteRequest {
  final int age;
  final String cityTier;
  final String members;
  final double selectedSumInsured;

  HealthQuoteRequest({
    required this.age,
    required this.cityTier,
    required this.members,
    required this.selectedSumInsured,
  });

  factory HealthQuoteRequest.fromJson(Map<String, dynamic> json) =>
      _$HealthQuoteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HealthQuoteRequestToJson(this);
}
