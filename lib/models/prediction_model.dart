import 'package:flutter/material.dart';

class PredictionModel {
  final int month;
  final String date;
  final double predictedDepth;
  final double confidenceLower;
  final double confidenceUpper;
  final String riskLevel;
  final String riskDescription;

  PredictionModel({
    required this.month,
    required this.date,
    required this.predictedDepth,
    required this.confidenceLower,
    required this.confidenceUpper,
    required this.riskLevel,
    required this.riskDescription,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      month: json['month'],
      date: json['date'],
      predictedDepth: json['predicted_depth'].toDouble(),
      confidenceLower: json['confidence_lower'].toDouble(),
      confidenceUpper: json['confidence_upper'].toDouble(),
      riskLevel: json['risk_level'],
      riskDescription: json['risk_description'],
    );
  }

  Color get riskColor {
    switch (riskLevel.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class PredictionResponse {
  final bool success;
  final String? wellId;
  final double? currentDepth;
  final List<PredictionModel>? predictions;
  final Location? location;
  final String? mode;
  final String? error;

  PredictionResponse({
    required this.success,
    this.wellId,
    this.currentDepth,
    this.predictions,
    this.location,
    this.mode,
    this.error,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == false) {
      return PredictionResponse(
        success: false,
        error: json['error'] ?? 'Unknown error',
      );
    }

    return PredictionResponse(
      success: true,
      wellId: json['well_id'],
      currentDepth: json['current_depth']?.toDouble(),
      predictions: json['predictions'] != null
          ? (json['predictions'] as List)
              .map((p) => PredictionModel.fromJson(p))
              .toList()
          : null,
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      mode: json['mode'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}
