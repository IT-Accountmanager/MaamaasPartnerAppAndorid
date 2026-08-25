// models/user_account.dart
class UserAccount {
  final int userId;
  final String? gender;
  final String? ageGroup;
  final String? city;
  final String? area;
  final String? languagePreference;
  final String? educationLevel;
  final String? fieldOfStudy;
  final String? occupationType;
  final String? occupationSubField;
  final List<String>? interests;
  final int? completionPercentage;

  UserAccount({
    required this.userId,
    this.gender,
    this.ageGroup,
    this.city,
    this.area,
    this.languagePreference,
    this.educationLevel,
    this.fieldOfStudy,
    this.occupationType,
    this.occupationSubField,
    this.interests,
    this.completionPercentage,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      // id: json['id'],
      userId: json['userId'],
      gender: json['gender'],
      ageGroup: json['ageGroup'],
      city: json['city'],
      area: json['area'],
      languagePreference: json['languagePreference'],
      educationLevel: json['educationLevel'],
      fieldOfStudy: json['fieldOfStudy'],
      occupationType: json['occupationType'],
      occupationSubField: json['occupationSubField'],
      interests: List<String>.from(json['interests'] ?? []),
      completionPercentage: json['completionPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['userId'] = userId;
    if (gender != null) data['gender'] = gender;
    if (ageGroup != null) data['ageGroup'] = ageGroup;
    if (city != null) data['city'] = city;
    if (area != null) data['area'] = area;
    if (languagePreference != null) {
      data['languagePreference'] = languagePreference;
    }
    if (educationLevel != null) data['educationLevel'] = educationLevel;
    if (fieldOfStudy != null) data['fieldOfStudy'] = fieldOfStudy;
    if (occupationType != null) data['occupationType'] = occupationType;
    if (occupationSubField != null) {
      data['occupationSubField'] = occupationSubField;
    }
    if (interests != null) data['interests'] = interests;
    if (completionPercentage != null) {
      data['completionPercentage'] = completionPercentage;
    }

    return data;
  }
}
