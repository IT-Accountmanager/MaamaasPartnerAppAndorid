import 'package:flutter/material.dart';
import 'PromotionalModel.dart';

class CampaignConstants {
  static const List<GoalOption> goals = [
    GoalOption(value: 'leads', label: 'Leads'),
    GoalOption(value: 'branding', label: 'Branding'),
    GoalOption(value: 'discount', label: 'Discount'),
  ];

  static const Map<String, List<SubGoalOption>> subGoals = {
    'leads': [
      SubGoalOption(
        value: 'whatsapp_messages',
        label: 'Get more WhatsApp messages',
        description: 'Create an ad that includes the call-to-action button.',
        icon: Icons.chat,
        iconColor: Color(0xFF3d4451),
        iconBg: Color(0xFFF0F2F5),
      ),
      SubGoalOption(
        value: 'more_calls',
        label: 'Get more calls',
        description: '',
        icon: Icons.phone_in_talk,
        iconColor: Color(0xFF3d4451),
        iconBg: Color(0xFFF0F2F5),
      ),
      SubGoalOption(
        value: 'website_visitors',
        label: 'Get more website visitors',
        description: 'Create an ad to send people to your website.',
        icon: Icons.mouse,
        iconColor: Color(0xFF3d4451),
        iconBg: Color(0xFFF0F2F5),
      ),
      SubGoalOption(
        value: 'more_leads',
        label: 'Get more leads',
        description: 'Create an ad to request contact details.',
        icon: Icons.contact_page,
        iconColor: Color(0xFF3d4451),
        iconBg: Color(0xFFF0F2F5),
      ),
    ],
    'branding': [
      SubGoalOption(
        value: 'awareness',
        label: 'Brand Awareness',
        description: 'Introduce your brand to new audiences',
        icon: Icons.visibility,
        iconColor: Color(0xFF185FA5),
        iconBg: Color(0xFFE6F1FB),
      ),
      SubGoalOption(
        value: 'recall',
        label: 'Brand Recall',
        description: 'Stay top of mind with your audience',
        icon: Icons.campaign,
        iconColor: Color(0xFF3B6D11),
        iconBg: Color(0xFFEAF3DE),
      ),
      SubGoalOption(
        value: 'premium',
        label: 'Premium Positioning',
        description: 'Build a high-value brand perception',
        icon: Icons.workspace_premium,
        iconColor: Color(0xFF854F0B),
        iconBg: Color(0xFFFAEEDA),
      ),
    ],
    'discount': [
      SubGoalOption(
        value: 'new_customers',
        label: 'New Customers',
        description: 'Attract first-time buyers with deals',
        icon: Icons.people_alt,
        iconColor: Color(0xFF185FA5),
        iconBg: Color(0xFFE6F1FB),
      ),
      SubGoalOption(
        value: 'existing_customers',
        label: 'Existing Customers',
        description: 'Reward loyalty with exclusive offers',
        icon: Icons.check_circle_outline,
        iconColor: Color(0xFF3B6D11),
        iconBg: Color(0xFFEAF3DE),
      ),
      SubGoalOption(
        value: 'all_customers',
        label: 'All Customers',
        description: 'Run a wide discount for everyone',
        icon: Icons.groups,
        iconColor: Color(0xFF533AB7),
        iconBg: Color(0xFFEDE9FF),
      ),
    ],
  };

  static const List<Map<String, String>> callToActionOptions = [
    {'value': 'apply_now', 'label': 'Apply Now'},
    {'value': 'book_now', 'label': 'Book Now'},
    {'value': 'contact_us', 'label': 'Contact Us'},
    {'value': 'shop_now', 'label': 'Shop Now'},
    {'value': 'get_directions', 'label': 'Get Directions'},
    {'value': 'watch_more', 'label': 'Watch More'},
    {'value': 'send_message', 'label': 'Send Message'},
    {'value': 'get_quote', 'label': 'Get Quote'},
    {'value': 'enquire_now', 'label': 'Enquire Now'},
    {'value': 'order_now', 'label': 'Order Now'},
  ];

  static const List<Map<String, dynamic>> mediumOptions = [
    {'value': 'app', 'label': 'App', 'icon': Icons.smartphone},
    {'value': 'digital', 'label': 'Digital', 'icon': Icons.language},
  ];

  static const List<Map<String, dynamic>> audienceOptions = [
    {'value': 'users', 'label': 'Users', 'icon': Icons.people},
    {'value': 'vendors', 'label': 'Vendors', 'icon': Icons.store},
    {'value': 'movers', 'label': 'Movers', 'icon': Icons.local_shipping},
  ];

  static const List<Map<String, String>> appTypes = [
    {'value': 'FOOD_AND_BEVERAGES', 'label': 'Food & Beverages'},
    {'value': 'CATERINGS_SERVICES', 'label': 'Catering Services'},
  ];

  static const List<Map<String, dynamic>> placementsApp = [
    {'value': 'place_banner', 'label': 'Place Banner', 'icon': Icons.dashboard},
    {'value': 'adds', 'label': 'Deals', 'icon': Icons.local_offer},
    {'value': 'cart', 'label': 'Cart', 'icon': Icons.shopping_cart},
    {
      'value': 'in_app_popup',
      'label': 'In-App Popup',
      'icon': Icons.open_in_new,
    },
  ];

  static const List<int> durationOptions = [5, 10, 15, 20];

  static const List<Map<String, String>> interestOptions = [
    {'value': 'food', 'label': '🍔 Food Lovers'},
    {'value': 'veg', 'label': '🥗 Veg Lovers'},
    {'value': 'students', 'label': '🎓 Students'},
    {'value': 'families', 'label': '👨‍👩‍👧 Families'},
    {'value': 'office', 'label': '💼 Office Crowd'},
  ];

  static const steps = [
    {'number': 1, 'label': 'Goal Details'},
    {'number': 2, 'label': 'Medium & Media'},
    {'number': 3, 'label': 'Targeting'},
    {'number': 4, 'label': 'Budget'},
  ];
}
