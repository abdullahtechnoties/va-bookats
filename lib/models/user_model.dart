import 'package:va_bookats/utilities/translation_extention.dart';
import '../network/api/api_path.dart';

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.emailSecondary,
    this.phonePrimary,
    this.phoneSecondary,
    this.countryId,
    this.stateId,
    this.cityId,
    this.areaId,
    this.zipCode,
    this.address,
    this.status,
    this.image,
    this.imageUrl,
    this.imageThumbUrl,
    this.dateOfBirth,
    this.serviceType,
    this.gender,
    this.qualification,
    this.nicFront,
    this.nicBack,
    this.nicFrontUrl,
    this.nicFrontThumbUrl,
    this.nicBackUrl,
    this.nicBackThumbUrl,
    this.salary,
    this.salaryType,
    this.commissionType,
    this.commission,
    this.joiningDate,
    this.customerSerial,
    this.staffSerial,
    this.branchId,
    this.shiftId,
    this.designationId,
    this.longitude,
    this.latitude,
    this.roles,
    this.country,
    this.state,
    this.city,
    this.area,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? emailSecondary;
  final String? phonePrimary;
  final String? phoneSecondary;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final int? areaId;
  final String? zipCode;
  final String? address;
  final String? status;
  final String? image; // full URL after processing
  final String? imageUrl;
  final String? imageThumbUrl;
  final String? dateOfBirth;
  final String? serviceType;
  final String? gender;
  final String? qualification;
  final String? nicFront;
  final String? nicBack;
  final String? nicFrontUrl;
  final String? nicFrontThumbUrl;
  final String? nicBackUrl;
  final String? nicBackThumbUrl;
  final String? salary;
  final String? salaryType;
  final String? commissionType;
  final String? commission;
  final String? joiningDate;
  final String? customerSerial;
  final String? staffSerial;
  final int? branchId;
  final int? shiftId;
  final int? designationId;
  final String? longitude;
  final String? latitude;
  final List<Role>? roles;
  final GeoName? country;
  final GeoName? state;
  final GeoName? city;
  final GeoName? area;

  // Full name – now just the `name` field
  String get fullName => name?.trim() ?? '';

  // Display name with fallback translation
  String get displayName =>
      (fullName.isNotEmpty) ? fullName : 'user.handyman'.trns();

  // Basic details: name, email, phone, gender, date of birth are present
  bool get hasBasicDetails =>
      name != null && name!.trim().isNotEmpty &&
      email != null && email!.trim().isNotEmpty &&
      phonePrimary != null && phonePrimary!.trim().isNotEmpty &&
      gender != null && gender!.trim().isNotEmpty &&
      dateOfBirth != null && dateOfBirth!.trim().isNotEmpty;

  // Profile considered complete if basic details + image + address are set
  bool get hasCompletedProfile =>
      hasBasicDetails &&
      image != null && image!.trim().isNotEmpty &&
      address != null && address!.trim().isNotEmpty;

  /// Best profile image URL — prefers the explicit `image_url` from the API,
  /// falls back to the legacy `image` field.
  String? get bestImageUrl => imageUrl ?? image;
  String? get bestImageThumbUrl => imageThumbUrl ?? image;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to build full image URL
    String? getImage(String? image) {
      if (image == null) return null;
      if (image.startsWith('http')) return image;
      return '${ApiPath.imageUrl}/$image';
    }

    return UserModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      emailSecondary: json['email_secondary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      phoneSecondary: json['phone_secondary']?.toString(),
      countryId: _parseInt(json['country_id']),
      stateId: _parseInt(json['state_id']),
      cityId: _parseInt(json['city_id']),
      areaId: _parseInt(json['area_id']),
      zipCode: json['zip_code']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
      image: getImage(json['image']?.toString()),
      imageUrl: json['image_url']?.toString(),
      imageThumbUrl: json['image_thumb_url']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      serviceType: json['service_type']?.toString(),
      gender: json['gender']?.toString(),
      qualification: json['qualification']?.toString(),
      nicFront: getImage(json['nic_front']?.toString()),
      nicBack: getImage(json['nic_back']?.toString()),
      nicFrontUrl: json['nic_front_url']?.toString(),
      nicFrontThumbUrl: json['nic_front_thumb_url']?.toString(),
      nicBackUrl: json['nic_back_url']?.toString(),
      nicBackThumbUrl: json['nic_back_thumb_url']?.toString(),
      salary: json['salary']?.toString(),
      salaryType: json['salary_type']?.toString(),
      commissionType: json['commission_type']?.toString(),
      commission: json['commission']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      customerSerial: json['customer_serial']?.toString(),
      staffSerial: json['staff_serial']?.toString(),
      branchId: _parseInt(json['branch_id']),
      shiftId: _parseInt(json['shift_id']),
      designationId: _parseInt(json['designation_id']),
      longitude: json['longitude']?.toString(),
      latitude: json['latitude']?.toString(),
      roles: (json['roles'] as List?)
          ?.map((roleJson) => Role.fromJson(roleJson))
          .toList(),
      country: json['country'] is Map
          ? GeoName.fromJson(Map<String, dynamic>.from(json['country']))
          : null,
      state: json['state'] is Map
          ? GeoName.fromJson(Map<String, dynamic>.from(json['state']))
          : null,
      city: json['city'] is Map
          ? GeoName.fromJson(Map<String, dynamic>.from(json['city']))
          : null,
      area: json['area'] is Map
          ? GeoName.fromJson(Map<String, dynamic>.from(json['area']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to strip full URL back to relative path (if needed)
    String? getImage(String? image) {
      if (image == null) return null;
      if (image.startsWith('http')) return image;
      return '${ApiPath.imageUrl}/$image';
    }

    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'email_secondary': emailSecondary,
      'phone_primary': phonePrimary,
      'phone_secondary': phoneSecondary,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'area_id': areaId,
      'zip_code': zipCode,
      'address': address,
      'status': status,
      'image': getImage(image),
      'image_url': imageUrl,
      'image_thumb_url': imageThumbUrl,
      'date_of_birth': dateOfBirth,
      'service_type': serviceType,
      'gender': gender,
      'qualification': qualification,
      'nic_front': getImage(nicFront),
      'nic_back': getImage(nicBack),
      'nic_front_url': nicFrontUrl,
      'nic_front_thumb_url': nicFrontThumbUrl,
      'nic_back_url': nicBackUrl,
      'nic_back_thumb_url': nicBackThumbUrl,
      'salary': salary,
      'salary_type': salaryType,
      'commission_type': commissionType,
      'commission': commission,
      'joining_date': joiningDate,
      'customer_serial': customerSerial,
      'staff_serial': staffSerial,
      'branch_id': branchId,
      'shift_id': shiftId,
      'designation_id': designationId,
      'longitude': longitude,
      'latitude': latitude,
      'roles': roles?.map((role) => role.toJson()).toList(),
      'country': country?.toJson(),
      'state': state?.toJson(),
      'city': city?.toJson(),
      'area': area?.toJson(),
    };
  }
}

/// Lightweight geo object returned inside the user response:
/// `{"id": 1, "name": "Pakistan"}`
class GeoName {
  final int? id;
  final String? name;

  const GeoName({this.id, this.name});

  factory GeoName.fromJson(Map<String, dynamic> json) {
    return GeoName(
      id: json['id'] as int?,
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Role {
  Role({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  final int? id;
  final String? name;
  final String? guardName;
  final String? createdAt;
  final String? updatedAt;
  final Pivot? pivot;

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      guardName: json['guard_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot?.toJson(),
    };
  }
}

class Pivot {
  Pivot({this.modelType, this.modelId, this.roleId});

  final String? modelType;
  final int? modelId;
  final int? roleId;

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      modelType: json['model_type']?.toString(),
      modelId: json['model_id'] as int?,
      roleId: json['role_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'model_type': modelType, 'model_id': modelId, 'role_id': roleId};
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}