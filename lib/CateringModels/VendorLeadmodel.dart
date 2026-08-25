class Lead {
  final int id;
  final String? eventType;
  final String? eventDate;
  final String? eventTime;
  final String? fromDate;
  final String? toDate;
  final int? vegPlates;
  final int? nonVegPlates;
  final int? mixedPlates;
  final double? leadPrice;
  final bool? accessible;
  final bool? masked;

  // Customer info - actual field names might differ
  final String? customerName;
  final String? clientName;
  final String? customerPhone;
  final String? clientPhone;
  final String? customerEmail;
  final String? clientEmail;
  final String? customerAddress;
  final String? location;

  final List<dynamic>? items;
  final List<dynamic>? addOns;
  final String? additionalRequests;

  Lead({
    required this.id,
    this.eventType,
    this.eventDate,
    this.eventTime,
    this.fromDate,
    this.toDate,
    this.vegPlates,
    this.nonVegPlates,
    this.mixedPlates,
    this.leadPrice,
    this.accessible,
    this.masked,
    this.customerName,
    this.clientName,
    this.customerPhone,
    this.clientPhone,
    this.customerEmail,
    this.clientEmail,
    this.customerAddress,
    this.location,
    this.items,
    this.addOns,
    this.additionalRequests,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? json['leadId'] ?? 0,
      eventType: json['eventType'],
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      vegPlates: json['vegPlates'],
      nonVegPlates: json['nonVegPlates'],
      mixedPlates: json['mixedPlates'],
      leadPrice: (json['leadPrice'] ?? 0).toDouble(),
      accessible: json['accessible'],
      masked: json['masked'],
      customerName: json['customerName'],
      clientName: json['clientName'],
      customerPhone: json['customerPhone'],
      clientPhone: json['clientPhone'],
      customerEmail: json['customerEmail'],
      clientEmail: json['clientEmail'],
      customerAddress: json['customerAddress'],
      location: json['location'],
      items: json['items'],
      addOns: json['addOns'],
      additionalRequests: json['additionalRequests'],
    );
  }
}
