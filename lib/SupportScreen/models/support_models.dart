// ─── Internal Issue (dashboardService endpoints) ─────────────────────────────


class InternalIssue {
  final int id;
  final String title;
  final String description;
  final String priority; // LOW | MEDIUM | HIGH
  final String status; // OPEN | IN_PROGRESS | CLOSED
  final String raisedBy;
  final String createdAt;

  const InternalIssue({
    this.id = 0,
    this.title = '',
    this.description = '',
    this.priority = 'LOW',
    this.status = 'OPEN',
    this.raisedBy = '',
    this.createdAt = '',
  });

  factory InternalIssue.fromJson(Map<String, dynamic> j) => InternalIssue(
    id: _i(j['id']),
    title: j['title']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    priority: j['priority']?.toString() ?? 'LOW',
    status: j['status']?.toString() ?? 'OPEN',
    raisedBy: j['raisedBy']?.toString() ?? '',
    createdAt: j['createdAt']?.toString() ?? '',
  );

  Map<String, dynamic> toJson(int? editId) => {
    'id': editId ?? 0,
    'title': description,
    'description': description,
    'priority': priority,
    'status': status,
    'raisedBy': raisedBy,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

// ─── Platform Ticket (PromotionsService endpoints) ────────────────────────────
// GET  /promotions/api/user/helpdesk/vendor/{vendorId}
// POST /promotions/api/user/helpdesk/create   (multipart: ticket blob + optional file)

class PlatformTicket {
  final int? id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String priority; // High | Medium | Critical
  final String
  status; // New | Assigned | In Progress | Escalated | Resolved | Reopened | Closed | Rejected
  final String
  issueType; // PAYMENT | GENERAL | APP | ORDER | REGISTRATION | DELIVERY | COUPON | BANNER
  final String ticketCategory;
  final String serviceType;
  final String createdBy;
  final String createdAt;
  final String city;
  final int? vendorId;

  const PlatformTicket({
    this.id,
    this.ticketNumber = '',
    this.subject = '',
    this.description = '',
    this.priority = 'Medium',
    this.status = 'New',
    this.issueType = 'GENERAL',
    this.ticketCategory = 'PLATFORM',
    this.serviceType = 'FOOD_AND_BEVERAGES',
    this.createdBy = 'VENDOR',
    this.createdAt = '',
    this.city = 'Hyderabad',
    this.vendorId,
  });

  factory PlatformTicket.fromJson(Map<String, dynamic> j) => PlatformTicket(
    id: _i(j['id']),
    ticketNumber: j['ticketNumber']?.toString() ?? '',
    subject: j['subject']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    priority: j['priority']?.toString() ?? 'Medium',
    status: j['status']?.toString() ?? 'New',
    issueType: j['issueType']?.toString() ?? '',
    ticketCategory: j['ticketCategory']?.toString() ?? 'PLATFORM',
    serviceType: j['serviceType']?.toString() ?? '',
    createdBy: j['createdBy']?.toString() ?? '',
    createdAt: j['createdAt']?.toString() ?? '',
    city: j['city']?.toString() ?? '',
    vendorId: _i(j['vendorId']),
  );

  Map<String, dynamic> toJson() => {
    'priority': priority,
    'vendorId': vendorId,
    'city': city,
    'subject': subject,
    'serviceType': serviceType,
    'status': 'OPEN',
    'issueType': issueType,
    'createdAt': DateTime.now().toIso8601String(),
    'description': description,
    'createdBy': createdBy,
    'ticketCategory': ticketCategory,
  };
}

// ─── FAQ ──────────────────────────────────────────────────────────────────────
class FaqItem {
  final int id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final bool popular;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.tags = const [],
    this.popular = false,
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
