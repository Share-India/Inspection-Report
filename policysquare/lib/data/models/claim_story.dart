import 'package:json_annotation/json_annotation.dart';

part 'claim_story.g.dart';

@JsonSerializable()
class ClaimStory {
  String? id;
  String title;
  String? category;
  String caseName;
  String? court;
  String? issue;
  String story;
  String? verdict;
  List<String>? principles;
  String? bottomLine;
  String? imagePath;
  String? createdAt;

  ClaimStory({
    this.id,
    required this.title,
    this.category,
    required this.caseName,
    this.court,
    this.issue,
    required this.story,
    this.verdict,
    this.principles,
    this.bottomLine,
    this.imagePath,
    this.createdAt,
  });

  factory ClaimStory.fromJson(Map<String, dynamic> json) =>
      _$ClaimStoryFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimStoryToJson(this);
}
