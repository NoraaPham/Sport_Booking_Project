import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/components/no_transaction_message.dart';
import 'package:intl/intl.dart'; // Để format tiền đẹp hơn

class TabHistoryView extends StatelessWidget {
  const TabHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    if (user == null) {
      return Center(child: Text("Vui lòng đăng nhập để xem lịch sử"));
    }

    final Query historyQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('paidStatus', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: historyQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: NoTranscationMessage(
                  messageTitle: "Chưa có lịch sử",
                  messageDesc: "Bạn chưa hoàn thành đơn đặt sân nào.",
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => SizedBox(height: 16), // Khoảng cách giữa các thẻ
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String venueName = data['venueName'] ?? 'Sân bóng';
              String date = data['selectedDate'] ?? 'N/A';
              String imageAsset = data['imageAsset'] ?? 'assets/images/vio_basketball.jpg';
              String timeDisplay = (data['selectedTime'] is List)
                  ? (data['selectedTime'] as List).join(", ")
                  : data['selectedTime'].toString();
              int totalPrice = data['totalPrice'] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // PHẦN TRÊN: ẢNH VÀ THÔNG TIN CƠ BẢN
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh sân bo tròn
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imageAsset,
                              width: 80, height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Thông tin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venueName,
                                  style: subTitleTextStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87
                                  ),
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                    SizedBox(width: 6),
                                    Text(date, style: descTextStyle.copyWith(fontSize: 12)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(timeDisplay, style: descTextStyle.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    // ĐƯỜNG KẺ NGANG (Dashed line simulator)
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                      margin: EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // PHẦN DƯỚI: TRẠNG THÁI VÀ GIÁ TIỀN
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge trạng thái
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[50], // Nền xanh nhạt
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Colors.green),
                                SizedBox(width: 6),
                                Text(
                                  "Hoàn thành",
                                  style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Giá tiền
                          Text(
                            "${currencyFormat.format(totalPrice)} đ",
                            style: priceTextStyle.copyWith(
                                fontSize: 18,
                                color: primaryColor500,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}