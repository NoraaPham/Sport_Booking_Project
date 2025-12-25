import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:intl/intl.dart';
import 'package:sport_booking_project/modules/admin/add_edit_venue_view.dart';
import 'package:sport_booking_project/modules/admin/admin_analytics_view.dart'; // 👉 IMPORT QUAN TRỌNG

class AdminHomeView extends StatelessWidget {
  // Callback để chuyển tab (được truyền từ Dashboard)
  final Function(int) onChangeTab;

  AdminHomeView({required this.onChangeTab});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // Màu nền xám nhạt hiện đại
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER GRADIENT & CHÀO MỪNG ---
            Container(
              padding: EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0061FF), Color(0xFF60EFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào,",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Administrator",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: AssetImage("assets/images/user_profile_example.png"),
                          child: Icon(Icons.person, color: primaryColor500),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),

                  // STREAM BUILDER ĐỂ LẤY SỐ LIỆU TỔNG QUAN
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                      builder: (context, snapshot) {
                        int revenue = 0;
                        int pendingOrders = 0;

                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            var data = doc.data() as Map<String, dynamic>;
                            if (data['paidStatus'] == true) {
                              revenue += (data['totalPrice'] as int? ?? 0);
                            } else {
                              pendingOrders++; // Đơn chưa thanh toán
                            }
                          }
                        }

                        return Row(
                          children: [
                            // --- THẺ DOANH THU (BẤM ĐƯỢC -> ANALYTICS) ---
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // 👉 Chuyển sang màn hình Thống kê chi tiết
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAnalyticsView()));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2), // Kính mờ
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                                          Icon(Icons.arrow_forward, color: Colors.white70, size: 16) // Mũi tên gợi ý
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text("Doanh thu", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                      Text("${currencyFormat.format(revenue)} đ",
                                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),

                            // --- THẺ ĐƠN CHỜ (BẤM ĐƯỢC -> TAB ĐƠN HÀNG) ---
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onChangeTab(2), // 👉 Chuyển sang tab Đơn hàng (Index 2)
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.assignment_late, color: Colors.orange, size: 28),
                                      SizedBox(height: 12),
                                      Text("Đơn chờ xử lý", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                      Text("$pendingOrders đơn",
                                          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),

            // --- 2. MENU CHỨC NĂNG (QUICK ACTIONS) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Truy cập nhanh", style: subTitleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Hàng nút bấm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionBtn(
                          context,
                          icon: Icons.add_circle,
                          color: Colors.blue,
                          label: "Thêm sân",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditVenueView()));
                          }
                      ),
                      _buildQuickActionBtn(
                        context,
                        icon: Icons.stadium,
                        color: Colors.green,
                        label: "QL Sân bãi",
                        onTap: () => onChangeTab(1), // Tab Sân bãi
                      ),
                      _buildQuickActionBtn(
                        context,
                        icon: Icons.receipt_long,
                        color: Colors.orange,
                        label: "QL Đơn hàng",
                        onTap: () => onChangeTab(2), // Tab Đơn hàng
                      ),
                      _buildQuickActionBtn(
                        context,
                        icon: Icons.settings,
                        color: Colors.purple,
                        label: "Cài đặt",
                        onTap: () => onChangeTab(3), // Tab Tài khoản
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 3. DANH SÁCH MỚI NHẤT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đơn hàng mới", style: subTitleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () => onChangeTab(2),
                      child: Text("Xem tất cả")
                  )
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(3).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text("Chưa có đơn hàng nào.", style: descTextStyle)),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      bool isPaid = data['paidStatus'] ?? false;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green[50] : Colors.orange[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPaid ? Icons.check_circle : Icons.access_time_filled,
                                color: isPaid ? Colors.green : Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['venueName'] ?? "Sân bóng", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(data['userEmail'] ?? "", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              "${currencyFormat.format(data['totalPrice'] ?? 0)} đ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor500),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, {required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        ],
      ),
    );
  }
}