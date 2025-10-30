//home_page.dart
import 'package:flutter/material.dart';
import '../widgets/feature_tile.dart';
//import '../widgets/inventory_summary_card.dart';
import 'deal_history_page.dart';
import 'product_declaration.dart';
import 'import_page.dart';
import 'export_page.dart';
import 'inventory_report.dart';

class HomePage extends StatefulWidget {
  @override
  //lop logic cua homepage theo doi su thay doi
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  //bien: thong bao cho widget su thay doi
  final ValueNotifier<bool> _refreshTrigger = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Add observer to detect when app comes to foreground
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    //khi widget khong con su dung
    WidgetsBinding.instance.removeObserver(this);
    _refreshTrigger.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //khi ứng dụng thay đổi trạng thái vòng đời (như khi ứng dụng quay lại từ nền)
    if (state == AppLifecycleState.resumed) {
      _refreshTrigger.value = true;
    }
  }

  //điều hướng đến page khác
  void _navigateAndRefresh(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Trigger refresh when returning from another page
    _refreshTrigger.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
              'Kim Thiên - Duy Trường',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.info_outline, size: 20),
        //     onPressed: () => _showInfoDialog(context),
        //     tooltip: 'Thông tin',
        //   ),
        // ],
      ),
      //safearea dam bao cac noi dung khong bi che
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.lightBlueAccent,  // Màu của border
                    width: 1.5,          // Độ rộng của border
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Tùy chọn: bo góc border
                ),
                child: FeatureTile(
                  icon: Icons.inventory_2,
                  iconColor: Colors.lightBlueAccent,
                  title: 'Khai Báo Sản Phẩm',
                  onTap: () => _navigateAndRefresh(
                    context,
                    ProductDeclarationPage(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow,  // Màu của border
                    width: 1.5,            // Độ rộng của border
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Tùy chọn: bo góc border
                ),
                child: FeatureTile(
                  icon: Icons.assessment_outlined,
                  iconColor: Colors.yellow,
                  title: 'Báo Cáo Tồn Kho',
                  onTap: () => _navigateAndRefresh(
                    context,
                    InventoryReportPage(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.greenAccent,  // Màu của border
                    width: 1.5,           // Độ rộng của border
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Tùy chọn: bo góc border
                ),
                child: FeatureTile(
                  icon: Icons.keyboard_double_arrow_down,
                  iconColor: Colors.greenAccent,
                  title: 'Nhập Hàng',
                  onTap: () => _navigateAndRefresh(context, ImportPage()),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.redAccent,  // Màu của border
                    width: 1.5,            // Độ rộng của border
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Tùy chọn: bo góc border
                ),
                child: FeatureTile(
                  icon: Icons.keyboard_double_arrow_up,
                  iconColor: Colors.redAccent,
                  title: 'Xuất Hàng',
                  onTap: () => _navigateAndRefresh(context, ExportPage()),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey,  // Màu của border
                    width: 1.5,           // Độ rộng của border
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Tùy chọn: bo góc border
                ),
                child: FeatureTile(
                  icon: Icons.keyboard_double_arrow_down,
                  iconColor: Colors.blueGrey,
                  title: 'Lịch sử',
                  onTap: () => _navigateAndRefresh(context, DealHistoryPage()),
                ),
              ),
              SizedBox(height: 10),
            ]

        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Row(
          //   children: [
          //     Icon(
          //       Icons.info_outline,
          //       color: Theme.of(context).primaryColor,
          //       size: 28,
          //     ),
          //     SizedBox(width: 10),
          //     Flexible(child: Text('Thông tin ứng dụng')),
          //   ],
          // ),
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: [
          //       ListTile(
          //         contentPadding: EdgeInsets.zero,
          //         title: Text('Tên ứng dụng'),
          //         subtitle: Text('NAME'),
          //         leading: Icon(Icons.android),
          //       ),
          //       ListTile(
          //         contentPadding: EdgeInsets.zero,
          //         title: Text('Phiên bản'),
          //         subtitle: Text('1.0.0'),
          //         leading: Icon(Icons.verified_outlined),
          //       ),
          //       ListTile(
          //         contentPadding: EdgeInsets.zero,
          //         title: Text('Tác giả'),
          //         subtitle: Text('ABC'),
          //         leading: Icon(Icons.logo_dev),
          //       ),
          //     ],
          //   ),
          // ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}
