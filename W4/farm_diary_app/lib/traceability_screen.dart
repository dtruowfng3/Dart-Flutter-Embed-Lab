//traceability_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({Key? key}) : super(key: key);

  @override
  _TraceabilityScreenState createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String scanResult = 'Quét mã QR để xem thông tin truy xuất nguồn gốc';
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  //dinh dang thong tin san pham se hien thi
  String _formatProductInfo(Map<String, dynamic> product) {
    return '''
=== THÔNG TIN TRUY XUẤT NGUỒN GỐC ===

Đặc điểm sản phẩm:
- Tên: ${product['product_name']}
- Giống: ${product['product_type']}
- Trọng lượng: ${product['weight']}kg

Cơ sở sản xuất:
- Tên: ${product['farm_name']}
- Địa chỉ: ${product['farm_address']}
- Chứng nhận: ${product['certification']}

Thông tin canh tác:
- Ngày trồng: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(product['planting_date']))}
- Ngày thu hoạch: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(product['harvest_date']))}
- Phương pháp: ${product['farming_method']}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _fetchProductInfo(barcode.rawValue!);
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  scanResult,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => cameraController.toggleTorch(),
                  child: const Icon(Icons.flashlight_on),
                ),
                ElevatedButton(
                  onPressed: () => cameraController.switchCamera(),
                  child: const Icon(Icons.cameraswitch),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //doi tuong bat dong bo giup kiem tra qr code va tra ve
  //du lieu dua tren qr code tuong ung
  Future<void> _fetchProductInfo(String qrCode) async {
    final product = await dbHelper.getProductByQrCode(qrCode);
    setState(() {
      scanResult = product != null
          ? _formatProductInfo(product)
          : 'Không tìm thấy thông tin cho mã QR: $qrCode';
    });
  }
}