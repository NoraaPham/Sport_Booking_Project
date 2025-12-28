import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:intl/intl.dart';

class ManageBookingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Định dạng tiền tệ VN
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    // Query lấy đơn hàng mới nhất lên đầu
    final Query ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Quản lý Đơn hàng", style: titleTextStyle),
        backgroundColor: colorWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("Chưa có đơn hàng nào.", style: descTextStyle),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              bool isPaid = data['paidStatus'] ?? false;
              String venueName = data['venueName'] ?? 'Sân thể thao';
              String userEmail = data['userEmail'] ?? 'N/A';
              String date = data['selectedDate'] ?? 'N/A';

              String time = (data['selectedTime'] is List)
                  ? (data['selectedTime'] as List).join(", ")
                  : data['selectedTime'].toString();
              int total = data['totalPrice'] ?? 0;

              return Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: InkWell( // Dùng InkWell để có hiệu ứng bấm (ripple effect)
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // --- GIỮ NGUYÊN LOGIC XÁC NHẬN CỦA BẠN ---
                    if (isPaid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đơn này đã thanh toán rồi!"))
                      );
                      return;
                    }
                    _showPaymentConfirmDialog(context, document, total, venueName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                venueName,
                                style: subTitleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(isPaid),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Thông tin người đặt
                        _buildInfoRow(Icons.person_outline, userEmail),
                        const SizedBox(height: 6),

                        // Thông tin thời gian (Xử lý tràn chữ)
                        _buildInfoRow(Icons.calendar_today_outlined, "$date • $time"),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tổng tiền:", style: descTextStyle),
                            Text(
                              "${currencyFormat.format(total)} đ",
                              style: priceTextStyle.copyWith(
                                  color: primaryColor500,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget hiển thị trạng thái
  Widget _buildStatusBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isPaid ? Colors.green : Colors.red, width: 0.5),
      ),
      child: Text(
        isPaid ? "Đã trả" : "Chờ thu",
        style: TextStyle(
            color: isPaid ? Colors.green[700] : Colors.red[700],
            fontSize: 11,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // Widget hiển thị dòng thông tin có icon
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: descTextStyle.copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // --- HÀM XÁC NHẬN THANH TOÁN (LOGIC CŨ) ---
  void _showPaymentConfirmDialog(BuildContext context, DocumentSnapshot doc, int amount, String venue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Xác nhận thanh toán"),
          content: Text("Bạn có chắc chắn muốn xác nhận đã thu tiền cho sân $venue?\n\nSố tiền: ${amount} VND"),
          actions: [
            TextButton(
                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.of(context).pop()
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor500,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
              onPressed: () {
                doc.reference.update({'paidStatus': true}).then((value) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã cập nhật trạng thái thanh toán!"), backgroundColor: Colors.green)
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}