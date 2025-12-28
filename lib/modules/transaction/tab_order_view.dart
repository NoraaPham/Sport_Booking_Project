import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/components/no_transaction_message.dart';

class OrderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Vui lòng đăng nhập để xem đơn hàng"));
    }

    final Query ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: SingleChildScrollView(
                    child: NoTranscationMessage(
                      messageTitle: "Chưa có đơn hàng nào",
                      messageDesc: "Bạn chưa đặt sân nào cả. Hãy tìm sân và đặt ngay nhé!",
                    )));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              String venueName = data['venueName'] ?? 'Sân thể thao';
              String date = data['selectedDate'] ?? 'N/A';
              String imageAsset = data['imageAsset'] ?? 'assets/images/vio_basketball.jpg';
              bool isPaid = data['paidStatus'] ?? false;
              String timeDisplay = (data['selectedTime'] is List)
                  ? (data['selectedTime'] as List).join(", ")
                  : data['selectedTime'].toString();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(imageAsset))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venueName,
                                  style: subTitleTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(date, style: descTextStyle.copyWith(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(timeDisplay, style: descTextStyle.copyWith(fontSize: 12, color: primaryColor500, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(isPaid ? Icons.check_circle : Icons.hourglass_bottom, size: 14, color: isPaid ? Colors.green : Colors.orange),
                                  const SizedBox(width: 6),
                                  Text(
                                    isPaid ? "Đã thanh toán" : "Chờ thanh toán",
                                    style: normalTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isPaid ? Colors.green : Colors.orange),
                                  ),
                                ],
                              )
                          ),
                          if (!isPaid)
                            TextButton.icon(
                              onPressed: () => _showCancelDialog(context, document.id),
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              label: const Text("Hủy đơn", style: TextStyle(color: Colors.red, fontSize: 13)),
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.red.withOpacity(0.05)
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hủy đặt sân?"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn đặt sân này không?"),
        actions: [
          TextButton(
            child: const Text("Quay lại"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Hủy ngay", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã hủy đơn hàng thành công!"))
              );
            },
          ),
        ],
      ),
    );
  }
}