import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_booking_project/modules/home/home_view.dart';
import 'package:sport_booking_project/modules/setting/settings_view.dart';
import 'package:sport_booking_project/modules/transaction/transaction_history_view.dart';
import 'package:sport_booking_project/theme.dart';

class RootView extends StatefulWidget {
  final int currentScreen; // Chuyển thành final để đúng chuẩn

  RootView({required this.currentScreen});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  int _currentIndex = 0;
  final screens = [
    HomeView(),
    TransactionHistoryView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentScreen;
  }

  @override
  Widget build(BuildContext context) {
    // Ép thanh trạng thái StatusBar trong suốt để đồng bộ màu Header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async => await _onBackPressed(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: screens[_currentIndex],
        bottomNavigationBar: CustomBottomNavBar(
          defaultSelectedIndex: _currentIndex,
          selectedItemIcon: const [
            "assets/icons/home_fill.png",
            "assets/icons/receipt_fill.png",
            "assets/icons/settings_fill.png"
          ],
          unselectedItemIcon: const [
            "assets/icons/home_outlined.png",
            "assets/icons/receipt_outlined.png",
            "assets/icons/settings_outlined.png"
          ],
          // 👉 ĐÃ ĐỔI TÊN SANG TIẾNG VIỆT
          label: const ["Trang chủ", "Lịch sử", "Hồ sơ"],
          onChange: (val) {
            setState(() {
              _currentIndex = val;
            });
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thoát ứng dụng'),
        content: const Text('Bạn có chắc chắn muốn thoát ứng dụng không?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thoát', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }
}

class CustomBottomNavBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final List<String> selectedItemIcon;
  final List<String> unselectedItemIcon;
  final List<String> label;
  final Function(int) onChange;

  const CustomBottomNavBar(
      {this.defaultSelectedIndex = 0,
        required this.selectedItemIcon,
        required this.unselectedItemIcon,
        required this.label,
        required this.onChange});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _navBarItems = [];

    for (int i = 0; i < 3; i++) {
      _navBarItems.add(bottomNavBarItem(
          widget.selectedItemIcon[i], widget.unselectedItemIcon[i], widget.label[i], i));
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: colorWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _navBarItems,
      ),
    );
  }

  Widget bottomNavBarItem(activeIcon, inactiveIcon, label, index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        widget.onChange(index);
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Nền khi chọn là Emerald nhạt (Mint)
            color: isSelected ? primaryColor100 : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadiusSize)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isSelected ? activeIcon : inactiveIcon,
              width: 22, height: 22,
              // 👉 ICON: Emerald khi chọn, xám đậm/đen khi không chọn
              color: isSelected ? primaryColor500 : darkBlue300.withOpacity(0.6),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                // 👉 CHỮ: Màu đen/xanh rừng đậm từ theme (darkBlue500)
                style: bottomNavTextStyle.copyWith(
                    color: darkBlue500,
                    fontWeight: FontWeight.bold
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}