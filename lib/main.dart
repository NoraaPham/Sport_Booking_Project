// lib/main.dart
import 'package:firebase_core/firebase_core.dart'; // Firebase
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // Provider
import 'package:sport_booking_project/modules/auth/auth_gate.dart'; // File AuthGate mới
import 'package:sport_booking_project/theme.dart';
import 'firebase_options.dart'; // File kết nối Firebase

// Tạm thời tạo Provider (sẽ dùng ở bước sau)
// TẠO FILE: lib/providers/booking_provider.dart
// VÀ DÁN CLASS NÀY VÀO:
// class BookingProvider with ChangeNotifier {
//   // Để trống
// }
// SAU ĐÓ IMPORT VÀO ĐÂY
// import 'package:sport_booking_project/providers/booking_provider.dart';
class BookingProvider with ChangeNotifier {
  // Để trống
}


Future<void> main() async {
  // ----- BẮT ĐẦU CODE KHỞI ĐỘNG MỚI -----
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo intl (cần thiết cho Spod App)
  await initializeDateFormatting('en', null);
  // ----- KẾT THÚC CODE KHỞI ĐỘNG MỚI -----

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bọc app bằng Provider
    return ChangeNotifierProvider(
      create: (context) => BookingProvider(),
      child: MaterialApp(
        title: 'Spod',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor500,
          useMaterial3: false,
        ),
        locale: const Locale('en', 'EN'),
        home: AuthGate(), // Bắt đầu từ AuthGate
      ),
    );
  }
}