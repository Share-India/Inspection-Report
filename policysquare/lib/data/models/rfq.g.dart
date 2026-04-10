// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rfq _$RfqFromJson(Map<String, dynamic> json) => Rfq(
      id: json['id'] as String?,
      companyName: json['companyName'] as String?,
      contactPerson: json['contactPerson'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      email: json['email'] as String?,
      product: json['product'] as String?,
      details: json['details'] as String?,
      status: json['status'] as String?,
      quoteDetails: json['quoteDetails'] as String?,
      quoteFilePath: json['quoteFilePath'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RfqToJson(Rfq instance) => <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'contactPerson': instance.contactPerson,
      'mobileNumber': instance.mobileNumber,
      'email': instance.email,
      'product': instance.product,
      'details': instance.details,
      'status': instance.status,
      'quoteDetails': instance.quoteDetails,
      'quoteFilePath': instance.quoteFilePath,
      'createdAt': instance.createdAt,
    };
