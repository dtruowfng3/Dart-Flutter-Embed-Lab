//scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

//ful widget la co trang thai thay doi
class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  //dieu khien camera
  MobileScannerController cameraController = MobileScannerController();
  bool _flashOn = false;
  bool _hasScanned = false; //chi quet 1 lan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //giao dien trang scanner
      appBar: AppBar(
        title: Text('Quét Mã QR'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _flashOn = !_flashOn;
                cameraController.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          //widget de quet qr
          MobileScanner(
            controller: cameraController,
            //xu ly su kien khi phat hien qr
            onDetect: (capture) {
              if (!_hasScanned) {
                setState(() {
                  _hasScanned = true;
                });

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                  final String code = barcodes[0].rawValue!;
                  //tra gia tri qua navigator
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          //khung quet qr
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          //widget layout huong dan quet ma
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Đặt mã QR vào khung',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    //giai phong tai nguyen khi khong sd camera nua
    cameraController.dispose();
    super.dispose();
  }
}
