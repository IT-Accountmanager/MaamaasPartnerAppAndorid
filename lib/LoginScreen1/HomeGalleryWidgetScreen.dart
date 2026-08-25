import 'package:flutter/material.dart';

class HomeGalleryWidget extends StatelessWidget {
  const HomeGalleryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': 'Food & Beverages',
        'desc':
            'From fine dining and quick-service restaurants to cafes, bakeries, juice bars, and specialty food stores, Maamaas empowers you to showcase your menu with stunning visuals.',
        'icon': Icons.restaurant,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            'Everything You Need, One Tap Away',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...cards.map(
            (card) => Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: Colors.grey.shade200,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1556745757-8d76bdb6984b',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              card['icon'] as IconData,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              card['title'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          card['desc'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('Book A Demo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
