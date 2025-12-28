import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/modules/root/root_view.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final Color bgLightGreen = const Color(0xFFF1F6F2);
  final Color primaryGreen = const Color(0xFF4A9B7B);
  final Color darkGreen = const Color(0xFF2D6A4F);

  // --- HÀM VALIDATE MẬT KHẨU MẠNH TỪ CODE CŨ ---
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (_isLogin) return null; // Đăng nhập thì không cần check kỹ regex

    // Regex: Ít nhất 8 ký tự, 1 hoa, 1 thường, 1 số, 1 ký tự đặc biệt
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return 'Cần: >8 ký tự, chữ Hoa, thường, số & ký tự đặc biệt';
    }
    return null;
  }

  // --- HÀM VALIDATE SỐ ĐIỆN THOẠI TỪ CODE CŨ ---
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập SĐT';
    if (value.length < 9 || value.length > 11) return 'SĐT không hợp lệ';
    return null;
  }

  void _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'hasSeenOnboarding': false,
            'imageProfile': '',
          });
          await userCredential.user!.updateDisplayName(_nameController.text.trim());
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RootView(currentScreen: 0))
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã xảy ra lỗi, vui lòng thử lại.";
      switch (e.code) {
        case 'email-already-in-use': errorMessage = "Email này đã được sử dụng."; break;
        case 'invalid-email': errorMessage = "Địa chỉ email không hợp lệ."; break;
        case 'weak-password': errorMessage = "Mật khẩu quá yếu."; break;
        case 'user-not-found': errorMessage = "Không tìm thấy tài khoản."; break;
        case 'wrong-password': errorMessage = "Mật khẩu không chính xác."; break;
        case 'network-request-failed': errorMessage = "Lỗi kết nối mạng."; break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bgLightGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLogin ? _buildLoginHeader(screenHeight * 0.45) : _buildRegisterHeader(screenHeight * 0.25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(_isLogin ? "Chào mừng bạn" : "Tạo tài khoản",
                    style: TextStyle(fontSize: 32, color: darkGreen, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_isLogin ? "Đăng nhập để đặt sân ngay" : "Tham gia cùng chúng tôi ngay",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF7A9085), fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          _buildPremiumInput(_nameController, "Họ và tên", Icons.person_outline_rounded,
                              validator: (val) => (val == null || val.isEmpty) ? "Nhập họ tên" : null),
                          const SizedBox(height: 15),
                          _buildPremiumInput(_phoneController, "Số điện thoại", Icons.phone_android_outlined,
                              validator: _validatePhone, isNumber: true),
                          const SizedBox(height: 15),
                        ],
                        _buildPremiumInput(_emailController, "Email", Icons.email_outlined,
                            validator: (val) => (val == null || !val.contains('@')) ? "Email không hợp lệ" : null),
                        const SizedBox(height: 15),
                        _buildPremiumInput(_passwordController, "Mật khẩu", Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: _validatePassword,
                            helper: !_isLogin ? "Gợi ý: Abc@1234 (Hoa, thường, số, đặc biệt)" : null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  _isLoading ? CircularProgressIndicator(color: primaryGreen) : _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumInput(TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, String? Function(String?)? validator, String? helper, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          helperText: helper,
          helperMaxLines: 2,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: primaryGreen, size: 20),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: primaryGreen, size: 20),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }

  // Header and UI Components remain same for branding consistency
  Widget _buildLoginHeader(double h) => SizedBox(height: h, child: Stack(children: [ClipPath(clipper: TopWaveClipper(), child: Container(color: const Color(0xFFE2F0E5))), ClipPath(clipper: MidWaveClipper(), child: Container(color: const Color(0xFFA8D5BA).withOpacity(0.5))), ClipPath(clipper: MainImageWaveClipper(), child: Container(height: h, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/anhlogin.png"), fit: BoxFit.cover, alignment: Alignment(0, -0.2))))), ClipPath(clipper: BottomWaveClipper(), child: Container(color: const Color(0xFF4A9B7B).withOpacity(0.2)))]));
  Widget _buildRegisterHeader(double h) => SizedBox(height: h, child: Stack(children: [ClipPath(clipper: TopWaveClipper(), child: Container(color: const Color(0xFFE2F0E5))), ClipPath(clipper: MidWaveClipper(), child: Container(color: const Color(0xFFA8D5BA).withOpacity(0.6))), ClipPath(clipper: MainImageWaveClipper(), child: Container(color: const Color(0xFFDDEEE6))), ClipPath(clipper: BottomWaveClipper(), child: Container(color: const Color(0xFF4A9B7B).withOpacity(0.1)))]));
  Widget _buildLoginButton() => Container(width: double.infinity, height: 55, decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryGreen, darkGreen]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: darkGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: _submitAuthForm, child: Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ NGAY", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2))));
  Widget _buildFooter() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_isLogin ? "Chưa có tài khoản? " : "Đã có tài khoản? ", style: const TextStyle(color: Color(0xFF7A9085), fontSize: 14)), GestureDetector(onTap: () { setState(() { _isLogin = !_isLogin; _formKey.currentState?.reset(); }); }, child: Text(_isLogin ? 'Đăng ký ngay' : 'Đăng nhập', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: 14)))]);
}

// Keep the wave clippers from previous version
class TopWaveClipper extends CustomClipper<Path> { @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height * 0.35); path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width, size.height * 0.25); path.lineTo(size.width, 0); return path; } @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false; }
class MidWaveClipper extends CustomClipper<Path> { @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height * 0.55); path.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.55); path.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.5); path.lineTo(size.width, 0); return path; } @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false; }
class MainImageWaveClipper extends CustomClipper<Path> { @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height * 0.8); path.quadraticBezierTo(size.width * 0.2, size.height * 0.65, size.width * 0.5, size.height * 0.8); path.quadraticBezierTo(size.width * 0.8, size.height * 1.0, size.width, size.height * 0.8); path.lineTo(size.width, 0); return path; } @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false; }
class BottomWaveClipper extends CustomClipper<Path> { @override Path getClip(Size size) { Path path = Path(); path.moveTo(0, size.height * 0.85); path.quadraticBezierTo(size.width * 0.35, size.height * 0.75, size.width * 0.6, size.height * 0.92); path.quadraticBezierTo(size.width * 0.85, size.height * 1.05, size.width, size.height * 0.85); path.lineTo(size.width, 0); path.lineTo(0, 0); return path; } @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false; }