// lib/Promotion&Marketing/Models.dart

class CampaignData {
  String? campaignId;
  String? name;
  String? goal;
  String? subGoal;
  List<String> mediums;
  List<String> audience;
  List<String> appScreens;
  String? callToAction;
  List<String> placements;
  List<String> appTypes;
  List<String> mediaTypes;
  MediaDurations mediaDurations;
  List<String> imagePrompts;
  List<String> aiGeneratedImages;
  String? videoFile;
  List<String> images;
  List<String> interests;
  String? areaType;
  String? areaValue;
  String? days;
  String? reach;
  String? investment;
  String? startDate;
  String? endDate;
  GoalConfig goalConfig;
  String? couponCode;
  String? websiteUrl;
  int? durationSeconds;

  CampaignData({
    this.campaignId,
    this.name,
    this.goal,
    this.subGoal,
    this.mediums = const [],
    this.audience = const [],
    this.appScreens = const [],
    this.callToAction,
    this.placements = const [],
    this.appTypes = const [],
    this.mediaTypes = const [],
    MediaDurations? mediaDurations,
    this.imagePrompts = const [],
    this.aiGeneratedImages = const [],
    this.videoFile,
    this.images = const [],
    this.interests = const [],
    this.areaType,
    this.areaValue,
    this.days,
    this.reach,
    this.investment,
    this.startDate,
    this.endDate,
    GoalConfig? goalConfig,
    this.couponCode,
    this.websiteUrl,
    this.durationSeconds,
  }) : mediaDurations = mediaDurations ?? MediaDurations(),
       goalConfig = goalConfig ?? GoalConfig();

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      campaignId: json['campaignId'],
      name: json['name'],
      goal: json['goal'],
      subGoal: json['subGoal'],
      mediums: List<String>.from(json['mediums'] ?? []),
      audience: List<String>.from(json['audience'] ?? []),
      appScreens: List<String>.from(json['appScreens'] ?? []),
      callToAction: json['callToAction'],
      placements: List<String>.from(json['placements'] ?? []),
      appTypes: List<String>.from(json['appTypes'] ?? []),
      mediaTypes: List<String>.from(json['mediaTypes'] ?? []),
      mediaDurations: MediaDurations.fromJson(json['mediaDurations'] ?? {}),
      imagePrompts: List<String>.from(json['imagePrompts'] ?? []),
      aiGeneratedImages: List<String>.from(json['aiGeneratedImages'] ?? []),
      videoFile: json['videoFile'],
      images: List<String>.from(json['images'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      areaType: json['areaType'],
      areaValue: json['areaValue'],
      days: json['days'],
      reach: json['reach'],
      investment: json['investment'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      goalConfig: GoalConfig.fromJson(json['goalConfig'] ?? {}),
      couponCode: json['couponCode'],
      websiteUrl: json['websiteUrl'],
      durationSeconds: json['durationSeconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaignId': campaignId,
      'name': name,
      'goal': goal,
      'subGoal': subGoal,
      'mediums': mediums,
      'audience': audience,
      'appScreens': appScreens,
      'callToAction': callToAction,
      'placements': placements,
      'appTypes': appTypes,
      'mediaTypes': mediaTypes,
      'mediaDurations': mediaDurations.toJson(),
      'imagePrompts': imagePrompts,
      'aiGeneratedImages': aiGeneratedImages,
      'videoFile': videoFile,
      'images': images,
      'interests': interests,
      'areaType': areaType,
      'areaValue': areaValue,
      'days': days,
      'reach': reach,
      'investment': investment,
      'startDate': startDate,
      'endDate': endDate,
      'goalConfig': goalConfig.toJson(),
      'couponCode': couponCode,
      'websiteUrl': websiteUrl,
      'durationSeconds': durationSeconds,
    };
  }

  CampaignData copyWith({
    String? campaignId,
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
    MediaDurations? mediaDurations,
    List<String>? imagePrompts,
    List<String>? aiGeneratedImages,
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
    GoalConfig? goalConfig,
    String? couponCode,
    String? websiteUrl,
    int? durationSeconds,
  }) {
    return CampaignData(
      campaignId: campaignId ?? this.campaignId,
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
      imagePrompts: imagePrompts ?? this.imagePrompts,
      aiGeneratedImages: aiGeneratedImages ?? this.aiGeneratedImages,
      videoFile: videoFile ?? this.videoFile,
      images: images ?? this.images,
      interests: interests ?? this.interests,
      areaType: areaType ?? this.areaType,
      areaValue: areaValue ?? this.areaValue,
      days: days ?? this.days,
      reach: reach ?? this.reach,
      investment: investment ?? this.investment,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goalConfig: goalConfig ?? this.goalConfig,
      couponCode: couponCode ?? this.couponCode,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

class MediaDurations {
  String? text;
  String? image;
  String? video;

  MediaDurations({this.text, this.image, this.video});

  factory MediaDurations.fromJson(Map<String, dynamic> json) {
    return MediaDurations(
      text: json['text'],
      image: json['image'],
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'image': image, 'video': video};
  }
}

class GoalConfig {
  LeadsConfig? leads;
  BrandingConfig? branding;
  DiscountConfig? discount;

  GoalConfig({this.leads, this.branding, this.discount});

  factory GoalConfig.fromJson(Map<String, dynamic> json) {
    return GoalConfig(
      leads: json['leads'] != null ? LeadsConfig.fromJson(json['leads']) : null,
      branding: json['branding'] != null
          ? BrandingConfig.fromJson(json['branding'])
          : null,
      discount: json['discount'] != null
          ? DiscountConfig.fromJson(json['discount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leads': leads?.toJson(),
      'branding': branding?.toJson(),
      'discount': discount?.toJson(),
    };
  }

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
  String? leadSource;
  String? ctaType;
  String? contactName;
  String? contactMobile;
  String? serviceInterest;
  String? gender;
  List<int>? ageRange;
  List<Location>? locations;
  List<String>? interests;
  String? followUpDate;

  LeadsConfig({
    this.leadSource,
    this.ctaType,
    this.contactName,
    this.contactMobile,
    this.serviceInterest,
    this.gender,
    this.ageRange,
    this.locations,
    this.interests,
    this.followUpDate,
  });

  factory LeadsConfig.fromJson(Map<String, dynamic> json) {
    return LeadsConfig(
      leadSource: json['leadSource'],
      ctaType: json['ctaType'],
      contactName: json['contactName'],
      contactMobile: json['contactMobile'],
      serviceInterest: json['serviceInterest'],
      gender: json['gender'],
      ageRange: json['ageRange'] != null
          ? List<int>.from(json['ageRange'])
          : null,
      locations: json['locations'] != null
          ? (json['locations'] as List)
                .map((e) => Location.fromJson(e))
                .toList()
          : null,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      followUpDate: json['followUpDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leadSource': leadSource,
      'ctaType': ctaType,
      'contactName': contactName,
      'contactMobile': contactMobile,
      'serviceInterest': serviceInterest,
      'gender': gender,
      'ageRange': ageRange,
      'locations': locations?.map((e) => e.toJson()).toList(),
      'interests': interests,
      'followUpDate': followUpDate,
    };
  }

  LeadsConfig copyWith({
    String? leadSource,
    String? ctaType,
    String? contactName,
    String? contactMobile,
    String? serviceInterest,
    String? gender,
    List<int>? ageRange,
    List<Location>? locations,
    List<String>? interests,
    String? followUpDate,
  }) {
    return LeadsConfig(
      leadSource: leadSource ?? this.leadSource,
      ctaType: ctaType ?? this.ctaType,
      contactName: contactName ?? this.contactName,
      contactMobile: contactMobile ?? this.contactMobile,
      serviceInterest: serviceInterest ?? this.serviceInterest,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      locations: locations ?? this.locations,
      interests: interests ?? this.interests,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }
}

class BrandingConfig {
  String? brandName;
  String? subGoal;
  String? contentType;
  String? callToAction;
  String? areaRadius;

  BrandingConfig({
    this.brandName,
    this.subGoal,
    this.contentType,
    this.callToAction,
    this.areaRadius,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      brandName: json['brandName'],
      subGoal: json['subGoal'],
      contentType: json['contentType'],
      callToAction: json['callToAction'],
      areaRadius: json['areaRadius'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'subGoal': subGoal,
      'contentType': contentType,
      'callToAction': callToAction,
      'areaRadius': areaRadius,
    };
  }
}

class DiscountConfig {
  String? applicableOn;
  List<MenuItem>? selectedItems;
  String? discountType;
  String? discountValue;
  String? validDays;
  String? timeSlot;
  String? startTime;
  String? endTime;
  String? timeCategory;
  String? couponCode;
  String? minimumOrderValue;
  String? couponType;
  String? startDate;
  String? endDate;

  DiscountConfig({
    this.applicableOn,
    this.selectedItems,
    this.discountType,
    this.discountValue,
    this.validDays,
    this.timeSlot,
    this.startTime,
    this.endTime,
    this.timeCategory,
    this.couponCode,
    this.minimumOrderValue,
    this.couponType,
    this.startDate,
    this.endDate,
  });

  factory DiscountConfig.fromJson(Map<String, dynamic> json) {
    return DiscountConfig(
      applicableOn: json['applicableOn'],
      selectedItems: json['selectedItems'] != null
          ? (json['selectedItems'] as List)
                .map((e) => MenuItem.fromJson(e))
                .toList()
          : null,
      discountType: json['discountType'],
      discountValue: json['discountValue'],
      validDays: json['validDays'],
      timeSlot: json['timeSlot'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      timeCategory: json['timeCategory'],
      couponCode: json['couponCode'],
      minimumOrderValue: json['minimumOrderValue'],
      couponType: json['couponType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicableOn': applicableOn,
      'selectedItems': selectedItems?.map((e) => e.toJson()).toList(),
      'discountType': discountType,
      'discountValue': discountValue,
      'validDays': validDays,
      'timeSlot': timeSlot,
      'startTime': startTime,
      'endTime': endTime,
      'timeCategory': timeCategory,
      'couponCode': couponCode,
      'minimumOrderValue': minimumOrderValue,
      'couponType': couponType,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  DiscountConfig copyWith({
    String? applicableOn,
    List<MenuItem>? selectedItems,
    String? discountType,
    String? discountValue,
    String? validDays,
    String? timeSlot,
    String? startTime,
    String? endTime,
    String? timeCategory,
    String? couponCode,
    String? minimumOrderValue,
    String? couponType,
    String? startDate,
    String? endDate,
  }) {
    return DiscountConfig(
      applicableOn: applicableOn ?? this.applicableOn,
      selectedItems: selectedItems ?? this.selectedItems,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      validDays: validDays ?? this.validDays,
      timeSlot: timeSlot ?? this.timeSlot,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeCategory: timeCategory ?? this.timeCategory,
      couponCode: couponCode ?? this.couponCode,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      couponType: couponType ?? this.couponType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class MenuItem {
  int? id;
  String? name;
  String? category;
  double? price;
  String? image;
  String? tag;
  String? menuStatus;
  bool? selected;
  String? discountType;
  String? discountValue;

  MenuItem({
    this.id,
    this.name,
    this.category,
    this.price,
    this.image,
    this.tag,
    this.menuStatus,
    this.selected,
    this.discountType,
    this.discountValue,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price']?.toDouble(),
      image: json['image'],
      tag: json['tag'],
      menuStatus: json['menuStatus'],
      selected: json['selected'],
      discountType: json['discountType'],
      discountValue: json['discountValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'tag': tag,
      'menuStatus': menuStatus,
      'selected': selected,
      'discountType': discountType,
      'discountValue': discountValue,
    };
  }
}

class Location {
  String? placeId;
  String? name;
  double? latitude;
  double? longitude;

  Location({this.placeId, this.name, this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      placeId: json['placeId'],
      name: json['name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Screen {
  int? id;
  String? name;
  String? deviceId;
  String? resolution;
  String? screenSize;
  String? location;
  String? screenStatus;

  Screen({
    this.id,
    this.name,
    this.deviceId,
    this.resolution,
    this.screenSize,
    this.location,
    this.screenStatus,
  });

  factory Screen.fromJson(Map<String, dynamic> json) {
    return Screen(
      id: json['id'],
      name: json['name'],
      deviceId: json['deviceId'],
      resolution: json['resolution'],
      screenSize: json['screenSize'],
      location: json['location'],
      screenStatus: json['screenStatus'],
    );
  }
}
