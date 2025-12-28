import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sport_booking_project/model/checkbox_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/model/field_order.dart';
import 'package:sport_booking_project/model/sport_field.dart';
import 'package:sport_booking_project/modules/root/root_view.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/utils/dummy_data.dart';
import 'package:sport_booking_project/utils/time_utils.dart';

class BookingView extends StatefulWidget {
  SportField field;

  BookingView({required this.field});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  // --- GIỮ NGUYÊN 100% BIẾN LOGIC CỦA BẠN ---
  final int _currentMonth = TimeUtils.getCurrentMonth();
  final int _currentYear = TimeUtils.getCurrentYear();
  int _selectedMonth = TimeUtils.getCurrentMonth();

  // SỬA: Ép kiểu lấy tên tháng tiếng Việt chuẩn
  String _selectedMonthName = DateFormat('MMMM', 'vi').format(DateTime.now());

  int _selectedYear = TimeUtils.getCurrentYear();
  final bool _isNextMonthValid = true;
  bool _isPrevMonthValid = false;
  List<int> _availableDates = TimeUtils.getAvailableDateList(
      month: TimeUtils.getCurrentMonth(), year: TimeUtils.getCurrentYear());
  int _selectedDate = 0;

  final String _selectedTime = "";

  final TextEditingController _controller = TextEditingController();
  final dateFormat = DateFormat("EEEE, dd MMM yyyy", "vi"); // Đổi locale sang 'vi'
  int _totalBill = 0;
  bool _isLoading = false;
  bool _enableCreateOrderBtn = false;
  final List<String> _selectedTimes = [];

  // --- HỆ MÀU GO SPORT ---
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color customBrown = const Color(0xFF8D6E63);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  // --- GIỮ NGUYÊN LOGIC CHECK TRÙNG LỊCH ---
  Future<bool> _checkAvailability(String venueId, String date, List<String> times) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('orders')
          .where('venueId', isEqualTo: venueId)
          .where('selectedDate', isEqualTo: date)
          .get();

