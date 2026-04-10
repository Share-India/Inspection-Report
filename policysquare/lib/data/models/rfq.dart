import 'package:json_annotation/json_annotation.dart';

part 'rfq.g.dart';

@JsonSerializable()
class Rfq {
  String? id;
  String? companyName;
  String? contactPerson;
  String? mobileNumber; // Added for user tracking
  String? email;
  String? product;
  String? details; // JSON string of the 10-step form
  String? status;
  String? quoteDetails; // Admin provided quote info
  String? quoteFilePath;
  String? createdAt;

  Rfq({
    this.id,
    this.companyName,
    this.contactPerson,
    this.mobileNumber,
    this.email,
    this.product,
    this.details,
    this.status,
    this.quoteDetails,
    this.quoteFilePath,
    this.createdAt,
  });

  factory Rfq.fromJson(Map<String, dynamic> json) => _$RfqFromJson(json);
  Map<String, dynamic> toJson() => _$RfqToJson(this);
}
