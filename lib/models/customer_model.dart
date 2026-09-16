// lib/models/customer_model.dart

import 'package:va_bookats/network/response/pagination_helper.dart';

class NamedRef {
  final int? id;
  final String? name;

  const NamedRef({this.id, this.name});

  factory NamedRef.fromJson(Map<String, dynamic> json) {
    return NamedRef(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class CustomerAttachment {
  final int id;
  final String title;
  final String fileName;
  final String mimeType;
  final int size;
  final String url;
  final String thumbnailUrl;

  const CustomerAttachment({
    required this.id,
    required this.title,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.url,
    required this.thumbnailUrl,
  });

  factory CustomerAttachment.fromJson(Map<String, dynamic> json) {
    return CustomerAttachment(
      id: _parseInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      size: _parseInt(json['size']) ?? 0,
      url: json['url']?.toString() ?? '',
      thumbnailUrl:
          (json['thumbnail_url'] ?? json['url'])?.toString() ?? '',
    );
  }
}

class CustomerDetail {
  final CustomerModel customer;
  final List<CustomerAttachment> attachments;
  final PaginationMeta? attachmentsMeta;

  const CustomerDetail({
    required this.customer,
    required this.attachments,
    this.attachmentsMeta,
  });
}

class CustomerModel {
  final int id;
  final int? customerSerial;
  final String name;
  final String email;
  final String phonePrimary;
  final String? phoneSecondary;
  final String? emailSecondary;
  final String? gender;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final int? areaId;
  final String? zipCode;
  final String? address;
  final String? status;
  final String? dateOfBirth;
  final String? joiningDate;
  final String? latitude;
  final String? longitude;
  final String? imageUrl;
  final String? imageThumbUrl;
  final String? nicFrontUrl;
  final String? nicBackUrl;
  final NamedRef? country;
  final NamedRef? state;
  final NamedRef? city;
  final NamedRef? area;

  const CustomerModel({
    required this.id,
    this.customerSerial,
    required this.name,
    required this.email,
    required this.phonePrimary,
    this.phoneSecondary,
    this.emailSecondary,
    this.gender,
    this.countryId,
    this.stateId,
    this.cityId,
    this.areaId,
    this.zipCode,
    this.address,
    this.status,
    this.dateOfBirth,
    this.joiningDate,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.imageThumbUrl,
    this.nicFrontUrl,
    this.nicBackUrl,
    this.country,
    this.state,
    this.city,
    this.area,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    NamedRef? ref(dynamic v) {
      if (v is Map) return NamedRef.fromJson(Map<String, dynamic>.from(v));
      return null;
    }

    return CustomerModel(
      id: _parseInt(json['id']) ?? 0,
      customerSerial: _parseInt(json['customer_serial']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phonePrimary: (json['phone_primary'] ?? json['phone'])?.toString() ?? '',
      phoneSecondary: json['phone_secondary']?.toString(),
      emailSecondary: json['email_secondary']?.toString(),
      gender: json['gender']?.toString(),
      countryId: _parseInt(json['country_id']),
      stateId: _parseInt(json['state_id']),
      cityId: _parseInt(json['city_id']),
      areaId: _parseInt(json['area_id']),
      zipCode: json['zip_code']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageThumbUrl: json['image_thumb_url']?.toString(),
      nicFrontUrl: (json['nic_front_url'] ?? json['nic_front'])?.toString(),
      nicBackUrl: (json['nic_back_url'] ?? json['nic_back'])?.toString(),
      country: ref(json['country']),
      state: ref(json['state']),
      city: ref(json['city']),
      area: ref(json['area']),
    );
  }

  bool get isActive => (status ?? '').toLowerCase() == 'active';

  String get displayImage => (imageThumbUrl?.isNotEmpty == true
          ? imageThumbUrl!
          : imageUrl ?? '');

  String get locationLabel {
    final parts = [
      if ((country?.name ?? '').isNotEmpty) country!.name!,
      if ((state?.name ?? '').isNotEmpty) state!.name!,
      if ((city?.name ?? '').isNotEmpty) city!.name!,
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return address ?? '—';
  }

  String get addressLabel =>
      (address?.isNotEmpty == true) ? address! : locationLabel;

  CustomerModel copyWith({String? status}) {
    return CustomerModel(
      id: id,
      customerSerial: customerSerial,
      name: name,
      email: email,
      phonePrimary: phonePrimary,
      phoneSecondary: phoneSecondary,
      emailSecondary: emailSecondary,
      gender: gender,
      countryId: countryId,
      stateId: stateId,
      cityId: cityId,
      areaId: areaId,
      zipCode: zipCode,
      address: address,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth,
      joiningDate: joiningDate,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      imageThumbUrl: imageThumbUrl,
      nicFrontUrl: nicFrontUrl,
      nicBackUrl: nicBackUrl,
      country: country,
      state: state,
      city: city,
      area: area,
    );
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
