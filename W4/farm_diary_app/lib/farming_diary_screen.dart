//farming_diary_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class FarmingDiaryScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FarmingDiaryScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _FarmingDiaryScreenState createState() => _FarmingDiaryScreenState();
}

class _FarmingDiaryScreenState extends State<FarmingDiaryScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> diaryEntries = [];
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isCameraOpen = false;
  String? _currentCategory;

  // Biến lưu thông tin nhập liệu (tach riêng notes cho từng loại)
  Map<String, String> _inputData = {
    'plantType': '',
    'plantNotes': '',
    'careMethod': '',
    'careNotes': '',
    'sprayChemical': '',
    'sprayNotes': '',
    'harvestAmount': '',
    'harvestNotes': '',
    'storageMethod': '',
    'storageNotes': '',
  };

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  //quan ly camera
  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    //dieu khien camera
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );

    //ham khoi dong
    await _controller!.initialize();
    setState(() {
      _isCameraReady = true;
      _isCameraOpen = true;
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _currentCategory == null) return;

    try {
      final XFile image = await _controller!.takePicture();
      setState(() {
        diaryEntries.add({
          'category': _currentCategory!,
          'imagePath': image.path,
          'data': Map.from(_inputData),
          'dateTime': DateTime.now(),
        });
        _resetForm();
        _exitCamera();
      });
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
    }
  }

  //chon anh tu thu vien
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && _currentCategory != null) {
      //cap nhat UI
      setState(() {
        diaryEntries.add({
          'category': _currentCategory!,
          'imagePath': image.path,
          'data': Map.from(_inputData),
          'dateTime': DateTime.now(),
        });
        _resetForm();
      });
    }
  }

  void _resetForm() {
    setState(() {
      _inputData = {
        'plantType': '',
        'plantNotes': '',
        'careMethod': '',
        'careNotes': '',
        'sprayChemical': '',
        'sprayNotes': '',
        'harvestAmount': '',
        'harvestNotes': '',
        'storageMethod': '',
        'storageNotes': '',
      };
      _currentCategory = null;
    });
  }

  void _showInputForm(String category) {
    setState(() {
      _currentCategory = category;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputField(category),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt),
                        label: Text('Chụp ảnh'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.pop(context);
                            await _initCamera();
                            //neu chon nut camera thi goi mo cam
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.photo_library),
                        label: Text('Chọn ảnh'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.pop(context);
                            _pickImageFromGallery();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  //dong form
                  TextButton(
                    child: Text('Hủy bỏ'),
                    onPressed: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  //truong nhap du lieu theo danh muc nguoi dung chon
  Widget _buildInputField(String category) {
    switch (category) {
      case 'Giống cây':
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Loại giống cây',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
              onSaved: (value) => _inputData['plantType'] = value!,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _inputData['plantNotes'] = value ?? '',
            ),
          ],
        );
      case 'Chăm sóc':
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phương pháp chăm sóc',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
              onSaved: (value) => _inputData['careMethod'] = value!,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _inputData['careNotes'] = value ?? '',
            ),
          ],
        );
      case 'Phun thuốc':
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Loại thuốc phun',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
              onSaved: (value) => _inputData['sprayChemical'] = value!,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _inputData['sprayNotes'] = value ?? '',
            ),
          ],
        );
      case 'Thu hoạch':
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Sản lượng thu hoạch',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
              onSaved: (value) => _inputData['harvestAmount'] = value!,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _inputData['harvestNotes'] = value ?? '',
            ),
          ],
        );
      case 'Bảo quản':
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phương pháp bảo quản',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
              onSaved: (value) => _inputData['storageMethod'] = value!,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _inputData['storageNotes'] = value ?? '',
            ),
          ],
        );
      default:
        return SizedBox();
    }
  }

  void _exitCamera() {
    setState(() {
      _isCameraOpen = false;
      _controller?.dispose();
      _controller = null;
      _isCameraReady = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: _isCameraOpen ? 7 : 1,
            child: _isCameraOpen
                ? Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _exitCamera,
                  ),
                ),
              ],
            )
                : Center(
              child: Text(
                'Chọn một hành động để bắt đầu',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            flex: _isCameraOpen ? 3 : 9,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildActionButton('Giống cây', Icons.spa),
                      _buildActionButton('Chăm sóc', Icons.medical_services),
                      _buildActionButton('Phun thuốc', Icons.sanitizer),
                      _buildActionButton('Thu hoạch', Icons.agriculture),
                      _buildActionButton('Bảo quản', Icons.warehouse),
                    ],
                  ),
                ),
                Expanded(
                  child: diaryEntries.isEmpty
                      ? Center(
                    child: Text(
                      'Chưa có nhật ký nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: diaryEntries.length,
                    itemBuilder: (context, index) {
                      final entry = diaryEntries[index];
                      return Card(
                        child: ListTile(
                          leading: Image.file(
                            File(entry['imagePath']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(entry['category']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getSummaryText(entry)),
                              Text(
                                '${entry['dateTime'].toLocal()}'.split(' ')[0],
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showDetailDialog(entry, context);
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                diaryEntries.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //tao tom tat du lieu
  String _getSummaryText(Map<String, dynamic> entry) {
    switch (entry['category']) {
      case 'Giống cây':
        return '${entry['data']['plantType']} - ${entry['data']['plantNotes']}';
      case 'Chăm sóc':
        return '${entry['data']['careMethod']} - ${entry['data']['careNotes']}';
      case 'Phun thuốc':
        return '${entry['data']['sprayChemical']} - ${entry['data']['sprayNotes']}';
      case 'Thu hoạch':
        return '${entry['data']['harvestAmount']} - ${entry['data']['harvestNotes']}';
      case 'Bảo quản':
        return '${entry['data']['storageMethod']} - ${entry['data']['storageNotes']}';
      default:
        return '';
    }
  }

  //hien thi chi tiet
  void _showDetailDialog(Map<String, dynamic> entry, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chi tiết ${entry['category']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(File(entry['imagePath'])),
                SizedBox(height: 16),
                Text(_getDetailText(entry)),
                SizedBox(height: 8),
                Text(
                  'Ngày: ${entry['dateTime'].toLocal()}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  //mo ta chi tiet cho muc nhap thong tin
  String _getDetailText(Map<String, dynamic> entry) {
    switch (entry['category']) {
      case 'Giống cây':
        return 'Loại giống cây: ${entry['data']['plantType']}\nGhi chú: ${entry['data']['plantNotes']}';
      case 'Chăm sóc':
        return 'Phương pháp: ${entry['data']['careMethod']}\nGhi chú: ${entry['data']['careNotes']}';
      case 'Phun thuốc':
        return 'Loại thuốc: ${entry['data']['sprayChemical']}\nGhi chú: ${entry['data']['sprayNotes']}';
      case 'Thu hoạch':
        return 'Sản lượng: ${entry['data']['harvestAmount']}\nGhi chú: ${entry['data']['harvestNotes']}';
      case 'Bảo quản':
        return 'Phương pháp: ${entry['data']['storageMethod']}\nGhi chú: ${entry['data']['storageNotes']}';
      default:
        return '';
    }
  }

  //tao cac nut hanh dong co bieu truong va nhan giup tai su dung
  Widget _buildActionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () => _showInputForm(label),
    );
  }
}