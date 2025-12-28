import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/modules/root/root_view.dart';
import 'dart:ui';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with TickerProviderStateMixin {
  // Bảng màu Forest Green đồng bộ với Dashboard Admin của bạn
  final Color forestGreen = const Color(0xFF2D5A47);
  final Color bgDarker = const Color(0xFF1B3D30);
  final Color primaryEmerald = const Color(0xFF4A9B7B);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDarker,
      body: Stack(
        children: [
          // 1. HÌNH ẢNH NỀN: Sử dụng ảnh local onboard.png
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/onboard.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: bgDarker);
                },
              ),
            ),
          ),

          // 2. LỚP PHỦ GRADIENT: Màu Forest Green sâu thẳm để nổi bật Text
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    forestGreen.withOpacity(0.2),
                    forestGreen.withOpacity(0.6),
                    bgDarker,
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
          ),

          // 3. NỘI DUNG CHÍNH
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // Tiêu đề chính
                    const Text(
                      "Chào mừng bạn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nội dung mô tả đã cập nhật theo yêu cầu
                    Text(
                      "Ứng dụng đặt sân thể thao chuyên nghiệp.\nHành trình rèn luyện của bạn bắt đầu tại đây.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Nút bấm Kính mờ (Glassmorphism)
                    _buildGlassButton(context),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _handleGetStarted(context),
          child: Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Bắt đầu ngay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, color: primaryEmerald, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGetStarted(BuildContext context) async {
    HapticFeedback.lightImpact();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'hasSeenOnboarding': true}, SetOptions(merge: true));
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => RootView(currentScreen: 0)),
    );
  }
}