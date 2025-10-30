//inventory_report.dart
import 'package:flutter/material.dart';
import "package:share_plus/share_plus.dart";
import '../models/product.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

import 'deal_history_page.dart';


//class fulwidget thay doi trang thai thong qua lop state
//lop state xu ly logic, yeu cau cap nhat giao dien
//widget build se la cach ma minh xay dung giao dien the nao

//quan ly giao dien report
class InventoryReportPage extends StatefulWidget {
  @override
  _InventoryReportPageState createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  final ValueNotifier<bool> _refreshTrigger = ValueNotifier<bool>(false);
  //danh sach san pham
  List<Product> _products = [];
  //loading?
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }


  //ham tai du lieu
  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
    });

    //lay tu database helper
    final products = await DatabaseHelper.instance.getAllProducts();

    setState(() {
      _products = products;
      _loading = false;
    });
  }

  //tao bao bao chuoi van ban, share bao cao qua cac ung dung khac
  void _shareInventoryReport() {
    // Kiểm tra xem có dữ liệu để chia sẻ không
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có dữ liệu để chia sẻ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String report = "BÁO CÁO TỒN KHO\n\n";
    report +=
        "Thời gian xuất báo cáo: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n\n";

    // Thêm thông tin tổng hợp
    report += "Tổng số sản phẩm: ${_products.length}\n";
    int totalQuantity = _products.fold(
      0,
      (sum, product) => sum + product.quantity,
    );
    report += "Tổng số lượng: $totalQuantity sản phẩm\n\n";

    // Chi tiết từng sản phẩm
    report += "CHI TIẾT SẢN PHẨM:\n";
    for (int i = 0; i < _products.length; i++) {
      var product = _products[i];
      report += "${i + 1}. ${product.name}\n";
      report += "   Mã SP: ${product.id}\n";
      report += "   Số lượng: ${product.quantity}\n";
      if (i < _products.length - 1) {
        report += "\n";
      }
    }

    Share.share(report, subject: 'Báo cáo tồn kho');
  }

  void _navigateAndRefresh(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Trigger refresh when returning from another page
    _refreshTrigger.value = true;
  }

  //giao dien va hien thi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Báo Cáo Tồn Kho'),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: _shareInventoryReport),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _navigateAndRefresh(context, DealHistoryPage()),
      //   tooltip: 'Lịch Sử Nhập Xuất',
      //   child: const Icon(Icons.history),
      // ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text('Không có sản phẩm nào trong kho.'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text('ID: ${product.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: product.quantity > 0
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'SL: ${product.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: product.quantity > 0
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.delete('products', 'id = ?', [productId]);
      _loadProducts();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa sản phẩm')));
    }
  }
}
