import 'package:flutter/cupertino.dart';

class CampaignFormData {
  String campaignId;
  String name;
  String goal;
  String subGoal;
  List<String> mediums;
  List<String> audience;
  List<String> appScreens;
  String callToAction;
  List<String> placements;
  List<String> appTypes;
  List<String> mediaTypes;
  Map<String, String> mediaDurations;
  Map<String, String> mediaDescriptions;
  String? videoFile;
  List<String> images;
  List<String> interests;
  String areaType;
  String areaValue;
  String days;
  String reach;
  String investment;
  String startDate;
  String endDate;
  String couponCode;
  int? durationSeconds;
  String? websiteUrl;

  GoalConfig goalConfig;

  CampaignFormData({
    String? campaignId,
    this.name = '',
    this.goal = '',
    this.subGoal = '',
    this.mediums = const [],
    this.audience = const [],
    this.appScreens = const [],
    this.callToAction = '',
    this.placements = const [],
    this.appTypes = const [],
    this.mediaTypes = const [],
    Map<String, String>? mediaDurations,
    Map<String, String>? mediaDescriptions,
    this.videoFile,
    this.images = const [],
    this.interests = const [],
    this.areaType = 'country',
    this.areaValue = '',
    this.days = '',
    this.reach = '',
    this.investment = '',
    this.startDate = '',
    this.endDate = '',
    this.couponCode = '',
    this.durationSeconds,
    this.websiteUrl,
    GoalConfig? goalConfig,
  }) : campaignId =
           campaignId ??
           'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
       mediaDurations =
           mediaDurations ?? {'text': '', 'image': '', 'video': ''},
       mediaDescriptions = mediaDescriptions ?? {},
       goalConfig = goalConfig ?? GoalConfig();

  CampaignFormData copyWith({
    String? name,
    String? goal,
    String? subGoal,
    List<String>? mediums,
    List<String>? audience,
    List<String>? appScreens,
    String? callToAction,
    List<String>? placements,
    List<String>? appTypes,
    List<String>? mediaTypes,
    Map<String, String>? mediaDurations,
    Map<String, String>? mediaDescriptions,
    String? videoFile,
    List<String>? images,
    List<String>? interests,
    String? areaType,
    String? areaValue,
    String? days,
    String? reach,
    String? investment,
    String? startDate,
    String? endDate,
    String? couponCode,
    int? durationSeconds,
    String? websiteUrl,
    GoalConfig? goalConfig,
    bool clearVideo = false,
  }) {
    return CampaignFormData(
      campaignId: campaignId,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      subGoal: subGoal ?? this.subGoal,
      mediums: mediums ?? this.mediums,
      audience: audience ?? this.audience,
      appScreens: appScreens ?? this.appScreens,
      callToAction: callToAction ?? this.callToAction,
      placements: placements ?? this.placements,
      appTypes: appTypes ?? this.appTypes,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      mediaDurations: mediaDurations ?? this.mediaDurations,
      mediaDescriptions: mediaDescriptions ?? this.mediaDescriptions,
      videoFile: clearVideo ? null : (videoFile ?? this.videoFile),
      images: images ?? this.images,
      interests: interests ?? this.interests,
      areaType: areaType ?? this.areaType,
      areaValue: areaValue ?? this.areaValue,
      days: days ?? this.days,
      reach: reach ?? this.reach,
      investment: investment ?? this.investment,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      couponCode: couponCode ?? this.couponCode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      goalConfig: goalConfig ?? this.goalConfig,
    );
  }
}

class GoalConfig {
  LeadsConfig leads;
  BrandingConfig branding;
  DiscountConfig discount;

  GoalConfig({
    LeadsConfig? leads,
    BrandingConfig? branding,
    DiscountConfig? discount,
  }) : leads = leads ?? LeadsConfig(),
       branding = branding ?? BrandingConfig(),
       discount = discount ?? DiscountConfig();

  GoalConfig copyWith({
    LeadsConfig? leads,
    BrandingConfig? branding,
    DiscountConfig? discount,
  }) {
    return GoalConfig(
      leads: leads ?? this.leads,
      branding: branding ?? this.branding,
      discount: discount ?? this.discount,
    );
  }
}

class LeadsConfig {
  String gender;
  List<int> ageRange;
  List<Map<String, dynamic>> locations;
  List<String> interests;
  String contactName;
  String contactMobile;

  LeadsConfig({
    this.gender = '',
    List<int>? ageRange,
    this.locations = const [],
    this.interests = const [],
    this.contactName = '',
    this.contactMobile = '',
  }) : ageRange = ageRange ?? [18, 60];

  LeadsConfig copyWith({
    String? gender,
    List<int>? ageRange,
    List<Map<String, dynamic>>? locations,
    List<String>? interests,
    String? contactName,
    String? contactMobile,
  }) {
    return LeadsConfig(
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      locations: locations ?? this.locations,
      interests: interests ?? this.interests,
      contactName: contactName ?? this.contactName,
      contactMobile: contactMobile ?? this.contactMobile,
    );
  }
}

class BrandingConfig {
  String brandName;
  String subGoal;
  String contentType;
  String callToAction;

  BrandingConfig({
    this.brandName = '',
    this.subGoal = '',
    this.contentType = '',
    this.callToAction = '',
  });
}

class DiscountConfig {
  String applicableOn;
  List<Map<String, dynamic>> selectedItems;
  String discountType;
  String discountValue;
  String validDays;
  String timeSlot;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String timeCategory;
  String couponCode;
  String couponType;
  String minimumOrderValue;
  String discountTarget;

  DiscountConfig({
    this.applicableOn = '',
    this.selectedItems = const [],
    this.discountType = 'percentage',
    this.discountValue = '',
    this.validDays = '',
    this.timeSlot = '',
    this.startDate = '',
    this.endDate = '',
    this.startTime = '',
    this.endTime = '',
    this.timeCategory = '',
    this.couponCode = '',
    this.couponType = '',
    this.minimumOrderValue = '',
    this.discountTarget = '',
  });

  DiscountConfig copyWith({
    String? discountType,
    String? discountValue,
    String? startDate,
    String? endDate,
    String? startTime,
    String? endTime,
    String? timeCategory,
    String? couponCode,
    String? couponType,
    String? minimumOrderValue,
    String? discountTarget,
    List<Map<String, dynamic>>? selectedItems,
  }) {
    return DiscountConfig(
      applicableOn: applicableOn,
      selectedItems: selectedItems ?? this.selectedItems,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      validDays: validDays,
      timeSlot: timeSlot,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeCategory: timeCategory ?? this.timeCategory,
      couponCode: couponCode ?? this.couponCode,
      couponType: couponType ?? this.couponType,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      discountTarget: discountTarget ?? this.discountTarget,
    );
  }
}

class GoalOption {
  final String value;
  final String label;
  const GoalOption({required this.value, required this.label});
}

class SubGoalOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const SubGoalOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}
