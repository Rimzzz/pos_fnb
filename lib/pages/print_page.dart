import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              InkWell(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        letterSpacing: 1, fontWeight: FontWeight.bold),
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'AMAZINK',
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        letterSpacing: 1, fontWeight: FontWeight.bold),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'POS', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<BluetoothDevice>(
                value: selectedDevice,
                hint: const Text('Pilih Printer'),
                onChanged: (device) {
                  setState(() {
                    selectedDevice = device;
                  });
                },
                items: devices
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name!),
                      ),
                    )
                    .toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      printer.connect(selectedDevice!);
                    },
                    child: const Text('Connect'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      printer.disconnect();
                    },
                    child: const Text('Disconnect'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if ((await printer.isConnected)!) {
                        printer.printCustom('Test Print', 0, 1);
                        printer.printQRcode('QR For Test', 200, 200, 1);
                        printer.printNewLine();
                        printer.printNewLine();
                      }
                    },
                    child: const Text('Test Print'),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
