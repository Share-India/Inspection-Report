// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimStory _$ClaimStoryFromJson(Map<String, dynamic> json) => ClaimStory(
      id: json['id'] as String?,
      title: json['title'] as String,
      category: json['category'] as String?,
      caseName: json['caseName'] as String,
      court: json['court'] as String?,
      issue: json['issue'] as String?,
      story: json['story'] as String,
      verdict: json['verdict'] as String?,
      principles: (json['principles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bottomLine: json['bottomLine'] as String?,
      imagePath: json['imagePath'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ClaimStoryToJson(ClaimStory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'caseName': instance.caseName,
      'court': instance.court,
      'issue': instance.issue,
      'story': instance.story,
      'verdict': instance.verdict,
      'principles': instance.principles,
      'bottomLine': instance.bottomLine,
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt,
    };
