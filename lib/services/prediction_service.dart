import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';

class PredictionService {
  // Production Render API URL
  static const String BASE_URL = 'https://groundwater-ml-api.onrender.com';

  Future<PredictionResponse> getPredictions({
    required String wellId,
    required double latitude,
    required double longitude,
    required double currentDepth,
  }) async {
    try {
      print('🔄 Requesting predictions from $BASE_URL/predict');
      print('📍 Location: ($latitude, $longitude)');
      print('💧 Current depth: $currentDepth m');
      
      final response = await http.post(
        Uri.parse('$BASE_URL/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'well_id': wellId,
          'latitude': latitude,
          'longitude': longitude,
          'current_depth': currentDepth,
        }),
      ).timeout(const Duration(seconds: 60));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Predictions received successfully');
        return PredictionResponse.fromJson(data);
      } else {
        print('❌ Server error: ${response.statusCode}');
        return PredictionResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      return PredictionResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/model/info'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching model info: $e');
      return null;
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/health'),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
