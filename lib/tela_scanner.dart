import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_analyze_image.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_controller.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_pageview.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_returning_image.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_simple.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_window.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_zoom.dart';
import 'package:carrinhodesupermercado/scanner/mobile_scanner_overlay.dart';
import 'package:carrinhodesupermercado/scanner/picklist/picklist_result.dart';

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  Widget _buildItem(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner Example')),
      body: Center(
        child: ListView(
          children: [
            _buildItem(
              context,
              'MobileScanner Simple',
              const BarcodeScannerSimple(),
            ),
            _buildItem(
              context,
              'MobileScanner with Controller',
              const BarcodeScannerWithController(),
            ),
            _buildItem(
              context,
              'MobileScanner with ScanWindow',
              const BarcodeScannerWithScanWindow(),
            ),
            _buildItem(
              context,
              'MobileScanner with Controller (return image)',
              const BarcodeScannerReturningImage(),
            ),
            _buildItem(
              context,
              'MobileScanner with zoom slider',
              const BarcodeScannerWithZoom(),
            ),
            _buildItem(
              context,
              'MobileScanner with PageView',
              const BarcodeScannerPageView(),
            ),
            _buildItem(
              context,
              'MobileScanner with Overlay',
              const BarcodeScannerWithOverlay(),
            ),
            _buildItem(
              context,
              'Analyze image from file',
              const BarcodeScannerAnalyzeImage(),
            ),
            _buildItem(
              context,
              'Picklist mode',
              const PicklistResult(),
            ),
          ],
        ),
      ),
    );
  }
}
