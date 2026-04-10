// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) =>
    RiskAssessment(
      id: json['id'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      status: json['status'] as String?,
      data: json['data'] as String?,
      createdAt: json['createdAt'],
    );

Map<String, dynamic> _$RiskAssessmentToJson(RiskAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobileNumber': instance.mobileNumber,
      'status': instance.status,
      'data': instance.data,
      'createdAt': instance.createdAt,
    };
