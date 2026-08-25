import 'package:flutter/material.dart';

class MaamaasBusinessWidget extends StatelessWidget {
  const MaamaasBusinessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': 'Trusted Digital Presence, Wider Reach',
        'desc':
            'Customers trust what they see online. A professional digital presence immediately improves credibility.',
        'icon': Icons.verified,
      },
      {
        'title': 'Clear, Easy, Cost-Effective',
        'desc':
            'Maamaas offers a simple yearly subscription plan. No complicated charges. No fluctuating costs.',
        'icon': Icons.money_off,
      },
      {
        'title': 'Digital Billing. Live Payments.',
        'desc':
            'Step into the future of business management with seamless digital billing.',
        'icon': Icons.payment,
      },
      {
        'title': 'Instant Order Alerts',
        'desc':
            'Stay connected to every customer moment — get instant alerts for orders.',
        'icon': Icons.notifications_active,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Digital Presence That Builds Trust & Expands Reach',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 3, color: Colors.orange),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            section['desc'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
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
