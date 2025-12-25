import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_booking_project/modules/admin/admin_dashboard_view.dart';
import 'package:sport_booking_project/modules/onboarding/onboarding_view.dart';
import 'package:sport_booking_project/modules/root/root_view.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Đang chờ kết nối Firebase Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Đã đăng nhập thành công
        if (authSnapshot.hasData) {
          final uid = authSnapshot.data!.uid;

          // Gọi hàm lấy Role và Onboarding status cùng lúc
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _getUserRole(uid),           // Index 0: Role
              _checkUserOnboardingStatus(uid), // Index 1: Onboarding status
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.hasError) {
                return Scaffold(body: Center(child: Text("Lỗi: ${snapshot.error}")));
              }

              // Lấy kết quả từ Future
              final String role = snapshot.data?[0] ?? 'user';
              final bool onBoardingSkipped = snapshot.data?[1] ?? false;

              // --- PHÂN QUYỀN ---
              if (role == 'admin') {
                return AdminDashboardView();
              } else {
                if (onBoardingSkipped) {
                  return RootView(currentScreen: 0);
                } else {
                  return OnboardingView();
                }
              }
            },
          );
        }

        // 3. Chưa đăng nhập -> Hiện màn hình Login
        else {
          return LoginScreen();
        }
      },
    );
  }

  // Hàm lấy Role từ Firestore
  Future<String> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'user';
      }
      return 'user'; // Mặc định là user nếu chưa có data
    } catch (e) {
      print("Lỗi lấy role: $e");
      return 'user';
    }
  }

  Future<bool> _checkUserOnboardingStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        // Lấy trạng thái từ Firestore, mặc định là false nếu chưa có trường này
        return doc.data()?['hasSeenOnboarding'] ?? false;
      }
      return false; // Nếu user chưa tồn tại doc, coi như chưa xem
    } catch (e) {
      print("Lỗi check onboarding: $e");
      return false; // An toàn: cho xem lại nếu lỗi
    }
  }
}