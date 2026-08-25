import 'package:flutter/material.dart';

class AboutMaamaasWidget extends StatelessWidget {
  const AboutMaamaasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'POS Billing Platform',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ABOUT MAAMAAS',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(width: 80, height: 3, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Maamaas is a modern POS billing software designed for restaurants, cafes, cloud kitchens and retail stores. It helps manage orders, billing, inventory and sales with a simple dashboard.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our platform allows businesses to automate billing, track inventory, manage staff and analyze sales data to grow faster and operate efficiently.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildFeatureItem('10+ Years POS Software Experience'),
          const SizedBox(height: 12),
          _buildFeatureItem('500+ Restaurants Using Maamaas POS'),
          const SizedBox(height: 12),
          _buildFeatureItem('Fast Billing & Smart Inventory'),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1556745757-8d76bdb6984b',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
