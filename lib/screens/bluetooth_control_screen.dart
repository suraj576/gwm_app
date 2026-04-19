import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class BluetoothControlScreen extends StatefulWidget {
  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  late BluetoothService bluetoothService;
  TextEditingController customCommandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bluetoothService = BluetoothService();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    try {
      await bluetoothService.getPairedDevices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing Bluetooth: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: bluetoothService,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Bluetooth Motor Control"),
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => bluetoothService.getPairedDevices(),
            ),
          ],
        ),
        body: Consumer<BluetoothService>(
          builder: (context, service, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status Card
                  _buildConnectionStatusCard(service),
                  SizedBox(height: 16),
                  
                  // Device Selection Card
                  _buildDeviceSelectionCard(service),
                  SizedBox(height: 16),
                  
                  // Control Buttons (only show when connected)
                  if (service.isConnected) ...[
                    _buildControlButtonsCard(service),
                    SizedBox(height: 16),
                    
                    // Custom Command Card
                    _buildCustomCommandCard(service),
                    SizedBox(height: 16),
                    
                    // Groundwater Level Display
                    _buildGroundwaterLevelCard(service),
                    SizedBox(height: 16),
                    
                    // Data Log Card
                    _buildDataLogCard(service),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              service.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              color: service.isConnected ? Colors.green : Colors.grey,
              size: 30,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                service.connectionStatus,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (service.isConnected)
              ElevatedButton(
                onPressed: service.disconnect,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Disconnect", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelectionCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Bluetooth Device:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            if (service.pairedDevices.isEmpty)
              Text("No paired devices found. Please pair your Arduino device in phone settings.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: service.pairedDevices.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = service.pairedDevices[index];
                  bool isSelected = service.selectedDevice?.address == device.address;
                  
                  return Card(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.bluetooth, color: isSelected ? Colors.blue : Colors.grey),
                      title: Text(device.name ?? "Unknown Device"),
                      subtitle: Text(device.address),
                      trailing: service.isConnecting && isSelected
                          ? CircularProgressIndicator()
                          : (service.isConnected && isSelected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: service.isConnecting ? null : () => service.connectToDevice(device),
                                  child: Text("Connect"),
                                )),
                      onTap: () => service.connectToDevice(device),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtonsCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Control Panel:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            // Motor Control Buttons (like your image)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton("ON", Icons.power, Colors.green, () => service.sendCommand("c")),
                _buildCircleButton("STOP", Icons.power_off, Colors.red, () => service.sendCommand("s")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton("CW", Icons.rotate_right, Colors.blue, () => service.sendCommand("a")),
                _buildCircleButton("CCW", Icons.rotate_left, Colors.orange, () => service.sendCommand("d")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
            ),
            child: Icon(icon, size: 35, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildCustomCommandCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Send Custom Command:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customCommandController,
                    decoration: InputDecoration(
                      hintText: "Enter command (e.g., READ_GWL)",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        service.sendCommand(value);
                        customCommandController.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (customCommandController.text.isNotEmpty) {
                      service.sendCommand(customCommandController.text);
                      customCommandController.clear();
                    }
                  },
                  child: Text("Send"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundwaterLevelCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Current Groundwater Level", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              service.currentGroundwaterLevel != null 
                  ? "${service.currentGroundwaterLevel!.toStringAsFixed(1)} cm"
                  : "No data",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[800]),
            ),
            SizedBox(height: 8),
            Text(
              "Last message: ${service.lastReceivedMessage.isEmpty ? 'None' : service.lastReceivedMessage}",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataLogCard(BluetoothService service) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Data Log:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: service.clearDataLog,
                  child: Text("Clear"),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: service.receivedData.isEmpty
                  ? Center(child: Text("No data received"))
                  : ListView.builder(
                      reverse: true,
                      itemCount: service.receivedData.length,
                      itemBuilder: (context, index) {
                        int reverseIndex = service.receivedData.length - 1 - index;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text(
                            service.receivedData[reverseIndex],
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    customCommandController.dispose();
    bluetoothService.dispose();
    super.dispose();
  }
}
