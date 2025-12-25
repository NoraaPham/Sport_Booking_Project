import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Thống kê chi tiết", style: titleTextStyle),
        backgroundColor: colorWhite,
        elevation: 0,
        centerTitle: true,
        // 👉 ĐÃ XÓA 'automaticallyImplyLeading: false' ĐỂ HIỆN NÚT BACK
        iconTheme: IconThemeData(color: darkBlue500),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) return Center(child: Text("Lỗi dữ liệu"));

          var docs = snapshot.data?.docs ?? [];

          int totalOrders = docs.length;
          int totalRevenue = 0;
          int paidOrders = 0;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            int price = data['totalPrice'] ?? 0;
            bool isPaid = data['paidStatus'] ?? false;

            if (isPaid) {
              totalRevenue += price;
              paidOrders++;
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tổng quan", style: subTitleTextStyle),
                SizedBox(height: 16),

                _buildStatCard(
                  title: "Tổng Doanh Thu",
                  value: "${currencyFormat.format(totalRevenue)} VND",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Tổng đơn",
                        value: "$totalOrders",
                        icon: Icons.receipt_long,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: "Đã thanh toán",
                        value: "$paidOrders",
                        icon: Icons.check_circle,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),
                Text("Biểu đồ tăng trưởng", style: subTitleTextStyle),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
                        Text("Tính năng đang phát triển", style: descTextStyle),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              Spacer(),
              Icon(Icons.more_horiz, color: Colors.grey[300]),
            ],
          ),
          SizedBox(height: 16),
          Text(value, style: titleTextStyle.copyWith(fontSize: 24, color: color)),
          SizedBox(height: 4),
          Text(title, style: descTextStyle),
        ],
      ),
    );
  }
}