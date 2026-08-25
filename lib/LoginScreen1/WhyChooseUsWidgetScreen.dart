import 'package:flutter/material.dart';

class WhyChooseUsWidget extends StatelessWidget {
  const WhyChooseUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Lightning Fast Billing',
        'desc':
            'Process transactions in seconds with our optimized billing engine.',
        'icon': Icons.flash_on,
      },
      {
        'title': 'Smart Order Management',
        'desc':
            'Track orders from kitchen to table with real-time status updates.',
        'icon': Icons.shopping_cart,
      },
      {
        'title': 'Cloud Based Access',
        'desc': 'Access your POS from anywhere, any device.',
        'icon': Icons.cloud_queue,
      },
      {
        'title': 'AI Sales Insights',
        'desc': 'Get AI-powered recommendations to boost sales.',
        'icon': Icons.auto_awesome,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Built for Modern Restaurants',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 3, color: Colors.orange),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        color: Colors.orange,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
