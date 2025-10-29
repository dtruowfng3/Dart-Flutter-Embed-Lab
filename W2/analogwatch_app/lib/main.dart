import 'dart:async'; // Thư viện để sử dụng Timer
import 'dart:math'; // Thư viện để sử dụng các hàm toán học (cos, sin, pi)
import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng UI

void main() => runApp(ClockApp()); // Khởi tạo ứng dụng Flutter

class ClockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch Analog', // Tiêu đề của ứng dụng
      debugShowCheckedModeBanner: false, // Tắt banner debug ở góc phải trên cùng
      home: ClockHome(), // Giao diện chính của ứng dụng
    );
  }
}

class ClockHome extends StatefulWidget {
  const ClockHome({Key? key}) : super(key: key);
  @override
  _ClockHomeState createState() => _ClockHomeState(); // Tạo trạng thái cho ClockHome
}

class _ClockHomeState extends State<ClockHome> {
  late Timer _timer; // Định nghĩa Timer để cập nhật thời gian liên tục
  DateTime _currentTime = DateTime.now(); // Lấy thời gian hiện tại

  // Danh sách các múi giờ và thông tin tương ứng
  final List<Map<String, dynamic>> timezones = [
    {'city': 'California', 'zone': 'America/Los_Angeles', 'offset': -7, 'country': 'USA'},
    {'city': 'New York', 'zone': 'America/New_York', 'offset': -4, 'country': 'USA'},
    {'city': 'London', 'zone': 'Europe/London', 'offset': 1, 'country': 'UK'},
    {'city': 'Cape Town', 'zone': 'Africa/Johannesburg', 'offset': 2, 'country': 'South Africa'},
    {'city': 'Moscow', 'zone': 'Europe/Moscow', 'offset': 3, 'country': 'Russia'},
    {'city': 'Dubai', 'zone': 'Asia/Dubai', 'offset': 4, 'country': 'UAE'},
    {'city': 'Kolkata', 'zone': 'Asia/Kolkata', 'offset': 5.5, 'country': 'India'},
    {'city': 'Ho Chi Minh City', 'zone': 'Asia/Ho_Chi_Minh', 'offset': 7, 'country': 'Vietnam'},
    {'city': 'Beijing', 'zone': 'Asia/Shanghai', 'offset': 8, 'country': 'China'},
    {'city': 'Tokyo', 'zone': 'Asia/Tokyo', 'offset': 9, 'country': 'Japan'},
  ];

