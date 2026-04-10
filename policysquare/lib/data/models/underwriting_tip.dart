import 'package:json_annotation/json_annotation.dart';

part 'underwriting_tip.g.dart';

@JsonSerializable()
class UnderwritingTip {
  String? id;
  String title;
  String category;
  String? description;
  String? example;
  String? keyTakeaway;
  String? imagePath;
  String? createdAt;

  UnderwritingTip({
    this.id,
    required this.title,
    required this.category,
    this.description,
    this.example,
    this.keyTakeaway,
    this.imagePath,
    this.createdAt,
  });

  factory UnderwritingTip.fromJson(Map<String, dynamic> json) =>
      _$UnderwritingTipFromJson(json);
  Map<String, dynamic> toJson() => _$UnderwritingTipToJson(this);
}
