import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/modules/auth/auth_gate.dart'; // 👈 IMPORT QUAN TRỌNG
import '../../../theme.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "User";
    final String userInitial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "U";

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          toolbarHeight: kTextTabBarHeight,
          title: Text("Cài đặt", style: titleTextStyle),
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tài khoản", style: subTitleTextStyle.copyWith(color: primaryColor500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor100,
                        child: Text(userInitial, style: titleTextStyle.copyWith(fontSize: 24, color: primaryColor500)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userEmail, style: subTitleTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text("Thành viên", style: descTextStyle.copyWith(color: primaryColor500))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Text("Ứng dụng", style: subTitleTextStyle.copyWith(color: primaryColor500)),

                // Nút Đăng xuất
                InkWell(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    // 👇 SỬA LẠI CHỖ NÀY: Quay về AuthGate
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AuthGate()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: colorWhite),
                          child: const Icon(Icons.logout, size: 24, color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Text("Đăng xuất", style: normalTextStyle.copyWith(color: Colors.red)),
                      ],
                    ),
                  ),
                ),

                // Thông tin App (Giữ nguyên)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: colorWhite),
                        child: const Icon(CupertinoIcons.info_circle_fill, size: 24, color: darkBlue300),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sport Booking App", style: normalTextStyle),
                          Text("Version 1.0.0", style: descTextStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}