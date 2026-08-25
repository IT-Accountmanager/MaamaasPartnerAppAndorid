class CampaignRequest {
  final int? id;
  final String campaignName;
  final String? description;
  final String goal;
  final String? subGoal;
  final String medium;
  final String? callToAction;
  final String startDate;
  final String endDate;
  final String? paymentStatus;
  final String? appType;
  final String? status;
  final String customerId;
  final int? vendorId; // Add vendorId
  final String? imageUrl;
  final String? deepLink;
  final String createdAt;
  final double? totalBudget;
  final double? calculatedAmount;
  final List<String>? interests;
  final String? city;
  final double? centerLatitude;
  final double? centerLongitude;
  final int? radiusKm;
  final int? dishId;
  final String? mobileNumber; // add this

  final String? mediaType;
  final String? addDisplayPosition;
  final String? resolution;
  final double? discountPercentage;
  final int? viewsCount;
  final int? likesCount;
  final int? sharesCount;
  final String? gender;
  final int? minAge;
  final int? maxAge;
  final List<String>? targetAudience;
  final String? timeCategory;
  final List<Map<String, dynamic>>? selectedMenuItems;
  final List<int>? dishIds;
  final List<double>? dishDiscounts;

  CampaignRequest({
    this.id,
    required this.campaignName,
    this.description,
    required this.goal,
    this.subGoal,
    required this.medium,
    this.callToAction,
    required this.startDate,
    required this.endDate,
    this.paymentStatus,
    this.appType,
    this.status,
    this.mobileNumber,

    required this.customerId,
    this.vendorId, // Add vendorId
    this.imageUrl,
    this.deepLink,
    required this.createdAt,
    this.totalBudget,
    this.calculatedAmount,
    this.interests,
    this.city,
    this.centerLatitude,
    this.centerLongitude,
    this.radiusKm,
    this.dishId,
    this.mediaType,
    this.addDisplayPosition,
    this.resolution,
    this.discountPercentage,
    this.viewsCount,
    this.likesCount,
    this.sharesCount,
    this.gender,
    this.minAge,
    this.maxAge,
    this.targetAudience,
    this.timeCategory,
    this.selectedMenuItems,
    this.dishIds,
    this.dishDiscounts,
  });

  factory CampaignRequest.fromJson(Map<String, dynamic> json) {
    return CampaignRequest(
      id: json['id'],
      campaignName: json['campaignName'] ?? '',
      description: json['description'],
      goal: json['goal'] ?? '',
      subGoal: json['subGoal'],
      medium: json['medium'] ?? '',
      callToAction: json['callToAction'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      mobileNumber: json['mobileNumber'],

      paymentStatus: json['paymentStatus'],
      appType: json['appType'],
      status: json['status'],
      customerId: json['customerId'] ?? '',
      vendorId: json['vendorId'],
      imageUrl: json['imageUrl'],
      deepLink: json['mediaLink'],
      createdAt: json['createdAt'] ?? '',
      totalBudget: json['totalBudget']?.toDouble(),
      calculatedAmount: json['calculatedAmount']?.toDouble(),
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      city: json['city'],
      centerLatitude: json['centerLatitude']?.toDouble(),
      centerLongitude: json['centerLongitude']?.toDouble(),
      radiusKm: json['radiusKm'],
      dishId: json['dishId'],
      mediaType: json['mediaType'],
      addDisplayPosition: json['addDisplayPosition'],
      resolution: json['resolution'],
      discountPercentage: json['discountPercentage']?.toDouble(),
      viewsCount: json['viewsCount'],
      likesCount: json['likesCount'],
      sharesCount: json['sharesCount'],
      gender: json['gender'],
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      targetAudience: json['targetAudience'] != null
          ? List<String>.from(json['targetAudience'])
          : null,
      timeCategory: json['timeCategory'],
      selectedMenuItems: json['selectedMenuItems'] != null
          ? List<Map<String, dynamic>>.from(json['selectedMenuItems'])
          : null,
      dishIds: json['dishIds'] != null ? List<int>.from(json['dishIds']) : null,
      dishDiscounts: json['dishDiscounts'] != null
          ? List<double>.from(json['dishDiscounts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignName': campaignName,
      'description': description,
      'goal': goal,
      'subGoal': subGoal,
      'medium': medium,
      'callToAction': callToAction,
      'startDate': startDate,
      'endDate': endDate,
      'paymentStatus': paymentStatus,
      'appType': appType,
      'status': status,
      'mobileNumber': mobileNumber,

      'customerId': customerId,
      'vendorId': vendorId,
      'imageUrl': imageUrl,
      'mediaLink': deepLink,
      'createdAt': createdAt,
      'totalBudget': totalBudget,
      'calculatedAmount': calculatedAmount,
      'interests': interests,
      'city': city,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radiusKm': radiusKm,
      'dishId': dishId,
      'mediaType': mediaType,
      'addDisplayPosition': addDisplayPosition,
      'resolution': resolution,
      'discountPercentage': discountPercentage,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'sharesCount': sharesCount,
      'gender': gender,
      'minAge': minAge,
      'maxAge': maxAge,
      'targetAudience': targetAudience,
      'timeCategory': timeCategory,
      'selectedMenuItems': selectedMenuItems,
      'dishIds': dishIds,
      'dishDiscounts': dishDiscounts,
    };
  }
}
