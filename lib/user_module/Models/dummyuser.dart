class DummyUserProfile {
  String? userName;
  String? mobileNumber;
  String? city;
  String? language;

  String? ageGroup;
  String? area;

  String? educationLevel;
  String? fieldOfStudy;

  String? occupationType;
  String? occupationSubType;

  List<String> interests = [];
}

class ProfileCompletionService {
  static int calculate(DummyUserProfile user) {
    int score = 0;

    // Basic – 40%
    if (user.userName != null &&
        user.mobileNumber != null &&
        user.city != null &&
        user.language != null) {
      score += 40;
    }

    // Personal – 20%
    if (user.ageGroup != null && user.area != null) {
      score += 20;
    }

    // Education – 10%
    if (user.educationLevel != null && user.fieldOfStudy != null) {
      score += 10;
    }

    // Occupation – 15%
    if (user.occupationType != null &&
        user.occupationSubType != null) {
      score += 15;
    }

    // Interests – 15%
    if (user.interests.isNotEmpty) {
      score += 15;
    }

    return score;
  }
}
