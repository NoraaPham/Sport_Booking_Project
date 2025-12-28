import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sport_booking_project/modules/admin/add_edit_venue_view.dart';
import 'package:sport_booking_project/modules/admin/admin_analytics_view.dart';

class AdminHomeView extends StatelessWidget {
  final Function(int) onChangeTab;
  AdminHomeView({required this.onChangeTab});

  // Bảng màu thiết kế Emerald & Mint đồng bộ
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);

  // MÀU NÂU MẪU CHO ICON TRẠNG THÁI
  final Color customBrown = const Color(0xFF8D6E63);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: bgMint,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER GRADIENT ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryEmerald, darkForest],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: darkForest.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Xin chào,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text("Administrator", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.admin_panel_settings, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 35),

                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                      builder: (context, snapshot) {
                        int revenue = 0;
                        int pending = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            var data = doc.data() as Map<String, dynamic>;
                            if (data['paidStatus'] == true) revenue += (data['totalPrice'] as int? ?? 0);
                            if (data['paidStatus'] == false) pending++;
                          }
                        }
                        return Row(
                          children: [
                            _buildStatCard("Doanh thu", "${currencyFormat.format(revenue)}đ", Icons.payments, true, () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAnalyticsView()));
                            }),
                            const SizedBox(width: 15),
                            _buildStatCard("Đơn chờ", "$pending đơn", Icons.timer, false, () => onChangeTab(2)),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),

            // --- 2. MENU TRUY CẬP NHANH (MÀU SẮC NỔI BẬT) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Truy cập nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkForest)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCircle(Icons.add_location_alt_rounded, "Thêm sân", primaryEmerald, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditVenueView()))),
                      _buildActionCircle(Icons.stadium, "Sân bãi", const Color(0xFF2D6A4F), () => onChangeTab(1)),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('orders').where('paidStatus', isEqualTo: false).snapshots(),
                          builder: (context, snapshot) {
                            int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                            return _buildActionCircle(Icons.list_alt_rounded, "Đơn hàng", const Color(0xFF74C69D), () => onChangeTab(2), badgeCount: pendingCount);
                          }
                      ),
                      _buildActionCircle(Icons.settings_suggest_rounded, "Cài đặt", const Color(0xFF52B788), () => onChangeTab(3)),
                    ],
                  ),
                ],
              ),
            ),

            // --- 3. DANH SÁCH ĐƠN HÀNG (ICON MÀU NÂU THEO MẪU) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đơn hàng mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkForest)),
                  TextButton(onPressed: () => onChangeTab(2), child: Text("Xem tất cả", style: TextStyle(color: primaryEmerald, fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(3).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      bool isPaid = data['paidStatus'] ?? false;

                      // ICON MÀU NÂU VÀ 3 CHẤM CHO ĐƠN CHỜ
                      final statusColor = isPaid ? Colors.green : customBrown;
                      final statusBgColor = isPaid ? Colors.green[50] : customBrown.withOpacity(0.15);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                              child: Icon(
                                  isPaid ? Icons.check_circle : Icons.more_horiz_rounded, // ICON 3 CHẤM NHƯ MẪU
                                  color: statusColor,
                                  size: 22
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['venueName'] ?? "Sân bóng", style: TextStyle(fontWeight: FontWeight.bold, color: darkForest), overflow: TextOverflow.ellipsis),
                                  Text(data['userEmail'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text("${currencyFormat.format(data['totalPrice'] ?? 0)}đ", style: TextStyle(fontWeight: FontWeight.bold, color: primaryEmerald)),
                          ],
                        ),
                      );
                    },
                  );
                }
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isDark ? Colors.white : customBrown, size: 28),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 13)),
              Text(value, style: TextStyle(color: isDark ? Colors.white : darkForest, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, String label, Color themeColor, VoidCallback onTap, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: themeColor.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Center(child: Icon(icon, color: themeColor, size: 30)),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkForest.withOpacity(0.8))),
        ],
      ),
    );
  }
}