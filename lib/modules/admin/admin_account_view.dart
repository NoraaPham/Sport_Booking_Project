import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/modules/auth/auth_gate.dart';
import 'package:sport_booking_project/theme.dart';

class AdminAccountView extends StatelessWidget {
  // Bảng màu đồng bộ hệ thống
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);
  final Color customBrown = const Color(0xFF8D6E63); // Màu nâu làm điểm nhấn

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "admin@gmail.com";

    return Scaffold(
      backgroundColor: bgMint,
      appBar: AppBar(
        title: Text("Cài đặt tài khoản",
            style: TextStyle(color: darkForest, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- 1. AVATAR SECTION CAO CẤP ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: primaryEmerald.withOpacity(0.2), width: 4),
                      boxShadow: [
                        BoxShadow(color: darkForest.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.person_rounded, size: 70, color: customBrown),
                    ),
                  ),
                  // Nút chỉnh sửa avatar nhỏ
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: darkForest, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text("Administrator",
                style: TextStyle(color: darkForest, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, letterSpacing: 0.5)),

            const SizedBox(height: 40),

            // --- 2. MENU OPTIONS ---
            _buildMenuItem(Icons.settings_suggest_rounded, "Cài đặt hệ thống", "Quản lý cấu hình chung"),
            _buildMenuItem(Icons.admin_panel_settings_rounded, "Bảo mật & Quyền hạn", "Mật khẩu và phân quyền"),
            _buildMenuItem(Icons.contact_support_rounded, "Trợ giúp & Phản hồi", "Trung tâm hỗ trợ 24/7"),
            _buildMenuItem(Icons.info_outline_rounded, "Về ứng dụng", "Phiên bản 1.0.2 (Beta)"),

            const SizedBox(height: 30),

            // --- 3. NÚT ĐĂNG XUẤT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFFEBEE), width: 1),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
                ),
                onPressed: () => _showLogoutDialog(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 10),
                    Text("Đăng xuất tài khoản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Khoảng trống để không bị tabbar che
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subTitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgMint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryEmerald, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: darkForest, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subTitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: customBrown),
            const SizedBox(width: 10),
            const Text("Đăng xuất?"),
          ],
        ),
        content: const Text("Bạn có chắc chắn muốn thoát khỏi phiên làm việc quản trị này không?"),
        actions: [
          TextButton(
              child: const Text("Quay lại", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx)
          ),
          TextButton(
            child: Text("Xác nhận thoát", style: TextStyle(color: customBrown, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthGate()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}