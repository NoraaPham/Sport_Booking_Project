import 'package:flutter/material.dart';
import 'package:sport_booking_project/modules/admin/admin_home_view.dart'; // Màn hình Home mới
import 'package:sport_booking_project/modules/admin/manage_venues_view.dart';
import 'package:sport_booking_project/modules/admin/manage_bookings_view.dart';
import 'package:sport_booking_project/modules/admin/admin_account_view.dart';
import 'package:sport_booking_project/theme.dart';

class AdminDashboardView extends StatefulWidget {
  @override
  _AdminDashboardViewState createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;

  // Danh sách màn hình
  // Lưu ý: Chúng ta dùng `lazy loading` hoặc truyền hàm callback để Home có thể điều khiển Tab
  late List<Widget> _adminScreens;

  @override
  void initState() {
    super.initState();
    _adminScreens = [
      AdminHomeView(onChangeTab: _onTabTapped), // Tab 0: Home (WOW)
      ManageVenuesView(),                       // Tab 1: Sân bãi
      ManageBookingsView(),                     // Tab 2: Đơn hàng
      AdminAccountView(),                       // Tab 3: Tài khoản
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái các màn hình khi chuyển tab
      body: IndexedStack(
        index: _currentIndex,
        children: _adminScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF0061FF), // Màu xanh dương hiện đại
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0, // Tắt bóng mặc định để dùng bóng custom đẹp hơn
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stadium_rounded),
              label: 'Sân bãi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}