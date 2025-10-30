//deal_history.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_helper.dart';
import '../models/deal.dart';

class DealHistoryPage extends StatefulWidget {
  @override
  _DealHistoryPageState createState() => _DealHistoryPageState();
}

class _DealHistoryPageState extends State<DealHistoryPage> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final dateOnlyFormat = DateFormat('dd/MM/yyyy');
  List<Map<String, dynamic>> combinedDeals = [];
  List<Map<String, dynamic>> filteredDeals = [];
  bool isLoading = true;

  // Filter variables
  String? typeFilter; // 'import', 'export', or null (all)
  DateTime? startDate;
  DateTime? endDate;
  bool isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDealsWithProductNames();
  }

  Future<void> _loadDealsWithProductNames() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Tải trực tiếp tất cả các giao dịch
      final List<Deal> allDeals = await DatabaseHelper.instance.getAllDeals();

      // Sắp xếp theo thời gian, gần đây nhất trước
      allDeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Tạo một set các productId để lấy thông tin sản phẩm
      final Set<String> productIds =
          allDeals.map((deal) => deal.productId).toSet();

      // Tạo map tên sản phẩm (chỉ tải những sản phẩm có trong giao dịch)
      final Map<String, String> productNameMap = {};
      for (var productId in productIds) {
        try {
          final product = await DatabaseHelper.instance.getProduct(productId);
          if (product != null) {
            productNameMap[productId] = product.name;
          } else {
            productNameMap[productId] = 'Sản phẩm không xác định';
          }
        } catch (e) {
          productNameMap[productId] = 'Sản phẩm không xác định';
        }
      }

      // Kết hợp dữ liệu giao dịch với tên sản phẩm
      final List<Map<String, dynamic>> combined = allDeals.map((deal) {
        return {
          'deal': deal,
          'productName':
              productNameMap[deal.productId] ?? 'Sản phẩm không xác định',
          'productId': deal.productId,
        };
      }).toList();

      setState(() {
        combinedDeals = combined;
        _applyFilters(); // Apply filters to initialize filteredDeals
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        combinedDeals = [];
        filteredDeals = [];
      });

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      filteredDeals = combinedDeals.where((item) {
        final deal = item['deal'] as Deal;

        // Apply type filter
        if (typeFilter != null && deal.type != typeFilter) {
          return false;
        }

        // Apply date range filter
        if (startDate != null) {
          final startDateTime = DateTime(
            startDate!.year,
            startDate!.month,
            startDate!.day,
          );

          if (deal.timestamp.isBefore(startDateTime)) {
            return false;
          }
        }

        if (endDate != null) {
          final endDateTime = DateTime(
            endDate!.year,
            endDate!.month,
            endDate!.day,
            23,
            59,
            59,
          );

          if (deal.timestamp.isAfter(endDateTime)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      typeFilter = null;
      startDate = null;
      endDate = null;
      _applyFilters();
    });
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  void _shareHistoryReport() {
    if (filteredDeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có dữ liệu để chia sẻ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Tạo nội dung báo cáo
    String report = "LỊCH SỬ NHẬP/XUẤT KHO HÀNG\n\n";

    // Thêm thời gian xuất báo cáo
    report +=
        "Thời gian xuất báo cáo: ${dateFormat.format(DateTime.now())}\n\n";

    // Thêm thông tin về bộ lọc đã áp dụng
    report += "Bộ lọc đã áp dụng:\n";
    report +=
        "Loại giao dịch: ${typeFilter == 'import' ? 'Nhập kho' : typeFilter == 'export' ? 'Xuất kho' : 'Tất cả'}\n";
    report +=
        "Từ ngày: ${startDate != null ? dateOnlyFormat.format(startDate!) : 'Không giới hạn'}\n";
    report +=
        "Đến ngày: ${endDate != null ? dateOnlyFormat.format(endDate!) : 'Không giới hạn'}\n\n";

    // Thêm thông tin tổng hợp
    int totalImports = 0;
    int totalExports = 0;

    for (var item in filteredDeals) {
      final deal = item['deal'] as Deal;
      if (deal.type == 'import') {
        totalImports++;
      } else {
        totalExports++;
      }
    }

    report += "Tổng số giao dịch: ${filteredDeals.length}\n";
    report += "Nhập kho: $totalImports lần\n";
    report += "Xuất kho: $totalExports lần\n\n";

    // Thêm chi tiết từng giao dịch
    report += "CHI TIẾT GIAO DỊCH:\n";

    for (int i = 0; i < filteredDeals.length; i++) {
      final deal = filteredDeals[i]['deal'] as Deal;
      final productName = filteredDeals[i]['productName'] as String;

      report +=
          "${i + 1}. ${deal.type == 'import' ? 'NHẬP' : 'XUẤT'}: $productName\n";
      report += "   Mã SP: ${deal.productId}\n";
      report += "   Số lượng: ${deal.quantity}\n";
      report += "   Thời gian: ${dateFormat.format(deal.timestamp)}\n";
      if (i < filteredDeals.length - 1) {
        report += "\n";
      }
    }

    // Chia sẻ báo cáo
    Share.share(report, subject: 'Báo cáo lịch sử nhập xuất kho');
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isFilterVisible ? null : 0,
      child: Card(
        margin: EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Loại giao dịch
              Text(
                'Loại giao dịch:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterChip(
                    label: 'Tất cả',
                    selected: typeFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        typeFilter = null;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Nhập kho',
                    selected: typeFilter == 'import',
                    onSelected: (selected) {
                      setState(() {
                        typeFilter = selected ? 'import' : null;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Xuất kho',
                    selected: typeFilter == 'export',
                    onSelected: (selected) {
                      setState(() {
                        typeFilter = selected ? 'export' : null;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Thời gian
              Text(
                'Khoảng thời gian:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await _selectDate(context, startDate);
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              startDate != null
                                  ? 'Từ: ${dateOnlyFormat.format(startDate!)}'
                                  : 'Từ ngày',
                              style: TextStyle(
                                color: startDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await _selectDate(context, endDate);
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              endDate != null
                                  ? 'Đến: ${dateOnlyFormat.format(endDate!)}'
                                  : 'Đến ngày',
                              style: TextStyle(
                                color: endDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Nút áp dụng và đặt lại
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text('Đặt lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      setState(() {
                        isFilterVisible = false;
                      });
                    },
                    child: Text('Áp dụng'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildFilterSummary() {
    if (typeFilter == null && startDate == null && endDate == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Đang lọc: ${typeFilter != null ? (typeFilter == 'import' ? 'Nhập kho' : 'Xuất kho') + ' ' : ''}${startDate != null ? 'từ ${dateOnlyFormat.format(startDate!)} ' : ''}${endDate != null ? 'đến ${dateOnlyFormat.format(endDate!)} ' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear, size: 18),
            onPressed: _resetFilters,
            tooltip: 'Xóa bộ lọc',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch Sử Nhập/Xuất',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                isFilterVisible = !isFilterVisible;
              });
            },
            tooltip: 'Lọc danh sách',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareHistoryReport,
            tooltip: 'Chia sẻ báo cáo',
          ),
        ],
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          _buildFilterSummary(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredDeals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_outlined,
                                size: 72, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              typeFilter != null ||
                                      startDate != null ||
                                      endDate != null
                                  ? 'Không tìm thấy giao dịch phù hợp với bộ lọc'
                                  : 'Chưa có lịch sử giao dịch',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                            if (typeFilter != null ||
                                startDate != null ||
                                endDate != null)
                              TextButton(
                                onPressed: _resetFilters,
                                child: Text('Xóa bộ lọc'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredDeals.length,
                        itemBuilder: (context, index) {
                          final deal = filteredDeals[index]['deal'] as Deal;
                          final productName =
                              filteredDeals[index]['productName'] as String;

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: deal.type == 'import'
                                    ? Colors.green[100]
                                    : Colors.orange[100],
                                child: Icon(
                                  deal.type == 'import'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: deal.type == 'import'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              title: Text(
                                productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    'Mã: ${deal.productId}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Thời gian: ${dateFormat.format(deal.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: deal.type == 'import'
                                      ? Colors.green[50]
                                      : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: deal.type == 'import'
                                        ? Colors.green[300]!
                                        : Colors.orange[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  deal.type == 'import'
                                      ? '+${deal.quantity}'
                                      : '-${deal.quantity}',
                                  style: TextStyle(
                                    color: deal.type == 'import'
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
