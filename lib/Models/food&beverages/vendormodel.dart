

class VendorModel {
  final int? id;
  final String? ownerName;
  final String? vendorName;
  final String? vendorRegisteredName;
  final String? email;
  final String? phoneNumber;
  final String? alternatePhone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? gstNumber;
  final String? panNumber;
  final String? fssaiNumber;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? accountHolderName;
  final String? businessType;
  final String? vendorType;
  final String? status;
  final String? planType;
  final String? registrationDate;
  final String? logoUrl;
  final String? coverImageUrl;
  final bool? isActive;
  final bool? isOpen;
  final double? rating;
  final int? totalOrders;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final List<String>? cuisineTypes;

  const VendorModel({
    this.id,
    this.ownerName,
    this.vendorName,
    this.vendorRegisteredName,
    this.email,
    this.phoneNumber,
    this.alternatePhone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.latitude,
    this.longitude,
    this.gstNumber,
    this.panNumber,
    this.fssaiNumber,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolderName,
    this.businessType,
    this.vendorType,
    this.status,
    this.planType,
    this.registrationDate,
    this.logoUrl,
    this.coverImageUrl,
    this.isActive,
    this.isOpen,
    this.rating,
    this.totalOrders,
    this.description,
    this.openTime,
    this.closeTime,
    this.cuisineTypes,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id:                   _parseInt(json['id']),
      ownerName:            _str(json['ownerName']),
      vendorName:           _str(json['vendorName']),
      vendorRegisteredName: _str(json['vendorRegisteredName']),
      email:                _str(json['email'] ?? json['emailId']),
      phoneNumber:          _str(json['phoneNumber'] ?? json['phone'] ?? json['mobileNumber']),
      alternatePhone:       _str(json['alternatePhone'] ?? json['alternatePhoneNumber']),
      address:              _str(json['address'] ?? json['addressLine']),
      city:                 _str(json['city']),
      state:                _str(json['state']),
      pincode:              _str(json['pincode']?.toString()),
      country:              _str(json['country']),
      latitude:             _parseDouble(json['latitude']),
      longitude:            _parseDouble(json['longitude']),
      gstNumber:            _str(json['gstNumber'] ?? json['gstNo']),
      panNumber:            _str(json['panNumber'] ?? json['panNo']),
      fssaiNumber:          _str(json['fssaiNumber'] ?? json['fssaiNo']),
      bankAccountNumber:    _str(json['bankAccountNumber'] ?? json['accountNumber']),
      ifscCode:             _str(json['ifscCode'] ?? json['ifsc']),
      bankName:             _str(json['bankName']),
      accountHolderName:    _str(json['accountHolderName']),
      businessType:         _str(json['businessType']),
      vendorType:           _str(json['vendorType']),
      status:               _str(json['status']),
      planType:             _str(json['planType'] ?? json['plan']),
      registrationDate:     _str(json['registrationDate'] ?? json['createdAt']),
      logoUrl:              _str(json['logoUrl'] ?? json['logo']),
      coverImageUrl:        _str(json['coverImageUrl'] ?? json['coverImage']),
      isActive:             _parseBool(json['isActive'] ?? json['active']),
      isOpen:               _parseBool(json['isOpen'] ?? json['open']),
      rating:               _parseDouble(json['rating']),
      totalOrders:          _parseInt(json['totalOrders'] ?? json['ordersCount']),
      description:          _str(json['description']),
      openTime:             _str(json['openTime'] ?? json['openingTime']),
      closeTime:            _str(json['closeTime'] ?? json['closingTime']),
      cuisineTypes:         json['cuisineTypes'] != null
          ? List<String>.from(json['cuisineTypes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (ownerName != null) 'ownerName': ownerName,
    if (vendorName != null) 'vendorName': vendorName,
    if (vendorRegisteredName != null) 'vendorRegisteredName': vendorRegisteredName,
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (alternatePhone != null) 'alternatePhone': alternatePhone,
    if (address != null) 'address': address,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (pincode != null) 'pincode': pincode,
    if (country != null) 'country': country,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (gstNumber != null) 'gstNumber': gstNumber,
    if (panNumber != null) 'panNumber': panNumber,
    if (fssaiNumber != null) 'fssaiNumber': fssaiNumber,
    if (bankAccountNumber != null) 'bankAccountNumber': bankAccountNumber,
    if (ifscCode != null) 'ifscCode': ifscCode,
    if (bankName != null) 'bankName': bankName,
    if (accountHolderName != null) 'accountHolderName': accountHolderName,
    if (businessType != null) 'businessType': businessType,
    if (vendorType != null) 'vendorType': vendorType,
    if (status != null) 'status': status,
    if (planType != null) 'planType': planType,
    if (registrationDate != null) 'registrationDate': registrationDate,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
    if (isActive != null) 'isActive': isActive,
    if (isOpen != null) 'isOpen': isOpen,
    if (rating != null) 'rating': rating,
    if (totalOrders != null) 'totalOrders': totalOrders,
    if (description != null) 'description': description,
    if (openTime != null) 'openTime': openTime,
    if (closeTime != null) 'closeTime': closeTime,
    if (cuisineTypes != null) 'cuisineTypes': cuisineTypes,
  };

  // ── Convenience getters ───────────────────────────────────────────────────────

  /// Best display name — prefers ownerName, falls back to vendorName / vendorRegisteredName
  String get displayName =>
      ownerName?.isNotEmpty == true ? ownerName! :
      vendorName?.isNotEmpty == true ? vendorName! :
      vendorRegisteredName ?? 'Vendor';

  /// Best display email
  String get displayEmail => email ?? '';

  /// Short address string: city, state
  String get shortAddress {
    final parts = [city, state].where((s) => s?.isNotEmpty == true).toList();
    return parts.join(', ');
  }

  /// Full address string
  String get fullAddress {
    final parts = [address, city, state, pincode, country]
        .where((s) => s?.isNotEmpty == true)
        .toList();
    return parts.join(', ');
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  static String? _str(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static bool? _parseBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    return val.toString().toLowerCase() == 'true';
  }

  @override
  String toString() => 'VendorModel(id: $id, ownerName: $ownerName, email: $email)';
}