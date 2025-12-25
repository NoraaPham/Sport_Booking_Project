import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sport_booking_project/theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool _isLogin = true; // Trạng thái đang ở màn Login hay Register
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Hàm kiểm tra mật khẩu mạnh (Regex)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (_isLogin) return null; // Khi đăng nhập thì không cần check kỹ regex cho đỡ phiền user

    // Regex: Ít nhất 8 ký tự, 1 hoa, 1 thường, 1 số, 1 ký tự đặc biệt
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return 'Mật khẩu yếu! Cần: >8 ký tự, chữ Hoa, thường, số & ký tự đặc biệt (@#\$...)';
    }
    return null;
  }

  // Hàm kiểm tra số điện thoại
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập SĐT';
    if (value.length < 9 || value.length > 11) return 'SĐT không hợp lệ';
    return null;
  }

  void _submitAuthForm() async {
    // 1. Chạy validator của Form
    if (!_formKey.currentState!.validate()) {
      return; // Nếu lỗi thì dừng lại
    }

    setState(() { _isLoading = true; });

    try {
      if (_isLogin) {
        // --- ĐĂNG NHẬP ---
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // --- ĐĂNG KÝ ---
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Lưu thêm thông tin mở rộng vào Firestore
        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'imageProfile': '',
            'hasSeenOnboarding': false,
          });

          // Cập nhật display name cho Auth (để hiện tên nhanh ở một số chỗ)
          await userCredential.user!.updateDisplayName(_nameController.text.trim());
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Đã xảy ra lỗi";
      if (e.code == 'weak-password') message = "Mật khẩu quá yếu.";
      else if (e.code == 'email-already-in-use') message = "Email này đã được đăng ký.";
      else if (e.code == 'user-not-found') message = "Không tìm thấy tài khoản này.";
      else if (e.code == 'wrong-password') message = "Sai mật khẩu.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form( // Wrap bằng Form để dùng validator
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor100,
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    _isLogin ? FontAwesomeIcons.userAstronaut : FontAwesomeIcons.userPlus,
                    size: 50, color: primaryColor500,
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  _isLogin ? "Welcome Back!" : "Create Account",
                  style: greetingTextStyle.copyWith(fontSize: 28),
                ),
                Text(
                  _isLogin ? "Đăng nhập để đặt sân ngay" : "Đăng ký thành viên mới",
                  style: descTextStyle,
                ),
                SizedBox(height: 32),

                // --- CÁC TRƯỜNG NHẬP LIỆU ---

                // 1. Họ và Tên (Chỉ hiện khi Đăng ký)
                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration("Họ và Tên", Icons.person_outline),
                      validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
                    ),
                  ),

                // 2. Số điện thoại (Chỉ hiện khi Đăng ký)
                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration("Số điện thoại", Icons.phone_android),
                      validator: _validatePhone,
                    ),
                  ),

                // 3. Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("Email", Icons.email_outlined),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
                ),
                SizedBox(height: 16),

                // 4. Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration("Mật khẩu", Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    helperText: !_isLogin ? "Gợi ý: Abc@1234 (Hoa, thường, số, đặc biệt)" : null,
                    helperMaxLines: 2,
                  ),
                  validator: _validatePassword,
                ),

                SizedBox(height: 32),

                // Nút Submit
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor500,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                      shadowColor: primaryColor500.withOpacity(0.4),
                    ),
                    onPressed: _isLoading ? null : _submitAuthForm,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? "Đăng Nhập" : "Đăng Ký", style: buttonTextStyle.copyWith(fontSize: 18)),
                  ),
                ),

                SizedBox(height: 24),

                // Nút chuyển đổi Login/Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isLogin ? "Chưa có tài khoản? " : "Đã có tài khoản? ", style: descTextStyle),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset(); // Xóa lỗi validation cũ
                        });
                      },
                      child: Text(
                        _isLogin ? "Đăng ký ngay" : "Đăng nhập",
                        style: titleTextStyle.copyWith(color: primaryColor500, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper để tạo Style cho Input đẹp hơn
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor500),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }
}