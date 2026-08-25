import 'package:flutter/material.dart';

class FoodRegistrationIntro extends StatelessWidget {
  final VoidCallback onBeginRegistration;

  const FoodRegistrationIntro({super.key, required this.onBeginRegistration});

  @override
  Widget build(BuildContext context) {
    final userEmail = _getUserEmail();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade600, Colors.purple.shade800],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VENDOR PORTAL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                            letterSpacing: 1,
                          ),
                        ),
                        if (userEmail != null && userEmail.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome to Maamaas',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Complete your vendor registration to unlock the full platform.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: onBeginRegistration,
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFFF97316,
                                ).withOpacity(0.4),
                              ).copyWith(
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return Colors.white.withOpacity(0.1);
                                      }
                                      return null;
                                    }),
                              ),
                          child: const Text(
                            'Start registration →',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _getUserEmail() {
    // TODO: Implement getting user email from SharedPreferences
    return null;
  }
}
