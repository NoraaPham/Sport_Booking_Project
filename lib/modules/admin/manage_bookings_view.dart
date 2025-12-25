// lib/modules/admin/manage_bookings_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';

class ManageBookingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Query lấy đơn hàng mới nhất lên đầu
    final Query ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Quản lý Đơn hàng", style: titleTextStyle),
        backgroundColor: colorWhite,
        elevation: 0, // Bỏ bóng cho phẳng đẹp
        centerTitle: true,
        automaticallyImplyLeading: false, // QUAN TRỌNG: Bỏ nút Back mặc định
        // ĐÃ XÓA PHẦN ACTIONS (NÚT LOGOUT)
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text("Chưa có đơn hàng nào.", style: descTextStyle),
              ],
            ));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              bool isPaid = data['paidStatus'] ?? false;
              String venueName = data['venueName'] ?? 'Chưa có tên sân';
              String userEmail = data['userEmail'] ?? 'N/A';
              String date = data['selectedDate'] ?? 'N/A';

              String time = (data['selectedTime'] is List)
                  ? (data['selectedTime'] as List).join(", ")
                  : data['selectedTime'].toString();
              int total = data['totalPrice'] ?? 0;

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(venueName, style: subTitleTextStyle.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Icon(Icons.person, size: 14, color: Colors.grey), SizedBox(width: 4), Expanded(child: Text(userEmail, style: descTextStyle))]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 4), Text("$date ($time)", style: descTextStyle)]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.attach_money, size: 14, color: Colors.grey), SizedBox(width: 4), Text("${total} VND", style: priceTextStyle.copyWith(fontSize: 14))]),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isPaid ? Colors.green : Colors.red, width: 1),
                        ),
                        child: Text(
                          isPaid ? "Đã trả" : "Chưa trả",
                          style: TextStyle(color: isPaid ? Colors.green[800] : Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Logic xác nhận thanh toán
                    if (isPaid) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đơn này đã thanh toán rồi!")));
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Xác nhận thanh toán"),
                          content: Text("Xác nhận khách đã trả tiền ($total VND)?"),
                          actions: [
                            TextButton(child: Text("Hủy"), onPressed: () => Navigator.of(context).pop()),
                            TextButton(
                              child: Text("Đồng ý", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                document.reference.update({'paidStatus': true}).then((value) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã cập nhật thành công!")));
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}