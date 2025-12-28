import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/components/no_transaction_message.dart';
import 'package:intl/intl.dart';

class TabHistoryView extends StatelessWidget {
  const TabHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    if (user == null) {
      return const Center(child: Text("Vui lòng đăng nhập để xem lịch sử"));
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
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

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
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String venueName = data['venueName'] ?? 'Sân thể thao';
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imageAsset,
                              width: 80, height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(date, style: descTextStyle.copyWith(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
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
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                                const SizedBox(width: 6),
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