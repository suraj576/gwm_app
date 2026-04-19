import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_model.dart';
import '../services/prediction_service.dart';

class PredictionScreen extends StatefulWidget {
  final String wellId;
  final double latitude;
  final double longitude;
  final double currentDepth;

  const PredictionScreen({
    Key? key,
    required this.wellId,
    required this.latitude,
    required this.longitude,
    required this.currentDepth,
  }) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final PredictionService _service = PredictionService();
  PredictionResponse? _response;
  bool _isLoading = false;
  Map<String, dynamic>? _modelInfo;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
    _loadModelInfo();
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);
    final response = await _service.getPredictions(
      wellId: widget.wellId,
      latitude: widget.latitude,
      longitude: widget.longitude,
      currentDepth: widget.currentDepth,
    );
    setState(() {
      _response = response;
      _isLoading = false;
    });
  }

  Future<void> _loadModelInfo() async {
    final info = await _service.getModelInfo();
    setState(() => _modelInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ML Predictions - ${widget.wellId}'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating AI predictions...'),
                  Text(
                    'Using Random Forest Model',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : _response == null || !_response!.success
              ? _buildError()
              : _buildPredictions(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Failed to load predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _response?.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadPredictions,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_modelInfo != null) _buildModelCard(),
          SizedBox(height: 16),
          _buildCurrentStatusCard(),
          SizedBox(height: 20),
          Text(
            'AI/ML Predictions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ..._response!.predictions!.map((p) => _buildPredictionCard(p)),
        ],
      ),
    );
  }

  Widget _buildModelCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Model: ${_modelInfo!['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Version: ${_modelInfo!['version']}'),
            Text('RMSE: ${_modelInfo!['rmse']?.toStringAsFixed(2)} meters'),
            Text('Region: ${_modelInfo!['region']}'),
            Text('Training Period: ${_modelInfo!['training_period']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.water_drop, color: Colors.blue, size: 40),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Water Level',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  '${widget.currentDepth.toStringAsFixed(2)} meters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(PredictionModel prediction) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${prediction.month}-Month Forecast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: prediction.riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: prediction.riskColor, width: 2),
                  ),
                  child: Text(
                    prediction.riskLevel.toUpperCase(),
                    style: TextStyle(
                      color: prediction.riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(prediction.date))}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Predicted Depth',
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 4),
                      Text(
                        '${prediction.predictedDepth.toStringAsFixed(2)} m',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      Text('Confidence Range',
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 4),
                      Text(
                        '${prediction.confidenceLower.toStringAsFixed(1)} - ${prediction.confidenceUpper.toStringAsFixed(1)} m',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              prediction.riskDescription,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}