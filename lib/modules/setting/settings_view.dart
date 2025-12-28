import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/modules/auth/auth_gate.dart';
import '../../../theme.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "boypho123@gmail.com";
    final String userName = user?.displayName ?? "boypho";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight + 20,
        // Tiêu đề lớn như mẫu
        title: Text("Hồ sơ", style: greetingTextStyle.copyWith(fontSize: 32)),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: darkBlue500, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN TÀI KHOẢN (ĐÃ ĐỒNG BỘ ẢNH VỚI HOME) ---
            _buildSectionContainer(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryColor500.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    // DÙNG CHUNG LINK VỚI TRANG HOME ĐỂ HIỆN CHÚ MÈO KITTY
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/adventurer/png?seed=${user?.uid ?? 'Kitty'}&backgroundColor=f1f6f2",
                    ),
                  ),
                ),
                title: Text(userName, style: subTitleTextStyle.copyWith(fontWeight: FontWeight.bold, color: primaryColor500, fontSize: 18)),
                subtitle: Text(userEmail, style: descTextStyle.copyWith(fontSize: 14)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // --- NHÓM CÀI ĐẶT CHUNG (Giống mẫu 100%) ---
            _buildSectionContainer(
              child: Column(
                children: [
                  _buildMenuTile(Icons.language_rounded, "Ngôn ngữ", "vi", Colors.green),
                  _buildDivider(),
                  _buildMenuTile(Icons.notifications_active_rounded, "Quản lý thông báo", null, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- NHÓM THÔNG TIN HỖ TRỢ ---
            _buildSectionContainer(
              child: Column(
                children: [
                  _buildMenuTile(Icons.people_alt_rounded, "Về chúng tôi", null, primaryColor500),
                  _buildDivider(),
                  _buildMenuTile(Icons.mail_outline_rounded, "Liên hệ", null, Colors.blueGrey),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- NHÓM PHÁP LÝ ---
            _buildSectionContainer(
              child: Column(
                children: [
                  _buildMenuTile(Icons.privacy_tip_rounded, "Chính sách bảo mật", null, Colors.grey),
                  _buildDivider(),
                  _buildMenuTile(Icons.description_rounded, "Điều khoản dịch vụ", null, Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- NÚT ĐĂNG XUẤT ---
            _buildSectionContainer(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                ),
                title: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () => _showLogoutDialog(context),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text("Phiên bản 1.0.0", style: descTextStyle.copyWith(fontSize: 12)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String? trailingText, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: normalTextStyle.copyWith(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: descTextStyle.copyWith(color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.withOpacity(0.1));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Đăng xuất?"),
        content: const Text("Bạn có chắc chắn muốn thoát khỏi ứng dụng?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthGate()), (route) => false,
              );
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}