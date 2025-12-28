import 'package:flutter/material.dart';
import 'package:sport_booking_project/modules/auth/auth_gate.dart';
import 'package:sport_booking_project/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Hiệu ứng mờ ảo tăng dần cho chữ
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeIn),
      ),
    );

    // Hiệu ứng chữ to dần nhẹ nhàng
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        // Curves.easeOutBack là lựa chọn an toàn và đẹp nhất cho hiệu ứng nảy nhẹ
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Tự động chuyển màn sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthGate(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Sử dụng bảng màu Emerald & Forest Green từ theme.dart
            colors: [primaryColor500, darkBlue500],
          ),
        ),
        child: Stack(
          children: [
            // Các họa tiết trang trí chìm cho giao diện thêm hiện đại
            Positioned(
              top: -50,
              right: -20,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.03),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TÊN APP: GO SPORT
                      const Text(
                        "GO SPORT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // TAGLINE TIẾNG VIỆT
                      Text(
                        "DI CHUYỂN • TRẢI NGHIỆM • KẾT NỐI",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Thanh tải tối giản tinh tế
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}