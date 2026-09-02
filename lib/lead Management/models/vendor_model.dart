/// Minimal vendor profile model used by [Authservice.fetchVendorData].
/// Extend this with whatever fields your `/api/vendors/{id}` endpoint
/// actually returns — only a safe generic subset is mapped here so the
/// module compiles standalone.
class VendorModel {
  final int? id;
  final String? businessName;
  final String? ownerName;
  final String? email;
  final String? phoneNumber;
  final String? city;
  final String? state;
  final Map<String, dynamic> raw;

  VendorModel({
    this.id,
    this.businessName,
    this.ownerName,
    this.email,
    this.phoneNumber,
    this.city,
    this.state,
    required this.raw,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      businessName: json['businessName']?.toString(),
      ownerName: json['ownerName']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      raw: json,
    );
  }
}
