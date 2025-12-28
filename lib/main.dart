import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sport_booking_project/modules/auth/splash_screen.dart'; // Import màn hình Splash mới
import 'package:sport_booking_project/theme.dart';
import 'firebase_options.dart';

class BookingProvider with ChangeNotifier {
  // Lớp Provider hiện tại của bạn
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase từ cấu hình options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo định dạng ngày tháng
  await initializeDateFormatting('en', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingProvider(),
      child: MaterialApp(
        title: 'Spod',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor500, // Sử dụng mã màu từ theme.dart
          useMaterial3: false,
        ),
        locale: const Locale('en', 'EN'),
        // Thay AuthGate bằng SplashScreen để chạy màn hình load trước
        home: const SplashScreen(),
      ),
    );
  }
}