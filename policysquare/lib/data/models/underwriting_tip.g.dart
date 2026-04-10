// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'underwriting_tip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnderwritingTip _$UnderwritingTipFromJson(Map<String, dynamic> json) =>
    UnderwritingTip(
      id: json['id'] as String?,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      example: json['example'] as String?,
      keyTakeaway: json['keyTakeaway'] as String?,
      imagePath: json['imagePath'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$UnderwritingTipToJson(UnderwritingTip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'example': instance.example,
      'keyTakeaway': instance.keyTakeaway,
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt,
    };
