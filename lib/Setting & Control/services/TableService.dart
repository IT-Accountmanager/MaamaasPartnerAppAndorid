import 'dart:convert';
import 'package:flutter/material.dart';

import '../../API/Apiclient.dart';

class TableService {
  static Future<List<dynamic>> fetchTables(String vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/seating/all/vendor/$vendorId',
        service: 'food',
      );

      debugPrint("FETCH TABLES STATUS : ${response.statusCode}");
      debugPrint("FETCH TABLES BODY : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception("Failed to fetch tables");
    } catch (e) {
      debugPrint("fetchTables ERROR : $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchBookings(
    String vendorId,
    String date,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/seatingdetails/vendor/$vendorId/vendor-bookings',
        service: 'food',
        queryParams: {"date": date},
      );

      debugPrint("FETCH BOOKINGS STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      debugPrint("fetchBookings ERROR : $e");
      return [];
    }
  }

  static Future<List<dynamic>> fetchWaitlist(String vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/seatingdetails/waiting/vendor/$vendorId',
        service: 'food',
      );

      debugPrint("FETCH WAITLIST STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      debugPrint("fetchWaitlist ERROR : $e");
      return [];
    }
  }

  static Future<bool> addTable({
    required String vendorId,
    required String name,
    required int numberOfTables,
    required int capacity,
  }) async {
    try {
      final response = await ApiClient.post('api/seating/vendor/$vendorId', {
        "numberOfTables": numberOfTables,
        "capacityPerTable": capacity,
        "name": name,
        "cleaningTime": "00:30:00",
      }, service: 'food');

      debugPrint("ADD TABLE STATUS : ${response.statusCode}");
      debugPrint("ADD TABLE BODY : ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("addTable ERROR : $e");
      return false;
    }
  }

  static Future<bool> updateTable({
    required String tableId,
    required String name,
    required String code,
    required int capacity,
    required String status,
    required String cleanTime,
    required String description,
    required String remarks,
    required bool manuallyUpdated,
  }) async {
    try {
      final response = await ApiClient.put('api/seating/edit/$tableId', {
        "id": int.tryParse(tableId) ?? 0,
        "name": name,
        "seatingStatus": status,
        "code": code,
        "capacity": capacity,
        "description": description,
        "remarks": remarks,
        "cleanTime": cleanTime,
        "manuallyUpdated": manuallyUpdated,
      }, service: 'food');

      debugPrint("UPDATE TABLE STATUS : ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("updateTable ERROR : $e");
      return false;
    }
  }

  static Future<bool> removeWaitlist(int id) async {
    try {
      final response = await ApiClient.delete(
        'api/seatingdetails/delete/waiting-list/$id',
        service: 'food',
      );

      debugPrint("REMOVE WAITLIST STATUS : ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("removeWaitlist ERROR : $e");
      return false;
    }
  }

  static Future<bool> deleteTable({required String tableId}) async {
    try {
      final response = await ApiClient.delete(
        'api/seating/delete/$tableId',
        service: 'food',
      );

      debugPrint("DELETE TABLE STATUS : ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("deleteTable ERROR : $e");
      return false;
    }
  }
}
