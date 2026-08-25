import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/APIclient.dart';
import '../CateringModels/CompanyScheduleItem_model.dart';
import '../CateringModels/Company_Model.dart';
import '../CateringModels/DailyCatering_model.dart'
    hide ScheduleItem, MonthlyScheduleSummary;
import '../CateringModels/Quotation_get_model.dart';

import '../CateringModels/Quotation_model.dart' hide QuotationData;
import '../CateringModels/package_model.dart';

class CateringService {
  static const String baseUrl = 'http://staging.maamaas.com:8080/catering';
  // 'http://staging.maamaas.com:8080/catering';

  // 🔹 Get Vendor ID
  static Future<int?> getVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('vendorId');
    } catch (e) {
      return null;
    }
  }

  // 🔹 GET All Packages for Vendor
  static Future<List<PackageModel>> getPackagesByVendor(int vendorId) async {
    final response = await ApiClient.get(
      "api/package/$vendorId",
      service: "catering",
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PackageModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load packages');
    }
  }

  // 🔹 DELETE Package
  static Future<bool> deletePackage(int packageId) async {
    try {
      final vendorId = await getVendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.delete(
        "api/vendor/$vendorId/$packageId",
        service: "catering",
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> initiateLeadPayment({
    required int leadId,
    required int vendorId,
    required double amount,
    required int orderId,
  }) async {
    final response = await ApiClient.post(
      "api/vendor/payment/initiate",
      null,
      service: "catering",
    );

    // If your backend strictly requires query params:
    // Use ApiClient.get with queryParams instead (cleaner approach)

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Lead Payment Initiate Failed");
    }
  }
}

class QuotationService {
  static Future<bool> hasExistingQuotation(int leadId, int vendorId) async {
    try {
      final response = await ApiClient.get(
        "api/vendor/quotation/$leadId/$vendorId",
        service: "catering",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data != null && data['quotationId'] != null;
      }

      if (response.statusCode == 404) {
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<QuotationResponse> sendQuotation({
    required int vendorId,
    required QuotationRequest request,
  }) async {
    final response = await ApiClient.post(
      "api/vendor/lead/quotation/$vendorId/${request.leadId}",
      request.toJson(),
      service: "catering",
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return QuotationResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to send quotation");
    }
  }
}

class ApiService {
  static Future<List<Order>?> fetchVendorOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');

      if (vendorId == null) {
        print("❌ Vendor ID not found in SharedPreferences");
        return null;
      }

      print("📥 Fetching orders for vendor ID: $vendorId");

      final response = await ApiClient.get(
        "vendor/getall/$vendorId",
        service: "catering",
      );

      print("📥 Orders response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print("✅ Successfully parsed ${jsonData.length} orders");
        return jsonData.map((item) => Order.fromJson(item)).toList();
      } else {
        print("❌ Failed to load orders: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in fetchVendorOrders: $e");
      return null;
    }
  }

  // NEW METHOD: Fetch daily catering schedules
  static Future<List<DailyCatering>?> fetchVendorDailyCatering() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');

      if (vendorId == null) {
        print("❌ Vendor ID not found in SharedPreferences");
        return null;
      }

      print("📥 Fetching daily catering for vendor ID: $vendorId");

      final response = await ApiClient.get(
        "vendor/getall/$vendorId", // This endpoint returns daily catering data
        service: "catering",
      );

      print("📥 Daily catering response status: ${response.statusCode}");

      // Even if status is not 200, try to parse if there's body
      if (response.body.isNotEmpty) {
        try {
          final List<dynamic> jsonData = jsonDecode(response.body);
          print(
            "✅ Successfully parsed ${jsonData.length} daily catering entries",
          );
          return jsonData.map((item) => DailyCatering.fromJson(item)).toList();
        } catch (e) {
          print("❌ Error parsing JSON: $e");
          print("❌ Response body: ${response.body}");
          return null;
        }
      } else {
        print("❌ Empty response body");
        return null;
      }
    } catch (e) {
      print("❌ Exception in fetchVendorDailyCatering: $e");
      return null;
    }
  }

  // NEW METHOD: Get company summaries from daily catering data
  static List<CompanySummary> getCompanySummaries(
    List<DailyCatering> dailyList,
  ) {
    final Map<String, List<DailyCatering>> companyGroups = {};

    // Group by company name
    for (var item in dailyList) {
      if (item.companyName.isEmpty) continue;

      if (!companyGroups.containsKey(item.companyName)) {
        companyGroups[item.companyName] = [];
      }
      companyGroups[item.companyName]!.add(item);
    }

    List<CompanySummary> summaries = [];

    // Create summary for each company
    companyGroups.forEach((companyName, entries) {
      double totalAmount = 0;
      int totalVeg = 0;
      int totalNonVeg = 0;
      String latestDate = '';
      String status = 'PENDING';

      // Sort entries by date to get the latest
      entries.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

      for (var entry in entries) {
        totalAmount += entry.dailyAmount;
        totalVeg += entry.vegCount;
        totalNonVeg += entry.nonVegCount;
      }

      // Get latest date and status
      if (entries.isNotEmpty) {
        latestDate = entries.first.serviceDate;
        status = entries.first.status;
      }

      summaries.add(
        CompanySummary(
          companyName: companyName,
          orderStatus: status,
          paymentStatus: 'PENDING', // Default value
          total: totalAmount,
          cateringDate: latestDate,
          paymentMethod: 'Not specified',
          userId: entries.first.userId,
          vendorId: entries.first.vendorId,
          totalVegMeals: totalVeg,
          totalNonVegMeals: totalNonVeg,
          dailyEntries: entries,
        ),
      );
    });

    // Sort summaries by company name
    summaries.sort((a, b) => a.companyName.compareTo(b.companyName));

    return summaries;
  }

  // Get unique companies from orders (original method)
  static List<Map<String, dynamic>> getUniqueCompanies(List<Order> orders) {
    final Map<String, Map<String, dynamic>> uniqueCompanies = {};

    for (var order in orders) {
      if (order.companyName == null || order.companyName!.isEmpty) continue;

      String key = '${order.quotationId}';

      if (!uniqueCompanies.containsKey(key)) {
        uniqueCompanies[key] = {
          'quotationId': order.quotationId,
          'companyName': order.companyName,
          'orderId': order.orderId,
          'orderStatus': order.orderStatus,
          'paymentStatus': order.paymentStatus,
          'total': order.total,
          'cateringDate': order.cateringDate,
          'paymentMethod': order.paymentMethod,
          'transactionId': order.transactionId,
        };
      }
    }

    return uniqueCompanies.values.toList();
  }

  // Fetch company schedule
  static Future<List<ScheduleItem>?> fetchCompanySchedule(
    String companyName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');

      if (vendorId == null) {
        print("❌ Vendor ID not found in SharedPreferences");
        return null;
      }

      print(
        "📥 Fetching schedule for vendor ID: $vendorId, company: $companyName",
      );

      final response = await ApiClient.get(
        "dailycatering/schedule?vendorId=$vendorId&companyName=$companyName",
        service: "catering",
      );

      print("📥 Schedule response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => ScheduleItem.fromJson(item)).toList();
      } else {
        print("❌ Failed to load schedule: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in fetchCompanySchedule: $e");
      return null;
    }
  }

  // Group schedule items by month
  static List<MonthlyScheduleSummary> groupScheduleByMonth(
    List<ScheduleItem> items,
  ) {
    final Map<String, List<ScheduleItem>> groupedByMonth = {};

    for (var item in items) {
      try {
        DateTime date = DateTime.parse(item.serviceDate);
        String monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }
        groupedByMonth[monthKey]!.add(item);
      } catch (e) {
        print("Error parsing date: ${item.serviceDate}");
      }
    }

    List<MonthlyScheduleSummary> summaries = [];

    // Sort keys chronologically
    var sortedKeys = groupedByMonth.keys.toList()..sort();

    for (var key in sortedKeys) {
      var monthItems = groupedByMonth[key]!;
      List<String> parts = key.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);

      int totalVeg = 0;
      int totalNonVeg = 0;
      double totalAmount = 0;
      int pending = 0;
      int completed = 0;

      for (var item in monthItems) {
        totalVeg += item.vegCount;
        totalNonVeg += item.nonVegCount;
        totalAmount += item.dailyAmount;
        if (item.status == 'PENDING') {
          pending++;
        } else if (item.status == 'COMPLETED' || item.status == 'DELIVERED') {
          completed++;
        }
      }

      summaries.add(
        MonthlyScheduleSummary(
          month: _getMonthName(month),
          year: year,
          totalDays: monthItems.length,
          totalVegMeals: totalVeg,
          totalNonVegMeals: totalNonVeg,
          totalAmount: totalAmount,
          pendingCount: pending,
          completedCount: completed,
          items: monthItems,
        ),
      );
    }

    return summaries;
  }

  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