  int _selectedTimeZoneIndex = 4; // Chỉ số múi giờ mặc định là Moscow
  bool _isDayTime = true; // Biến xác định liệu thời gian có phải là ban ngày không

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now(); // Cập nhật thời gian mỗi giây
        _updateDayNightStatus(); // Cập nhật trạng thái ban ngày hay đêm
      });
    });
  }

  // Hàm cập nhật trạng thái ban ngày hay đêm
  void _updateDayNightStatus() {
    final currentHour = _currentTime.toUtc().add(
      Duration(hours: timezones[_selectedTimeZoneIndex]['offset'].toInt(),
          minutes: ((timezones[_selectedTimeZoneIndex]['offset'] -
              timezones[_selectedTimeZoneIndex]['offset'].toInt()) * 60).toInt()),
    ).hour;

    setState(() {
      _isDayTime = currentHour >= 6 && currentHour < 18; // Giờ ban ngày từ 6h sáng đến 6h tối
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Hủy bỏ timer khi widget bị hủy
    super.dispose();
  }

  // Hàm định dạng thời gian theo định dạng 12 giờ (AM/PM)
  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM'; // Kiểm tra là AM hay PM
    int hour = time.hour % 12;
    if (hour == 0) hour = 12; // Nếu giờ là 0 (12 giờ đêm), đổi thành 12
    String minute = time.minute.toString().padLeft(2, '0'); // Đảm bảo phút có 2 chữ số
    return '$hour:$minute $period'; // Trả về thời gian dạng 12 giờ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Huỳnh Kim Thiên, Võ Duy Trường'), // Tiêu đề trên thanh app bar
      ),
      backgroundColor: _isDayTime ? Color(0xFFe0f7fa) : Color(0xFF0d1b2a), // Màu nền thay đổi theo ngày/đêm
      body: Center(
        child: PageView.builder(
          controller: PageController(initialPage: _selectedTimeZoneIndex), // Quản lý trang
          itemCount: timezones.length, // Số trang là số múi giờ
          onPageChanged: (index) {
            setState(() {
              _selectedTimeZoneIndex = index; // Thay đổi múi giờ khi chuyển trang
              _updateDayNightStatus();
            });
          },
          itemBuilder: (context, index) {
            DateTime timeInSelectedZone = _currentTime.toUtc().add(
              Duration(hours: timezones[index]['offset'].toInt(),
                  minutes: ((timezones[index]['offset'] - timezones[index]['offset'].toInt()) * 60).toInt()),
            );

            bool isDay = timeInSelectedZone.hour >= 6 && timeInSelectedZone.hour < 18;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  painter: ClockPainter(timeInSelectedZone, isDay: isDay),
                  size: Size(300, 300), // Kích thước đồng hồ
                ),
                SizedBox(height: 30),
                Text(
                  timezones[index]['city'], // Hiển thị thành phố
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDay ? Colors.blue[800] : Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _formatTime(timeInSelectedZone), // Hiển thị thời gian đã được định dạng
                  style: TextStyle(
                    fontSize: 48,
                    color: isDay ? Colors.blue[700] : Colors.lightBlue[200],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${timezones[index]['country']}', // Hiển thị quốc gia
                  style: TextStyle(
                    fontSize: 36,
                    color: isDay ? Colors.blue[600] : Colors.lightBlue[100],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

//tuy chinh de ve dong ho
class ClockPainter extends CustomPainter {
  final DateTime time;
  final bool isDay;

  ClockPainter(this.time, {required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDay
            ? [Colors.white, Colors.blue[200]!]
            : [Color(0xFF1b263b), Color(0xFF415a77)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final borderPaint = Paint()
      ..color = isDay ? Colors.blueGrey : Color(0xFF778da9)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final centerDot = Paint()..color = isDay ? Color(0xFF1565C0) : Colors.orangeAccent;

    final textStyle = TextStyle(
      color: isDay ? Colors.deepPurple : Colors.lightBlue[100],
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(center, radius, borderPaint);

    // Vẽ các vạch chỉ giờ và phút
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180;
      final isHourTick = i % 5 == 0;

      final tickLength = isHourTick ? 12.0 : 6.0;
      tickPaint.strokeWidth = isHourTick ? 3 : 1;

      final start = Offset(
        center.dx + (radius - tickLength - 8) * cos(angle),
        center.dy + (radius - tickLength - 8) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 8) * cos(angle),
        center.dy + (radius - 8) * sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    // Vẽ các số trên mặt đồng hồ
    for (int i = 1; i <= 12; i++) {
      double angle = (i * 30) * pi / 180;
      double x = center.dx + (radius - 35) * cos(angle - pi / 2);
      double y = center.dy + (radius - 35) * sin(angle - pi / 2);

      final textSpan = TextSpan(text: '$i', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // Vẽ kim đồng hồ
    drawHand(canvas, center, time.hour % 12 * 30 + time.minute * 0.5, radius * 0.5,
        isDay ? Colors.blueAccent : Colors.blueAccent[200]!, 5);
    drawHand(canvas, center, time.minute * 6 + time.second * 0.1, radius * 0.7,
        isDay ? Colors.lightBlue : Colors.lightBlue[200]!, 3);
    drawHand(canvas, center, time.second * 6, radius * 0.9,
        isDay ? Colors.redAccent : Colors.orangeAccent, 2);

    canvas.drawCircle(center, 6, centerDot);
  }

  // Vẽ kim đồng hồ
  void drawHand(Canvas canvas, Offset center, double angleDegrees, double length, Color color, double width) {
    final angleRadians = angleDegrees * pi / 180;
    final handPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + length * cos(angleRadians - pi / 2),
        center.dy + length * sin(angleRadians - pi / 2),
      ),
      handPaint,
    );
  }

  // Đồng bộ lại khi có sự thay đổi
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
