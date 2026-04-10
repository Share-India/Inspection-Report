// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_quote_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthQuoteRequest _$HealthQuoteRequestFromJson(Map<String, dynamic> json) =>
    HealthQuoteRequest(
      age: (json['age'] as num).toInt(),
      cityTier: json['cityTier'] as String,
      members: json['members'] as String,
      selectedSumInsured: (json['selectedSumInsured'] as num).toDouble(),
    );

Map<String, dynamic> _$HealthQuoteRequestToJson(HealthQuoteRequest instance) =>
    <String, dynamic>{
      'age': instance.age,
      'cityTier': instance.cityTier,
      'members': instance.members,
      'selectedSumInsured': instance.selectedSumInsured,
    };
