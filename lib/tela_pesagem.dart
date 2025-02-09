import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'package:scoped_model/scoped_model.dart';
import 'package:carrinhodesupermercado/pesagem/bluetooth_service.dart';
import 'package:carrinhodesupermercado/pesagem/ChatPage.dart';
import 'package:carrinhodesupermercado/pesagem/selectBondedDevicePage.dart';
import 'package:permission_handler/permission_handler.dart';

// import './helpers/LineChart.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreen createState() => _BluetoothScreen();
}

class _BluetoothScreen extends State<BluetoothScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  bool _autoAcceptPairingRequests = false;

  Future<void> requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    if (statuses[Permission.bluetoothConnect]!.isGranted) {
      print("Permissão BLUETOOTH_CONNECT concedida.");
    } else {
      print(
          "Permissão BLUETOOTH_CONNECT negada. O usuário deve concedê-la manualmente.");
      openAppSettings(); // Abre as configurações do app se a permissão for negada
    }
  }

  @override
  void initState() {
    super.initState();

    requestBluetoothPermissions();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);

    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: ListView(
        children: <Widget>[
          Divider(),
          ListTile(title: const Text('Geral')),
          SwitchListTile(
            title: const Text('Ligar Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Status do Bluetooth'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: const Text('Config'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('Mac'),
            subtitle: Text(_address),
          ),
          ListTile(
            title: const Text('Nome do Dispositivo'),
            subtitle: Text(_name),
            onLongPress: null,
          ),
          Divider(),
          ListTile(title: const Text('Descobrir dispositivos e conexões')),
          SwitchListTile(
            title: const Text('Parear com Pin'),
            subtitle: const Text('Pin 1234'),
            value: _autoAcceptPairingRequests,
            onChanged: (bool value) {
              setState(() {
                _autoAcceptPairingRequests = value;
              });
              if (value) {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(
                    (BluetoothPairingRequest request) {
                  print("Trying to auto-pair with Pin 1234");
                  if (request.pairingVariant == PairingVariant.Pin) {
                    return Future.value("1234");
                  }
                  return Future.value(null);
                });
              } else {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
              }
            },
          ),
          ListTile(
            title: ElevatedButton(
                child: const Text('Encontrar Dispositivos'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return BluetoothService();
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Discovery -> selected ${selectedDevice.address}');
                  } else {
                    print('Discovery -> no device selected');
                  }
                }),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Conectar dispositivos pareados'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SelectBondedDevicePage(checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  print('Connect -> selected ${selectedDevice.address}');
                  _startChat(context, selectedDevice);
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
