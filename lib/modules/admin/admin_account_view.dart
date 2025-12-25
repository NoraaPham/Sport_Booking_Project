import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/modules/auth/auth_gate.dart'; // 👈 IMPORT QUAN TRỌNG
import 'package:sport_booking_project/theme.dart';

class AdminAccountView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Admin";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Tài khoản", style: titleTextStyle),
        backgroundColor: colorWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Center(
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor100),
              child: Icon(Icons.person, size: 60, color: primaryColor500),
            ),
          ),
          SizedBox(height: 16),
          Text("Administrator", style: titleTextStyle.copyWith(fontSize: 24)),
          Text(email, style: descTextStyle),

          SizedBox(height: 40),

          _buildMenuItem(Icons.settings, "Cài đặt hệ thống"),
          _buildMenuItem(Icons.security, "Bảo mật & Quyền hạn"),
          _buildMenuItem(Icons.help_outline, "Trợ giúp"),

          Spacer(),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
                child: Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 16),
          Text(title, style: subTitleTextStyle),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Đăng xuất?"),
        content: Text("Bạn có chắc muốn thoát quyền quản trị?"),
        actions: [
          TextButton(child: Text("Hủy"), onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              // 👇 SỬA LẠI CHỖ NÀY: Quay về AuthGate
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