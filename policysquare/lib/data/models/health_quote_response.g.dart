// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthQuoteResponse _$HealthQuoteResponseFromJson(Map<String, dynamic> json) =>
    HealthQuoteResponse(
      companyName: json['companyName'] as String,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      productName: json['productName'] as String,
      type: json['type'] as String,
      sumInsured: (json['sumInsured'] as num).toDouble(),
      premium: (json['premium'] as num).toDouble(),
    );

Map<String, dynamic> _$HealthQuoteResponseToJson(
        HealthQuoteResponse instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'companyLogoUrl': instance.companyLogoUrl,
      'productName': instance.productName,
      'type': instance.type,
      'sumInsured': instance.sumInsured,
      'premium': instance.premium,
    };
