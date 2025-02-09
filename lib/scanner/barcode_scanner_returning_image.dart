//barcode_scanner_returning_image
import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/mobile_scanner.dart';
import 'package:carrinhodesupermercado/scanner/scanned_barcode_label.dart';
import 'package:carrinhodesupermercado/scanner/scanner_button_widgets.dart';

class BarcodeScannerReturningImage extends StatefulWidget {
  const BarcodeScannerReturningImage({super.key});

  @override
  State<BarcodeScannerReturningImage> createState() =>
      _BarcodeScannerReturningImageState();
}

class _BarcodeScannerReturningImageState
    extends State<BarcodeScannerReturningImage> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back, // Garante que está usando a câmera traseira
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returning image')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<BarcodeCapture>(
                stream: controller.barcodes,
                builder: (context, snapshot) {
                  final barcodeData = snapshot.data?.barcodes.firstOrNull;

                  // Delaying the navigation until after the widget build phase is complete
                  if (barcodeData != null) {
                    return const Center(
                      child: Text(
                        'produto',
                      ),
                    );
                    //print("existe um produto");
                    /*
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context, barcodeData.rawValue);
                    });*/
                  }

                  return const Center(
                      child: Text('Escaneie um código de barras'));
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: ColoredBox(
                color: Colors.grey,
                child: Stack(
                  children: [
                    FutureBuilder(
                      future: controller.start(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        }
                        return MobileScanner(controller: controller);
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 50,
                        color: const Color.fromRGBO(0, 0, 0, 0.4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ToggleFlashlightButton(controller: controller),
                            StartStopMobileScannerButton(
                                controller: controller),
                            Expanded(
                              child: Center(
                                child: ScannedBarcodeLabel(
                                  barcodes: controller.barcodes,
                                ),
                              ),
                            ),
                            SwitchCameraButton(controller: controller),
                          ],
                        ),
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

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
}
}