      for (var doc in result.docs) {
        List<dynamic> bookedTimes = doc['selectedTime'];
        for (String time in times) {
          if (bookedTimes.contains(time)) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      print("Lỗi check trùng: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMint, // Đổi màu nền nền
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            title: Text("Đặt lịch sân", style: TextStyle(color: darkForest, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            centerTitle: true,
            foregroundColor: darkForest,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkForest, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding:
            const EdgeInsets.only(right: 24, left: 24, bottom: 24, top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Tên sân", // Việt hóa
                        style: subTitleTextStyle.copyWith(color: darkForest),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border:
                            Border.all(color: primaryEmerald.withOpacity(0.1), width: 1),
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: primaryEmerald),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(widget.field.name,
                                style: normalTextStyle.copyWith(
                                    color: darkForest,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Chọn ngày", style: subTitleTextStyle.copyWith(color: darkForest)), // Việt hóa
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_isPrevMonthValid) {
                                        setState(() {
                                          if (_selectedMonth - 1 == 0) {
                                            _selectedMonth = 12;
                                            _selectedYear = _selectedYear - 1;
                                          } else {
                                            _selectedMonth = _selectedMonth - 1;
                                          }
                                          _selectedMonthName = DateFormat('MMMM', 'vi').format(DateTime(_selectedYear, _selectedMonth));
                                          _isPrevMonthValid =
                                              _selectedMonth > _currentMonth ||
                                                  _selectedYear > _currentYear;
                                          _availableDates =
                                              TimeUtils.getAvailableDateList(
                                                  month: _selectedMonth,
                                                  year: _selectedYear);
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: (_isPrevMonthValid)
                                            ? primaryEmerald
                                            : neutral50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 16,
                                        color: (_isPrevMonthValid)
                                            ? Colors.white
                                            : neutral700,
                                      ),
                                    ),
                                  ),
                                  // Hiển thị tên tháng tiếng Việt viết hoa chữ cái đầu
                                  Text("${_selectedMonthName[0].toUpperCase()}${_selectedMonthName.substring(1)} $_selectedYear",
                                      style: descTextStyle.copyWith(color: primaryEmerald, fontWeight: FontWeight.bold, fontSize: 16)),
                                  GestureDetector(
                                    onTap: () {
                                      if (_isNextMonthValid) {
                                        setState(() {
                                          if (_selectedMonth + 1 == 13) {
                                            _selectedMonth = 1;
                                            _selectedYear = _selectedYear + 1;
                                          } else {
                                            _selectedMonth = _selectedMonth + 1;
                                          }
                                          _selectedMonthName = DateFormat('MMMM', 'vi').format(DateTime(_selectedYear, _selectedMonth));
                                          _isPrevMonthValid =
                                              _selectedMonth > _currentMonth ||
                                                  _selectedYear > _currentYear;
                                          _availableDates =
                                              TimeUtils.getAvailableDateList(
                                                  month: _selectedMonth,
                                                  year: _selectedYear);
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: (_isNextMonthValid)
                                            ? primaryEmerald
                                            : neutral50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: (_isNextMonthValid)
                                            ? Colors.white
                                            : neutral700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.0, // Hình vuông to đẹp
                                ),
                                itemCount: _availableDates.length,
                                itemBuilder: (context, index) {
                                  int day = _availableDates[index];
                                  bool isSelected = _selectedDate == day;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = day;
                                        _enableCreateOrderBtn = _selectedTimes.isNotEmpty && _selectedDate != 0;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: isSelected ? primaryEmerald : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: isSelected ? primaryEmerald : neutral200,
                                              width: 1)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        day.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : darkForest,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Chọn khung giờ", style: subTitleTextStyle.copyWith(color: darkForest)), // Việt hóa
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  _buildLegend(primaryEmerald, "Đang chọn"),
                                  const SizedBox(width: 16),
                                  _buildLegend(Colors.white, "Trống", border: true),
                                  const SizedBox(width: 16),
                                  _buildLegend(neutral200, "Đã đặt"),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.1,
                                children: availableTimeList.map(
                                      (e) {
                                    final isSelected =
                                    _selectedTimes.contains(e.time);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (e.isAvailable) {
                                            if (_selectedTimes.contains(e.time)) {
                                              _selectedTimes.remove(e.time);
                                              _totalBill -= widget.field.price;
                                            } else {
                                              _selectedTimes.add(e.time);
                                              _totalBill += widget.field.price;
                                            }
                                            _enableCreateOrderBtn =
                                                _selectedTimes.isNotEmpty &&
                                                    _selectedDate != 0;
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: (isSelected)
                                                ? primaryEmerald
                                                : e.isAvailable
                                                ? Colors.white
                                                : neutral200,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: Border.all(
                                                color: (isSelected)
                                                    ? primaryEmerald
                                                    : neutral200,
                                                width: 1)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          e.time,
                                          style: descTextStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: (isSelected)
                                                ? Colors.white
                                                : e.isAvailable
                                                ? darkForest
                                                : neutral500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 10,
          )
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tổng thanh toán:",
                  style: descTextStyle,
                ),
                Text(
                  "${NumberFormat("#,##0", "vi_VN").format(_totalBill)}đ",
                  style: TextStyle(color: customBrown, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darkForest,
                      minimumSize: const Size(100, 55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16))),
                  onPressed: !_enableCreateOrderBtn || _isLoading
                      ? null
                      : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        _showSnackBar(context, "Lỗi: Bạn chưa đăng nhập.");
                        setState(() { _isLoading = false; });
                        return;
                      }

                      DateTime selectedDateTime =
                      DateTime(_selectedYear, _selectedMonth, _selectedDate);
                      String formattedDate =
                      dateFormat.format(selectedDateTime).toString();

                      bool isAvailable = await _checkAvailability(widget.field.id, formattedDate, _selectedTimes);

                      if (!isAvailable) {
                        _showSnackBar(context, "Rất tiếc! Giờ bạn chọn vừa có người khác đặt rồi.");
                        setState(() { _isLoading = false; });
                        return;
                      }

                      Map<String, dynamic> orderData = {
                        'userId': user.uid,
                        'userEmail': user.email,
                        'venueId': widget.field.id,
                        'venueName': widget.field.name,
                        'imageAsset': widget.field.imageAsset,
                        'selectedDate': formattedDate,
                        'selectedTime': _selectedTimes,
                        'totalPrice': _totalBill,
                        'paidStatus': false,
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .add(orderData);

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RootView(currentScreen: 1)),
                              (route) => false);
                      _showSnackBar(
                          context, "Đặt sân thành công!");

                    } catch (e) {
                      _showSnackBar(context, "Lỗi khi tạo đơn: $e");
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                    "Tạo đơn hàng",
                    style: buttonTextStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị chú thích
  Widget _buildLegend(Color color, String text, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border ? Border.all(color: neutral200) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: descTextStyle.copyWith(fontSize: 12))
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}