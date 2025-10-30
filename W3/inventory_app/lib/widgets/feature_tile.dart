//feature_tile.dart
import 'package:flutter/material.dart';

//widget chung de tai su dung khi muon lam cac chuc nang khac
//chi can goi la feature tile la su dung lai
class FeatureTile extends StatelessWidget {
  //cac thuoc tinh cua o chuc nang
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap; //xu ly su kien

  //cau truc
  const FeatureTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor), // Áp dụng màu sắc cho icon
      title: Text(title),
      onTap: onTap,
    );
  }
}
