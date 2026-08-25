import 'package:flutter/material.dart';

class PricingSectionWidget extends StatelessWidget {
  const PricingSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final addons = [
      {
        'title': 'Chef Management',
        'desc': 'Kitchen order display & chef assignments',
      },
      {
        'title': 'Inventory Management',
        'desc': 'Stock tracking & purchase orders',
      },
      {'title': 'Team Management', 'desc': 'Staff scheduling & permissions'},
      {
        'title': 'Sales Management',
        'desc': 'Advanced sales tracking & targets',
      },
      {'title': 'Service Management', 'desc': 'Rider assignment & tracking'},
    ];

    final orderTypes = [
      {'title': 'Delivery Orders', 'desc': 'Doorstep delivery workflows'},
      {'title': 'Dine-out Orders', 'desc': 'Table service & billing'},
      {'title': 'Catering Orders', 'desc': 'Bulk & event order workflows'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Simple Pricing',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'One powerful base plan. Add only what you need.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Base Plan Card
          Container(
            padding: const EdgeInsets.all(24),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Base Plan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const Text(
                      '₹1/year',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Everything to Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureItem('Dashboard'),
                    _FeatureItem('Business Profile'),
                    _FeatureItem('Settings and Controls'),
                    _FeatureItem('Products and Prices'),
                    _FeatureItem('Order Management'),
                    _FeatureItem('Chef Management'),
                    _FeatureItem('Team Management'),
                    _FeatureItem('Accounting Management'),
                    _FeatureItem('Promotions and Marketing'),
                    _FeatureItem('Reports Management'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Get Started →'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Add-ons Card
          Container(
            padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Add-on Modules',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scale As You Grow',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Feature Add-ons',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                ...addons.map(
                  (addon) =>
                      _AddonItem(title: addon['title']!, desc: addon['desc']!),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Types',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                ...orderTypes.map(
                  (type) =>
                      _AddonItem(title: type['title']!, desc: type['desc']!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _AddonItem extends StatelessWidget {
  final String title;
  final String desc;
  const _AddonItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
