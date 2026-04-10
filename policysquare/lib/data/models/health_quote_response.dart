import 'package:json_annotation/json_annotation.dart';

part 'health_quote_response.g.dart';

@JsonSerializable()
class HealthQuoteResponse {
  final String companyName;
  final String? companyLogoUrl;
  final String productName;
  final String type;
  final double sumInsured;
  final double premium;

  HealthQuoteResponse({
    required this.companyName,
    this.companyLogoUrl,
    required this.productName,
    required this.type,
    required this.sumInsured,
    required this.premium,
  });

  factory HealthQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthQuoteResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthQuoteResponseToJson(this);
}
