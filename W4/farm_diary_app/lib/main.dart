//main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'farming_diary_screen.dart';
import 'traceability_screen.dart';

//khoi dong app
void main() async {
  //dam bao api camera
  WidgetsFlutterBinding.ensureInitialized();
  //danh sach camera
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký Trồng trọt',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(cameras: cameras),
    );
  }
}

class MainScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  //constructor cho MainScreen, nhận một key (tuỳ chọn) và một cameras (bắt buộc)
  //rồi truyền key đó lên StatelessWidget (lớp cha)
  // còn cameras thì giữ lại dùng trong class
  const MainScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //2 tab
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farm Diary\nKim Thiên - Duy Trường'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.agriculture), text: 'Nhật ký'),
              Tab(icon: Icon(Icons.qr_code), text: 'Truy xuất'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FarmingDiaryScreen(cameras: cameras),
            TraceabilityScreen(),
          ],
        ),
      ),
    );
  }
}