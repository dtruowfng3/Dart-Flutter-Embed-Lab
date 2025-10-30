//import_page.dart
import '../models/deal.dart';
import 'package:flutter/material.dart';
import 'scanner_page.dart';
import '../models/product.dart';
import '../services/database_helper.dart';
import 'product_declaration.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _formKey = GlobalKey<FormState>();
  String _scannedId = '';
  final _quantityController = TextEditingController();
  bool _isScanned = false;
  Product? _product;

  Future _scanProduct() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScannerPage()),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _scannedId = result;
        });

        // Kiểm tra xem sản phẩm có tồn tại không
        final exists = await DatabaseHelper.instance.productExists(result);
        if (exists) {
          final product = await DatabaseHelper.instance.getProduct(result);
          setState(() {
            _product = product;
            _isScanned = true;
          });
        } else {
          // Chuyển hướng ngay lập tức đến trang khai báo sản phẩm
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sản phẩm không tồn tại. Vui lòng khai báo sản phẩm trước.',
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDeclarationPage(productId: result),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi quét mã QR: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _importProduct() async {
    if (_formKey.currentState!.validate() && _product != null) {
      try {
        final quantity = int.parse(_quantityController.text);

        // Update product quantity_product!.quantity
        final newQuantity = _product!.quantity + quantity;
        await DatabaseHelper.instance.updateProductQuantity(
          _scannedId,
          newQuantity,
        );

        // Add deal record
        final deal = Deal(
          productId: _scannedId,
          type: 'import',
          quantity: quantity,
          timestamp: DateTime.now(),
        );
        await DatabaseHelper.instance.addDeal(deal);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã nhập hàng thành công.')));

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi nhập hàng: $e')));
      }
    }
  }

  void _resetForm() {
    setState(() {
      _scannedId = '';
      _quantityController.clear();
      _isScanned = false;
      _product = null;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập Hàng'), backgroundColor: Colors.greenAccent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 1: Quét mã QR sản phẩm
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Quét mã QR sản phẩm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _scanProduct,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Quét mã QR'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      if (_isScanned && _product != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID sản phẩm: ${_product!.id}',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Tên sản phẩm: ${_product!.name}',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Số lượng hiện tại: ${_product!.quantity}',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Step 2: Nhập số lượng nhập kho
                if (_isScanned && _product != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Nhập số lượng nhập kho',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng nhập',
                            hintText: 'Nhập số lượng nhập kho',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số lượng';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Số lượng phải là số nguyên';
                            }
                            if (int.parse(value) <= 0) {
                              return 'Số lượng phải lớn hơn 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _importProduct,
                          icon: const Icon(Icons.save),
                          label: const Text('Nhập hàng'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
