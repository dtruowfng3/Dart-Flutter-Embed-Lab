//product_declaration.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; //json ma hoa
import '../services/database_helper.dart';
import '../models/product.dart';
import '../models/deal.dart';

class ProductDeclarationPage extends StatefulWidget {
  @override
  _ProductDeclarationPageState createState() => _ProductDeclarationPageState();
}

class _ProductDeclarationPageState extends State<ProductDeclarationPage> {
  final _formKey = GlobalKey<FormState>();
  //bien dieu khien text editor
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _generatedId;
  String? _qrData;
  bool _showQrCode = false;

  // Tạo id rieng cho san pham
  String _generateProductId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tạo ID mới nếu chưa có
        final productId = _generatedId ?? _generateProductId();

        //đối tượng Product từ tên và số lượng mà người dùng nhập vào
        final product = Product(
          id: productId,
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
        );

        // Tạo dữ liệu QR code
        //data của sản phẩm được mã hóa thành một chuỗi JSON và lưu vào _qrData
        setState(() {
          _generatedId = productId;
          _qrData = jsonEncode({
            'id': productId,
            'name': _nameController.text,
            'quantity': _quantityController.text,
          });
          _showQrCode = true;
        });

        // Lưu vào database
        await DatabaseHelper.instance.createProduct(product);

        // Ghi lại lịch sử nhập kho
        if (int.parse(_quantityController.text) > 0) {
          final deal = Deal(
            productId: productId,
            type: "import",
            quantity: int.parse(_quantityController.text),
            timestamp: DateTime.now(),
          );
          await DatabaseHelper.instance.addDeal(deal);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sản phẩm đã được tạo thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu sản phẩm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //reset form de khai bao san pham moi
  void _resetForm() {
    setState(() {
      _generatedId = null;
      _qrData = null;
      _showQrCode = false;
      _nameController.clear();
      _quantityController.clear();
    });
  }

  //giai phong tai nguyen
  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Sản Phẩm Mới')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form nhập thông tin
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  prefixIcon: Icon(Icons.inventory),
                ),

                //kiem tra du lieu
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Số lượng',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập số lượng';
                  if (int.tryParse(value) == null) return 'Số lượng phải là số';
                  if (int.parse(value) < 0) return 'Số lượng không thể âm';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Nút tạo sản phẩm
              ElevatedButton.icon(
                onPressed: _saveProduct,
                icon: Icon(Icons.add),
                label: Text('Tạo Sản Phẩm'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 32),

              // Hiển thị thông tin sản phẩm và QR code
              if (_showQrCode) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Thông tin sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Icon(Icons.qr_code),
                          title: Text('Mã sản phẩm'),
                          subtitle: Text(_generatedId!),
                        ),
                        ListTile(
                          leading: Icon(Icons.inventory),
                          title: Text('Tên sản phẩm'),
                          subtitle: Text(_nameController.text),
                        ),
                        ListTile(
                          leading: Icon(Icons.format_list_numbered),
                          title: Text('Số lượng'),
                          subtitle: Text(_quantityController.text),
                        ),
                        SizedBox(height: 20),

                        // Hiển thị QR code
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Mã QR sản phẩm',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                size: 200,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Quét mã này để xem thông tin sản phẩm',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _resetForm,
                  child: Text('Tạo sản phẩm mới'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}