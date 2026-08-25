import 'package:flutter/material.dart';
import 'package:maamaaspartner/user_module/API/Auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/user_account.dart';

enum ProfileSectionType { basic, personal, education, occupation, interests }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ---------------- STATE ----------------
  String ageGroup = "26–35";
  String area = "";
  String language = "English";

  String educationField = "OTHER";

  String occupation = "Job Seeker";
  String subType = "";

  int completion = 0;
  bool isLoading = false;

  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  final selectedInterests = <String>{};

  final educationItems = ["SCIENCE", "COMMERCE", "ENGINEERING", "IT", "OTHER"];

  final List<String> interests = [
    "JOBS",
    "FOOD",
    "EDUCATION",
    "OFFERS",
    "REAL_ESTATE",
    "ONLINE_COURSES",
    "BAKERY",
    "HEALTH",
    "TRAVEL",
    "ENTERTAINMENT",
  ];

  final Map<String, List<String>> occupationOptions = {
    "Student": ["School", "College"],
    "Employed": ["IT", "Government", "Private"],
    "Freelancer": ["Design", "Tech", "Marketing"],
    "Entrepreneur": ["Startup", "Business"],
    "Homemaker": ["Household"],
    "Job Seeker": ["Fresher", "Experienced"],
  };

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    cityCtrl.dispose();
    areaCtrl.dispose();
    super.dispose();
  }

  // ---------------- HELPERS ----------------
  Future<int> _userId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId')!;
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final data = await AuthService.getAccount();
      setState(() {
        cityCtrl.text = data.city ?? "";
        areaCtrl.text = data.area ?? "";
        area = data.area ?? "";
        language = data.languagePreference ?? "English";
        completion = data.completionPercentage ?? 0;
        selectedInterests.addAll(data.interests ?? []);
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- SAVE METHODS ----------------
  Future<void> saveBasic() async {
    setState(() => isLoading = true);
    try {
      await AuthService.saveAccount(
        UserAccount(
          userId: await _userId(),
          city: cityCtrl.text,
          languagePreference: language,
        ),
      );
      _toast("Basic profile saved", Colors.green);
      await loadProfile(); // Refresh completion percentage
    } catch (e) {
      _toast("Failed to save", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> savePersonal() async {
    setState(() => isLoading = true);
    try {
      await AuthService.saveAccount(
        UserAccount(
          userId: await _userId(),
          ageGroup: mapAgeGroup(ageGroup),
          area: areaCtrl.text,
        ),
      );
      _toast("Personal profile saved", Colors.green);
      await loadProfile();
    } catch (e) {
      _toast("Failed to save", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveEducation() async {
    setState(() => isLoading = true);
    try {
      await AuthService.saveAccount(
        UserAccount(userId: await _userId(), fieldOfStudy: educationField),
      );
      _toast("Education saved", Colors.green);
      await loadProfile();
    } catch (e) {
      _toast("Failed to save", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveOccupation() async {
    setState(() => isLoading = true);
    try {
      await AuthService.saveAccount(
        UserAccount(
          userId: await _userId(),
          occupationType: mapOccupation(occupation),
          occupationSubField: subType,
        ),
      );
      _toast("Occupation saved", Colors.green);
      await loadProfile();
    } catch (e) {
      _toast("Failed to save", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveInterests() async {
    setState(() => isLoading = true);
    try {
      await AuthService.saveAccount(
        UserAccount(
          userId: await _userId(),
          interests: selectedInterests.toList(),
        ),
      );
      _toast("Interests saved", Colors.green);
      await loadProfile();
    } catch (e) {
      _toast("Failed to save", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ---------------- MAPPERS ----------------
  String mapAgeGroup(String ui) {
    switch (ui) {
      case "18–25":
        return "AGE_18_25";
      case "26–35":
        return "AGE_26_35";
      case "36–45":
        return "AGE_36_45";
      case "45+":
        return "AGE_45_PLUS";
      default:
        return "AGE_26_35";
    }
  }

  String mapOccupation(String ui) {
    switch (ui) {
      case "Student":
        return "STUDENT";
      case "Employed":
        return "EMPLOYED";
      case "Freelancer":
        return "FREELANCER";
      case "Entrepreneur":
        return "ENTREPRENEUR";
      case "Homemaker":
        return "HOMEMAKER";
      default:
        return "JOB_SEEKER";
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Your Profile",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : Column(
              children: [
                // Progress Banner
                _completionCard(),

                // Profile Sections
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionCard(
                        title: "Basic Profile",
                        icon: Icons.person_outline,
                        color: Colors.blue.shade50,
                        iconColor: Colors.blue,
                        child: _basicForm(),
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Personal Profile",
                        icon: Icons.badge_outlined,
                        color: Colors.green.shade50,
                        iconColor: Colors.green,
                        child: _personalForm(),
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Education",
                        icon: Icons.school_outlined,
                        color: Colors.orange.shade50,
                        iconColor: Colors.orange,
                        child: _educationForm(),
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Occupation",
                        icon: Icons.work_outline,
                        color: Colors.purple.shade50,
                        iconColor: Colors.purple,
                        child: _occupationForm(),
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Interests",
                        icon: Icons.favorite_outline,
                        color: Colors.red.shade50,
                        iconColor: Colors.red,
                        child: _interestsForm(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                completion < 100 ? _rewardBanner() : const SizedBox.shrink(),
              ],
            ),
    );
  }

  Widget _completionCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade800],
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Completion",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$completion%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completion / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completion == 100
                    ? Icons.check_circle_outline
                    : Icons.trending_up_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
        if (completion < 100) ...[
          const SizedBox(height: 12),
          Text(
            "Complete all sections to unlock rewards!",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Widget child,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.expand_more, size: 20),
        ),
        children: [
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    ),
  );

  // ---------------- FORMS ----------------
  Widget _basicForm() => Column(
    children: [
      cleanTextField(controller: cityCtrl, hint: "City"),
      const SizedBox(height: 16),
      cleanDropdown(
        hint: "Language Preference",
        value: language,
        items: const ["English", "Hindi", "Telugu"],
        onChanged: (v) => setState(() => language = v!),
      ),
      const SizedBox(height: 20),
      saveButton(saveBasic),
    ],
  );

  Widget _personalForm() => Column(
    children: [
      cleanDropdown(
        hint: "Age Group",
        value: ageGroup,
        items: const ["18–25", "26–35", "36–45", "45+"],
        onChanged: (v) => setState(() => ageGroup = v!),
      ),
      const SizedBox(height: 16),
      cleanTextField(controller: areaCtrl, hint: "Area/Locality"),
      const SizedBox(height: 20),
      saveButton(savePersonal),
    ],
  );

  Widget _educationForm() => Column(
    children: [
      cleanDropdown(
        hint: "Field of Study",
        value: educationField,
        items: educationItems,
        onChanged: (v) => setState(() => educationField = v!),
      ),
      const SizedBox(height: 20),
      saveButton(saveEducation),
    ],
  );

  Widget _occupationForm() => Column(
    children: [
      cleanDropdown(
        hint: "Occupation Type",
        value: occupation,
        items: occupationOptions.keys.toList(),
        onChanged: (v) {
          setState(() {
            occupation = v!;
            subType = "";
          });
        },
      ),
      const SizedBox(height: 16),
      cleanDropdown(
        hint: "Sub Category",
        value: subType.isEmpty ? null : subType,
        items: occupationOptions[occupation] ?? [],
        onChanged: (v) => setState(() => subType = v!),
      ),
      const SizedBox(height: 20),
      saveButton(saveOccupation),
    ],
  );

  Widget _interestsForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Select your interests:",
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: interests.map((e) {
          return FilterChip(
            label: Text(
              e.replaceAll("_", " "),
              style: TextStyle(
                color: selectedInterests.contains(e)
                    ? Colors.white
                    : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: selectedInterests.contains(e),
            selectedColor: Colors.deepPurple,
            checkmarkColor: Colors.white,
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selectedInterests.contains(e)
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
              ),
            ),
            onSelected: (v) {
              setState(() {
                v ? selectedInterests.add(e) : selectedInterests.remove(e);
              });
            },
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      saveButton(saveInterests),
    ],
  );

  Widget _rewardBanner() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.amber.shade600, Colors.orange.shade600],
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Row(
      children: [
        Icon(Icons.celebration_outlined, color: Colors.white, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete Profile & Get ₹50",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Finish all sections to unlock your reward",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward, color: Colors.white),
      ],
    ),
  );
}

/* ---------------- REUSABLE UI ---------------- */

Widget cleanTextField({
  required TextEditingController controller,
  required String hint,
}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),
  );
}

Widget cleanDropdown({
  required String hint,
  required List<String> items,
  String? value,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: items.contains(value) ? value : null,
    items: items
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 15)),
          ),
        )
        .toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),
    icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    style: const TextStyle(color: Colors.black87),
  );
}

Widget saveButton(VoidCallback onPressed) => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    child: const Text(
      "Save Changes",
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
  ),
);
