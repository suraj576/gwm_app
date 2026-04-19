import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends ChangeNotifier {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  
  List<BluetoothDevice> pairedDevices = [];
  BluetoothDevice? selectedDevice;
  BluetoothConnection? connection;
  bool isConnected = false;
  bool isConnecting = false;
  String connectionStatus = "Disconnected";
  
  // Data handling
  List<String> receivedData = [];
  String lastReceivedMessage = "";
  double? currentGroundwaterLevel;

  // Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }

  // Get paired devices
  Future<void> getPairedDevices() async {
    try {
      await requestPermissions();
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      pairedDevices = devices;
      print("Found ${pairedDevices.length} paired devices");
      notifyListeners();
    } catch (e) {
      print("Error getting paired devices: $e");
      throw e;
    }
  }

  // Connect to selected device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (isConnecting) return false;
    
    try {
      isConnecting = true;
      connectionStatus = "Connecting...";
      selectedDevice = device;
      notifyListeners();

      connection = await BluetoothConnection.toAddress(device.address);
      isConnected = true;
      isConnecting = false;
      connectionStatus = "Connected to ${device.name}";
      
      // Start listening for incoming data
      _listenForData();
      
      print("Successfully connected to ${device.name}");
      notifyListeners();
      return true;
      
    } catch (e) {
      print("Connection failed: $e");
      isConnecting = false;
      isConnected = false;
      connectionStatus = "Connection failed";
      selectedDevice = null;
      notifyListeners();
      return false;
    }
  }

  // Listen for incoming data
  void _listenForData() {
    connection?.input?.listen(
      (Uint8List data) {
        String received = utf8.decode(data).trim();
        if (received.isNotEmpty) {
          lastReceivedMessage = received;
          receivedData.add("${DateTime.now().toString().substring(11, 19)}: $received");
          
          // Parse groundwater level data
          _parseGroundwaterData(received);
          
          // Keep only last 100 messages to prevent memory issues
          if (receivedData.length > 100) {
            receivedData.removeAt(0);
          }
          
          print("Received: $received");
          notifyListeners();
        }
      },
      onDone: () {
        print("Connection closed");
        _disconnect();
      },
      onError: (error) {
        print("Bluetooth error: $error");
        _disconnect();
      },
    );
  }

  // Parse groundwater level data from Arduino
  void _parseGroundwaterData(String data) {
    // Example patterns your Arduino might send:
    // "GWL:125.5" - Groundwater Level: 125.5 cm
    // "LEVEL:89.2" - Level: 89.2 cm
    // "ENCODER:1250" - Encoder count: 1250
    
    if (data.contains(":")) {
      List<String> parts = data.split(":");
      if (parts.length == 2) {
        String command = parts[0].toUpperCase();
        String value = parts[11];
        
        try {
          double numericValue = double.parse(value);
          
          switch (command) {
            case "GWL":
            case "LEVEL":
              currentGroundwaterLevel = numericValue;
              break;
            case "ENCODER":
              // Convert encoder count to groundwater level if needed
              // currentGroundwaterLevel = convertEncoderToLevel(numericValue);
              break;
          }
        } catch (e) {
          print("Error parsing numeric value: $e");
        }
      }
    }
  }

  // Send command to Arduino
  void sendCommand(String command) async {
    if (connection != null && connection!.isConnected) {
      try {
        String message = "$command\n";
        connection!.output.add(Uint8List.fromList(message.codeUnits));
        await connection!.output.allSent;
        
        // Add to received data for logging
        receivedData.add("${DateTime.now().toString().substring(11, 19)}: SENT -> $command");
        
        print("Sent: $command");
        notifyListeners();
      } catch (e) {
        print("Error sending command: $e");
      }
    }
  }

  // Disconnect from device
  void _disconnect() {
    if (connection != null) {
      connection!.dispose();
      connection = null;
    }
    isConnected = false;
    isConnecting = false;
    connectionStatus = "Disconnected";
    selectedDevice = null;
    currentGroundwaterLevel = null;
    notifyListeners();
  }

  // Public disconnect method
  void disconnect() {
    _disconnect();
  }

  // Clear received data log
  void clearDataLog() {
    receivedData.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}