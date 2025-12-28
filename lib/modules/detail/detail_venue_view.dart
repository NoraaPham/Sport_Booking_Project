import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_booking_project/model/sport_field.dart';
import 'package:sport_booking_project/modules/booking/booking_view.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/components/facility_card.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng tiền

class DetailView extends StatelessWidget {
  final SportField field;

  DetailView({required this.field});

  // Bảng màu đồng bộ
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);
  final Color customBrown = const Color(0xFF8D6E63);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          customSliverAppBar(context, field),
          SliverPadding(
            padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24, top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ĐỊA CHỈ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF4A9B7B), size: 24),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: Text(
                        field.address,
                        overflow: TextOverflow.visible,
                        style: addressTextStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // GIÁ TIỀN (ĐÃ ĐỔI SANG VND)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.money_dollar_circle_fill, color: customBrown),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: Text(
                        "${currencyFormat.format(field.price)} VND / giờ",
                        overflow: TextOverflow.visible,
                        style: addressTextStyle.copyWith(color: customBrown, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Liên hệ:",
                  style: subTitleTextStyle.copyWith(color: darkForest),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: primaryEmerald),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: Text(
                        field.phoneNumber,
                        overflow: TextOverflow.visible,
                        style: addressTextStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trạng thái:",
                      style: subTitleTextStyle.copyWith(color: darkForest),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text("Xem lịch trống", style: TextStyle(color: primaryEmerald)))
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.date_range_rounded, color: primaryEmerald),
                    const SizedBox(width: 16.0),
                    Text(
                      field.openDay,
                      style: descTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: primaryEmerald),
                    const SizedBox(width: 16.0),
                    Text(
                      "${field.openTime} - ${field.closeTime}",
                      style: descTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Tiện ích:",
                  style: subTitleTextStyle.copyWith(color: darkForest),
                ),
                const SizedBox(height: 16),
                FacilityCardList(facilities: field.facilities),
              ]),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ]),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryEmerald, // ĐỔI MÀU NÚT
                minimumSize: const Size(100, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BookingView(field: field);
              }));
            },
            child: const Text("Đặt sân ngay", style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget customSliverAppBar(context, field) {
    return SliverAppBar(
      shadowColor: primaryEmerald.withOpacity(.2),
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.black.withOpacity(0.4),
        statusBarIconBrightness: Brightness.light,
      ),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        expandedTitleScale: 1,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: kToolbarHeight,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Center(
            child: Text(
              field.name,
              style: titleTextStyle.copyWith(color: darkForest),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        background: Image.asset(
          field.imageAsset,
          fit: BoxFit.cover,
        ),
        collapseMode: CollapseMode.parallax,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              iconSize: 22,
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkForest)),
        ),
      ),
      expandedHeight: 300,
    );
  }
}