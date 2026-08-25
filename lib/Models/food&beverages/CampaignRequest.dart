

class CampaignRequest {
  final int? id;
  final String campaignName;
  final String? description;
  final String goal;
  final String medium;
  final String startDate;
  final String endDate;
  final String? paymentStatus;
  final String? appType;
  final String? status;
  final String customerId;
  final String? imageUrl;
  final String? deepLink; // or deepLink? check your API
  final String createdAt;
  final double? totalBudget;
  final double? calculatedAmount;
  final List<String>? interests;
  final String? city;
  final double? centerLatitude;
  final double? centerLongitude;
  final int? radiusKm; // or double?
  final int? dishId;
  final int? vendorId;
  final String? mediaType;
  final String? addDisplayPosition;
  final String? resolution;
  final double? discountPercentage;
  final int? viewsCount;   // ✅ NEW FIELD
  final int? likesCount;
  final int? sharesCount;


  CampaignRequest({
    this.id,
    required this.campaignName,
    this.description,
    required this.goal,
    required this.medium,
    required this.startDate,
    required this.endDate,
    this.paymentStatus,
    this.appType,
    this.status,
    required this.customerId,
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
    this.vendorId,
    this.mediaType,
    this.addDisplayPosition,
    this.resolution,
    this.discountPercentage,
    this.viewsCount, // ✅ Constructor
    this.likesCount,
    this.sharesCount,

  });

  factory CampaignRequest.fromJson(Map<String, dynamic> json) {
    return CampaignRequest(
      id: json['id'],
      campaignName: json['campaignName'] ?? '',
      description: json['description'],
      goal: json['goal'] ?? '',
      medium: json['medium'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      paymentStatus: json['paymentStatus'],
      appType: json['appType'],
      status: json['status'],
      customerId: json['customerId'] ?? '',
      imageUrl: json['imageUrl'],
      deepLink: json['mediaLink'], // or json['deepLink'] if that's the field
      createdAt: json['createdAt'] ?? '',
      totalBudget: json['totalBudget']?.toDouble(),
      calculatedAmount: json['calculatedAmount']?.toDouble(),
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      city: json['city'],
      centerLatitude: json['centerLatitude']?.toDouble(),
      centerLongitude: json['centerLongitude']?.toDouble(),
      radiusKm: json['radiusKm'], // if it's integer, keep as int
      dishId: json['dishId'],
      vendorId: json['vendorId'],
      mediaType: json['mediaType'],
      addDisplayPosition: json['addDisplayPosition'],
      resolution: json['resolution'],
      discountPercentage: json['discountPercentage']?.toDouble(),
      viewsCount: json['viewsCount'], // ✅ Parse from API
      likesCount: json['likesCount'], // ✅ Parse from API
      sharesCount: json['sharesCount'], // ✅ Parse from API


    );
  }
}