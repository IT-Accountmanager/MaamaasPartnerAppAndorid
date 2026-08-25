import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterBottomSheet extends StatefulWidget {
  final ScrollController controller;
  final Function(String) onPrint;
  final Function(String) onConnected;
  final Future<bool> Function() parentEnsureBluetoothPermissions;
  final VoidCallback parentShowBluetoothPermissionDialog;
  final Future<void> Function(String) onSetDefault;

  const PrinterBottomSheet({
    super.key,
    required this.controller,
    required this.onPrint,
    required this.onConnected,
    required this.parentEnsureBluetoothPermissions,
    required this.parentShowBluetoothPermissionDialog,
    required this.onSetDefault,
  });

  @override
  State<PrinterBottomSheet> createState() => _PrinterBottomSheetState();
}

class _PrinterBottomSheetState extends State<PrinterBottomSheet> {
  List<BluetoothInfo> pairedDevices = [];
  List<BluetoothInfo> scannedDevices = [];
  bool isScanning = false;
  bool isConnected = false;
  String? connectedMac;

  @override
  void initState() {
    super.initState();
    getPairedDevices();
  }

  void _showBluetoothPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Permission Needed'),
        content: const Text(
          'Nearby Devices / Bluetooth permissions are required. '
          'Go to Settings > Apps > Your App > Permissions and enable Bluetooth related permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> getPairedDevices() async {
    final ok = await widget.parentEnsureBluetoothPermissions();
    if (!ok) return;

    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      setState(() => pairedDevices = devices);
      if (devices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No printers paired. Go to Settings > Bluetooth > Pair printer',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      widget.parentShowBluetoothPermissionDialog();
    }
  }

  Future<bool> ensureBluetoothPermissions() async {
    try {
      final bool pluginGranted =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;
      final bool bluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;

      if (!pluginGranted || !bluetoothOn) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.locationWhenInUse,
        ].request();

        final bool ok =
            statuses[Permission.bluetoothScan]?.isGranted == true &&
            statuses[Permission.bluetoothConnect]?.isGranted == true &&
            bluetoothOn;

        if (!ok) {
          _showBluetoothPermissionDialog();
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }

  Future<void> _scanDevices() async {
    setState(() => isScanning = true);
    try {
      // Scan for nearby printers (fallback to paired if scan not supported)
      await Future.delayed(Duration(seconds: 3));
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        scannedDevices = devices;
        isScanning = false;
      });
    } catch (e) {
      setState(() => isScanning = false);
    }
  }

  Future<void> connectPrinter(String macAddress) async {
    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      if (result) {
        setState(() {
          connectedMac = macAddress;
          isConnected = true;
        });

        // Existing callback
        widget.onConnected(macAddress);

        // NEW: remember as default
        await widget.onSetDefault(macAddress);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to $macAddress'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Container(
            width: 40.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Select Printer",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: getPairedDevices,
                  icon: Icon(Icons.settings_bluetooth),
                  label: Text("Paired"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? null : _scanDevices,
                  icon: Icon(isScanning ? Icons.hourglass_empty : Icons.search),
                  label: Text(isScanning ? "Scanning..." : "Scan"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Connection Status
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.green : Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 12.w),
                Text(
                  isConnected ? "Connected" : "No Printer",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (connectedMac != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    connectedMac!.substring(connectedMac!.length - 4),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Devices List
          Expanded(
            child: pairedDevices.isEmpty && scannedDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No printers found",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Pair printer in device Settings first",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: getPairedDevices,
                          icon: Icon(Icons.refresh),
                          label: Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: widget.controller,
                    itemCount: (pairedDevices + scannedDevices).length,
                    itemBuilder: (context, index) {
                      final device = (pairedDevices + scannedDevices)[index];
                      final isConnectedDevice =
                          connectedMac == device.macAdress;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[100],
                            child: Icon(Icons.print, color: Colors.teal[700]),
                          ),
                          title: Text(
                            device.name,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(device.macAdress),
                          trailing: isConnectedDevice
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                )
                              : ElevatedButton(
                                  onPressed: () =>
                                      connectPrinter(device.macAdress),
                                  child: Text("Connect"),
                                ),
                        ),
                      );
                    },
                  ),
          ),

          // Print Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isConnected
                  ? () {
                      Navigator.pop(context);
                      widget.onPrint(connectedMac!);
                    }
                  : null,
              icon: Icon(Icons.print),
              label: Text("🖨️ Print Invoice"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
