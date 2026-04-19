import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/prediction_service.dart';
import 'prediction_screen.dart';

class MLPredictionLauncher extends StatefulWidget {
  @override
  _MLPredictionLauncherState createState() => _MLPredictionLauncherState();
}

class _MLPredictionLauncherState extends State<MLPredictionLauncher> {
  final LocationService _locationService = LocationService();
  final PredictionService _predictionService = PredictionService();
  
  final TextEditingController _wellIdController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  
  bool _isLoadingLocation = false;
  bool _useManualLocation = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkAPIHealth();
  }

  Future<void> _checkAPIHealth() async {
    bool isHealthy = await _predictionService.checkHealth();
    if (!isHealthy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ API may be sleeping. First request might take 50s.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoadingLocation = true);
    
    Position? position = await _locationService.getCurrentLocation();
    
    setState(() {
      _isLoadingLocation = false;
      if (position != null) {
        _currentPosition = position;
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
        _useManualLocation = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location. Enable location services.')),
        );
      }
    });
  }

  void _launchPrediction() {
    if (_wellIdController.text.isEmpty || 
        _depthController.text.isEmpty ||
        _latController.text.isEmpty ||
        _lonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      double lat = double.parse(_latController.text);
      double lon = double.parse(_lonController.text);
      double depth = double.parse(_depthController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionScreen(
            wellId: _wellIdController.text,
            latitude: lat,
            longitude: lon,
            currentDepth: depth,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input values')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI/ML Predictions'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 48, color: Colors.green[700]),
                    SizedBox(height: 8),
                    Text(
                      'Groundwater Level Predictions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Using CGWB Madhya Pradesh AI/ML Model',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Well ID Input
            TextField(
              controller: _wellIdController,
              decoration: InputDecoration(
                labelText: 'Well ID',
                hintText: 'e.g., INDORE_001',
                prefixIcon: Icon(Icons.confirmation_number),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Current Depth Input
            TextField(
              controller: _depthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Current Water Depth (meters)',
                hintText: 'e.g., 8.5',
                prefixIcon: Icon(Icons.water_drop),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // Location Section
            Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Auto-fetch location button
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _fetchLocation,
              icon: _isLoadingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.my_location),
              label: Text(_isLoadingLocation ? 'Fetching...' : 'Use Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            
            SizedBox(height: 12),

            // Manual location inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      hintText: '22.7196',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _useManualLocation = true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      hintText: '75.8577',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _useManualLocation = true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Generate Predictions Button
            ElevatedButton.icon(
              onPressed: _launchPrediction,
              icon: Icon(Icons.auto_graph, size: 28),
              label: Text(
                'Generate Predictions',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'First prediction may take 50 seconds (API warmup)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
