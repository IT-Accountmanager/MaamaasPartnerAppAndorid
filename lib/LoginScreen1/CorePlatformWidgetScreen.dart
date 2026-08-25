import 'package:flutter/material.dart';

class CorePlatformWidget extends StatelessWidget {
  const CorePlatformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Strong Digital Presence',
        'points': ['Online storefront', 'Marketplace visibility', 'Reach nearby customers'],
        'icon': Icons.language,
      },
      {
        'title': 'Better Profit Control',
        'points': ['Track sales clearly', 'Control costs', 'Smart reporting'],
        'icon': Icons.trending_up,
      },
      {
        'title': 'Business Growth Insights',
        'points': ['Data dashboards', 'Reports & trends', 'Performance tracking'],
        'icon': Icons.bar_chart,
      },
      {
        'title': 'Customer Experience',
        'points': ['Fast billing', 'Live order updates', 'Ratings & feedback'],
        'icon': Icons.star_border,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Why Choose MAAMAAS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Everything you need to digitize and grow your food business.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(feature['points'] as List<String>).map(
                            (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  point,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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