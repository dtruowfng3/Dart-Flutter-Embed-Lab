import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // giao dien chinh

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(InventoryApp());
}

//widget Stateless (không có trạng thái thay đổi theo thời gian)
class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //tat banner debug
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Kho Hàng',
      theme: ThemeData(
        //mau chu dao
        primaryColor: Color(0xFF1EB308),
        //mau trang
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        //thanh tieu de
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      //hien thi widget khi mo app
      home: HomePage(),
    );
  }
}
