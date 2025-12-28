import 'package:flutter/material.dart';
import 'package:sport_booking_project/modules/admin/admin_home_view.dart';
import 'package:sport_booking_project/modules/admin/manage_venues_view.dart';
import 'package:sport_booking_project/modules/admin/manage_bookings_view.dart';
import 'package:sport_booking_project/modules/admin/admin_account_view.dart';

class AdminDashboardView extends StatefulWidget {
  @override
  _AdminDashboardViewState createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;
  late List<Widget> _adminScreens;

  @override
  void initState() {
    super.initState();
    _adminScreens = [
      AdminHomeView(onChangeTab: _onTabTapped),
      ManageVenuesView(),
      ManageBookingsView(),
      AdminAccountView(),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _adminScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D6A4F).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4A9B7B), // Màu Emerald nổi bật
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,

          // --- FIX LỖI OVERFLOW TẠI ĐÂY ---
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

          elevation: 0,
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