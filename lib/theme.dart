import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- HỆ MÀU EMERALD CHỦ ĐẠO (Đã bỏ xanh dương) ---
const Color primaryColor100 = Color(0xFFDDEEE6); // Xanh lục nhạt (Mint/Emerald Light)
const Color primaryColor300 = Color(0xFFA8D5BA); // Xanh lục trung bình
const Color primaryColor500 = Color(0xFF4A9B7B); // MÀU CHÍNH (Emerald)
const Color colorWhite = Colors.white;

// --- HỆ MÀU NỀN VÀ TRẠNG THÁI ---
const Color backgroundColor = Color(0xFFF1F6F2); // Nền Mint cực sạch
const Color lightBlue100 = Color(0xFFF1F6F2);    // Giữ tên biến để tránh lỗi code cũ
const Color lightBlue300 = Color(0xFFDDEEE6);
const Color lightBlue400 = Color(0xFFB1BACC);

// --- HỆ MÀU FOREST (Xanh rừng sâu cho tiêu đề) ---
const Color darkBlue300 = Color(0xFF2D6A4F);
const Color darkBlue500 = Color(0xFF1B4332);
const Color darkBlue700 = Color(0xFF081C15);

// --- HỆ MÀU TRUNG TÍNH ---
const neutral50 = Color(0xFFF8FAF9);
const neutral200 = Color(0xFFE2E8E5);
const neutral400 = Color(0xFF7A9085);
const neutral500 = Color(0xFF55685E);
const neutral700 = Color(0xFF3C4A43);

const double borderRadiusSize = 16.0;

// --- TEXT STYLES ĐỒNG BỘ ---
TextStyle greetingTextStyle = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w700, color: darkBlue500);

TextStyle titleTextStyle = GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w700, color: darkBlue500);

TextStyle subTitleTextStyle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w500, color: darkBlue500);

TextStyle normalTextStyle = GoogleFonts.poppins(color: darkBlue500);

TextStyle descTextStyle = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: neutral400);

TextStyle addressTextStyle = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: neutral400);

TextStyle facilityTextStyle = GoogleFonts.poppins(
    fontSize: 13, fontWeight: FontWeight.w500, color: darkBlue300);

TextStyle priceTextStyle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue500);

TextStyle buttonTextStyle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w600, color: colorWhite);

TextStyle bottomNavTextStyle = GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor500);

TextStyle tabBarTextStyle =
GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor500);

// --- HÀM TẠO MATERIAL COLOR TỰ ĐỘNG ---
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}