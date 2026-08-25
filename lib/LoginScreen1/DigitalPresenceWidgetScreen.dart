import 'package:flutter/material.dart';

class DigitalPresenceWidget extends StatelessWidget {
  const DigitalPresenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': 'Stronger Digital Identity',
        'desc':
            'A strong digital identity builds trust, credibility, and influence in the online world.',
        'icon': Icons.badge, // Changed from Icons.identity
      },
      {
        'title': 'Higher Profit',
        'desc':
            'With intelligent strategies and optimized operations, your business can unlock higher profitability.',
        'icon': Icons.trending_up,
      },
      {
        'title': 'Smarter Growth',
        'desc':
            'Scalable systems, well-planned frameworks, and accurate market insights help businesses grow steadily.',
        'icon': Icons.insights,
      },
      {
        'title': 'Enhanced Customer Experience',
        'desc': 'A delightful customer journey creates loyalty and retention.',
        'icon': Icons.thumb_up,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'What Maamaas Brings to Your Business',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Transform your business with our powerful solutions designed to elevate your digital brand and deliver meaningful, measurable growth.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        section['icon'] as IconData,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section['desc'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
