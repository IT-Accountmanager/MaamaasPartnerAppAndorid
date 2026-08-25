import '../models/support_models.dart';

const List<FaqItem> staticFaqs = [
  FaqItem(
    id: 1,
    category: 'ordering',
    popular: true,
    tags: ['ordering', 'basics'],
    question: 'How do I place an order?',
    answer:
        'You can place an order through our mobile app or website. Simply browse restaurants, select items, add them to your cart, and proceed to checkout. You\'ll need to provide delivery address and payment details.',
  ),
  FaqItem(
    id: 2,
    category: 'ordering',
    popular: false,
    tags: ['schedule', 'timing'],
    question: 'Can I schedule an order for later?',
    answer:
        'Yes! You can schedule orders for up to 3 days in advance. During checkout, select the \'Schedule for later\' option and choose your preferred delivery time.',
  ),
  FaqItem(
    id: 3,
    category: 'ordering',
    popular: true,
    tags: ['modify', 'cancel'],
    question: 'How do I modify or cancel my order?',
    answer:
        'You can modify or cancel your order within 5 minutes of placing it. Go to \'My Orders\' → select the order → click \'Modify\' or \'Cancel\'. After 5 minutes, please contact support.',
  ),
  FaqItem(
    id: 4,
    category: 'delivery',
    popular: true,
    tags: ['charges', 'fees'],
    question: 'What are the delivery charges?',
    answer:
        'Delivery charges vary by restaurant and distance. They range from ₹20 to ₹60. Some restaurants offer free delivery on orders above ₹300. Charges are clearly shown before checkout.',
  ),
  FaqItem(
    id: 5,
    category: 'delivery',
    popular: true,
    tags: ['time', 'tracking'],
    question: 'How long does delivery take?',
    answer:
        'Delivery typically takes 30-45 minutes. This depends on restaurant preparation time, traffic, and your location. You can track your order in real-time on the app.',
  ),
  FaqItem(
    id: 6,
    category: 'delivery',
    popular: false,
    tags: ['tracking', 'live'],
    question: 'Can I track my delivery partner?',
    answer:
        'Yes! Once your order is out for delivery, you can track your delivery partner\'s live location on the map in real-time. You\'ll also receive ETA updates.',
  ),
  FaqItem(
    id: 7,
    category: 'payment',
    popular: true,
    tags: ['payments', 'methods'],
    question: 'What payment methods do you accept?',
    answer:
        'We accept UPI, credit/debit cards, net banking, wallets (Paytm, PhonePe), cash on delivery, and food credits. All payments are secure and encrypted.',
  ),
  FaqItem(
    id: 8,
    category: 'payment',
    popular: false,
    tags: ['COD', 'cash'],
    question: 'Is cash on delivery available?',
    answer:
        'Yes, cash on delivery is available for most restaurants. However, some restaurants may require prepayment. This will be clearly indicated during checkout.',
  ),
  FaqItem(
    id: 9,
    category: 'payment',
    popular: true,
    tags: ['promo', 'discount'],
    question: 'How do I apply a promo code?',
    answer:
        'During checkout, look for the \'Apply Promo Code\' field. Enter your code and click apply. The discount will be reflected in your total immediately.',
  ),
  FaqItem(
    id: 10,
    category: 'account',
    popular: false,
    tags: ['password', 'security'],
    question: 'How do I reset my password?',
    answer:
        'Go to \'Account\' → \'Security\' → \'Change Password\'. You\'ll need to verify via OTP sent to your registered mobile number or email.',
  ),
  FaqItem(
    id: 11,
    category: 'account',
    popular: false,
    tags: ['address', 'profile'],
    question: 'How do I update my delivery address?',
    answer:
        'Navigate to \'Account\' → \'Addresses\' → \'Add New Address\' or edit existing ones. You can save multiple addresses for quick ordering.',
  ),
  FaqItem(
    id: 12,
    category: 'app',
    popular: true,
    tags: ['crash', 'technical'],
    question: 'The app is crashing. What should I do?',
    answer:
        '1. Force close and restart the app\n2. Check for updates in Play Store/App Store\n3. Clear app cache in settings\n4. Reinstall the app\nIf issues persist, contact support.',
  ),
];

const List<Map<String, dynamic>> faqCategories = [
  {'id': 'all', 'name': 'All FAQs', 'icon': '⭐', 'color': 0xFFFF6B35},
  {'id': 'ordering', 'name': 'Ordering', 'icon': '🍔', 'color': 0xFF06D6A0},
  {'id': 'payment', 'name': 'Payments', 'icon': '💳', 'color': 0xFFFFD166},
  {'id': 'account', 'name': 'Account', 'icon': '👤', 'color': 0xFF9D4EDD},
  {'id': 'app', 'name': 'App Issues', 'icon': '📱', 'color': 0xFFEF476F},
];

const List<Map<String, String>> ticketTypes = [
  {'label': 'Payment Issue', 'value': 'PAYMENT'},
  {'label': 'Subscription Issue', 'value': 'GENERAL'},
  {'label': 'Technical Glitch', 'value': 'APP'},
  {'label': 'Order Fulfillment', 'value': 'ORDER'},
  {'label': 'KYC Verification', 'value': 'REGISTRATION'},
  {'label': 'Account Access', 'value': 'APP'},
  {'label': 'Product Quality', 'value': 'DELIVERY'},
  {'label': 'Refund Request', 'value': 'PAYMENT'},
  {'label': 'Coupon Issue', 'value': 'COUPON'},
  {'label': 'Banner Issue', 'value': 'BANNER'},
  {'label': 'Other', 'value': 'GENERAL'},
];
