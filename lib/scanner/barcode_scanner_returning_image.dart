//barcode_scanner_returning_image
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/mobile_scanner.dart';
import 'package:carrinhodesupermercado/scanner/scanned_barcode_label.dart';
import 'package:carrinhodesupermercado/scanner/scanner_button_widgets.dart';
import 'package:carrinhodesupermercado/scanner/scanner_error_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  final List<Map<String, dynamic>> _products = [];
  void _scanProduct(barcode) async {
    if (barcode != null && barcode.isNotEmpty) {
      _addProductToCart(barcode);
    }
  }

  void _addProductToCart(String barcode) async {
    var produtos = {
      "1234567891286": {
        "nome": "Arroz 5kg",
        "preco": 24.99,
        "imagem": "https://via.placeholder.com/150"
      },
      "789012": {
        "nome": "Feijão 1kg",
        "preco": 8.99,
        "imagem":
            "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"
      },
    };

    var produto = produtos[barcode];

    if (produto != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto ${produto['nome']} adicionado!")),
      );
      setState(() {
        _products.add({
          'description': produto["nome"],
          'weight': '1.0 kg',
          'quantity': 1,
          'price': (produto["preco"] as num).toDouble(),
          'imageUrl': produto["imagem"], // Armazena a URL da imagem
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto não encontrado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Returning image'))
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
                    _scanProduct(barcodeData);
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
